import '../../../../core/models/paginated_response.dart';
import '../../../student/data/models/student_models.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../datasources/teacher_remote_datasource.dart';
import '../models/teacher_models.dart';
import '../../../auth/data/models/user_model.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource _dataSource;

  TeacherRepositoryImpl(this._dataSource);

  @override
  Future<UserModel> getProfile() => _dataSource.getProfile();

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) => _dataSource.updateProfile(data);

  @override
  Future<TeacherDashboardModel> getDashboard() => _dataSource.getDashboard();

  @override
  Future<List<SubjectModel>> getSubjects() => _dataSource.getSubjects();

  @override
  Future<PaginatedResponse<TeacherClassModel>> getClasses({
    int page = 1, 
    int perPage = 15, 
    String? status, 
    int? subjectId, 
    String? timeFilter,
  }) => _dataSource.getClasses(
    page: page, 
    perPage: perPage, 
    status: status, 
    subjectId: subjectId, 
    timeFilter: timeFilter,
  );

  @override
  Future<TeacherClassModel> createClass(Map<String, dynamic> data) =>
      _dataSource.createClass(data);

  @override
  Future<TeacherClassModel> getClassDetails(int id) =>
      _dataSource.getClassDetails(id);

  @override
  Future<TeacherClassModel> updateClass(int id, Map<String, dynamic> data) =>
      _dataSource.updateClass(id, data);

  @override
  Future<void> deleteClass(int id) => _dataSource.deleteClass(id);

  @override
  Future<void> startClass(int id) => _dataSource.startClass(id);

  @override
  Future<void> finishClass(int id) => _dataSource.finishClass(id);

  @override
  Future<void> createClassSummary(int classId, String content, String materials) =>
      _dataSource.createClassSummary(classId, content, materials);

  @override
  Future<void> uploadClassFile(int classId, String title, String description, String filePath) =>
      _dataSource.uploadClassFile(classId, title, description, filePath);

  @override
  Future<List<AttendanceModel>> getClassAttendance(int id) =>
      _dataSource.getClassAttendance(id);

  @override
  Future<void> markAttendance(int id, List<Map<String, dynamic>> attendances) =>
      _dataSource.markAttendance(id, attendances);

  @override
  Future<PaginatedResponse<AssignmentModel>> getClassAssignments(int classId, {int page = 1, int perPage = 15}) =>
      _dataSource.getClassAssignments(classId, page: page, perPage: perPage);

  @override
  Future<AssignmentModel> createAssignment(int classId, Map<String, dynamic> data) =>
      _dataSource.createAssignment(classId, data);

  @override
  Future<AssignmentModel> updateAssignment(int classId, int id, Map<String, dynamic> data) =>
      _dataSource.updateAssignment(classId, id, data);

  @override
  Future<void> deleteAssignment(int classId, int id) => _dataSource.deleteAssignment(classId, id);

  @override
  Future<AssignmentModel> getAssignmentDetails(int classId, int id) =>
      _dataSource.getAssignmentDetails(classId, id);

  @override
  Future<List<SubmissionModel>> getAssignmentSubmissions(int classId, int assignmentId) =>
      _dataSource.getAssignmentSubmissions(classId, assignmentId);

  @override
  Future<void> gradeSubmission(int classId, int assignmentId, int submissionId, double score, String? feedback) =>
      _dataSource.gradeSubmission(classId, assignmentId, submissionId, score, feedback);

  @override
  Future<ZoomMeetingModel> getZoomMeeting(int classId) =>
      _dataSource.getZoomMeeting(classId);

  @override
  Future<ZoomMeetingModel> createZoomMeeting(int classId, String title, String startTime) =>
      _dataSource.createZoomMeeting(classId, title, startTime);

  @override
  Future<ZoomMeetingModel> updateZoomMeeting(int classId, {String? title, String? startTime, bool? regenerate}) =>
      _dataSource.updateZoomMeeting(classId, title: title, startTime: startTime, regenerate: regenerate);
}
