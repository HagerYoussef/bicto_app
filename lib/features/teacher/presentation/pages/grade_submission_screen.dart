import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/teacher_viewmodel.dart';
import '../../../student/data/models/student_models.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../../../../shared/widgets/app_card.dart';

class GradeSubmissionScreen extends StatefulWidget {
  final int classId;
  final AssignmentModel assignment;
  final SubmissionModel submission;
  final TeacherAssignmentsViewModel viewModel;

  const GradeSubmissionScreen({
    super.key,
    required this.classId,
    required this.assignment,
    required this.submission,
    required this.viewModel,
  });

  @override
  State<GradeSubmissionScreen> createState() => _GradeSubmissionScreenState();
}

class _GradeSubmissionScreenState extends State<GradeSubmissionScreen> {
  late final TextEditingController _scoreController;
  late final TextEditingController _feedbackController;

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController(text: widget.submission.score?.toString() ?? '');
    _feedbackController = TextEditingController(text: widget.submission.feedback ?? '');
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final scoreText = _scoreController.text;
    if (scoreText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال الدرجة')));
      return;
    }

    final double? score = double.tryParse(scoreText);
    if (score == null || score < 0 || score > widget.assignment.maxScore) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('الدرجة يجب أن تكون بين 0 و ${widget.assignment.maxScore}')));
      return;
    }

    final success = await widget.viewModel.gradeSubmission(
      widget.assignment.id,
      widget.submission.id,
      score,
      _feedbackController.text.isEmpty ? null : _feedbackController.text,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تقييم الواجب بنجاح'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء التقييم'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('تقييم الطالب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentInfo(theme),
            const SizedBox(height: 24),
            _buildSubmittedWork(theme),
            const SizedBox(height: 32),
            _buildGradingForm(theme),
            const SizedBox(height: 48),
            CustomButton(
              text: 'حفظ التقييم واستمرار',
              isLoading: widget.viewModel.isSubmissionsLoading,
              onPressed: _handleSubmit,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfo(ThemeData theme) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
           CircleAvatar(
                radius: 28,
                backgroundColor: theme.primaryColor.withOpacity(0.1),
                child: Text(
                  widget.submission.studentName.isNotEmpty ? widget.submission.studentName.substring(0, 1).toUpperCase() : 'S',
                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.submission.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(widget.assignment.title, style: TextStyle(color: theme.hintColor, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittedWork(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('العمل المسلم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.submission.content != null && widget.submission.content!.isNotEmpty) ...[
                const Text('إجابة الطالب:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue)),
                const SizedBox(height: 8),
                Text(widget.submission.content!, style: const TextStyle(height: 1.5)),
                const Divider(height: 32),
              ],
              if (widget.submission.fileUrls.isEmpty)
                const Text('لا توجد ملفات مرفقة', style: TextStyle(color: Colors.grey, fontSize: 12))
              else ...[
                const Text('الملفات المرفقة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                ...widget.submission.fileUrls.map((url) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(LucideIcons.fileText),
                  title: Text('ملف ${widget.submission.fileUrls.indexOf(url) + 1}', style: const TextStyle(fontSize: 14)),
                  trailing: TextButton(
                    onPressed: () async {
                      try {
                        final uri = Uri.parse(url);
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } catch (_) {}
                    },
                    child: const Text('عرض'),
                  ),
                )).toList(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGradingForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('تقييم المعلم', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CustomTextField(
                label: 'الدرجة (من ${widget.assignment.maxScore})',
                hint: '0',
                keyboardType: TextInputType.number,
                controller: _scoreController,
                prefixIcon: LucideIcons.award,
                maxlines: 1,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'ملاحظات المعلم (اختياري)',
                hint: 'اكتب ملاحظاتك للطالب هنا...',
                controller: _feedbackController,
                prefixIcon: LucideIcons.messageSquare,
                maxlines: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
