import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../viewmodels/teacher_viewmodel.dart';
import '../../data/models/teacher_models.dart';
import '../../../../shared/widgets/app_card.dart';

class TeacherClassDetailsScreen extends StatefulWidget {
  final TeacherClassModel classModel;
  
  const TeacherClassDetailsScreen({super.key, required this.classModel});

  @override
  State<TeacherClassDetailsScreen> createState() => _TeacherClassDetailsScreenState();
}

class _TeacherClassDetailsScreenState extends State<TeacherClassDetailsScreen> {
  late TeacherClassModel cls;

  @override
  void initState() {
    super.initState();
    cls = widget.classModel;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startTime = DateFormat('EEEE, d MMMM - hh:mm a', 'ar').format(DateTime.parse(cls.startTime).toLocal());
    final isFinished = cls.status == 'finished';
    final isStarted = cls.status == 'started' || cls.status == 'active';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(theme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: _buildHeader(theme, startTime),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 100),
                    child: _buildMeetingSection(theme),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: _buildActionGrid(theme),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    delay: const Duration(milliseconds: 300),
                    child: _buildDescription(theme),
                  ),
                  const SizedBox(height: 40),
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: SizedBox(
                      width: double.infinity,
                      child: cls.isFinished 
                        ? OutlinedButton.icon(
                            onPressed: null,
                            icon: const Icon(LucideIcons.checkCircle2),
                            label: const Text('هذه الحصة مكتملة', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () {
                              if (cls.canStart) {
                                _handleStartClass();
                              } else if (cls.canFinish) {
                                _showFinishClassDialog(context);
                              }
                            },
                            icon: Icon(cls.canStart ? LucideIcons.playCircle : LucideIcons.checkCircle2),
                            label: Text(
                              cls.canStart ? 'بدء الحصة الآن' : 'إنهاء الحصة ورفع الملخص',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cls.canStart ? theme.primaryColor : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: theme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(LucideIcons.bookOpen, size: 150, color: Colors.white.withOpacity(0.1)),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.graduationCap, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      cls.subject ?? 'المادة الدراسية',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
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

  Widget _buildHeader(ThemeData theme, String startTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                cls.title,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            _buildStatusChip(cls.status),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(LucideIcons.calendar, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(startTime, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(LucideIcons.users, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text('${cls.enrolledCount ?? 0} طالباً مسجلاً من أصل ${cls.maxStudents}', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildMeetingSection(ThemeData theme) {
    final hasZoom = cls.zoomMeetingUrl != null || cls.zoomMeeting != null;
    final isStarted = cls.status == 'started' || cls.status == 'active';

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.video, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('لقاء الحصة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('منصة زوم (Zoom)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!isStarted && cls.status != 'finished')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleStartClass(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('بدء الحصة الآن', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          else if (hasZoom)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final url = cls.zoomMeeting?.startUrl ?? cls.zoomMeetingUrl;
                      if (url != null) _launchURL(url);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('دخول (المدرس)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    final url = cls.zoomMeetingUrl;
                    if (url != null) {
                      Clipboard.setData(ClipboardData(text: url));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ رابط الطلاب')));
                    }
                  },
                  icon: const Icon(LucideIcons.copy, color: Colors.blue),
                  tooltip: 'نسخ رابط الطلاب',
                ),
              ],
            )
          else if (cls.status == 'finished')
            const Text('انتهت هذه الحصة', style: TextStyle(color: Colors.grey))
          else
            const Text('جاري تجهيز الرابط...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionGrid(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            _actionCard(
              theme, 
              'تسجيل الحضور', 
              LucideIcons.userCheck, 
              Colors.orange, 
              () => Navigator.pushNamed(context, '/teacher/attendance', arguments: {'classId': cls.id, 'classTitle': cls.title})
            ),
            const SizedBox(width: 16),
            _actionCard(
              theme, 
              'إدارة الواجبات', 
              LucideIcons.clipboardList, 
              Colors.purple, 
              () => Navigator.pushNamed(context, '/teacher/assignments', arguments: {'classId': cls.id, 'classTitle': cls.title})
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionCard(ThemeData theme, String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('وصف الحصة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Text(
            cls.description ?? 'لا يوجد وصف متاح.',
            style: TextStyle(color: Colors.grey[800], height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'started':
      case 'active':
        color = Colors.green;
        label = 'جارية الآن';
        break;
      case 'finished':
        color = Colors.grey;
        label = 'منتهية';
        break;
      default:
        color = Colors.blue;
        label = 'مجدولة';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Future<void> _handleStartClass() async {
    final vm = context.read<TeacherViewModel>();
    final success = await vm.startClass(cls.id);
    if (success) {
      // Refresh current class metadata
      await vm.loadDashboard();
      final updatedClass = vm.dashboard?.classes.firstWhere((c) => c.id == cls.id);
      if (updatedClass != null) {
        setState(() => cls = updatedClass);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم بدء الحصة بنجاح'), backgroundColor: Colors.green));
      }
    }
  }

  void _showFinishClassDialog(BuildContext context) {
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
                    
                    // Update UI
                    await vm.loadDashboard();
                    final updated = vm.dashboard?.classes.firstWhere((c) => c.id == cls.id);
                    if (mounted && updated != null) setState(() => cls = updated);
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
}
