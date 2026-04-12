import '../../data/models/user_model.dart';
import '../../../student/data/models/student_models.dart';

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final int? educationalLevel;
  final String password;
  final String passwordConfirmation;
  final String? bio;
  final String? cvPath;
  final String? birthday;
  final String role;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    this.educationalLevel,
    required this.password,
    required this.passwordConfirmation,
    this.bio,
    this.cvPath,
    this.birthday,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone': phone,
    'gender': gender,
    if (educationalLevel != null) ...{
      'educational_level': educationalLevel,
      'grade_id': educationalLevel,
    },
    'password': password,
    'password_confirmation': passwordConfirmation,
    'role': role,
    if (bio != null) 'bio': bio,
    if (birthday != null) 'birthday': birthday,
  };
}

class AuthResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle 'data' wrapped response structure
    Map<String, dynamic> actualJson = json;
    if (json.containsKey('data') && json['data'] is Map) {
      actualJson = Map<String, dynamic>.from(json['data']);
    }

    // Extract user data: could be under 'user' key or flat in 'actualJson'
    Map<String, dynamic> userJson;
    if (actualJson.containsKey('user') && actualJson['user'] is Map) {
      userJson = Map<String, dynamic>.from(actualJson['user']);
    } else {
      userJson = Map<String, dynamic>.from(actualJson);
    }

    if (actualJson.containsKey('role') && !userJson.containsKey('role')) {
      userJson['role'] = actualJson['role'];
    }
    
    return AuthResponse(
      accessToken: actualJson['access_token'] ?? '',
      tokenType: actualJson['token_type'] ?? 'bearer',
      expiresIn: int.tryParse(actualJson['expires_in']?.toString() ?? '') ?? 3600,
      user: UserModel.fromJson(userJson),
    );
  }
}


class GradeModel {
  final int id;
  final String title;
  final int stageId;
  final String? stageName;
  final String? status;
  final List<SubjectModel> subjects;

  GradeModel({
    required this.id, 
    required this.title, 
    required this.stageId,
    this.stageName,
    this.status,
    this.subjects = const [],
  });

  String get displayName => title;


  factory GradeModel.fromJson(Map<String, dynamic> json) {
    final stage = json['stage'];
    return GradeModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      stageId: int.tryParse(json['stage_id']?.toString() ?? '') ?? 0,
      stageName: stage is Map ? (stage['name'] ?? stage['title']) : (json['stage_name'] ?? json['stage']?.toString()),
      status: json['status'],
      subjects: (json['subjects'] as List? ?? [])
          .map((e) => SubjectModel.fromJson(e))
          .toList(),
    );
  }
}

class StageModel {
  final int id;
  final String name;

  StageModel({required this.id, required this.name});

  factory StageModel.fromJson(Map<String, dynamic> json) {
    return StageModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? json['title'] ?? '',
    );
  }

  factory StageModel.fromId(int id) {
    String stageName = '';
    switch (id) {
      case 1:
        stageName = 'المرحلة الابتدائية';
        break;
      case 2:
        stageName = 'المرحله الاعداديه';
        break;
      case 3:
        stageName = 'المرحله الثانويه';
        break;
      default:
        stageName = 'مرحلة تعليمية ($id)';
    }
    return StageModel(id: id, name: stageName);
  }
}
