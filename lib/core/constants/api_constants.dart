class ApiConstants {
  static const String baseUrl = "https://land-roof.com";

  // General
  static const String grades = "/api/grades";

  // Auth
  static const String login = "/api/auth/login";
  static const String loginAlternative = "/api/login"; // Fallback/Alternative based on Postman
  static const String register = "/api/auth/register";
  static const String teacherRegister = "/api/auth/teacher/register";
  static const String logout = "/api/auth/logout";
  static const String refresh = "/api/auth/refresh";
  static const String me = "/api/auth/me";
  static const String verifyOtp = "/api/auth/otp/verify";
  static const String resendOtp = "/api/auth/otp/resend";
  static const String passwordOtp = "/api/auth/password/otp";
  static const String passwordOtpVerify = "/api/auth/password/otp/verify";
  static const String passwordReset = "/api/auth/password/reset";

  // Student
  static const String studentDashboard = "/api/student/dashboard";
  static const String studentProfile = "/api/student/profile"; // GET to read, PUT to update
  static const String studentSubjects = "/api/student/subjects";
  static const String studentTeachers = "/api/student/teachers";
  static const String studentPlans = "/api/student/plans";
  static const String studentSubscriptions = "/api/student/subscriptions";
  static const String studentSubscriptionsSummary = "/api/student/subscriptions/summary";
  static const String studentBookings = "/api/student/bookings";
  static const String studentSessions = "/api/student/sessions";
  static const String studentSummaries = "/api/student/summaries";
  static const String studentFiles = "/api/student/files";
  static const String studentPayments = "/api/student/payments";
  static const String studentAssignments = "/api/student/assignments";
  static const String studentNotifications = "/api/student/notifications";
  static const String studentMarkAllNotificationsRead = "/api/student/notifications/mark-all-as-read";

  static String studentTeacherDetails(int id) => "/api/student/teachers/$id";
  static String studentSummaryDetails(int id) => "/api/student/summaries/$id";
  static String studentFileDetails(int id) => "/api/student/files/$id";
  static String studentAssignmentDetails(int id) => "/api/student/assignments/$id";
  static String studentSubmitAssignment(int id) => "/api/student/assignments/$id/submit";
  static String studentSubmissionDetails(int id) => "/api/student/submissions/$id";
  static String studentClassAssignments(int id) => "/api/student/classes/$id/assignments";
  static String studentClassBooking(int id) => "/api/student/classes/$id/book";
  static String studentClassCancel(int id) => "/api/student/classes/$id/cancel";
  static String studentClassEligibility(int id) => "/api/student/classes/$id/eligibility";
  static String studentNotificationRead(String id) => "/api/student/notifications/$id/read";
  static String studentNotificationDelete(String id) => "/api/student/notifications/$id";
  static String studentClassDetails(int id) => "/api/student/classes/$id";
  static String studentPlanCheckout(int id) => "/api/student/plans/$id/checkout";
  static String studentSubscriptionDetails(int id) => "/api/student/subscriptions/$id";
  static String studentPaymentDetails(int id) => "/api/student/payments/$id";

  // Teacher
  static const String teacherDashboard = "/api/teacher/dashboard";
  static const String teacherClasses = "/api/teacher/classes";
  static const String teacherProfile = "/api/teacher/profile";

  static String teacherClassDetails(int id) => "/api/teacher/classes/$id";
  static String teacherStartClass(int id) => "/api/teacher/classes/$id/start";
  static String teacherFinishClass(int id) => "/api/teacher/classes/$id/finish";
  static String teacherClassAttendance(int id) => "/api/teacher/classes/$id/attendance";
  static String teacherClassAssignments(int id) => "/api/teacher/classes/$id/assignments";
  static String teacherAssignmentDetails(int id) => "/api/teacher/assignments/$id";
  static String teacherAssignmentSubmissions(int id) => "/api/teacher/assignments/$id/submissions";
  static String teacherGradeSubmission(int assignmentId, int submissionId) => "/api/teacher/assignments/$assignmentId/submissions/$submissionId/review";
  static String teacherClassZoom(int id) => "/api/teacher/classes/$id/zoom";
  static String teacherClassSummary(int id) => "/api/teacher/classes/$id/summary";
  static String teacherClassFiles(int id) => "/api/teacher/classes/$id/files";
  static const String teacherSubjects = "/api/teacher/subjects";
}