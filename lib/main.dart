import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme.dart';
import 'core/services/storage_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/pages/landing_screen.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/student/data/datasources/student_remote_datasource.dart';
import 'features/student/data/repositories/student_repository_impl.dart';
import 'features/student/presentation/viewmodels/student_dashboard_viewmodel.dart';
import 'features/student/presentation/viewmodels/student_viewmodels.dart';
import 'features/teacher/data/datasources/teacher_remote_datasource.dart';
import 'features/teacher/data/repositories/teacher_repository_impl.dart';
import 'features/teacher/presentation/viewmodels/teacher_viewmodel.dart';
import 'features/teacher/data/models/teacher_models.dart';
import 'features/auth/presentation/pages/role_selection_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/student_signup.dart';
import 'features/auth/presentation/pages/teacher_signup.dart';
import 'features/auth/presentation/pages/forgot_password_flow.dart';
import 'features/auth/presentation/pages/email_verification_screen.dart';
import 'features/student/presentation/pages/student_main_nav.dart';
import 'features/student/presentation/pages/student_dashboard.dart';
import 'features/student/presentation/pages/subscriptions_screen.dart';
import 'features/student/presentation/pages/packages_screen.dart';
import 'features/student/presentation/pages/teachers_list_screen.dart';
import 'features/student/presentation/pages/bookings_screen.dart';
import 'features/student/presentation/pages/summaries_screen.dart';
import 'features/student/presentation/pages/class_details_screen.dart';
import 'features/student/presentation/pages/payments_screen.dart';
import 'features/student/presentation/pages/profile_screen.dart';
import 'features/teacher/presentation/pages/teacher_profile_screen.dart';
import 'features/student/presentation/pages/assignments_screen.dart';
import 'features/student/presentation/pages/submission_details_screen.dart';
import 'features/teacher/presentation/pages/teacher_dashboard.dart';
import 'features/teacher/presentation/pages/classes_screen.dart';
import 'features/teacher/presentation/pages/add_class_screen.dart';
import 'features/teacher/presentation/pages/attendance_screen.dart';
import 'features/teacher/presentation/pages/assignment_list_screen.dart';
import 'features/teacher/presentation/pages/add_assignment_screen.dart';
import 'features/teacher/presentation/pages/students_screen.dart';
import 'features/teacher/presentation/pages/reports_screen.dart';
import 'features/teacher/presentation/pages/settings_screen.dart';
import 'features/teacher/presentation/pages/submissions_list_screen.dart';
import 'features/teacher/presentation/pages/grade_submission_screen.dart';
import 'features/teacher/presentation/pages/teacher_class_details_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await StorageService.getInstance();
  final authDataSource = AuthRemoteDataSourceImpl();
  final authRepo = AuthRepositoryImpl(authDataSource, storage);

  final studentDataSource = StudentRemoteDataSourceImpl();
  final studentRepo = StudentRepositoryImpl(studentDataSource);

  final teacherDataSource = TeacherRemoteDataSourceImpl();
  final teacherRepo = TeacherRepositoryImpl(teacherDataSource);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(authRepo)),
        ChangeNotifierProvider(create: (_) => StudentDashboardViewModel(studentRepo)),
        ChangeNotifierProvider(create: (_) => BookingsViewModel(studentRepo)),
        ChangeNotifierProvider(create: (_) => PaymentsViewModel(studentRepo)),
        ChangeNotifierProvider(create: (_) => SummariesViewModel(studentRepo)),
        ChangeNotifierProvider(create: (_) => SubscriptionsViewModel(studentRepo)),
        ChangeNotifierProvider(create: (_) => TeachersViewModel(studentRepo)),
        ChangeNotifierProvider(create: (_) => AssignmentsViewModel(studentRepo)),
        ChangeNotifierProvider(create: (_) => ClassDetailsViewModel(studentRepo)),
        ChangeNotifierProvider(create: (_) => SubjectsViewModel(studentRepo)),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel(studentRepo)),
        ChangeNotifierProvider(create: (_) => PlansViewModel(studentRepo)),
        ChangeNotifierProvider(create: (_) => StudentProfileViewModel(studentRepo)),
        ChangeNotifierProvider(create: (_) => TeacherViewModel(teacherRepo)),
        ChangeNotifierProvider(create: (_) => TeacherClassesViewModel(teacherRepo)),
        ChangeNotifierProvider(create: (_) => TeacherAttendanceViewModel(teacherRepo)),
      ],
      child: EduApp(storage: storage),
    ),
  );
}

