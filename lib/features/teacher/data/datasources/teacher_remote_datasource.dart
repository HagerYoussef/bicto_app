import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/network/dio_client.dart';
import '../models/teacher_models.dart';
import '../../../student/data/models/student_models.dart';
import '../../../auth/data/models/user_model.dart';

abstract class TeacherRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<TeacherDashboardModel> getDashboard();
  Future<PaginatedResponse<TeacherClassModel>> getClasses({int page = 1, int perPage = 15, String? status, int? subjectId, String? timeFilter});
  Future<TeacherClassModel> getClassDetails(int id);
  Future<TeacherClassModel> createClass(Map<String, dynamic> data);
  Future<TeacherClassModel> updateClass(int id, Map<String, dynamic> data);
  Future<void> deleteClass(int id);
  Future<void> startClass(int id);
  Future<void> finishClass(int id);
  Future<void> createClassSummary(int classId, String content, String materials);
  Future<void> uploadClassFile(int classId, String title, String description, String filePath);
  Future<List<AttendanceModel>> getClassAttendance(int classId);
  Future<void> markAttendance(int classId, List<Map<String, dynamic>> attendances);
  Future<PaginatedResponse<AssignmentModel>> getClassAssignments(int classId, {int page = 1, int perPage = 15});
  Future<AssignmentModel> createAssignment(int classId, Map<String, dynamic> data);
  Future<AssignmentModel> updateAssignment(int classId, int id, Map<String, dynamic> data);
  Future<void> deleteAssignment(int classId, int id);
  Future<AssignmentModel> getAssignmentDetails(int classId, int id);
  Future<List<SubmissionModel>> getAssignmentSubmissions(int classId, int id);
  Future<void> gradeSubmission(int classId, int assignmentId, int submissionId, double score, String? feedback);
  Future<List<SubjectModel>> getSubjects();
  Future<ZoomMeetingModel> getZoomMeeting(int classId);
  Future<ZoomMeetingModel> createZoomMeeting(int classId, String title, String startTime);
  Future<ZoomMeetingModel> updateZoomMeeting(int classId, {String? title, String? startTime, bool? regenerate});
}

class TeacherRemoteDataSourceImpl implements TeacherRemoteDataSource {
  final _dio = DioClient.getInstance();

