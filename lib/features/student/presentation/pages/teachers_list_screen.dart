import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/constants.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../data/models/student_models.dart';
import '../viewmodels/student_viewmodels.dart';
import 'bookings_screen.dart';

class TeachersListScreen extends StatefulWidget {
  final int? subjectId;
  final String? subjectName;
  const TeachersListScreen({super.key, this.subjectId, this.subjectName});

  @override
  State<TeachersListScreen> createState() => _TeachersListScreenState();
}

class _TeachersListScreenState extends State<TeachersListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show all teachers by default without forced grade or subject linkage
      // This follows the requirement to show everyone from the start.
      context.read<TeachersViewModel>().setFilters(
        gradeId: null, 
        subjectId: null,
      );
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<TeachersViewModel>().loadMoreData();
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
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   if (Navigator.of(context).canPop())
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: IconButton(
                        icon: const Icon(LucideIcons.arrowRight),
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          foregroundColor: theme.primaryColor,
                        ),
                      ),
                    ),
                  Text(
                    widget.subjectName != null ? 'مدرسي ${widget.subjectName}' : 'المدرسين المتميزين',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subjectName != null ? 'تصفح أفضل مدرسي ${widget.subjectName} حالياً' : 'تواصل مع أفضل المدرسين لتحقيق حلمك',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                  ),
                  const SizedBox(height: 24),
                  _buildSearchField(theme),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: Consumer<TeachersViewModel>(
              builder: (context, vm, _) {
                if (vm.isInitialLoading) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator())),
                  );
                }
                if (vm.error != null && vm.items.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(vm.error!),
                          ElevatedButton(onPressed: () => vm.loadInitialData(), child: const Text('إعادة المحاولة'))
                        ],
                      ),
                    ),
                  );
                }
                if (vm.items.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 64),
                          Icon(LucideIcons.users, size: 64, color: theme.hintColor.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            'لا يوجد مدرسين حالياً لهذه الاختيارات.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              vm.setFilters(subjectId: null, gradeId: null);
                            },
                            icon: const Icon(LucideIcons.filterX, size: 16),
                            label: const Text('عرض جميع المدرسين'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor.withOpacity(0.1),
                              foregroundColor: theme.primaryColor,
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == vm.items.length) {
                        return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                      }
                      return _buildTeacherCard(context, theme, vm.items[index], index);
                    },
                    childCount: vm.items.length + (vm.isFetchingMore ? 1 : 0),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Container(
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
              decoration: InputDecoration(
                hintText: 'ابحث باسم المدرس...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: theme.hintColor.withOpacity(0.5)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(BuildContext context, ThemeData theme, TeacherModel teacher, int index) {
    return FadeInUp(
      delay: Duration(milliseconds: 100 * (index % 6)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
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
        child: InkWell(
          onTap: () => _handleTeacherClick(context, theme, teacher),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                    image: teacher.avatarUrl != null 
                        ? NetworkImage(teacher.avatarUrl!) 
                        : NetworkImage('https://i.pravatar.cc/150?u=${teacher.id}'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            teacher.name,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              teacher.rating.toStringAsFixed(1),
                              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher.bio ?? 'لا يوجد وصف متاح حالياً.',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (teacher.subject != null && teacher.subject!.isNotEmpty)
                          _tag(theme, teacher.subject!, Colors.blue),
                        if (teacher.reviewCount > 0)
                           _tag(theme, '${teacher.reviewCount} تقييم', Colors.green),
                      ],
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

  Widget _tag(ThemeData theme, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _handleTeacherClick(BuildContext context, ThemeData theme, TeacherModel teacher) async {
    // Show a small loading indicator while fetching full details
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final fullTeacher = await context.read<TeachersViewModel>().getTeacherDetails(teacher.id);

    if (context.mounted) {
      Navigator.pop(context); // Close loading dialog
      if (fullTeacher != null) {
        _showSchedule(context, theme, fullTeacher);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تحميل بيانات المدرس حالياً')),
        );
      }
    }
  }

  void _showSchedule(BuildContext context, ThemeData theme, TeacherModel teacher) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final classes = teacher.classes;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'جدول الحصص المتاحة',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (classes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text('لا توجد حصص مجدولة حالياً لهذا المدرس.'),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: classes.length,
                    itemBuilder: (context, idx) {
                      final cls = classes[idx];
                      final isBooked = teacher.bookedClassIds.contains(cls.id);
                      final statusLower = cls.status.toLowerCase();
                      final isFinished = statusLower == 'finished' || statusLower == 'completed' || statusLower == 'cancelled';
                      final isOngoing = statusLower == 'ongoing';
                      
                      // Determination of whether it's too late (past end time)
                      final isPast = DateTime.now().isAfter(DateTime.tryParse(cls.endTime)?.toLocal() ?? DateTime.now());

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (theme.brightness == Brightness.light ? Colors.grey[50] : theme.colorScheme.surface),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.calendar, size: 20, color: theme.primaryColor),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cls.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(_formatDateRange(cls.startTime, cls.endTime), style: theme.textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isBooked)
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(
                                      context, 
                                      '/class-details',
                                      arguments: {
                                        'classId': cls.id,
                                        'initialData': BookingModel.fromTeacherClass(cls, teacher),
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('تفاصيل الحصة', style: TextStyle(fontSize: 12)),
                                )
                              else if (!isFinished && !isOngoing && !isPast)
                                ElevatedButton(
                                  onPressed: () async {
                                    final vm = context.read<BookingsViewModel>();
                                    final success = await vm.bookClass(cls.id);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(success ? 'تم حجز الحصة بنجاح!' : 'فشل عملية الحجز. يرجى المحاولة لاحقاً.'),
                                          backgroundColor: success ? Colors.green : Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('احجز الآن', style: TextStyle(fontSize: 12)),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (isOngoing ? Colors.orange : Colors.grey).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    statusLower == 'cancelled' ? 'ملغاة' : (isOngoing ? 'جارية حالياً' : 'انتهت'),
                                    style: TextStyle(
                                      color: isOngoing ? Colors.orange : Colors.grey, 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }


  String _formatDateRange(String start, String end) {
    try {
      final s = DateTime.parse(start);
      // Simple formatting for now
      return '${s.day}/${s.month} - ${s.hour}:${s.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'موعد غير محدد';
    }
  }

}
