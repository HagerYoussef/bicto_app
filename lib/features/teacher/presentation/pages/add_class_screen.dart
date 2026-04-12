import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../viewmodels/teacher_viewmodel.dart';
import '../../data/models/teacher_models.dart';
import '../../../student/data/models/student_models.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../auth/data/models/auth_models.dart' hide SubjectModel;
import '../../../../shared/widgets/app_card.dart';

class AddClassScreen extends StatefulWidget {
  final TeacherClassModel? editClass;
  const AddClassScreen({super.key, this.editClass});

  @override
  State<AddClassScreen> createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _titleController;
  late final TextEditingController _maxStudentsController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;
  
  int? _selectedGradeId;
  int? _selectedSubjectId;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  String? _coverImagePath;
  String? _lessonMaterialPath;
  bool _enableZoom = true;

  bool get _isEdit => widget.editClass != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.editClass?.title);
    _maxStudentsController = TextEditingController(text: widget.editClass?.maxStudents?.toString() ?? '30');
    _descriptionController = TextEditingController(text: widget.editClass?.description);
    _notesController = TextEditingController(text: widget.editClass?.notes);
    _selectedSubjectId = widget.editClass?.subjectId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().fetchGrades();
      context.read<TeacherViewModel>().loadSubjects();
    });

    if (_isEdit) {
      _enableZoom = widget.editClass!.enableZoom;
      try {
        final start = DateTime.parse(widget.editClass!.startTime).toLocal();
        final end = DateTime.parse(widget.editClass!.endTime).toLocal();
        _startDate = start;
        _startTime = TimeOfDay.fromDateTime(start);
        _endDate = end;
        _endTime = TimeOfDay.fromDateTime(end);
      } catch (e) {
        // Fallback for invalid formats
      }
    }
  }

  Future<void> _pickFile(bool isImage) async {
    final result = await FilePicker.platform.pickFiles(
      type: isImage ? FileType.image : FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (isImage) {
          _coverImagePath = result.files.single.path;
        } else {
          _lessonMaterialPath = result.files.single.path;
        }
      });
    }
  }

  Future<void> _selectDateTime(bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: (isStart ? _startTime : _endTime) ?? TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          if (isStart) {
            _startDate = pickedDate;
            _startTime = pickedTime;
          } else {
            _endDate = pickedDate;
            _endTime = pickedTime;
          }
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('الرجاء اختيار المادة الدراسية'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (_startDate == null || _startTime == null || _endDate == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار وقت البدء والانتهاء')));
      return;
    }

    final startDateTime = DateTime(_startDate!.year, _startDate!.month, _startDate!.day, _startTime!.hour, _startTime!.minute);
    final endDateTime = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, _endTime!.hour, _endTime!.minute);

    if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('يجب أن يكون وقت الانتهاء بعد وقت البدء'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final data = {
      'title': _titleController.text,
      'subject_id': _selectedSubjectId ?? 1,
      'start_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(startDateTime),
      'end_time': DateFormat('yyyy-MM-dd HH:mm:ss').format(endDateTime),
      'max_students': int.tryParse(_maxStudentsController.text) ?? 30,
      'description': _descriptionController.text,
      'notes': _notesController.text,
      'enable_zoom': _enableZoom ? 1 : 0,
      if (_coverImagePath != null) 'cover_image': _coverImagePath,
      if (_lessonMaterialPath != null) 'lesson_material': _lessonMaterialPath,
    };

    final vm = context.read<TeacherViewModel>();
    final bool success;
    if (_isEdit) {
      success = await vm.updateClass(widget.editClass!.id, data);
    } else {
      success = await vm.createClass(data);
    }
    
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'تم تحديث الفصل بنجاح' : 'تمت إضافة الفصل بنجاح'),
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
        title: Text(_isEdit ? 'تعديل فصل' : 'إضافة فصل جديد'),
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
                child: _buildSectionHeader(theme, 'المعلومات الأساسية', LucideIcons.info),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'عنوان الفصل',
                      hint: 'مثال: أساسيات الفيزياء الحديثة',
                      prefixIcon: LucideIcons.type,
                      controller: _titleController,
                      validator: (v) => v?.isEmpty ?? true ? 'العنوان مطلوب' : null,
                      maxlines: 1,
                    ),
                    const SizedBox(height: 20),
                    _buildSubjectDropdown(theme),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'الحد الأقصى للطلاب',
                      hint: '30',
                      prefixIcon: LucideIcons.users,
                      controller: _maxStudentsController,
                      keyboardType: TextInputType.number,
                      maxlines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              FadeInDown(
                delay: const Duration(milliseconds: 100),
                child: _buildSectionHeader(theme, 'الجدول الزمني', LucideIcons.calendar),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDateTimePicker(theme, 'وقت البدء', true),
                    const SizedBox(height: 16),
                    _buildDateTimePicker(theme, 'وقت الانتهاء', false),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: _buildSectionHeader(theme, 'محتوى و ملاحظات', LucideIcons.alignLeft),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'وصف الفصل',
                      hint: 'اكتب وصفاً مفصلاً عما سيتم شرحه...',
                      prefixIcon: LucideIcons.alignLeft,
                      controller: _descriptionController,
                      maxlines: 4,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'ملاحظات إضافية',
                      hint: 'أي ملاحظات تود إضافتها للطلاب...',
                      prefixIcon: LucideIcons.stickyNote,
                      controller: _notesController,
                      maxlines: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FadeInDown(
                delay: const Duration(milliseconds: 220),
                child: _buildSectionHeader(theme, 'الوسائط و الملفات', LucideIcons.image),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildFilePickerItem(
                      theme,
                      'صورة الغلاف (Cover Image)',
                      _coverImagePath,
                      widget.editClass?.coverUrl,
                      true,
                    ),
                    const SizedBox(height: 16),
                    _buildFilePickerItem(
                      theme,
                      'المادة العلمية (Lesson Material)',
                      _lessonMaterialPath,
                      widget.editClass?.lessonMaterialUrl,
                      false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              FadeInDown(
                delay: const Duration(milliseconds: 250),
                child: _buildSectionHeader(theme, 'إعدادات الاجتماع', LucideIcons.video),
              ),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SwitchListTile(
                  title: const Text('تفعيل اجتماع زوم (Zoom)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: const Text('سيتم إنشاء رابط اجتماع تلقائياً عند بدء الفصل', style: TextStyle(fontSize: 12)),
                  value: _enableZoom,
                  onChanged: (v) => setState(() => _enableZoom = v),
                  activeColor: theme.primaryColor,
                  secondary: Icon(LucideIcons.video, color: theme.primaryColor),
                ),
              ),
              
              const SizedBox(height: 48),
              FadeInUp(
                child: Consumer<TeacherViewModel>(
                  builder: (context, vm, _) => CustomButton(
                    text: _isEdit ? 'تحديث الفصل' : 'حفظ وتفعيل الفصل',
                    isLoading: vm.isLoading,
                    onPressed: vm.isLoading ? null : _handleSubmit,
                  ),
                ),
              ),
              const SizedBox(height: 40),
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

  Widget _buildSubjectDropdown(ThemeData theme) {
    return Consumer2<AuthViewModel, TeacherViewModel>(
      builder: (context, authVm, teacherVm, _) {
        final grades = authVm.grades; // Show all grades for now to avoid filtering issues
        List<SubjectModel> subjects = teacherVm.subjects;

        // Fallback: If dedicated subjects list is empty, collect from grades
        if (subjects.isEmpty && grades.isNotEmpty) {
          final allGradeSubjects = <int, SubjectModel>{};
          for (final g in grades) {
            for (final s in g.subjects) {
              allGradeSubjects[s.id] = s;
            }
          }
          subjects = allGradeSubjects.values.toList();
        }

        debugPrint('Rendered AddClassDropdowns: ${grades.length} grades, ${subjects.length} subjects');

        if ((authVm.isLoading || teacherVm.isLoading) && grades.isEmpty && subjects.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
        }

        if (!authVm.isLoading && !teacherVm.isLoading && grades.isEmpty && subjects.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Text('حدث خطأ في تحميل البيانات'),
                TextButton(
                  onPressed: () {
                    authVm.fetchGrades();
                    teacherVm.loadSubjects();
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildDropdownField(
              theme,
              'السنة الدراسية (Grade)',
              _selectedGradeId,
              grades.map((g) => DropdownMenuItem(value: g.id, child: Text(g.displayName))).toList(),
              (v) => setState(() {
                _selectedGradeId = v;
                if (v != null) {
                   final g = grades.firstWhere((e) => e.id == v);
                   if (g.subjects.length == 1 && _selectedSubjectId == null) {
                     _selectedSubjectId = g.subjects.first.id;
                   }
                }
              }),
              hint: grades.isEmpty ? (authVm.isLoading ? 'جاري التحميل...' : 'لا توجد سنوات متاحة') : 'اختر السنة الدراسية',
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              theme,
              'المادة الدراسية (Subject)',
              _selectedSubjectId,
              subjects.map((s) => DropdownMenuItem(
                value: s.id,
                child: Text(s.title),
              )).toList(),
              (v) => setState(() => _selectedSubjectId = v),
              hint: subjects.isEmpty ? (teacherVm.isLoading ? 'جاري التحميل...' : 'لا توجد مواد متاحة') : 'اختر المادة',
              enabled: subjects.isNotEmpty,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdownField(ThemeData theme, String label, int? value, List<DropdownMenuItem<int>> items, ValueChanged<int?> onChanged, {String? hint, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: enabled 
              ? (theme.brightness == Brightness.light ? Colors.grey[50] : theme.colorScheme.surface) 
              : (theme.brightness == Brightness.light ? Colors.grey[100] : theme.colorScheme.surfaceContainerHighest),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: items.any((i) => i.value == value) ? value : null,
              isExpanded: true,
              hint: Text(hint ?? '', style: TextStyle(color: theme.hintColor, fontSize: 13)),
              items: items,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker(ThemeData theme, String label, bool isStart) {
    final date = isStart ? _startDate : _endDate;
    final time = isStart ? _startTime : _endTime;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDateTime(isStart),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light ? Colors.grey[50] : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.calendar, size: 18, color: theme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date == null ? 'اختر الوقت' : '${DateFormat('y/MM/dd').format(date)} ${time?.format(context) ?? ''}',
                    style: TextStyle(fontSize: 14, color: date == null ? theme.hintColor : theme.textTheme.bodyLarge?.color),
                  ),
                ),
                Icon(LucideIcons.chevronDown, size: 16, color: theme.hintColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilePickerItem(ThemeData theme, String label, String? localPath, String? networkPath, bool isImage) {
    String displayPath = localPath ?? networkPath ?? '';
    bool isNetwork = localPath == null && networkPath != null;
    if (!isNetwork && localPath != null && displayPath.length > 30) {
      displayPath = '...${displayPath.substring(displayPath.length - 27)}';
    }

    String text;
    if (localPath != null) {
      text = isImage ? 'تم اختيار صورة' : displayPath;
    } else if (networkPath != null) {
      text = 'ملف مرفوع مسبقاً (مرفق)';
    } else {
      text = 'لم يتم اختيار ملف';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            if (localPath != null || networkPath != null) 
              const Icon(LucideIcons.checkCircle2, color: Colors.green, size: 16),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickFile(isImage),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light ? Colors.grey[50] : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(isImage ? LucideIcons.image : LucideIcons.fileText, size: 18, color: theme.primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 12, 
                      color: (localPath == null && networkPath == null) ? theme.hintColor : theme.textTheme.bodyMedium?.color,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Text(
                  (localPath == null && networkPath == null) ? 'اختيار' : 'تغيير',
                  style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

extension on Widget {
  Widget withDashedBorder(ThemeData theme) {
    return this; // Placeholder for dashed border implementation
  }
}
