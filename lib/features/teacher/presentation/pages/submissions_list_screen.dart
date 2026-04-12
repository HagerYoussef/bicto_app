import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animate_do/animate_do.dart';
import '../viewmodels/teacher_viewmodel.dart';
import '../../../student/data/models/student_models.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_card.dart';

class SubmissionsListScreen extends StatefulWidget {
  final int classId;
  final AssignmentModel assignment;

  const SubmissionsListScreen({
    super.key,
    required this.classId,
    required this.assignment,
  });

  @override
  State<SubmissionsListScreen> createState() => _SubmissionsListScreenState();
}

class _SubmissionsListScreenState extends State<SubmissionsListScreen> {
  late TeacherAssignmentsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TeacherAssignmentsViewModel(
      context.read<TeacherViewModel>().repository,
      widget.classId,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchSubmissions(widget.assignment.id);
    });
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
              const Text('تسليمات الطلاب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(widget.assignment.title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
        ),
        body: Consumer<TeacherAssignmentsViewModel>(
          builder: (context, vm, _) {
            if (vm.isSubmissionsLoading && vm.submissions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.submissions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.users, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('لا توجد تسليمات لهذا الواجب حتى الآن', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => vm.fetchSubmissions(widget.assignment.id),
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: vm.submissions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final submission = vm.submissions[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: 50 * (index % 20)),
                    child: _buildSubmissionCard(context, theme, submission, vm),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(BuildContext context, ThemeData theme, SubmissionModel submission, TeacherAssignmentsViewModel vm) {
    final isGraded = submission.status == 'graded' || submission.score != null;
    final statusColor = isGraded ? Colors.green : Colors.orange;

    return AppCard(
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context, 
          '/teacher/grade-submission',
          arguments: {
            'classId': widget.classId,
            'assignment': widget.assignment,
            'submission': submission,
            'viewModel': vm,
          },
        ),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                child: Text(
                  submission.studentName.isNotEmpty ? submission.studentName.substring(0, 1).toUpperCase() : 'S',
                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.studentName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'تم التسليم: ${AppDateUtils.formatDateTime(submission.createdAt)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isGraded ? 'تم التقييم' : 'قيد الانتظار',
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isGraded) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${submission.score} / ${widget.assignment.maxScore}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 12),
              const Icon(LucideIcons.chevronLeft, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
