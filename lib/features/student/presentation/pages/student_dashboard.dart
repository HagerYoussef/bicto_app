import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/student_dashboard_viewmodel.dart';
import '../../data/models/student_models.dart';
import '../../../../core/utils/date_utils.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      if (authVm.currentUser?.role == 'student') {
        if (authVm.currentUser == null) {
          authVm.loadCurrentUser();
        }
        context.read<StudentDashboardViewModel>().fetchDashboard();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('لوحة التحكم - طالب')),
      body: Consumer2<AuthViewModel, StudentDashboardViewModel>(
        builder: (context, authVm, studentVm, _) {
          final user = authVm.currentUser;
          if (studentVm.isLoading && studentVm.dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (studentVm.state.name == 'error' && studentVm.dashboard == null) {
            return _buildError(theme, studentVm.error ?? '', () => studentVm.fetchDashboard());
          }
          final dashboard = studentVm.dashboard;
          if (dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () => studentVm.fetchDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInLeft(
                    child: Text(
                      'أهلاً بك، ${user?.firstName ?? ''} 👋',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'نتمنى لك يوماً دراسياً موفقاً ومليئاً بالنجاح.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  ),
                  const SizedBox(height: 32),
                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    children: [
                      _buildStatCard(theme, 'إجمالي الحجوزات', '${dashboard.totalBookings}', LucideIcons.bookMarked, Colors.blue),
                      _buildStatCard(theme, 'حضر', '${dashboard.attendedClasses}', LucideIcons.checkCircle2, Colors.green),
                      _buildStatCard(theme, 'متبقي', '${dashboard.remainingClasses}', LucideIcons.clock, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('روابط سريعة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildQuickActions(context, theme),
                  const SizedBox(height: 32),
                  // Recent Activity
                  if (dashboard.recentActivity.isNotEmpty) ...[
                    Text('النشاط الأخير', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...dashboard.recentActivity.map((a) => _buildActivityItem(context, theme, a)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(ThemeData theme, String msg, VoidCallback retry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.wifiOff, size: 48, color: theme.hintColor),
          const SizedBox(height: 16),
          Text(msg, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: retry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          ),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(label, style: TextStyle(fontSize: 9, color: theme.hintColor), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    final actions = [
      {'title': 'تصفح المدرسين', 'icon': LucideIcons.users, 'color': Colors.indigo, 'route': '/teachers-list'},
      {'title': 'مشاهدة الباقات', 'icon': LucideIcons.package, 'color': Colors.purple, 'route': '/packages'},
      {'title': 'حجوزاتي', 'icon': LucideIcons.bookOpen, 'color': Colors.blue, 'route': '/bookings'},
      {'title': 'ملخصات الحصص', 'icon': LucideIcons.fileText, 'color': Colors.orange, 'route': '/summaries'},
      {'title': 'الواجبات', 'icon': LucideIcons.clipboardList, 'color': Colors.red, 'route': '/assignments'},
      {'title': 'الملف الشخصي', 'icon': LucideIcons.user, 'color': Colors.teal, 'route': '/profile'},
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 2.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return InkWell(
          onTap: () => Navigator.pushNamed(context, action['route'] as String),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: (action['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(action['icon'] as IconData, color: action['color'] as Color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(action['title'] as String, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(BuildContext context, ThemeData theme, RecentActivityModel activity) {
    IconData icon;
    Color color;
    String route = '';
    dynamic arguments;

    switch (activity.type.toLowerCase()) {
      case 'booking':
      case 'class':
        icon = LucideIcons.calendarCheck;
        color = Colors.indigo;
        route = '/class-details';
        arguments = activity.id;
        break;
      case 'summary':
        icon = LucideIcons.fileText;
        color = Colors.orange;
        route = '/summaries';
        break;
      case 'assignment':
        icon = LucideIcons.clipboardList;
        color = Colors.red;
        route = '/assignments';
        break;
      case 'payment':
        icon = LucideIcons.creditCard;
        color = Colors.teal;
        route = '/payments';
        break;
      default:
        icon = LucideIcons.bell;
        color = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: route.isNotEmpty ? () => Navigator.pushNamed(context, route, arguments: arguments) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                    Text(AppDateUtils.formatDateTime(activity.createdAt), style: TextStyle(fontSize: 12, color: theme.hintColor)),
                  ],
                ),
              ),
              if (route.isNotEmpty)
                Icon(LucideIcons.chevronLeft, size: 16, color: theme.hintColor.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
