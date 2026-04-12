import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';
import '../viewmodels/teacher_viewmodel.dart';
import '../../data/models/teacher_models.dart';
import '../../../../shared/widgets/custom_button.dart';

class AttendanceScreen extends StatefulWidget {
  final int classId;
  final String classTitle;

  const AttendanceScreen({
    super.key,
    required this.classId,
    required this.classTitle,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final Map<int, String> _tempStatus = {};
  final Map<int, TextEditingController> _noteControllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherAttendanceViewModel>().loadAttendance(widget.classId).then((_) {
        final vm = context.read<TeacherAttendanceViewModel>();
        setState(() {
          for (var a in vm.attendanceList) {
            _noteControllers[a.studentId] = TextEditingController(text: a.notes);
          }
        });
      });
    });
  }

  @override
  void dispose() {
    for (var controller in _noteControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('تحضير الطلاب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(widget.classTitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.checkCheck),
            onPressed: () => _markAll(context, 'attended'),
            tooltip: 'تحضير الجميع',
          ),
        ],
      ),
      body: Consumer<TeacherAttendanceViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.attendanceList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vm.error != null && vm.attendanceList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.alertCircle, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('خطأ: ${vm.error}'),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: () => vm.loadAttendance(widget.classId), child: const Text('إعادة المحاولة')),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildStatsHeader(theme, vm),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: vm.attendanceList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final attendance = vm.attendanceList[index];
                    final currentStatus = _tempStatus[attendance.studentId] ?? attendance.status;

                    return FadeInUp(
                      delay: Duration(milliseconds: 30 * (index % 20)),
                      child: _buildStudentCard(theme, attendance, currentStatus),
                    );
                  },
                ),
              ),
              _buildSubmitButton(context, vm),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsHeader(ThemeData theme, TeacherAttendanceViewModel vm) {
    final attendedCount = vm.attendanceList.where((e) => (_tempStatus[e.studentId] ?? e.status) == 'attended').length;
    final total = vm.attendanceList.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('إجمالي الطلاب', total.toString(), Colors.blue),
          _buildStatItem('حاضر', attendedCount.toString(), Colors.green),
          _buildStatItem('غائب', (total - attendedCount).toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStudentCard(ThemeData theme, AttendanceModel attendance, String currentStatus) {
    _noteControllers.putIfAbsent(attendance.studentId, () => TextEditingController(text: attendance.notes));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                child: Text(
                  attendance.studentName.substring(0, 1).toUpperCase(),
                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendance.studentName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusLabel(currentStatus),
                      style: TextStyle(color: _getStatusColor(currentStatus), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusToggle(attendance.studentId, currentStatus),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteControllers[attendance.studentId],
            decoration: InputDecoration(
              hintText: 'أضف ملاحظة لهذا الطالب...',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              fillColor: theme.brightness == Brightness.light ? Colors.grey[50] : theme.colorScheme.surface,
              filled: true,
              prefixIcon: const Icon(LucideIcons.stickyNote, size: 16, color: Colors.grey),
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(int studentId, String currentStatus) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light ? Colors.grey[100] : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _statusIconButton(LucideIcons.check, Colors.green, currentStatus == 'attended', () {
            setState(() => _tempStatus[studentId] = 'attended');
          }),
          _statusIconButton(LucideIcons.x, Colors.red, currentStatus == 'missed', () {
            setState(() => _tempStatus[studentId] = 'missed');
          }),
        ],
      ),
    );
  }

  Widget _statusIconButton(IconData icon, Color color, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: isActive ? Colors.white : Colors.grey[400]),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, TeacherAttendanceViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: CustomButton(
        text: 'حفظ التحضير',
        isLoading: vm.isLoading,
        onPressed: () async {
          final updates = vm.attendanceList.map((a) {
            final status = _tempStatus[a.studentId] ?? a.status;
            final note = _noteControllers[a.studentId]?.text;
            return {
              'student_id': a.studentId,
              'status': status,
              if (note != null && note.isNotEmpty) 'notes': note,
            };
          }).toList();
          
          if (updates.isEmpty && _tempStatus.isEmpty) {
            Navigator.pop(context);
            return;
          }

          final success = await vm.markAttendance(widget.classId, updates);
          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حفظ التحضير بنجاح'), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _markAll(BuildContext context, String status) {
    final vm = context.read<TeacherAttendanceViewModel>();
    setState(() {
      for (var a in vm.attendanceList) {
        _tempStatus[a.studentId] = status;
      }
    });
  }

  String _getStatusLabel(String status) {
    final s = status.toLowerCase();
    if (s == 'present' || s == 'attended') return 'حاضر';
    if (s == 'absent' || s == 'missed') return 'غائب';
    if (s == 'late') return 'متأخر';
    if (s == 'cancelled') return 'ملغى';
    return 'بانتظار التحضير';
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'present' || s == 'attended') return Colors.green;
    if (s == 'absent' || s == 'missed') return Colors.red;
    if (s == 'late') return Colors.orange;
    if (s == 'cancelled') return Colors.grey;
    return Colors.blueGrey;
  }
}
