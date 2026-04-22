import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/student_models.dart';

abstract class StudentRemoteDataSource {
  Future<StudentDashboardModel> getDashboard();
  Future<List<SubjectModel>> getSubjects({int? gradeId});
  Future<PaginatedResponse<TeacherModel>> getTeachers({int? subjectId, int? gradeId, int page, int perPage});
  Future<TeacherModel> getTeacherDetails(int id);
  Future<PaginatedResponse<SubscriptionModel>> getSubscriptions({int page, int perPage});
  Future<PaginatedResponse<BookingModel>> getBookings({int page, int perPage});
  Future<void> bookClass(int classId);
  Future<void> cancelBooking(int classId);
  Future<PaginatedResponse<SummaryModel>> getSummaries({int page, int perPage});
  Future<SummaryModel> getSummaryDetails(int id);
  Future<PaginatedResponse<PaymentModel>> getPayments({int page, int perPage});
  Future<PaginatedResponse<AssignmentModel>> getAssignments({int page, int perPage});
  Future<AssignmentModel> getAssignmentDetails(int id);
  Future<void> submitAssignment(int assignmentId, {String? content, List<String>? filePaths});
  
  // New from Postman
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<List<PlanModel>> getPlans();
  Future<CheckoutResponseModel?> checkoutPlan(int planId);
  Future<Map<String, dynamic>> getPaymentStatus(String tapId);
  Future<Map<String, dynamic>> checkEligibility(int classId);
  Future<PaginatedResponse<NotificationModel>> getNotifications({int page, int perPage});
  Future<void> markAllNotificationsAsRead();
  Future<void> markNotificationAsRead(String id);
  Future<void> deleteNotification(String id);
  
  // Missing from Postman
  Future<SubscriptionSummaryModel> getSubscriptionSummary();
  Future<SubscriptionModel> getSubscriptionDetails(int id);
  Future<PaginatedResponse<SessionModel>> getSessions({int page, int perPage});
  Future<PaginatedResponse<FileModel>> getFiles({int page, int perPage});
  Future<PaginatedResponse<FileModel>> getFilesByClass(int classId, {int page, int perPage});
  Future<PaymentModel> getPaymentDetails(int id);
  Future<PaginatedResponse<AssignmentModel>> getClassAssignments(int classId, {int page = 1, int perPage = 15});
  Future<BookingModel> getClassDetails(int classId);
  Future<SubmissionModel> getSubmission(int id);
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final _dio = DioClient.getInstance();

