import '../../../../core/models/paginated_response.dart';
import '../../../student/data/models/student_models.dart';
import '../../data/models/teacher_models.dart';
import '../../../auth/data/models/user_model.dart';

abstract class TeacherRepository {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<TeacherDashboardModel> getDashboard();
  Future<List<SubjectModel>> getSubjects();
  Future<PaginatedResponse<TeacherClassModel>> getClasses({int page, int perPage, String? status, int? subjectId, String? timeFilter});
  Future<TeacherClassModel> createClass(Map<String, dynamic> data);
  Future<TeacherClassModel> getClassDetails(int id);
  Future<TeacherClassModel> updateClass(int id, Map<String, dynamic> data);
  Future<void> deleteClass(int id);
  Future<void> startClass(int id);
  Future<void> finishClass(int id);
  Future<void> createClassSummary(int classId, String content, String materials);
  Future<void> uploadClassFile(int classId, String title, String description, String filePath);
  Future<List<AttendanceModel>> getClassAttendance(int id);
  Future<void> markAttendance(int id, List<Map<String, dynamic>> attendances);
  
  // Assignments
  Future<PaginatedResponse<AssignmentModel>> getClassAssignments(int classId, {int page, int perPage});
  Future<AssignmentModel> createAssignment(int classId, Map<String, dynamic> data);
  Future<AssignmentModel> updateAssignment(int classId, int id, Map<String, dynamic> data);
  Future<void> deleteAssignment(int classId, int id);
  Future<AssignmentModel> getAssignmentDetails(int classId, int id);
  Future<List<SubmissionModel>> getAssignmentSubmissions(int classId, int assignmentId);
  Future<void> gradeSubmission(int classId, int assignmentId, int submissionId, double score, String? feedback);
  
  // Zoom
  Future<ZoomMeetingModel> getZoomMeeting(int classId);
  Future<ZoomMeetingModel> createZoomMeeting(int classId, String title, String startTime);
  Future<ZoomMeetingModel> updateZoomMeeting(int classId, {String? title, String? startTime, bool? regenerate});
}
