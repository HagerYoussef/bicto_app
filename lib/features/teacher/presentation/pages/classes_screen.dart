import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/app_card.dart';
import '../viewmodels/teacher_viewmodel.dart';
import '../../data/models/teacher_models.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final _scrollController = ScrollController();
  String? _selectedStatus = 'scheduled';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<TeacherClassesViewModel>().setFilters(status: _selectedStatus);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<TeacherClassesViewModel>().loadMoreData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('إدارة الفصول', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          _buildFilters(theme),
          Expanded(
            child: Consumer<TeacherClassesViewModel>(
              builder: (context, vm, _) {
                if (vm.isInitialLoading && vm.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (vm.error != null && vm.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.alertCircle, size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text('خطأ: ${vm.error}', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                if (vm.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.calendarOff, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد فصول تطابق البحث.',
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: vm.items.length + (vm.isFetchingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index == vm.items.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _buildClassListItem(context, theme, vm.items[index], index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-class'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus),
        label: const Text('إضافة فصل', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    final statuses = [
      {'label': 'الكل', 'value': null},
      {'label': 'مجدولة', 'value': 'scheduled'},
      {'label': 'بدأت', 'value': 'started'},
      {'label': 'منتهية', 'value': 'finished'},
      {'label': 'ملغاة', 'value': 'cancelled'},
    ];
    
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = _selectedStatus == status['value'];
          return GestureDetector(
            onTap: () {
              setState(() => _selectedStatus = status['value'] as String?);
              _loadData();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? theme.primaryColor : theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? theme.primaryColor : theme.dividerColor.withOpacity(0.1),
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Center(
                child: Text(
                  status['label']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassListItem(BuildContext context, ThemeData theme, TeacherClassModel cls, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: 50 * (index % 10)),
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(LucideIcons.bookOpen, color: theme.primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls.title,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cls.subject ?? 'بدون مادة',
                        style: TextStyle(color: theme.primaryColor, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(cls.status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoTag(LucideIcons.calendar, _formatDate(cls.startTime), Colors.grey[600]!),
                const SizedBox(width: 16),
                _buildInfoTag(LucideIcons.clock, _formatTime(cls.startTime), Colors.grey[600]!),
                const Spacer(),
                _buildInfoTag(LucideIcons.users, '${cls.enrolledCount ?? 0}/${cls.maxStudents ?? '∞'}', Colors.grey[600]!),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 8),
                if (cls.canEditOrDelete) ...[
                  Expanded(
                    child: _buildActionButton(
                      context, 
                      'تعديل', 
                      LucideIcons.edit, 
                      Colors.blue[700]!, 
                      () => Navigator.pushNamed(context, '/edit-class', arguments: cls),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      context, 
                      'التحضير', 
                      LucideIcons.userCheck, 
                      Colors.orange[700]!, 
                      () => Navigator.pushNamed(context, '/teacher/attendance', arguments: {'classId': cls.id, 'classTitle': cls.title}),
                    ),
                  ),
                ] else ...[
                   Expanded(
                    child: _buildActionButton(
                      context, 
                      'التحضور', 
                      LucideIcons.userCheck, 
                      Colors.orange[700]!, 
                      () => Navigator.pushNamed(context, '/teacher/attendance', arguments: {'classId': cls.id, 'classTitle': cls.title}),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TeacherClassesViewModel vm, TeacherClassModel cls) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الفصل'),
        content: Text('هل أنت متأكد من رغبتك في حذف فصل "${cls.title}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await vm.deleteClass(cls.id);
              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لا يمكن حذف الفصول التي بدأت أو ماضية'), backgroundColor: Colors.red),
                );
              } else if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف الفصل بنجاح'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status.toLowerCase()) {
      case 'started':
      case 'active':
        color = Colors.green;
        label = 'جارية';
        break;
      case 'scheduled':
        color = Colors.blue;
        label = 'مجدولة';
        break;
      case 'finished':
      case 'completed':
        color = Colors.grey;
        label = 'منتهية';
        break;
      default:
        color = Colors.orange;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String text, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatDate(String time) {
    try {
      final dt = DateTime.parse(time).toLocal();
      return DateFormat('y/MM/dd').format(dt);
    } catch (e) {
      return time;
    }
  }

  String _formatTime(String time) {
    try {
      final dt = DateTime.parse(time).toLocal();
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return time;
    }
  }
}
