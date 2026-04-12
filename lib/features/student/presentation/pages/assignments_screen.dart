import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../viewmodels/student_viewmodels.dart';
import '../../data/models/student_models.dart';
import '../../../../core/utils/date_utils.dart';

class AssignmentsScreen extends StatefulWidget {
  final int? classId;
  const AssignmentsScreen({super.key, this.classId});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentsViewModel>().setFilters(classId: widget.classId);
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
      context.read<AssignmentsViewModel>().loadMoreData();
    }
  }

  Future<void> _submitHomework(BuildContext context, ThemeData theme, AssignmentModel assignment, AssignmentsViewModel vm) async {
    final TextEditingController contentController = TextEditingController();
    List<String> selectedFiles = [];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              builder: (_, scrollController) => SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                    const SizedBox(height: 16),
                    Text('تفاصيل الواجب', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(assignment.title, style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(assignment.description, style: theme.textTheme.bodyMedium),
                    ),
                    if (assignment.fileUrls.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('ملفات المدرس:', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: assignment.fileUrls.map((url) => ActionChip(
                          avatar: const Icon(LucideIcons.fileText, size: 14),
                          label: Text('عرض الملف ${assignment.fileUrls.indexOf(url) + 1}', style: const TextStyle(fontSize: 10)),
                          onPressed: () async {
                            try {
                              final uri = Uri.parse(url);
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } catch (_) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن فتح الملف')));
                            }
                          },
                        )).toList(),
                      ),
                    ],
                    const Divider(height: 48),
                    Text('تسليم الإجابة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'أضف ملاحظاتك أو إجابتك هنا...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
                        if (result != null) {
                          setModalState(() {
                            selectedFiles.addAll(result.paths.whereType<String>());
                          });
                        }
                      },
                      icon: const Icon(LucideIcons.uploadCloud),
                      label: const Text('إرفاق ملفات الإجابة'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    if (selectedFiles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('إجاباتك المرفقة:', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...selectedFiles.map((path) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.file, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(child: Text(path.split('/').last, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16, color: Colors.red),
                              onPressed: () {
                                setModalState(() {
                                  selectedFiles.remove(path);
                                });
                              },
                            )
                          ],
                        ),
                      )),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: vm.isSubmitting ? null : () async {
                          if (contentController.text.isEmpty && selectedFiles.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء كتابة إجابة أو إرفاق ملف')));
                            return;
                          }
                          Navigator.pop(ctx);
                          final success = await vm.submitAssignment(
                            assignment.id, 
                            content: contentController.text, 
                            filePaths: selectedFiles,
                          );
                          if (mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? 'تم تسليم الواجب بنجاح' : (vm.error ?? 'حدث خطأ أثناء التسليم')),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: vm.isSubmitting 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('تأكيد التسليم', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('الواجبات'), centerTitle: true),
      body: Consumer<AssignmentsViewModel>(
        builder: (context, vm, _) {
          if (vm.isInitialLoading && vm.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null && vm.items.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(LucideIcons.wifiOff, size: 48, color: theme.hintColor),
              const SizedBox(height: 16),
              Text(vm.error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => vm.loadInitialData(), child: const Text('إعادة المحاولة')),
            ]));
          }
          if (vm.items.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(LucideIcons.clipboardList, size: 64, color: theme.hintColor.withOpacity(0.4)),
              const SizedBox(height: 16),
              Text('لا توجد واجبات حالياً', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
            ]));
          }
          
          return RefreshIndicator(
            onRefresh: () => vm.loadInitialData(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: vm.items.length + (vm.isFetchingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == vm.items.length) {
                   return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                }
                return FadeInUp(
                  delay: Duration(milliseconds: 60 * index),
                  child: _buildAssignmentCard(theme, vm.items[index], vm),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAssignmentCard(ThemeData theme, AssignmentModel assignment, AssignmentsViewModel vm) {
    final isSubmitted = assignment.submission != null || assignment.status == 'submitted';
    final statusColor = isSubmitted ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  assignment.title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(
                  isSubmitted ? 'تم التسليم' : 'قيد الانتظار', 
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(assignment.description, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          if (assignment.fileUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: assignment.fileUrls.map((url) => ActionChip(
                avatar: const Icon(LucideIcons.fileText, size: 14),
                label: const Text('ملف الواجب', style: TextStyle(fontSize: 10)),
                onPressed: () async {
                  try {
                    final uri = Uri.parse(url);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('لا يمكن فتح الملف')));
                  }
                },
              )).toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 16, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text('تاريخ التسليم: ${AppDateUtils.formatDate(assignment.dueDate)}', style: const TextStyle(fontSize: 12)),
              const Spacer(),
              if (assignment.submission?.score != null) ...[
                const Icon(LucideIcons.award, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Text('${assignment.submission!.score} / ${assignment.maxScore}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ] else ...[
                const Icon(LucideIcons.hash, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('الدرجة: ${assignment.maxScore}', style: const TextStyle(fontSize: 12)),
              ],
            ],
          ),
          if (!isSubmitted) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _submitHomework(context, theme, assignment, vm),
                icon: const Icon(LucideIcons.upload),
                label: const Text('تسليم الواجب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ] else if (assignment.submission != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context, 
                  '/submission-details',
                  arguments: {
                    'submissionId': assignment.submission!.id,
                    'assignmentTitle': assignment.title,
                  },
                ),
                icon: const Icon(LucideIcons.eye, size: 18),
                label: const Text('عرض التفاصيل والنتيجة'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
