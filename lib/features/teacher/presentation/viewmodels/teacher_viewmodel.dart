import 'package:flutter/material.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/viewmodels/base_paginated_viewmodel.dart';
import '../../data/models/teacher_models.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../../student/data/models/student_models.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../auth/data/models/user_model.dart';

class TeacherViewModel extends ChangeNotifier {
  final TeacherRepository _repository;
  TeacherViewModel(this._repository);

  TeacherRepository get repository => _repository;

  TeacherDashboardModel? _dashboard;
  String? _error;
  bool _isLoading = false;
  List<SubjectModel> _subjects = [];

  TeacherDashboardModel? get dashboard => _dashboard;
  String? get error => _error;
  bool get isLoading => _isLoading;
  List<SubjectModel> get subjects => _subjects;
  
  UserModel? _profile;
  UserModel? get profile => _profile;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repository.getProfile();
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _repository.updateProfile(data);
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSubjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _subjects = await _repository.getSubjects();
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final classesRes = await _repository.getClasses(perPage: 50); 
      
      try {
        _dashboard = await _repository.getDashboard();
        
        final now = DateTime.now();
        final filteredClasses = classesRes.data.where((cls) {
          try {
            final start = DateTime.parse(cls.startTime).toLocal();
            return start.year == now.year && start.month == now.month && start.day == now.day;
          } catch (_) {
            return false;
          }
        }).toList();

        _dashboard = TeacherDashboardModel(
          totalClasses: _dashboard!.totalClasses > 0 ? _dashboard!.totalClasses : classesRes.total,
          todaysClasses: filteredClasses.length,
          totalStudents: _dashboard!.totalStudents,
          attendanceAverage: _dashboard!.attendanceAverage,
          classes: filteredClasses,
        );
      } catch (e) {
        final now = DateTime.now();
        final filteredClasses = classesRes.data.where((cls) {
          try {
            final start = DateTime.parse(cls.startTime).toLocal();
            return start.year == now.year && start.month == now.month && start.day == now.day;
          } catch (_) {
            return false;
          }
        }).toList();

        _dashboard = TeacherDashboardModel(
          totalClasses: classesRes.total,
          todaysClasses: filteredClasses.length,
          totalStudents: 0,
          classes: filteredClasses,
        );
      }
      
      _dashboard?.classes.sort((a, b) => a.startTime.compareTo(b.startTime));
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startClass(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.startClass(id);
      
      try {
        final cls = _dashboard?.classes.firstWhere((c) => c.id == id);
        if (cls != null && cls.enableZoom && (cls.zoomMeetingUrl == null || cls.zoomMeetingUrl!.isEmpty)) {
          await _repository.createZoomMeeting(id, "لقاء: ${cls.title}", DateTime.now().toIso8601String());
        }
      } catch (zoomError) {
        // Silent zoom error
      }
      
      await loadDashboard();
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> finishClass(int id, {Map<String, dynamic>? additionalData}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (additionalData != null && additionalData.isNotEmpty) {
        await _repository.updateClass(id, additionalData);
      }
      await _repository.finishClass(id);
      await loadDashboard();
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClassSummary(int classId, String content, String materials) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.createClassSummary(classId, content, materials);
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadClassFile(int classId, String title, String description, String filePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.uploadClassFile(classId, title, description, filePath);
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClass(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.createClass(data);
      await loadDashboard();
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateClass(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateClass(id, data);
      await loadDashboard();
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteClass(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteClass(id);
      await loadDashboard();
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ZoomMeetingModel?> getZoomMeeting(int classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      return await _repository.getZoomMeeting(classId);
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createZoomMeeting(int classId, String title, String startTime) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.createZoomMeeting(classId, title, startTime);
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateZoomMeeting(int classId, {String? title, String? startTime, bool? regenerate}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateZoomMeeting(classId, title: title, startTime: startTime, regenerate: regenerate);
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAssignment(int classId, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.createAssignment(classId, data);
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAssignment(int classId, int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateAssignment(classId, id, data);
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAssignment(int classId, int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteAssignment(classId, id);
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}

class TeacherClassesViewModel extends BasePaginatedViewModel<TeacherClassModel> {
  final TeacherRepository _repository;
  TeacherClassesViewModel(this._repository);

  String? _status;
  int? _subjectId;
  String? _timeFilter;

  void setFilters({String? status, int? subjectId, String? timeFilter}) {
    _status = status;
    _subjectId = subjectId;
    _timeFilter = timeFilter;
    if (status != null || subjectId != null || timeFilter != null) {
      loadInitialData();
    }
  }

  @override
  Future<PaginatedResponse<TeacherClassModel>> fetchFromRepository(int page, int perPage) {
    return _repository.getClasses(
      page: page,
      perPage: perPage,
      status: _status,
      subjectId: _subjectId,
      timeFilter: _timeFilter,
    );
  }

  Future<bool> deleteClass(int id) async {
    try {
      await _repository.deleteClass(id);
      await loadInitialData();
      return true;
    } catch (e) {
      debugPrint('Error deleting class: $e');
      return false;
    }
  }
}

class TeacherAttendanceViewModel extends ChangeNotifier {
  final TeacherRepository _repository;
  TeacherAttendanceViewModel(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;
  List<AttendanceModel> _attendanceList = [];
  List<AttendanceModel> get attendanceList => _attendanceList;

  Future<void> loadAttendance(int classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _attendanceList = await _repository.getClassAttendance(classId);
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAttendance(int classId, List<Map<String, dynamic>> attendances) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.markAttendance(classId, attendances);
      return true;
    } catch (e) {
      _error = ErrorHandler.handle(e).message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class TeacherAssignmentsViewModel extends BasePaginatedViewModel<AssignmentModel> {
  final TeacherRepository _repository;
  final int classId;

  TeacherAssignmentsViewModel(this._repository, this.classId);

  @override
  Future<PaginatedResponse<AssignmentModel>> fetchFromRepository(int page, int perPage) {
    return _repository.getClassAssignments(classId, page: page, perPage: perPage);
  }

  List<SubmissionModel> _submissions = [];
  List<SubmissionModel> get submissions => _submissions;
  bool _isSubmissionsLoading = false;
  bool get isSubmissionsLoading => _isSubmissionsLoading;

  Future<void> fetchSubmissions(int assignmentId) async {
    _isSubmissionsLoading = true;
    notifyListeners();
    try {
      _submissions = await _repository.getAssignmentSubmissions(classId, assignmentId);
    } catch (e) {
      debugPrint('Error fetching submissions: $e');
    } finally {
      _isSubmissionsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> gradeSubmission(int assignmentId, int submissionId, double score, String? feedback) async {
    _isSubmissionsLoading = true;
    notifyListeners();
    try {
      await _repository.gradeSubmission(classId, assignmentId, submissionId, score, feedback);
      // Refresh submissions to reflect the new grade
      await fetchSubmissions(assignmentId);
      return true;
    } catch (e) {
      debugPrint('Error grading submission: $e');
      return false;
    } finally {
      _isSubmissionsLoading = false;
      notifyListeners();
    }
  }
}
