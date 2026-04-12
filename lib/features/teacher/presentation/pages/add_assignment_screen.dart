import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../../../../shared/widgets/app_card.dart';
import '../viewmodels/teacher_viewmodel.dart';
import '../../../student/data/models/student_models.dart';

class AddAssignmentScreen extends StatefulWidget {
  final int classId;
  final AssignmentModel? editAssignment;

  const AddAssignmentScreen({
    super.key,
    required this.classId,
    this.editAssignment,
  });

  @override
  State<AddAssignmentScreen> createState() => _AddAssignmentScreenState();
}

class _AddAssignmentScreenState extends State<AddAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _maxScoreController;
  
  DateTime? _dueDate;
  final List<String> _selectedFiles = [];
  
  bool get _isEdit => widget.editAssignment != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.editAssignment?.title);
    _descriptionController = TextEditingController(text: widget.editAssignment?.description);
    _maxScoreController = TextEditingController(text: widget.editAssignment?.maxScore?.toString() ?? '100');
    
    if (_isEdit) {
      try {
        _dueDate = DateTime.parse(widget.editAssignment!.dueDate);
      } catch (e) {
        _dueDate = DateTime.now().add(const Duration(days: 7));
      }
    } else {
      _dueDate = DateTime.now().add(const Duration(days: 7));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxScoreController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _dueDate) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.paths.whereType<String>());
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار تاريخ التسليم')));
      return;
    }

    final data = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'due_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(_dueDate!),
      'max_score': int.tryParse(_maxScoreController.text) ?? 100,
      if (_selectedFiles.isNotEmpty) 'files': _selectedFiles,
    };

    final vm = context.read<TeacherViewModel>();
    final bool success;
    
    if (_isEdit) {
      success = await vm.updateAssignment(widget.classId, widget.editAssignment!.id, data);
    } else {
      success = await vm.createAssignment(widget.classId, data);
    }
    
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'تم تحديث الواجب بنجاح' : 'تمت إضافة الواجب بنجاح'),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(vm.error ?? 'حدث خطأ'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isEdit ? 'تعديل واجب' : 'إضافة واجب جديد'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: _buildSectionHeader(theme, 'معلومات الواجب', LucideIcons.fileText),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'عنوان الواجب',
                      hint: 'مثال: حل مسائل الفيزياء الفصل الأول',
                      prefixIcon: LucideIcons.type,
                      controller: _titleController,
                      validator: (v) => v?.isEmpty ?? true ? 'العنوان مطلوب' : null,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'الوصف والتعليمات',
                      hint: 'اكتب تفاصيل الواجب والتعليمات للطلاب...',
                      prefixIcon: LucideIcons.alignLeft,
                      controller: _descriptionController,
                      maxlines: 5,
                      validator: (v) => v?.isEmpty ?? true ? 'الوصف مطلوب' : null,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'الدرجة القصوى',
                      hint: '100',
                      prefixIcon: LucideIcons.hash,
                      controller: _maxScoreController,
                      keyboardType: TextInputType.number,
                      validator: (v) => (int.tryParse(v ?? '') ?? 0) <= 0 ? 'الدرجة يجب أن تكون أكبر من صفر' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: _buildSectionHeader(theme, 'المواعيد', LucideIcons.calendar),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: InkWell(
                  onTap: _selectDueDate,
                  child: Row(
                    children: [
                      Icon(LucideIcons.calendar, color: theme.primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('آخر موعد للتسليم', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              _dueDate == null ? 'اختر تاريخاً' : DateFormat('y/MM/dd').format(_dueDate!),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Icon(LucideIcons.chevronDown, size: 16, color: theme.hintColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeInDown(
                delay: const Duration(milliseconds: 120),
                child: _buildSectionHeader(theme, 'المرفقات', LucideIcons.paperclip),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(LucideIcons.plus),
                      label: const Text('إضافة ملفات للواجب'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    if (_selectedFiles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ..._selectedFiles.map((path) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.file, size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    path.split('/').last,
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 16, color: Colors.red),
                                  onPressed: () => setState(() => _selectedFiles.remove(path)),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              FadeInUp(
                child: Consumer<TeacherViewModel>(
                  builder: (context, vm, _) => CustomButton(
                    text: _isEdit ? 'تحديث الواجب' : 'نشر الواجب للطلاب',
                    isLoading: vm.isLoading,
                    onPressed: vm.isLoading ? null : _handleSubmit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: theme.primaryColor, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
