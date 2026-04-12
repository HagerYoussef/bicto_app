import '../../../../core/models/paginated_response.dart';
import '../../data/models/student_models.dart';

abstract class StudentRepository {
  Future<StudentDashboardModel> getDashboard();
  Future<List<SubjectModel>> getSubjects({int? gradeId});
  Future<PaginatedResponse<TeacherModel>> getTeachers({int? subjectId, int? gradeId, int page, int perPage});
  Future<TeacherModel> getTeacherDetails(int id);
  Future<PaginatedResponse<SubscriptionModel>> getSubscriptions({int page = 1, int perPage = 15});
  Future<PaginatedResponse<BookingModel>> getBookings({int page = 1, int perPage = 15});
  Future<void> bookClass(int classId);
  Future<void> cancelBooking(int classId);
  Future<PaginatedResponse<SummaryModel>> getSummaries({int page, int perPage});
  Future<SummaryModel> getSummaryDetails(int id);
  Future<BookingModel> getClassDetails(int id);
  Future<PaginatedResponse<PaymentModel>> getPayments({int page = 1, int perPage = 15});
  Future<PaginatedResponse<AssignmentModel>> getAssignments({int page = 1, int perPage = 15});
  Future<AssignmentModel> getAssignmentDetails(int id);
  Future<void> submitAssignment(int assignmentId, {String? content, List<String>? filePaths});

  // New from Postman
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<List<PlanModel>> getPlans();
  Future<String?> checkoutPlan(int planId);
  Future<Map<String, dynamic>> checkEligibility(int classId);
  Future<PaginatedResponse<NotificationModel>> getNotifications({int page, int perPage});
  Future<void> markAllNotificationsAsRead();
  Future<void> markNotificationAsRead(String id);
  Future<void> deleteNotification(String id);
  Future<SubscriptionSummaryModel> getSubscriptionSummary();
  Future<SubscriptionModel> getSubscriptionDetails(int id);
  Future<PaginatedResponse<SessionModel>> getSessions({int page = 1, int perPage = 15});
  Future<PaginatedResponse<FileModel>> getFiles({int page = 1, int perPage = 15});
  Future<PaginatedResponse<FileModel>> getFilesByClass(int classId, {int page = 1, int perPage = 15});
  Future<PaymentModel> getPaymentDetails(int id);
  Future<PaginatedResponse<AssignmentModel>> getClassAssignments(int classId, {int page = 1, int perPage = 15});
  Future<SubmissionModel> getSubmission(int id);
}
