import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants.dart';
import '../../../../shared/widgets/app_card.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../data/models/teacher_models.dart';
import '../viewmodels/teacher_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVm = context.read<AuthViewModel>();
      if (authVm.currentUser == null) {
        authVm.loadCurrentUser();
      }
      context.read<TeacherViewModel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer2<AuthViewModel, TeacherViewModel>(
        builder: (context, authVm, teacherVm, child) {
          final user = authVm.currentUser;
          final dashboard = teacherVm.dashboard;

          if (teacherVm.isLoading && dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (teacherVm.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(teacherVm.error!), backgroundColor: Colors.red),
              );
              teacherVm.clearError();
            });
          }

          return RefreshIndicator(
            onRefresh: () => teacherVm.loadDashboard(),
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, theme, user),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 500),
                          child: _buildStatsRow(theme, dashboard),
                        ),
                        const SizedBox(height: 32),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'الجدول اليومي',
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              TextButton.icon(
                                onPressed: () => Navigator.pushNamed(context, '/teacher-classes'),
                                label: const Text('مشاهدة الكل'),
                                icon: const Icon(LucideIcons.chevronLeft, size: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (dashboard != null && dashboard.classes.isNotEmpty)
                          _buildTodaysClasses(context, theme, dashboard.classes)
                        else
                          _buildEmptyState(theme),
                        const SizedBox(height: 32),
                        FadeInUp(
                          duration: const Duration(milliseconds: 700),
                          child: Text(
                            'إجراءات سريعة',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildQuickActions(context, theme),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-class'),
        label: const Text('إضافة فصل', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(LucideIcons.plus),
        backgroundColor: theme.primaryColor,
        elevation: 4,
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ThemeData theme, dynamic user) {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: theme.primaryColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppConstants.primaryGradient,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.white.withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white24,
                          child: Text(
                            user?.fullName?.substring(0, 1) ?? 'T',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'أهلاً بك،',
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                              ),
                              Text(
                                user?.fullName ?? 'المدرس',
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(LucideIcons.bell, color: Colors.white, size: 22),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.calendar, color: Colors.white70, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('EEEE, d MMMM', 'ar').format(DateTime.now()),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme, TeacherDashboardModel? dashboard) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            'فصول اليوم',
            dashboard?.todaysClasses.toString() ?? '0',
            LucideIcons.calendarCheck,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            theme,
            'إجمالي الطلاب',
            dashboard?.totalStudents.toString() ?? '0',
            LucideIcons.users,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTodaysClasses(BuildContext context, ThemeData theme, List<TeacherClassModel> classes) {
    return Column(
      children: classes.map((cls) {
        final startTime = DateFormat('jm', 'ar').format(DateTime.parse(cls.startTime).toLocal());
        final isFinished = cls.status == 'finished';

        return FadeInUp(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      decoration: BoxDecoration(
                        color: isFinished ? Colors.grey : theme.primaryColor,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    cls.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isFinished ? Colors.grey : theme.primaryColor).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    startTime,
                                    style: TextStyle(
                                      color: isFinished ? Colors.grey : theme.primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildClassInfo(LucideIcons.users, '${cls.maxStudents} طالب'),
                                const SizedBox(width: 16),
                                _buildClassInfo(LucideIcons.bookOpen, cls.subject ?? 'غير معروف'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: isFinished ? null : () => _showClassOptions(context, cls),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isFinished ? Colors.grey : theme.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                    child: const Text('الإجراءات'),
                                  ),
                                ),
                                if ((cls.zoomMeetingUrl != null || cls.zoomMeeting != null) && !isFinished) ...[
                                  const SizedBox(width: 12),
                                  IconButton(
                                    onPressed: () {
                                      final url = cls.zoomMeeting?.startUrl ?? cls.zoomMeetingUrl;
                                      if (url != null) launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                    },
                                    icon: const Icon(LucideIcons.video, color: Colors.blue),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.blue.withOpacity(0.1),
                                      padding: const EdgeInsets.all(12),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClassInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      ],
    );
  }

  void _showClassOptions(BuildContext context, TeacherClassModel cls) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(cls.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            _buildOptionItem(context, LucideIcons.userCheck, 'تسجيل الحضور', Colors.blue, 'attendance'),
            _buildOptionItem(context, LucideIcons.filePlus, 'إضافة واجب', Colors.orange, 'add_assignment'),
            _buildOptionItem(context, LucideIcons.clipboardList, 'قائمة الواجبات', Colors.purple, 'assignments'),
            _buildOptionItem(context, LucideIcons.video, 'لقاء زوم', Colors.blueAccent, 'zoom'),
            if (cls.canStart)
              _buildOptionItem(context, LucideIcons.playCircle, 'بدء الحصة', Colors.green, 'start'),
            if (cls.canFinish)
              _buildOptionItem(context, LucideIcons.checkCircle2, 'إنهاء الحصة', Colors.green, 'finish'),
            _buildOptionItem(context, LucideIcons.trash2, 'حذف الحصة', cls.canEditOrDelete ? Colors.red : Colors.grey, 'delete'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).then((val) {
      if (val == null) return;
      if (val == 'attendance') {
        Navigator.pushNamed(context, '/teacher/attendance', arguments: {'classId': cls.id, 'classTitle': cls.title});
      } else if (val == 'assignments') {
        Navigator.pushNamed(context, '/teacher/assignments', arguments: {'classId': cls.id, 'classTitle': cls.title});
      } else if (val == 'add_assignment') {
        Navigator.pushNamed(context, '/teacher/add-assignment', arguments: {'classId': cls.id});
      } else if (val == 'finish') {
        if (cls.canFinish) {
          _showFinishClassDialog(context, cls);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب بدء الحصة أولاً قبل إنهائها'), backgroundColor: Colors.orange));
        }
      } else if (val == 'start') {
        context.read<TeacherViewModel>().startClass(cls.id);
      } else if (val == 'zoom') {
        _showZoomDialog(context, cls);
      } else if (val == 'delete') {
        if (cls.canEditOrDelete) {
          _confirmDeleteClass(context, cls);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن حذف حصة بدأت بالفعل أو انتهت'), backgroundColor: Colors.red));
        }
      }
    });
  }

  Widget _buildOptionItem(BuildContext context, IconData icon, String title, Color color, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () => Navigator.pop(context, value),
    );
  }

  void _showZoomDialog(BuildContext context, TeacherClassModel cls) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('لقاء زوم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogInfo(context, 'رابط المدرس', (cls.zoomMeeting?.startUrl ?? cls.zoomMeetingUrl) ?? 'غير متوفر', true),
            const SizedBox(height: 16),
            _buildDialogInfo(context, 'رابط الطالب', cls.zoomMeetingUrl ?? 'غير متوفر', true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
          ElevatedButton(
            onPressed: () {
              context.read<TeacherViewModel>().createZoomMeeting(cls.id, "لقاء: ${cls.title}", cls.startTime);
              Navigator.pop(context);
            },
            child: const Text('تجديد الرابط'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogInfo(BuildContext context, String label, String value, bool isCopyable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCopyable && value != 'غير متوفر')
              IconButton(
                icon: const Icon(LucideIcons.copy, size: 16),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الرابط إلى الحافظة'), duration: Duration(seconds: 2)));
                },
              ),
          ],
        ),
      ],
    );
  }

  void _showFinishClassDialog(BuildContext context, TeacherClassModel cls) {
    final theme = Theme.of(context);
    final vm = context.read<TeacherViewModel>();
    final notesController = TextEditingController();
    String? summaryPath;
    List<String> photos = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('إنهاء الحصة ورفع الملخص', style: TextStyle(fontWeight: FontWeight.bold)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('هل تم الانتهاء من شرح جميع النقاط؟ يمكنك رفع الملخص والصور الآن.', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'اكتب ملخصاً سريعاً أو ملاحظات...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _dialogFileCard(
                    theme,
                    'ملف الملخص (Summary/Material)',
                    summaryPath,
                    () async {
                      final res = await FilePicker.platform.pickFiles();
                      if (res != null) setDialogState(() => summaryPath = res.files.single.path);
                    }
                  ),
                  const SizedBox(height: 12),
                  _dialogFileCard(
                    theme,
                    'صور من الحصة (${photos.length} صور)',
                    photos.isNotEmpty ? 'تم اختيار الصور' : null,
                    () async {
                      final res = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);
                      if (res != null) setDialogState(() => photos.addAll(res.paths.whereType<String>()));
                    }
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: vm.isLoading ? null : () async {
                  final success = await vm.finishClass(cls.id);
                  if (success) {
                    if (notesController.text.isNotEmpty) {
                      await vm.createClassSummary(cls.id, notesController.text, 'ملاحظات المعلم');
                    }
                    if (summaryPath != null) {
                      await vm.uploadClassFile(cls.id, 'الملخص / المادة العلمية', 'ملخص مرفق لدرس اليوم', summaryPath!);
                    }
                    for (final photo in photos) {
                       await vm.uploadClassFile(cls.id, 'صورة مرفقة', 'صورة من الحصة', photo);
                    }
                  }
                  
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنهاء الحصة ورفع البيانات بنجاح'), backgroundColor: Colors.green));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: vm.isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('إنهاء وحفظ'),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _dialogFileCard(ThemeData theme, String label, String? path, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.uploadCloud, size: 20, color: theme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  if (path != null) 
                    Text(path.split('/').last, style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)
                  else
                    const Text('اضغط للاختيار', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            if (path != null) const Icon(LucideIcons.checkCircle2, size: 16, color: Colors.green),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteClass(BuildContext context, TeacherClassModel cls) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الحصة'),
        content: Text('هل أنت متأكد من حذف ${cls.title}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              context.read<TeacherViewModel>().deleteClass(cls.id);
              Navigator.pop(context);
            }, 
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        _quickActionCard(theme, 'إضافة حصة', LucideIcons.plusCircle, Colors.blue, () => Navigator.pushNamed(context, '/add-class')),
        const SizedBox(width: 12),
        _quickActionCard(theme, 'الطلاب', LucideIcons.users, Colors.orange, () {}),
        const SizedBox(width: 12),
        _quickActionCard(theme, 'التقارير', LucideIcons.barChart, Colors.purple, () {}),
      ],
    );
  }

  Widget _quickActionCard(ThemeData theme, String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: FadeInUp(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.calendarX2, size: 64, color: theme.primaryColor.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد فصول دراسية قادمة',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك البدء بإضافة فصل دراسي جديد من الزر أدناه',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
