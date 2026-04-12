import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../../../../shared/widgets/custom_button.dart';

class ForgotPasswordFlow extends StatefulWidget {
  const ForgotPasswordFlow({super.key});

  @override
  State<ForgotPasswordFlow> createState() => _ForgotPasswordFlowState();
}

class _ForgotPasswordFlowState extends State<ForgotPasswordFlow> {
  final _pageController = PageController();
  int _currentStep = 0;

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _handleEmailStep() async {
    final vm = context.read<AuthViewModel>();
    final success = await vm.sendPasswordOtp(_emailController.text.trim());
    if (!mounted) return;
    if (success) {
      _nextStep();
    } else {
      _showError(vm.errorMessage ?? 'فشل إرسال الكود');
    }
  }

  Future<void> _handleCodeStep() async {
    final vm = context.read<AuthViewModel>();
    final success = await vm.verifyPasswordOtp(
      _emailController.text.trim(),
      _codeController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      _nextStep();
    } else {
      _showError(vm.errorMessage ?? 'كود غير صحيح');
    }
  }

  Future<void> _handleResetStep() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('كلمات المرور غير متطابقة');
      return;
    }
    final vm = context.read<AuthViewModel>();
    final success = await vm.resetPassword(
      _emailController.text.trim(),
      _codeController.text.trim(),
      _newPasswordController.text,
      _confirmPasswordController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح'), backgroundColor: Colors.green),
      );
    } else {
      _showError(vm.errorMessage ?? 'فشل تغيير كلمة المرور');
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('استعادة كلمة المرور'),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildEmailStep(theme),
          _buildCodeStep(theme),
          _buildResetStep(theme),
        ],
      ),
    );
  }

  Widget _buildEmailStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              'أدخل بريدك الإلكتروني',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'سنرسل لك كود التحقق لاستعادة حسابك',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            label: 'البريد الإلكتروني',
            hint: 'example@email.com',
            prefixIcon: LucideIcons.mail,
            controller: _emailController,
            maxlines: 1,
          ),
          const Spacer(),
          Consumer<AuthViewModel>(
            builder: (context, vm, _) => CustomButton(
              text: 'إرسال الكود',
              isLoading: vm.isLoading,
              onPressed: vm.isLoading ? null : _handleEmailStep,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCodeStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              'كود التحقق',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'أدخل الكود المرسل إلى بريدك الإلكتروني',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            label: 'كود التحقق',
            hint: '000000',
            prefixIcon: LucideIcons.shieldCheck,
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxlines: 1,
          ),
          const Spacer(),
          Consumer<AuthViewModel>(
            builder: (context, vm, _) => CustomButton(
              text: 'تحقق من الكود',
              isLoading: vm.isLoading,
              onPressed: vm.isLoading ? null : _handleCodeStep,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildResetStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              'تعيين كلمة مرور جديدة',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'يجب أن تكون كلمة المرور قوية ومعقدة',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            label: 'كلمة المرور الجديدة',
            hint: '********',
            prefixIcon: LucideIcons.lock,
            isPassword: true,
            controller: _newPasswordController,
            maxlines: 1,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'تأكيد كلمة المرور',
            hint: '********',
            prefixIcon: LucideIcons.checkCircle,
            isPassword: true,
            controller: _confirmPasswordController,
            maxlines: 1,
          ),
          const Spacer(),
          Consumer<AuthViewModel>(
            builder: (context, vm, _) => CustomButton(
              text: 'تغيير كلمة المرور',
              isLoading: vm.isLoading,
              onPressed: vm.isLoading ? null : _handleResetStep,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