  @override
  Future<StudentDashboardModel> getDashboard() async {
    try {
      final res = await _dio.get(ApiConstants.studentDashboard);
      return StudentDashboardModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<SubjectModel>> getSubjects({int? gradeId}) async {
    try {
      // Simplified: Fetch all subjects by default as per provided documentation
      final res = await _dio.get(ApiConstants.studentSubjects);
      final list = res.data['data'] ?? res.data;
      return (list as List).map((e) => SubjectModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<PaginatedResponse<TeacherModel>> getTeachers({int? subjectId, int? gradeId, int page = 1, int perPage = 12}) async {
    try {
      final Map<String, dynamic> query = {
        'page': page,
        'per_page': perPage,
      };

      // Only add filters if they are explicitly provided and not null
      if (subjectId != null) query['subject_id'] = subjectId;
      if (gradeId != null) query['grade_id'] = gradeId;

      final res = await _dio.get(ApiConstants.studentTeachers, queryParameters: query);
      return PaginatedResponse.fromJson(res.data, TeacherModel.fromJson);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<TeacherModel> getTeacherDetails(int id) async {
    try {
      final res = await _dio.get(ApiConstants.studentTeacherDetails(id));
      return TeacherModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<PaginatedResponse<SubscriptionModel>> getSubscriptions({int page = 1, int perPage = 15}) async {
    try {
      final res = await _dio.get(ApiConstants.studentSubscriptions,
          queryParameters: {'page': page, 'per_page': perPage});
      return PaginatedResponse.fromJson(res.data, SubscriptionModel.fromJson);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<PaginatedResponse<BookingModel>> getBookings({int page = 1, int perPage = 15}) async {
    try {
      final res = await _dio.get(ApiConstants.studentBookings,
          queryParameters: {'page': page, 'per_page': perPage});
      return PaginatedResponse.fromJson(res.data, BookingModel.fromJson);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> bookClass(int classId) async {
    try {
      await _dio.post(ApiConstants.studentClassBooking(classId));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> cancelBooking(int classId) async {
    try {
      await _dio.post(ApiConstants.studentClassCancel(classId));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<PaginatedResponse<SummaryModel>> getSummaries({int page = 1, int perPage = 12}) async {
    try {
      final res = await _dio.get(ApiConstants.studentSummaries,
          queryParameters: {'page': page, 'per_page': perPage});
      return PaginatedResponse.fromJson(res.data, SummaryModel.fromJson);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<SummaryModel> getSummaryDetails(int id) async {
    try {
      final res = await _dio.get('${ApiConstants.studentSummaries}/$id');
      return SummaryModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<PaginatedResponse<PaymentModel>> getPayments({int page = 1, int perPage = 15}) async {
    try {
      final res = await _dio.get(ApiConstants.studentPayments,
          queryParameters: {'page': page, 'per_page': perPage});
      return PaginatedResponse.fromJson(res.data, PaymentModel.fromJson);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<PaginatedResponse<AssignmentModel>> getAssignments({int page = 1, int perPage = 15}) async {
    try {
      final res = await _dio.get(ApiConstants.studentAssignments,
          queryParameters: {'page': page, 'per_page': perPage});
      return PaginatedResponse.fromJson(res.data, AssignmentModel.fromJson);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<AssignmentModel> getAssignmentDetails(int id) async {
    try {
      final res = await _dio.get(ApiConstants.studentAssignmentDetails(id));
      return AssignmentModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> submitAssignment(int assignmentId, {String? content, List<String>? filePaths}) async {
    final formData = FormData.fromMap({
      'content': content ?? '',
    });

    if (filePaths != null && filePaths.isNotEmpty) {
      for (final path in filePaths) {
        formData.files.add(MapEntry(
          'files[]',
          await MultipartFile.fromFile(path),
        ));
      }
    }

    try {
      debugPrint('StudentRemoteDataSource: Submitting assignment $assignmentId');
      await _dio.post(
        ApiConstants.studentSubmitAssignment(assignmentId),
        data: formData,
      );
    } on DioException catch (e) {
      debugPrint('StudentRemoteDataSource: Error submitting assignment: ${e.response?.data}');
      throw ErrorHandler.handle(e);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await _dio.put(ApiConstants.studentProfile, data: data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<PlanModel>> getPlans() async {
    try {
      final res = await _dio.get(ApiConstants.studentPlans);
      final list = res.data['data'] ?? res.data;
      return (list as List).map((e) => PlanModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<CheckoutResponseModel?> checkoutPlan(int planId) async {
    try {
      final res = await _dio.post(ApiConstants.studentPlanCheckout(planId));
      return CheckoutResponseModel.fromJson(res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getPaymentStatus(String tapId) async {
    try {
      final res = await _dio.get(ApiConstants.paymentStatus(tapId));
      return res.data;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<Map<String, dynamic>> checkEligibility(int classId) async {
    try {
      final res = await _dio.get(ApiConstants.studentClassEligibility(classId));
      return res.data;
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<PaginatedResponse<NotificationModel>> getNotifications({int page = 1, int perPage = 20}) async {
    try {
      final res = await _dio.get(ApiConstants.studentNotifications, queryParameters: {
        'page': page,
        'per_page': perPage,
      });
      return PaginatedResponse.fromJson(res.data, NotificationModel.fromJson);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    try {
      await _dio.post(ApiConstants.studentMarkAllNotificationsRead);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    try {
      await _dio.post(ApiConstants.studentNotificationRead(id));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _dio.delete(ApiConstants.studentNotificationDelete(id));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<SubscriptionSummaryModel> getSubscriptionSummary() async {
    try {
      final res = await _dio.get(ApiConstants.studentSubscriptionsSummary);
      return SubscriptionSummaryModel.fromJson(res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<SubscriptionModel> getSubscriptionDetails(int id) async {
    try {
      final res = await _dio.get(ApiConstants.studentSubscriptionDetails(id));
      return SubscriptionModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<PaginatedResponse<SessionModel>> getSessions({int page = 1, int perPage = 15}) async {
    try {
      final res = await _dio.get(ApiConstants.studentSessions,
          queryParameters: {'page': page, 'per_page': perPage});
      return PaginatedResponse.fromJson(res.data, SessionModel.fromJson);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<PaginatedResponse<FileModel>> getFiles({int page = 1, int perPage = 15}) async {
    try {
      final res = await _dio.get(ApiConstants.studentFiles,
          queryParameters: {'page': page, 'per_page': perPage});
      return PaginatedResponse.fromJson(res.data, FileModel.fromJson);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<PaginatedResponse<FileModel>> getFilesByClass(int classId, {int page = 1, int perPage = 15}) async {
    try {
      final res = await _dio.get(ApiConstants.studentFileDetails(classId),
          queryParameters: {'page': page, 'per_page': perPage});
      return PaginatedResponse.fromJson(res.data, FileModel.fromJson);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<PaymentModel> getPaymentDetails(int id) async {
    try {
      final res = await _dio.get(ApiConstants.studentPaymentDetails(id));
      return PaymentModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<PaginatedResponse<AssignmentModel>> getClassAssignments(int classId, {int page = 1, int perPage = 15}) async {
    try {
      final res = await _dio.get(ApiConstants.studentClassAssignments(classId),
          queryParameters: {'page': page, 'per_page': perPage});
      return PaginatedResponse.fromJson(res.data, AssignmentModel.fromJson);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<BookingModel> getClassDetails(int classId) async {
    try {
      final res = await _dio.get(ApiConstants.studentClassDetails(classId));
      return BookingModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<SubmissionModel> getSubmission(int id) async {
    try {
      final res = await _dio.get(ApiConstants.studentSubmissionDetails(id));
      return SubmissionModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
