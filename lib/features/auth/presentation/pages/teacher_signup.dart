import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../../../../shared/widgets/app_card.dart';
import '../viewmodels/auth_viewmodel.dart';

class TeacherSignUpScreen extends StatefulWidget {
  const TeacherSignUpScreen({super.key});

  @override
  State<TeacherSignUpScreen> createState() => _TeacherSignUpScreenState();
}

class _TeacherSignUpScreenState extends State<TeacherSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _gender = 'male';
  DateTime? _birthday;
  String? _cvPath;
  String? _cvName;

  // Password validation state
  bool _hasMin8 = false;
  bool _hasUpper = false;
  bool _hasLower = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;

  void _validatePassword(String value) {
    setState(() {
      _hasMin8 = value.length >= 8;
      _hasUpper = value.contains(RegExp(r'[A-Z]'));
      _hasLower = value.contains(RegExp(r'[a-z]'));
      _hasNumber = value.contains(RegExp(r'[0-9]'));
      _hasSpecial = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1960),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (picked != null) setState(() => _birthday = picked);
  }

  Future<void> _pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _cvPath = result.files.single.path;
        _cvName = result.files.single.name;
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_birthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار تاريخ الميلاد')));
      return;
    }

    final authVm = context.read<AuthViewModel>();
    final success = await authVm.register(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      gender: _gender,
      bio: _bioController.text,
      cvPath: _cvPath,
      birthday: DateFormat('yyyy-MM-dd').format(_birthday!),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
      role: 'teacher',
    );

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/email-verification', arguments: 'teacher');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authVm.errorMessage ?? 'حدث خطأ ما'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب معلم')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text(
                  'انضم إلينا كمدرب',
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),
              
              _buildSectionTitle('المعلومات الشخصية', LucideIcons.user),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'الاسم الأول',
                            hint: 'الاسم الأول',
                            prefixIcon: LucideIcons.user,
                            controller: _firstNameController,
                            maxlines: 1,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            label: 'الاسم الأخير',
                            hint: 'الاسم الأخير',
                            prefixIcon: LucideIcons.user,
                            controller: _lastNameController,
                            maxlines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'البريد الإلكتروني',
                      hint: 'teacher@example.com',
                      prefixIcon: LucideIcons.mail,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      maxlines: 1,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'رقم الهاتف',
                      hint: '05XXXXXXXX',
                      prefixIcon: LucideIcons.phone,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxlines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle('البيانات الحيوية', LucideIcons.info),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الجنس', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 12),
                    Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.light ? Colors.grey[50] : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _gender = 'male'),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _gender == 'male' ? theme.primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'ذكر',
                                  style: TextStyle(
                                    color: _gender == 'male' ? Colors.white : Colors.grey[700],
                                    fontWeight: _gender == 'male' ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _gender = 'female'),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _gender == 'female' ? theme.primaryColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'أنثى',
                                  style: TextStyle(
                                    color: _gender == 'female' ? Colors.white : Colors.grey[700],
                                    fontWeight: _gender == 'female' ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('تاريخ الميلاد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickBirthday,
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.light ? Colors.grey[50] : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.calendar, size: 18, color: theme.primaryColor),
                            const SizedBox(width: 12),
                            Text(
                              _birthday == null ? 'mm/dd/yyyy' : DateFormat('yyyy-MM-dd').format(_birthday!),
                              style: TextStyle(color: _birthday == null ? theme.hintColor : Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('الحساب والأمان', LucideIcons.lock),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'كلمة المرور',
                      hint: '••••••••',
                      prefixIcon: LucideIcons.lock,
                      controller: _passwordController,
                      isPassword: true,
                      onChanged: _validatePassword,
                      maxlines: 1,
                    ),
                    const SizedBox(height: 12),
                    _buildPasswordRules(theme),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'تأكيد كلمة المرور',
                      hint: '••••••••',
                      prefixIcon: LucideIcons.checkCircle2,
                      controller: _confirmPasswordController,
                      isPassword: true,
                      maxlines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle('الملف المهني', LucideIcons.fileText),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'نبذة عنك (Bio)',
                      hint: 'اكتب باختصار عن خبرتك الأكاديمية والمهنية...',
                      prefixIcon: LucideIcons.penTool,
                      controller: _bioController,
                      maxlines: 4,
                    ),
                    const SizedBox(height: 20),
                    _buildCVUploadField(theme),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              Consumer<AuthViewModel>(
                builder: (context, authVm, _) => CustomButton(
                  text: 'إنشاء حساب معلم',
                  isLoading: authVm.isLoading,
                  onPressed: authVm.isLoading ? null : _handleSignUp,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      text: 'لديك حساب بالفعل؟ ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'سجل دخولك',
                          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCVUploadField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('رفع السيرة الذاتية (CV)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickCV,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light ? Colors.grey[50] : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(_cvName == null ? LucideIcons.uploadCloud : LucideIcons.fileCheck, 
                     size: 20, color: theme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _cvName ?? 'PDF, Word, or Image',
                    style: TextStyle(color: _cvName == null ? theme.hintColor : Colors.black87, fontSize: 14),
                  ),
                ),
                if (_cvName != null)
                  const Icon(LucideIcons.check, color: Colors.green, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildPasswordRules(ThemeData theme) {
    return Column(
      children: [
        _ruleItem('8 أحرف على الأقل', _hasMin8),
        _ruleItem('حرف كبير واحد على الأقل', _hasUpper),
        _ruleItem('حرف صغير واحد على الأقل', _hasLower),
        _ruleItem('رقم واحد على الأقل', _hasNumber),
        _ruleItem('رمز خاص واحد على الأقل', _hasSpecial),
      ],
    );
  }

  Widget _ruleItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? LucideIcons.checkCircle2 : LucideIcons.circle,
          size: 16,
          color: isValid ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isValid ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }
}
