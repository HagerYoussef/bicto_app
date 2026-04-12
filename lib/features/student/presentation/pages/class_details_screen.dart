import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import '../viewmodels/student_viewmodels.dart';
import '../../data/models/student_models.dart';
import '../../../../core/utils/date_utils.dart';

class ClassDetailsScreen extends StatefulWidget {
  final int classId;
  final BookingModel? initialData;
  const ClassDetailsScreen({super.key, required this.classId, this.initialData});

  @override
  State<ClassDetailsScreen> createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ClassDetailsViewModel>();
      if (widget.initialData != null) {
        vm.setInitialData(widget.initialData);
        debugPrint('ClassDetailsScreen: Used initialData for classId: ${widget.classId}');
      }
      // Always load latest details to get the full description, material, and meeting URL
      vm.loadClassDetails(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Consumer<ClassDetailsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.classDetails == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (vm.error != null && vm.classDetails == null) {
            return _buildError(theme, vm.error!, () => vm.loadClassDetails(widget.classId));
          }

          final cls = vm.classDetails;
          if (cls == null) {
            return const Center(child: Text('لم يتم العثور على تفاصيل الحصة'));
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(theme, cls),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInUp(child: _buildMainInfo(theme, cls)),
                      const SizedBox(height: 24),
                      FadeInUp(delay: const Duration(milliseconds: 100), child: _buildDescription(theme, cls)),
                      const SizedBox(height: 24),
                      FadeInUp(delay: const Duration(milliseconds: 200), child: _buildActionButtons(theme, cls)),
                      const SizedBox(height: 100), // Space for bottom
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, BookingModel cls) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor,
                theme.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'teacher_${cls.classId}',
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: cls.teacherAvatar != null ? NetworkImage(cls.teacherAvatar!) : null,
                    child: cls.teacherAvatar == null 
                        ? const Icon(LucideIcons.user, color: Colors.white, size: 40) 
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  cls.teacherName,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'مدرس المادة',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfo(ThemeData theme, BookingModel cls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                cls.classTitle,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            _buildStatusBadge(theme, cls),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _infoCard(theme, LucideIcons.calendar, 'التاريخ', AppDateUtils.formatDate(cls.startTime)),
            const SizedBox(width: 12),
            _infoCard(theme, LucideIcons.clock, 'الوقت', AppDateUtils.formatTime(cls.startTime)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme, BookingModel cls) {
    Color color;
    String label;
    
    switch (cls.classStatus.toLowerCase()) {
      case 'ongoing':
        color = Colors.orange;
        label = 'جارية الآن';
        break;
      case 'finished':
      case 'completed':
        color = Colors.green;
        label = 'مكتملة';
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'ملغاة';
        break;
      default:
        color = theme.primaryColor;
        label = 'مجدولة';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _infoCard(ThemeData theme, IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: theme.primaryColor),
            const SizedBox(height: 8),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(ThemeData theme, BookingModel cls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'عن هذه الحصة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          ),
          child: Text(
            cls.description ?? 'لا يوجد وصف متاح لهذه الحصة.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, BookingModel cls) {
    return Column(
      children: [
        if (cls.meetingUrl != null && cls.meetingUrl!.isNotEmpty)
          _actionButton(
            theme,
            label: cls.canJoin ? 'دخول الحصة الآن' : 'رابط الحصة (يفتح قبل الموعد بـ 10 دقائق)',
            icon: LucideIcons.video,
            color: cls.canJoin ? theme.primaryColor : Colors.grey,
            onPressed: cls.canJoin ? () => _launchURL(cls.meetingUrl!) : null,
            isFullWidth: true,
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            _actionButton(
              theme,
              label: 'الواجبات',
              icon: LucideIcons.clipboardList,
              color: Colors.orange,
              onPressed: () => Navigator.pushNamed(context, '/assignments', arguments: cls.classId),
            ),
            const SizedBox(width: 12),
            _actionButton(
              theme,
              label: 'المادة العلمية',
              icon: LucideIcons.fileText,
              color: Colors.blue,
              onPressed: cls.lessonMaterialUrl != null ? () => _launchURL(cls.lessonMaterialUrl!) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(
    ThemeData theme, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    bool isFullWidth = false,
  }) {
    final button = ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: Size(isFullWidth ? double.infinity : 0, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
    );

    return isFullWidth ? button : Expanded(child: button);
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن فتح الموقع المطلوب')),
        );
      }
    }
  }

  Widget _buildError(ThemeData theme, String msg, VoidCallback retry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.alertCircle, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(msg, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: retry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
