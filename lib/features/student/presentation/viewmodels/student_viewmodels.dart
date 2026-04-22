import 'package:flutter/material.dart';
import '../../../../core/viewmodels/base_paginated_viewmodel.dart';
import '../../../../core/models/paginated_response.dart';
import '../../data/models/student_models.dart';
import '../../domain/repositories/student_repository.dart';

// ── Bookings ──────────────────────────────────────────────────────────────────
class BookingsViewModel extends BasePaginatedViewModel<BookingModel> {
  final StudentRepository _repository;
  BookingsViewModel(this._repository);

  @override
  Future<PaginatedResponse<BookingModel>> fetchFromRepository(int page, int perPage) {
    return _repository.getBookings(page: page, perPage: perPage);
  }

  Future<bool> cancelBooking(int classId) async {
    try {
      await _repository.cancelBooking(classId);
      await loadInitialData();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> bookClass(int classId) async {
    try {
      await _repository.bookClass(classId);
      await loadInitialData();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// ── Payments ──────────────────────────────────────────────────────────────────
class PaymentsViewModel extends BasePaginatedViewModel<PaymentModel> {
  final StudentRepository _repository;
  PaymentsViewModel(this._repository);

  @override
  Future<PaginatedResponse<PaymentModel>> fetchFromRepository(int page, int perPage) {
    return _repository.getPayments(page: page, perPage: perPage);
  }
}

// ── Summaries ─────────────────────────────────────────────────────────────────
class SummariesViewModel extends BasePaginatedViewModel<SummaryModel> {
  final StudentRepository _repository;
  SummariesViewModel(this._repository);

  @override
  Future<PaginatedResponse<SummaryModel>> fetchFromRepository(int page, int perPage) async {
    try {
      final response = await _repository.getSummaries(page: page, perPage: perPage);
      debugPrint('SummariesViewModel: Fetched ${response.data.length} summaries');
      return response;
    } catch (e) {
      debugPrint('SummariesViewModel: Error fetching summaries: $e');
      rethrow;
    }
  }
}

// ── Subscriptions ─────────────────────────────────────────────────────────────
class SubscriptionsViewModel extends BasePaginatedViewModel<SubscriptionModel> {
  final StudentRepository _repository;
  SubscriptionsViewModel(this._repository);

  @override
  Future<PaginatedResponse<SubscriptionModel>> fetchFromRepository(int page, int perPage) {
    return _repository.getSubscriptions(page: page, perPage: perPage);
  }
}

// ── Teachers ──────────────────────────────────────────────────────────────────
class TeachersViewModel extends BasePaginatedViewModel<TeacherModel> {
  final StudentRepository _repository;
  TeachersViewModel(this._repository);

  int? _selectedSubjectId;
  int? _selectedGradeId;
  
  void setFilters({int? subjectId, int? gradeId}) {
    debugPrint('TeachersViewModel: Setting filters - Subject: $subjectId, Grade: $gradeId');
    _selectedSubjectId = subjectId;
    _selectedGradeId = gradeId;
    
    // Reset state to allow a fresh initial load even if it was loading before
    loadInitialData();
  }

  @override
  Future<PaginatedResponse<TeacherModel>> fetchFromRepository(int page, int perPage) async {
    debugPrint('TeachersViewModel: Fetching from repo - Page: $page, Filters: {subject: $_selectedSubjectId, grade: $_selectedGradeId}');
    return _repository.getTeachers(
      subjectId: _selectedSubjectId,
      gradeId: _selectedGradeId,
      page: page,
      perPage: perPage,
    );
  }

  Future<TeacherModel?> getTeacherDetails(int id) async {
    try {
      final teacher = await _repository.getTeacherDetails(id);
      return teacher;
    } catch (e) {
      debugPrint('Error fetching teacher details: $e');
      return null;
    }
  }
}

// ── Assignments ───────────────────────────────────────────────────────────────
class AssignmentsViewModel extends BasePaginatedViewModel<AssignmentModel> {
  final StudentRepository _repository;
  AssignmentsViewModel(this._repository);

  int? _classId;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  @override
  List<AssignmentModel> get items {
    if (_classId == null || _classId == 0) return super.items;
    return super.items.where((a) => a.classId == _classId || a.classId == null).toList();
  }

  void setFilters({int? classId}) {
    debugPrint('AssignmentsViewModel: Setting filters - ClassId: $classId');
    _classId = classId;
    loadInitialData();
  }

  @override
  Future<PaginatedResponse<AssignmentModel>> fetchFromRepository(int page, int perPage) {
    if (_classId != null && _classId != 0) {
      return _repository.getClassAssignments(_classId!, page: page, perPage: perPage);
    }
    return _repository.getAssignments(page: page, perPage: perPage);
  }

  Future<bool> submitAssignment(int assignmentId, {String? content, List<String>? filePaths}) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await _repository.submitAssignment(assignmentId, content: content, filePaths: filePaths);
      _isSubmitting = false;
      notifyListeners();
      await loadInitialData();
      return true;
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  SubmissionModel? _currentSubmission;
  SubmissionModel? get currentSubmission => _currentSubmission;
  bool _isLoadingSubmission = false;
  bool get isLoadingSubmission => _isLoadingSubmission;

  Future<void> fetchSubmission(int id) async {
    _isLoadingSubmission = true;
    _currentSubmission = null;
    notifyListeners();
    try {
      _currentSubmission = await _repository.getSubmission(id);
    } catch (e) {
      debugPrint('Error fetching submission: $e');
    } finally {
      _isLoadingSubmission = false;
      notifyListeners();
    }
  }
}

// ── Subjects ──────────────────────────────────────────────────────────────────
class SubjectsViewModel extends ChangeNotifier {
  final StudentRepository _repository;
  SubjectsViewModel(this._repository);

  ViewState _state = ViewState.idle;
  String? _error;
  List<SubjectModel> _subjects = [];
  String _searchQuery = '';

  ViewState get state => _state;
  String? get error => _error;
  List<SubjectModel> get subjects {
    if (_searchQuery.isEmpty) return _subjects;
    return _subjects.where((s) => s.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }
  bool get isLoading => _state == ViewState.loading;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> fetchSubjects({int? gradeId}) async {
    _state = ViewState.loading;
    _error = null;
    _searchQuery = '';
    notifyListeners();

    try {
      _subjects = await _repository.getSubjects(gradeId: gradeId);
      _state = ViewState.loaded;
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
      _error = 'حدث خطأ أثناء تحميل المواد';
      _state = ViewState.error;
    }

    notifyListeners();
  }
}

// ── Notifications ─────────────────────────────────────────────────────────────
class NotificationsViewModel extends BasePaginatedViewModel<NotificationModel> {
  final StudentRepository _repository;
  NotificationsViewModel(this._repository);

  @override
  Future<PaginatedResponse<NotificationModel>> fetchFromRepository(int page, int perPage) {
    return _repository.getNotifications(page: page, perPage: perPage);
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllNotificationsAsRead();
      loadInitialData();
    } catch (_) {}
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markNotificationAsRead(id);
      loadInitialData();
    } catch (_) {}
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
      loadInitialData();
    } catch (_) {}
  }
}

// ── Plans ──────────────────────────────────────────────────────────────────
class PlansViewModel extends ChangeNotifier {
  final StudentRepository _repository;
  PlansViewModel(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<PlanModel> _plans = [];
  List<PlanModel> get plans => _plans;

  String? _lastTapId;
  String? get lastTapId => _lastTapId;

  Future<void> fetchPlans() async {
    _isLoading = true;
    notifyListeners();
    try {
      _plans = await _repository.getPlans();
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<CheckoutResponseModel?> checkoutPlan(int planId) async {
    _isLoading = true;
    _lastTapId = null;
    notifyListeners();
    try {
      final response = await _repository.checkoutPlan(planId);
      _lastTapId = response?.tapId;
      return response;
    } catch (_) {
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> checkPaymentStatus() async {
    if (_lastTapId == null) return null;
    _isLoading = true;
    notifyListeners();
    try {
      final status = await _repository.getPaymentStatus(_lastTapId!);
      return status;
    } catch (_) {
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// ── Student Profile ──────────────────────────────────────────────────────────
class StudentProfileViewModel extends ChangeNotifier {
  final StudentRepository _repository;
  StudentProfileViewModel(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.updateProfile(data);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// ── Class Details ────────────────────────────────────────────────────────────
class ClassDetailsViewModel extends ChangeNotifier {
  final StudentRepository _repository;
  ClassDetailsViewModel(this._repository);

  ViewState _state = ViewState.idle;
  ViewState get state => _state;
  bool get isLoading => _state == ViewState.loading;
  String? _error;
  String? get error => _error;

  BookingModel? _classDetails;
  BookingModel? get classDetails => _classDetails;

  void setInitialData(BookingModel? data) {
    _classDetails = data;
    if (data != null) _state = ViewState.loaded;
    notifyListeners();
  }

  Future<void> loadClassDetails(int id) async {
    // If we already have data, don't show loading or error if the fetch fails
    // This is a workaround since /api/student/classes/{id} is missing from the API
    if (_classDetails == null) {
      _state = ViewState.loading;
      _error = null;
      notifyListeners();
    }

    debugPrint('ClassDetailsViewModel: Loading details for classId: $id');
    try {
      _classDetails = await _repository.getClassDetails(id);
      debugPrint('ClassDetailsViewModel: Successfully loaded details for classId: $id');
      _state = ViewState.loaded;
    } catch (e) {
      debugPrint('ClassDetailsViewModel: Error loading classId: $id | Error: $e');
      // If we already had initial data, don't overwrite it with an error
      if (_classDetails == null) {
        _error = e.toString();
        _state = ViewState.error;
      }
    } finally {
      notifyListeners();
    }
  }
}
