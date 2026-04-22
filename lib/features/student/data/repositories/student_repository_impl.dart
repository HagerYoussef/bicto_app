import '../../../../core/models/paginated_response.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_datasource.dart';
import '../models/student_models.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource _dataSource;

  StudentRepositoryImpl(this._dataSource);

  @override
  Future<StudentDashboardModel> getDashboard() => _dataSource.getDashboard();

  @override
  Future<List<SubjectModel>> getSubjects({int? gradeId}) => _dataSource.getSubjects(gradeId: gradeId);

  @override
  Future<PaginatedResponse<TeacherModel>> getTeachers({int? subjectId, int? gradeId, int page = 1, int perPage = 12}) =>
      _dataSource.getTeachers(subjectId: subjectId, gradeId: gradeId, page: page, perPage: perPage);

  @override
  Future<TeacherModel> getTeacherDetails(int id) => _dataSource.getTeacherDetails(id);

  @override
  Future<PaginatedResponse<SubscriptionModel>> getSubscriptions({int page = 1, int perPage = 15}) =>
      _dataSource.getSubscriptions(page: page, perPage: perPage);

  @override
  Future<PaginatedResponse<BookingModel>> getBookings({int page = 1, int perPage = 15}) =>
      _dataSource.getBookings(page: page, perPage: perPage);

  @override
  Future<void> bookClass(int classId) => _dataSource.bookClass(classId);

  @override
  Future<void> cancelBooking(int classId) => _dataSource.cancelBooking(classId);

  @override
  Future<PaginatedResponse<SummaryModel>> getSummaries({int page = 1, int perPage = 12}) =>
      _dataSource.getSummaries(page: page, perPage: perPage);

  @override
  Future<SummaryModel> getSummaryDetails(int id) => _dataSource.getSummaryDetails(id);

  @override
  Future<BookingModel> getClassDetails(int id) => _dataSource.getClassDetails(id);

  @override
  Future<PaginatedResponse<PaymentModel>> getPayments({int page = 1, int perPage = 15}) =>
      _dataSource.getPayments(page: page, perPage: perPage);

  @override
  Future<PaginatedResponse<AssignmentModel>> getAssignments({int page = 1, int perPage = 15}) =>
      _dataSource.getAssignments(page: page, perPage: perPage);

  @override
  Future<AssignmentModel> getAssignmentDetails(int id) => _dataSource.getAssignmentDetails(id);

  @override
  Future<void> submitAssignment(int assignmentId, {String? content, List<String>? filePaths}) =>
      _dataSource.submitAssignment(assignmentId, content: content, filePaths: filePaths);

  @override
  Future<void> updateProfile(Map<String, dynamic> data) => _dataSource.updateProfile(data);

  @override
  Future<List<PlanModel>> getPlans() => _dataSource.getPlans();

  @override
  Future<CheckoutResponseModel?> checkoutPlan(int planId) => _dataSource.checkoutPlan(planId);
  
  @override
  Future<Map<String, dynamic>> getPaymentStatus(String tapId) => _dataSource.getPaymentStatus(tapId);

  @override
  Future<Map<String, dynamic>> checkEligibility(int classId) => _dataSource.checkEligibility(classId);

  @override
  Future<PaginatedResponse<NotificationModel>> getNotifications({int page = 1, int perPage = 20}) =>
      _dataSource.getNotifications(page: page, perPage: perPage);

  @override
  Future<void> markAllNotificationsAsRead() => _dataSource.markAllNotificationsAsRead();

  @override
  Future<void> markNotificationAsRead(String id) => _dataSource.markNotificationAsRead(id);

  @override
  Future<void> deleteNotification(String id) => _dataSource.deleteNotification(id);

  @override
  Future<SubscriptionSummaryModel> getSubscriptionSummary() => _dataSource.getSubscriptionSummary();

  @override
  Future<SubscriptionModel> getSubscriptionDetails(int id) => _dataSource.getSubscriptionDetails(id);

  @override
  Future<PaginatedResponse<SessionModel>> getSessions({int page = 1, int perPage = 15}) =>
      _dataSource.getSessions(page: page, perPage: perPage);

  @override
  Future<PaginatedResponse<FileModel>> getFiles({int page = 1, int perPage = 15}) =>
      _dataSource.getFiles(page: page, perPage: perPage);

  @override
  Future<PaginatedResponse<FileModel>> getFilesByClass(int classId, {int page = 1, int perPage = 15}) =>
      _dataSource.getFilesByClass(classId, page: page, perPage: perPage);

  @override
  Future<PaymentModel> getPaymentDetails(int id) => _dataSource.getPaymentDetails(id);

  @override
  Future<PaginatedResponse<AssignmentModel>> getClassAssignments(int classId, {int page = 1, int perPage = 15}) =>
      _dataSource.getClassAssignments(classId, page: page, perPage: perPage);

  @override
  Future<SubmissionModel> getSubmission(int id) => _dataSource.getSubmission(id);
}