class EduApp extends StatelessWidget {
  final StorageService storage;
  const EduApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Educational Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LandingScreen());
          case '/login':
            final role = settings.arguments as String? ?? 'student';
            return MaterialPageRoute(builder: (_) => LoginScreen(role: role));
          case '/student-signup':
            return MaterialPageRoute(builder: (_) => const StudentSignUpScreen());
          case '/teacher-signup':
            return MaterialPageRoute(builder: (_) => const TeacherSignUpScreen());
          case '/forgot-password':
            return MaterialPageRoute(builder: (_) => const ForgotPasswordFlow());
          case '/email-verification':
            final role = settings.arguments as String? ?? 'student';
            return MaterialPageRoute(builder: (_) => EmailVerificationScreen(role: role));
          case '/student-main':
          case '/student-dashboard':
          case '/subscriptions':
          case '/packages':
          case '/teachers-list':
          case '/bookings':
          case '/summaries':
          case '/assignments':
          case '/payments':
          case '/profile':
          case '/class-details':
          case '/submission-details':
            return MaterialPageRoute(builder: (_) {
              return Consumer<AuthViewModel>(
                builder: (context, authVm, _) {
                  if (authVm.currentUser?.role == 'teacher' && settings.name != '/profile' && settings.name != '/submission-details') {
                    return const TeacherDashboard();
                  }
                  final args = settings.arguments;
                  switch (settings.name) {
                    case '/student-main': return const StudentMainNav();
                    case '/student-dashboard': return const StudentDashboard();
                    case '/subscriptions': return const SubscriptionsScreen();
                    case '/packages': return const PackagesScreen();
                    case '/teachers-list': return const TeachersListScreen();
                    case '/bookings': return const BookingsScreen();
                    case '/summaries': return const SummariesScreen();
                    case '/class-details': 
                      if (args is Map) {
                        return ClassDetailsScreen(
                          classId: args['classId'] ?? 0,
                          initialData: args['initialData'],
                        );
                      }
                      return ClassDetailsScreen(classId: args is int ? args : 0);
                    case '/assignments': 
                      return AssignmentsScreen(
                        classId: args is int ? args : (args is Map ? args['classId'] : null),
                      );
                    case '/submission-details':
                      final mArgs = args as Map<String, dynamic>;
                      return SubmissionDetailsScreen(
                        submissionId: mArgs['submissionId'],
                        assignmentTitle: mArgs['assignmentTitle'],
                      );
                    case '/payments': return const PaymentsScreen();
                    case '/profile': 
                      if (authVm.currentUser?.role == 'teacher') {
                        return const TeacherProfileScreen();
                      }
                      return const StudentProfileScreen();
                    default: return const StudentMainNav();
                  }
                },
              );
            });
          case '/teacher-dashboard':
          case '/teacher-classes':
          case '/add-class':
          case '/edit-class':
          case '/teacher-students':
          case '/teacher-reports':
          case '/teacher-settings':
            return MaterialPageRoute(builder: (_) {
              return Consumer<AuthViewModel>(
                builder: (context, authVm, _) {
                  if (authVm.currentUser?.role == 'student') {
                    return const StudentMainNav();
                  }
                  switch (settings.name) {
                    case '/teacher-dashboard': return const TeacherDashboard();
                    case '/teacher-classes': return const ClassesScreen();
                    case '/add-class': return const AddClassScreen();
                    case '/teacher-students': return const TeacherStudentsScreen();
                    case '/teacher-reports': return const TeacherReportsScreen();
                    case '/teacher-settings': return const TeacherSettingsScreen();
                    case '/edit-class':
                      final cls = settings.arguments as TeacherClassModel;
                      return AddClassScreen(editClass: cls);
                    case '/teacher/class-details':
                      return TeacherClassDetailsScreen(classModel: settings.arguments as TeacherClassModel);
                    default: return const TeacherDashboard();
                  }
                },
              );
            });
          case '/teacher/attendance':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AttendanceScreen(
                classId: args['classId'],
                classTitle: args['classTitle'],
              ),
            );
          case '/teacher/assignments':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AssignmentListScreen(
                classId: args['classId'],
                classTitle: args['classTitle'],
              ),
            );
          case '/teacher/add-assignment':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AddAssignmentScreen(
                classId: args['classId'],
                editAssignment: args['assignment'],
              ),
            );
          case '/teacher/assignment-submissions':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => SubmissionsListScreen(
                classId: args['classId'],
                assignment: args['assignment'],
              ),
            );
          case '/teacher/grade-submission':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => GradeSubmissionScreen(
                classId: args['classId'],
                assignment: args['assignment'],
                submission: args['submission'],
                viewModel: args['viewModel'],
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Center(child: Text('Page not found'))),
            );
        }
      },
    );
  }
}
