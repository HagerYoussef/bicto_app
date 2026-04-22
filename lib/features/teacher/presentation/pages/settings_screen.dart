import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

class TeacherSettingsScreen extends StatelessWidget {
  const TeacherSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            FadeInDown(
              child: _buildSettingsTile(LucideIcons.user, 'تعديل الملف الشخصي', () => Navigator.pushNamed(context, '/profile')),
            ),
            const SizedBox(height: 12),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: _buildSettingsTile(LucideIcons.bell, 'الإشعارات', () {}),
            ),
            const SizedBox(height: 12),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              child: _buildSettingsTile(LucideIcons.shieldCheck, 'الأمان والحماية', () {}),
            ),
            const SizedBox(height: 12),
            FadeInDown(
              delay: const Duration(milliseconds: 300),
              child: _buildSettingsTile(LucideIcons.languages, 'اللغة', () {}),
            ),
            const SizedBox(height: 12),
            FadeInDown(
              delay: const Duration(milliseconds: 400),
              child: _buildSettingsTile(LucideIcons.helpCircle, 'المساعدة والدعم', () {}),
            ),
            const SizedBox(height: 12),
            FadeInDown(
              delay: const Duration(milliseconds: 500),
              child: _buildSettingsTile(
                LucideIcons.userX, 
                'حذف الحساب', 
                () => _showDeleteAccountDialog(context),
                isDestructive: true,
              ),
            ),
            const SizedBox(height: 12),
            FadeInDown(
              delay: const Duration(milliseconds: 600),
              child: _buildSettingsTile(
                LucideIcons.logOut, 
                'تسجيل الخروج', 
                () async {
                  final authVm = context.read<AuthViewModel>();
                  await authVm.logout(context);
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                  }
                },
                isDestructive: true,
              ),
            ),
            const SizedBox(height: 48),
            FadeInUp(
              child: Text(
                'الإصدار 1.0.0',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('حذف الحساب', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('هل أنت متأكد أنك تريد حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.', textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'كلمة المرور الحالية',
                      prefixIcon: Icon(LucideIcons.lock),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال كلمة المرور' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('لتأكيد الحذف، يرجى كتابة كلمة "DELETE" بالأسفل:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: confirmController,
                    decoration: const InputDecoration(
                      hintText: 'DELETE',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v != 'DELETE' ? 'كلمة التأكيد غير صحيحة' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: authVm.isLoading ? null : () async {
                if (formKey.currentState?.validate() ?? false) {
                  final success = await authVm.deleteAccount(
                    passwordController.text,
                    confirmController.text,
                  );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(authVm.errorMessage ?? 'فشل حذف الحساب'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: authVm.isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('تأكيد الحذف النهائي'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.blueGrey),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      trailing: Icon(LucideIcons.chevronLeft, size: 18, color: isDestructive ? Colors.red : null),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