  @override
  Future<UserModel> getProfile() async {
    try {
      final res = await _dio.get(ApiConstants.teacherProfile);
      final json = res.data['data'] ?? res.data;
      return UserModel.fromJson(json['user'] ?? json);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final res = await _dio.put(ApiConstants.teacherProfile, data: data);
      return UserModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<dynamic> _prepareData(Map<String, dynamic> data) async {
    final Map<String, dynamic> body = {};
    bool hasFile = false;

    data.forEach((key, value) {
      if (key == 'cover_image' || key == 'image' || key == 'lesson_material' || key == 'file') {
        if (value != null && value is String && value.isNotEmpty) {
          body[key] = MultipartFile.fromFileSync(value);
          hasFile = true;
        }
      } else if (key == 'files' || key == 'photos') {
        if (value != null && value is List) {
          body['files[]'] = value.map((path) => MultipartFile.fromFileSync(path.toString())).toList();
          hasFile = true;
        }
      } else {
        body[key] = value;
      }
    });

    if (hasFile) {
      return FormData.fromMap(body);
    }
    return body;
  }

  @override
  Future<TeacherDashboardModel> getDashboard() async {
    try {
      final res = await _dio.get(ApiConstants.teacherDashboard);
      return TeacherDashboardModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<PaginatedResponse<TeacherClassModel>> getClasses({int page = 1, int perPage = 15, String? status, int? subjectId, String? timeFilter}) async {
    try {
      final res = await _dio.get(
        ApiConstants.teacherClasses,
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (status != null) 'status': status,
          if (subjectId != null) 'subject_id': subjectId,
          if (timeFilter != null) 'time_filter': timeFilter,
        },
      );
      return PaginatedResponse.fromJson(res.data, TeacherClassModel.fromJson);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<TeacherClassModel> getClassDetails(int id) async {
    try {
      final res = await _dio.get(ApiConstants.teacherClassDetails(id));
      return TeacherClassModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<TeacherClassModel> createClass(Map<String, dynamic> data) async {
    try {
      final body = await _prepareData(data);
      final res = await _dio.post(ApiConstants.teacherClasses, 
        data: body,
        options: body is FormData ? Options(contentType: 'multipart/form-data') : null,
      );
      return TeacherClassModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<TeacherClassModel> updateClass(int id, Map<String, dynamic> data) async {
    try {
      final body = await _prepareData(data);
      final isFormData = body is FormData;
      
      Response res;
      if (isFormData) {
        (body as FormData).fields.add(const MapEntry('_method', 'PUT'));
        res = await _dio.post(
          ApiConstants.teacherClassDetails(id), 
          data: body,
          options: Options(contentType: 'multipart/form-data'),
        );
      } else {
        res = await _dio.put(
          ApiConstants.teacherClassDetails(id), 
          data: body,
        );
      }
      return TeacherClassModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteClass(int id) async {
    try {
      await _dio.delete(ApiConstants.teacherClassDetails(id));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> startClass(int id) async {
    try {
      await _dio.post(ApiConstants.teacherStartClass(id));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> finishClass(int id) async {
    try {
      await _dio.post(ApiConstants.teacherFinishClass(id));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> createClassSummary(int classId, String content, String materials) async {
    try {
      await _dio.post(
        ApiConstants.teacherClassSummary(classId),
        data: {
          'content': content,
          'materials': materials,
        },
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> uploadClassFile(int classId, String title, String description, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'file': await MultipartFile.fromFile(filePath),
      });
      await _dio.post(
        ApiConstants.teacherClassFiles(classId),
        data: formData,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<AttendanceModel>> getClassAttendance(int classId) async {
    try {
      final res = await _dio.get(ApiConstants.teacherClassAttendance(classId));
      final dynamic data = res.data;
      final List list = (data is Map) ? (data['data'] ?? []) : (data is List ? data : []);
      return list.map((json) => AttendanceModel.fromJson(json)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> markAttendance(int classId, List<Map<String, dynamic>> attendances) async {
    try {
      await _dio.post(
        ApiConstants.teacherClassAttendance(classId),
        data: {'attendances': attendances},
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<PaginatedResponse<AssignmentModel>> getClassAssignments(int classId, {int page = 1, int perPage = 15}) async {
    try {
      final res = await _dio.get(
        ApiConstants.teacherClassAssignments(classId),
        queryParameters: {'page': page, 'per_page': perPage},
      );
      return PaginatedResponse.fromJson(res.data, AssignmentModel.fromJson);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<AssignmentModel> createAssignment(int classId, Map<String, dynamic> data) async {
    try {
      final requestData = Map<String, dynamic>.from(data);
      requestData['class_id'] = classId;
      final body = await _prepareData(requestData);
      final res = await _dio.post(
        ApiConstants.teacherClassAssignments(classId), 
        data: body,
        options: body is FormData ? Options(contentType: 'multipart/form-data') : null,
      );
      return AssignmentModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<AssignmentModel> updateAssignment(int classId, int id, Map<String, dynamic> data) async {
    try {
      final body = await _prepareData(data);
      final isFormData = body is FormData;
      
      Response res;
      if (isFormData) {
        (body as FormData).fields.add(const MapEntry('_method', 'PUT'));
        res = await _dio.post(
          ApiConstants.teacherAssignmentDetails(id), 
          data: body,
          options: Options(contentType: 'multipart/form-data'),
        );
      } else {
        res = await _dio.put(
          ApiConstants.teacherAssignmentDetails(id), 
          data: body,
        );
      }
      return AssignmentModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteAssignment(int classId, int id) async {
    try {
      await _dio.delete(ApiConstants.teacherAssignmentDetails(id));
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<AssignmentModel> getAssignmentDetails(int classId, int id) async {
    try {
      final res = await _dio.get(ApiConstants.teacherAssignmentDetails(id));
      return AssignmentModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<SubmissionModel>> getAssignmentSubmissions(int classId, int id) async {
    try {
      final res = await _dio.get(ApiConstants.teacherAssignmentSubmissions(id));
      final dynamic data = res.data;
      final List list = (data is Map) ? (data['data'] ?? []) : (data is List ? data : []);
      return list.map((json) => SubmissionModel.fromJson(json)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> gradeSubmission(int classId, int assignmentId, int submissionId, double score, String? feedback) async {
    try {
      await _dio.post(
        ApiConstants.teacherGradeSubmission(assignmentId, submissionId),
        data: {
          'score': score,
          'feedback': feedback ?? '',
        },
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<SubjectModel>> getSubjects() async {
    try {
      final res = await _dio.get(ApiConstants.teacherSubjects);
      final dynamic data = res.data;
      final List list = (data is Map) ? (data['data'] ?? []) : (data is List ? data : []);
      return list.map((json) => SubjectModel.fromJson(json)).toList();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<ZoomMeetingModel> getZoomMeeting(int classId) async {
    try {
      final res = await _dio.get(ApiConstants.teacherClassZoom(classId));
      return ZoomMeetingModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<ZoomMeetingModel> createZoomMeeting(int classId, String title, String startTime) async {
    try {
      final res = await _dio.post(ApiConstants.teacherClassZoom(classId), data: {
        'title': title,
        'start_time': startTime,
      });
      return ZoomMeetingModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<ZoomMeetingModel> updateZoomMeeting(int classId, {String? title, String? startTime, bool? regenerate}) async {
    try {
      final res = await _dio.put(ApiConstants.teacherClassZoom(classId), data: {
        if (title != null) 'title': title,
        if (startTime != null) 'start_time': startTime,
        if (regenerate != null) 'regenerate': regenerate,
      });
      return ZoomMeetingModel.fromJson(res.data['data'] ?? res.data);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
