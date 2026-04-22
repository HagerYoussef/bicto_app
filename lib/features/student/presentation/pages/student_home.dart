import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/student_viewmodels.dart';
import 'teachers_list_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      
      // GUARD: Only fetch student-specific statistics and subjects if the role is student
      if (authVm.currentUser?.role == 'student') {
        final gradeId = authVm.currentUser?.gradeId;
        context.read<SubjectsViewModel>().fetchSubjects(gradeId: gradeId);
      } else {
        context.read<SubjectsViewModel>().fetchSubjects();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                _buildSearchAndFilters(theme),
                const SizedBox(height: 32),
                _buildSectionHeader(theme, 'المواد الدراسية', 'عرض الكل'),
                const SizedBox(height: 16),
                _buildSubjectsGrid(theme),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppConstants.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInLeft(
            child: Text(
              'ابدأ رحلة النجاح اليوم',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'تصفح مئات الكورسات التعليمية المختارة بعناية لتحقيق أهدافك.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.sparkles, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'خصم 50% على أول اشتراك',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Column(
      children: [
        FadeInUp(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light ? Colors.grey[100] : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.search, color: theme.hintColor),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      context.read<SubjectsViewModel>().setSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث عن مادة أو مدرس...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.5)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          action,
          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSubjectsGrid(ThemeData theme) {
    return Consumer<SubjectsViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.alertTriangle, color: Colors.red[300], size: 48),
                const SizedBox(height: 16),
                Text(
                  vm.error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final gradeId = context.read<AuthViewModel>().currentUser?.gradeId;
                    vm.fetchSubjects(gradeId: gradeId);
                  },
                  icon: const Icon(LucideIcons.refreshCw, size: 16),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor.withOpacity(0.1),
                    foregroundColor: theme.primaryColor,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          );
        }
        
        final subjects = vm.subjects;
        if (subjects.isEmpty) {
          return const Center(child: Text('لا توجد مواد دراسية متوفرة حالياً'));
        }

        final List<Map<String, dynamic>> predefinedStyles = [
          {'icon': LucideIcons.calculator, 'color': Colors.blue},
          {'icon': LucideIcons.atom, 'color': Colors.purple},
          {'icon': LucideIcons.flaskConical, 'color': Colors.red},
          {'icon': LucideIcons.dna, 'color': Colors.green},
          {'icon': LucideIcons.languages, 'color': Colors.orange},
          {'icon': LucideIcons.landmark, 'color': Colors.brown},
        ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final style = predefinedStyles[index % predefinedStyles.length];
        return FadeInUp(
          delay: Duration(milliseconds: 100 * (index % 6)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeachersListScreen(
                    subjectId: subject.id,
                    subjectName: subject.title,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: (style['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: subject.imageUrl != null 
                      ? ClipOval(
                          child: Image.network(
                            subject.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, _, __) => Icon(
                              style['icon'] as IconData, 
                              color: style['color'] as Color, 
                              size: 32
                            ),
                          ),
                        )
                      : Icon(style['icon'] as IconData, color: style['color'] as Color, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      subject.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    },
   );
  }
}
