import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../viewmodels/auth_viewmodel.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String role;

  const EmailVerificationScreen({super.key, required this.role});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _codeController = TextEditingController();

  Future<void> _verifyCode() async {
    final authVm = context.read<AuthViewModel>();
    final role = await authVm.verifyOtp(_codeController.text);
    
    if (!mounted) return;
    
    if (role != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تفعيل الحساب بنجاح، يمكنك تسجيل الدخول الآن'), backgroundColor: Colors.green),
      );
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/login', 
        (route) => false, 
        arguments: role
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVm.errorMessage ?? 'رقم التحقق غير صحيح'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _resendCode() async {
    final authVm = context.read<AuthViewModel>();
    if (authVm.pendingEmail == null) return;
    final success = await authVm.resendOtp(authVm.pendingEmail!);
    
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إعادة إرسال الكود بنجاح'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVm.errorMessage ?? 'فشل إعادة الإرسال'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              FadeInDown(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.mail, size: 64, color: theme.primaryColor),
                ),
              ),
              const SizedBox(height: 32),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'تحقق من بريدك الإلكتروني',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              FadeInDown(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'لقد أرسلنا كود التفعيل المكون من 6 أرقام إلى بريدك الإلكتروني. يرجى إدخاله هنا للمتابعة.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
              ),
              const SizedBox(height: 48),
              
              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: CustomTextField(
                  label: 'كود التفعيل',
                  hint: '000000',
                  prefixIcon: LucideIcons.shieldCheck,
                  controller: _codeController,
                  keyboardType: TextInputType.number, maxlines: 1,
                ),
              ),
              
              const SizedBox(height: 24),
              FadeInUp(
                delay: const Duration(milliseconds: 800),
                child: Consumer<AuthViewModel>(
                  builder: (context, authVm, _) => TextButton(
                    onPressed: authVm.isLoading ? null : _resendCode,
                    child: Text(
                      'لم يصلك الكود؟ أعد الإرسال',
                      style: TextStyle(
                        color: authVm.isLoading ? Colors.grey : theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              FadeInUp(
                delay: const Duration(milliseconds: 1000),
                child: Consumer<AuthViewModel>(
                  builder: (context, authVm, _) => CustomButton(
                    text: 'تأكيد الرمز',
                    isLoading: authVm.isLoading,
                    onPressed: authVm.isLoading ? null : _verifyCode,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
