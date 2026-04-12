import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../viewmodels/teacher_viewmodel.dart';
import '../../../student/data/models/student_models.dart';
import '../../../../core/utils/date_utils.dart';

class AssignmentListScreen extends StatefulWidget {
  final int classId;
  final String classTitle;

  const AssignmentListScreen({
    super.key,
    required this.classId,
    required this.classTitle,
  });

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final _scrollController = ScrollController();
  late TeacherAssignmentsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TeacherAssignmentsViewModel(
      context.read<TeacherViewModel>().repository,
      widget.classId,
    );
    // Actually, I should use the TeacherAssignmentsViewModel as a separate provider or local instance.
    // I'll use a local instance for now and initialize it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadInitialData();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _viewModel.loadMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Column(
            children: [
              const Text('الواجبات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(widget.classTitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),
        floatingActionButton: FadeInUp(
          child: FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(
              context, 
              '/teacher/add-assignment', 
              arguments: {'classId': widget.classId},
            ).then((_) => _viewModel.loadInitialData()),
            backgroundColor: theme.primaryColor,
            icon: const Icon(LucideIcons.plus, color: Colors.white),
            label: const Text('واجب جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        body: Consumer<TeacherAssignmentsViewModel>(
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
                    Text('خطأ: ${vm.error}'),
                    const SizedBox(height: 24),
                    ElevatedButton(onPressed: () => vm.loadInitialData(), child: const Text('إعادة المحاولة')),
                  ],
                ),
              );
            }

            if (vm.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.clipboardList, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('لا توجد واجبات مضافة لهذا الفصل', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => vm.loadInitialData(),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                itemCount: vm.items.length + (vm.isFetchingMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index == vm.items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final assignment = vm.items[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 50 * (index % 10)),
                    child: _buildAssignmentCard(theme, assignment),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(ThemeData theme, AssignmentModel assignment) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (assignment.description.isNotEmpty) ...[
                         const SizedBox(height: 4),
                         Text(
                            assignment.description,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildActionButtons(theme, assignment),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoItem(LucideIcons.calendar, 'التسليم: ${AppDateUtils.formatDate(assignment.dueDate)}', theme.primaryColor),
                const SizedBox(width: 20),
                _buildInfoItem(LucideIcons.hash, 'الدرجة: ${assignment.maxScore}', Colors.orange),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context, 
                    '/teacher/assignment-submissions',
                    arguments: {
                      'classId': widget.classId,
                      'assignment': assignment,
                    },
                  ),
                  icon: const Icon(LucideIcons.users, size: 16),
                  label: const Text('التسليمات', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: TextButton.styleFrom(
                    backgroundColor: theme.primaryColor.withOpacity(0.05),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, AssignmentModel assignment) {
    return Row(
      children: [
        IconButton(
          icon: Icon(LucideIcons.edit2, size: 18, color: theme.primaryColor),
          onPressed: () => Navigator.pushNamed(
            context, 
            '/teacher/add-assignment', 
            arguments: {'classId': widget.classId, 'assignment': assignment},
          ).then((_) => _viewModel.loadInitialData()),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
          onPressed: () => _confirmDelete(assignment),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  void _confirmDelete(AssignmentModel assignment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الواجب'),
        content: Text('هل أنت متأكد من حذف الواجب "${assignment.title}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<TeacherViewModel>().deleteAssignment(widget.classId, assignment.id);
              if (success) {
                _viewModel.loadInitialData();
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
