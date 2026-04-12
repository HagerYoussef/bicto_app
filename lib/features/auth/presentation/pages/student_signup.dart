import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../viewmodels/auth_viewmodel.dart';

class StudentSignUpScreen extends StatefulWidget {
  const StudentSignUpScreen({super.key});

  @override
  State<StudentSignUpScreen> createState() => _StudentSignUpScreenState();
}

class _StudentSignUpScreenState extends State<StudentSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String _gender = 'male';
  int? _selectedGradeId;
  DateTime? _dob;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().fetchGrades();
    });
  }

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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }


  Future<void> _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authVm = context.read<AuthViewModel>();
      final success = await authVm.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        gender: _gender,
        educationalLevel: _selectedGradeId,
        birthday: _dob != null ? DateFormat('yyyy-MM-dd').format(_dob!) : null,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        role: 'student',
      );

      if (!mounted) return;
      if (success) {
        Navigator.pushReplacementNamed(context, '/email-verification', arguments: 'student');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authVm.errorMessage ?? 'حدث خطأ ما'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب طالب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text(
                  'انضم إلينا اليوم',
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'الاسم الأول',
                      hint: 'محمد',
                      prefixIcon: LucideIcons.user,
                      controller: _firstNameController, maxlines: 1,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'الاسم الأخير',
                      hint: 'أحمد',
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
                hint: 'example@email.com',
                prefixIcon: LucideIcons.mail,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                maxlines: 1,
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                label: 'رقم الهاتف',
                hint: '01XXXXXXXXX',
                prefixIcon: LucideIcons.phone,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxlines: 1,
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: _buildGenderToggle(theme),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(theme),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              _buildEducationDropdown(theme),
              const SizedBox(height: 20),
              
              CustomTextField(
                label: 'كلمة المرور',
                hint: '********',
                prefixIcon: LucideIcons.lock,
                isPassword: true,
                controller: _passwordController,
                onChanged: _validatePassword,
                maxlines: 1,
              ),
              const SizedBox(height: 12),
              _buildPasswordRules(theme),
              const SizedBox(height: 20),
              
              CustomTextField(
                label: 'تأكيد كلمة المرور',
                hint: '********',
                prefixIcon: LucideIcons.checkCircle,
                isPassword: true,
                controller: _confirmPasswordController,
                maxlines: 1,
              ),
              
              const SizedBox(height: 40),
              const SizedBox(height: 40),
              Consumer<AuthViewModel>(
                builder: (context, authVm, _) => CustomButton(
                  text: 'إنشاء الحساب',
                  isLoading: authVm.isLoading,
                  onPressed: authVm.isLoading ? null : _handleSignUp,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderToggle(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الجنس', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
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
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius - 4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'ذكر',
                      style: TextStyle(
                        color: _gender == 'male' ? Colors.white : theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
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
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius - 4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'أنثى',
                      style: TextStyle(
                        color: _gender == 'female' ? Colors.white : theme.textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('تاريخ الميلاد', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.calendar, size: 20, color: theme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  _dob == null ? 'اختر التاريخ' : DateFormat('yyyy-MM-dd').format(_dob!),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationDropdown(ThemeData theme) {
    return Consumer<AuthViewModel>(
      builder: (context, authVm, _) {
        final grades = authVm.grades;
        final isLoading = authVm.isLoading && grades.isEmpty;
        final hasError = authVm.state == AuthState.error && grades.isEmpty;
        if (_selectedGradeId == null && grades.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _selectedGradeId == null) {
              setState(() => _selectedGradeId = grades.first.id);
            }
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('المرحلة التعليمية', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (authVm.isLoading && grades.isNotEmpty)
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              ),
              child: isLoading
                ? const Center(child: LinearProgressIndicator())
                : hasError
                  ? Row(
                      children: [
                        Icon(LucideIcons.alertCircle, size: 18, color: theme.colorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(child: Text('فشل تحميل المراحل التعليمية', style: TextStyle(color: theme.colorScheme.error, fontSize: 13))),
                        TextButton(
                          onPressed: () => authVm.fetchGrades(),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedGradeId,
                        isExpanded: true,
                        hint: const Text('اختر المرحلة التعليمية'),
                        items: grades.map((grade) {
                          return DropdownMenuItem(
                            value: grade.id,
                            child: Text(grade.displayName),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedGradeId = value),
                      ),
                    ),
            ),
          ],
        );
      },
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
