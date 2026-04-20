import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/data/models/auth_models.dart';
import '../viewmodels/student_viewmodels.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit3),
            onPressed: () => _showEditProfile(context),
            tooltip: 'تعديل',
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, vm, _) {
          final user = vm.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildProfileHeader(theme, user),
                const SizedBox(height: 32),
                _buildSection(theme, 'المعلومات الأساسية', [
                  _infoTile(theme, LucideIcons.user, 'الاسم الكامل',
                      user?.fullName ?? '—'),
                  _infoTile(theme, LucideIcons.mail, 'البريد الإلكتروني',
                      user?.email ?? '—'),
                  _infoTile(theme, LucideIcons.phone, 'رقم الهاتف',
                      user?.phone ?? '—'),
                  _infoTile(theme, LucideIcons.users, 'الجنس',
                      _genderLabel(user?.gender)),
                ]),
                const SizedBox(height: 24),
                if (user?.role == 'teacher' && user?.bio != null)
                  _buildSection(theme, 'النبذة الشخصية', [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(user!.bio!, style: const TextStyle(height: 1.5)),
                    ),
                  ]),
                if (user?.role == 'teacher') const SizedBox(height: 24),
                _buildSection(theme, user?.role == 'teacher' ? 'المرحلة التعليمية' : 'المعلومات الدراسية', [
                  _infoTile(theme, LucideIcons.graduationCap, user?.role == 'teacher' ? 'المرحلة المستهدفة' : 'المستوى التعليمي',
                      user?.formattedEducationalLevel ?? '—'),
                ]),
                const SizedBox(height: 32),
                TextButton.icon(
                  onPressed: () async {
                    final success = await vm.logout(context);
                    if (success && context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (r) => false);
                    }
                  },
                  icon: vm.isLoading
                      ? const SizedBox(width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.red))
                      : const Icon(LucideIcons.logOut, color: Colors.red),
                  label: const Text('تسجيل الخروج', style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => _showDeleteAccountDialog(context),
                  icon: const Icon(LucideIcons.userX, color: Colors.grey, size: 18),
                  label: const Text('حذف الحساب', style: TextStyle(
                      color: Colors.grey, fontSize: 13, decoration: TextDecoration.underline)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  String _genderLabel(String? gender) {
    if (gender == 'male') return 'ذكر';
    if (gender == 'female') return 'أنثى';
    return '—';
  }

  Widget _buildProfileHeader(ThemeData theme, UserModel? user) {
    final name = user?.fullName ?? 'المستخدم';
    final avatarUrl = user?.avatarUrl;
    return FadeInDown(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.primaryColor, width: 4),
                  boxShadow: [
                    BoxShadow(color: theme.primaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                  image: avatarUrl != null
                      ? DecorationImage(
                      image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                      : null,
                  color: avatarUrl == null ? Colors.grey[200] : null,
                ),
                child: avatarUrl == null
                    ? Center(child: Icon(
                    LucideIcons.user, size: 40, color: theme.hintColor))
                    : null,
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: theme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(
                      LucideIcons.camera, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(name, style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold)),
          Text(user?.role == 'teacher' ? 'معلم' : 'طالب', style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor)),
        ],
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _infoTile(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.primaryColor.withOpacity(0.7)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(color: theme.hintColor, fontSize: 10)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(ThemeData theme, IconData icon, String label,
      VoidCallback onTap, {String? trailing}) {
    return ListTile(
      leading: Icon(icon, size: 20, color: theme.primaryColor),
      title: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (trailing != null)
          Padding(padding: const EdgeInsets.only(left: 8.0),
              child: Text(trailing,
                  style: TextStyle(color: theme.hintColor, fontSize: 12))),
        const Icon(LucideIcons.chevronLeft, size: 16),
      ]),
      onTap: onTap,
    );
  }

  void _showEditProfile(BuildContext context) {
      final authVm = context.read<AuthViewModel>();
      final profileVm = context.read<StudentProfileViewModel>();
      final user = authVm.currentUser;

      if (user == null) return;

    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final phoneController = TextEditingController(text: user.phone);
    final emailController = TextEditingController(text: user.email);
    final bioController = TextEditingController(text: user.bio);
    String selectedGender = user.gender ?? 'male';
    int selectedGrade = user.gradeId ?? 1;
    int selectedStage = user.educationalLevel ?? 1;
    final isTeacher = user.role == 'teacher';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('تعديل الملف الشخصي', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'الاسم الأول', prefixIcon: Icon(LucideIcons.user)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'الاسم الأخير', prefixIcon: Icon(LucideIcons.user)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(LucideIcons.mail)),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(LucideIcons.phone)),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                // Gender Selection
                Row(
                  children: [
                    const Text('الجنس:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    ChoiceChip(
                      label: const Text('ذكر'),
                      selected: selectedGender == 'male',
                      onSelected: (v) => setModalState(() => selectedGender = 'male'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('أنثى'),
                      selected: selectedGender == 'female',
                      onSelected: (v) => setModalState(() => selectedGender = 'female'),
                    ),
                  ],
                ),
                if (isTeacher) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'النبذة التعريفية (Bio)',
                      prefixIcon: Icon(LucideIcons.pencil),
                      hintText: 'اكتب نبذة عن خبرتك التعليمية...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: authVm.stages.any((s) => s.id == selectedStage) ? selectedStage : (authVm.stages.isNotEmpty ? authVm.stages.first.id : null),
                    decoration: const InputDecoration(labelText: 'المرحلة التعليمية', prefixIcon: Icon(LucideIcons.layers)),
                    items: authVm.stages.map((stage) => DropdownMenuItem(
                      value: stage.id,
                      child: Text(stage.name),
                    )).toList(),
                    onChanged: (v) => setModalState(() => selectedStage = v ?? 1),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: authVm.grades.any((g) => g.id == selectedGrade) ? selectedGrade : (authVm.grades.isNotEmpty ? authVm.grades.first.id : null),
                    decoration: const InputDecoration(labelText: 'المستوى التعليمي', prefixIcon: Icon(LucideIcons.graduationCap)),
                    items: authVm.grades.map((grade) => DropdownMenuItem(
                      value: grade.id,
                      child: Text(grade.displayName),
                    )).toList(),
                    onChanged: (v) => setModalState(() => selectedGrade = v ?? 1),
                  ),
                ],

                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    final success = await profileVm.updateProfile({
                      'first_name': firstNameController.text,
                      'last_name': lastNameController.text,
                      'email': emailController.text,
                      'phone': phoneController.text,
                      'gender': selectedGender,
                      if (isTeacher) 'bio': bioController.text,
                      if (isTeacher) 'educational_level': selectedStage,
                      if (!isTeacher) 'grade_id': selectedGrade,
                    });
                    if (success) {
                      await authVm.loadCurrentUser();
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: profileVm.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('حفظ التغييرات'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
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
          content: Form(
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
}
