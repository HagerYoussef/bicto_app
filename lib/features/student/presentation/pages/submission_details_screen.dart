import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/student_viewmodels.dart';
import '../../../../core/utils/date_utils.dart';

class SubmissionDetailsScreen extends StatefulWidget {
  final int submissionId;
  final String assignmentTitle;

  const SubmissionDetailsScreen({
    super.key,
    required this.submissionId,
    required this.assignmentTitle,
  });

  @override
  State<SubmissionDetailsScreen> createState() => _SubmissionDetailsScreenState();
}

class _SubmissionDetailsScreenState extends State<SubmissionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentsViewModel>().fetchSubmission(widget.submissionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل التسليم'),
        centerTitle: true,
      ),
      body: Consumer<AssignmentsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoadingSubmission) {
            return const Center(child: CircularProgressIndicator());
          }

          final submission = vm.currentSubmission;
          if (submission == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.fileX, size: 64, color: theme.hintColor.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('تعذر تحميل بيانات التسليم'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.fetchSubmission(widget.submissionId),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  child: _buildScoreCard(theme, submission),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: _buildSubmissionInfo(theme, submission),
                ),
                const SizedBox(height: 24),
                if (submission.content != null && submission.content!.isNotEmpty)
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildContent(theme, submission.content!),
                  ),
                const SizedBox(height: 24),
                if (submission.fileUrls.isNotEmpty)
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildFiles(theme, submission.fileUrls),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreCard(ThemeData theme, dynamic submission) {
    final hasScore = submission.score != null;
    final score = submission.score ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasScore 
            ? [Colors.green.shade400, Colors.green.shade700]
            : [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (hasScore ? Colors.green : theme.primaryColor).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            hasScore ? 'الدرجة المستحقة' : 'في انتظار التصحيح',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          if (hasScore)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$score',
                  style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const Text(
                  ' / 100',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ],
            )
          else
            const Icon(LucideIcons.clock, color: Colors.white, size: 48),
        ],
      ),
    );
  }

  Widget _buildSubmissionInfo(ThemeData theme, dynamic submission) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _infoRow(theme, LucideIcons.book, 'الواجب', widget.assignmentTitle),
          const Divider(height: 24),
          _infoRow(theme, LucideIcons.calendar, 'تاريخ التسليم', AppDateUtils.formatDateTime(submission.submittedAt)),
        ],
      ),
    );
  }

  Widget _infoRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: theme.primaryColor),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
            Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نص التسليم',
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
            content,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildFiles(ThemeData theme, List<String> urls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الملفات المرفقة',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ...urls.map((url) => _fileItem(theme, url)),
      ],
    );
  }

  Widget _fileItem(ThemeData theme, String url) {
    final fileName = url.split('/').last;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: const Icon(LucideIcons.file),
        title: Text(fileName, style: const TextStyle(fontSize: 14)),
        trailing: IconButton(
          icon: const Icon(LucideIcons.download, size: 20),
          onPressed: () => _launchURL(url),
        ),
        onTap: () => _launchURL(url),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح الملف')),
        );
      }
    }
  }
}
