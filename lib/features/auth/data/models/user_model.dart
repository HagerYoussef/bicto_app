import 'auth_models.dart';

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? gender;
  final String role;
  final String? avatarUrl;
  final bool isVerified;
  final String? bio;
  final int? educationalLevel;
  
  // Student specific
  final String? stage;
  final int? gradeId;
  final String? gradeTitle;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.gender,
    required this.role,
    this.avatarUrl,
    required this.isVerified,
    this.bio,
    this.educationalLevel,
    this.stage,
    this.gradeId,
    this.gradeTitle,
  });

  String get fullName => '$firstName $lastName';

  String get formattedEducationalLevel {
    if (role == 'teacher' && educationalLevel != null) {
      return StageModel.fromId(educationalLevel!).name;
    }
    return gradeTitle ?? '—';
  }


  factory UserModel.fromJson(Map<String, dynamic> json) {
    final studentProfile = json['student_profile'] ?? {};
    final grade = studentProfile['grade'] ?? {};
    
    // Improved role detection
    String? rawRole = json['role']?.toString();
    String roleValue = (rawRole != null && rawRole.isNotEmpty && rawRole != 'null') ? rawRole : 'student';
    
    if (roleValue == 'student') {
       // If role is student or null, check for teacher-specific fields to infer role
       if (json['educational_level'] != null || 
           json['bio'] != null || 
           (json['cv'] != null && json['cv'].toString().isNotEmpty) ||
           json['teacher_profile'] != null) {
         roleValue = 'teacher';
       }
    }
    
    final status = json['status']?.toString() ?? 'pending';
    
    return UserModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      firstName: json['first_name'] ?? json['full_name']?.split(' ').first ?? '',
      lastName: json['last_name'] ?? (
          (json['full_name']?.split(' ').length ?? 0) > 1 
          ? json['full_name'].split(' ').last 
          : ''
      ),
      email: json['email'] ?? '',
      phone: json['phone']?.toString(),
      gender: json['gender'],
      role: roleValue,
      avatarUrl: json['avatar_url'],
      isVerified: status == 'active' || (json['is_verified'] == true) || (json['is_verified']?.toString() == '1'),
      bio: json['bio'],
      educationalLevel: json['educational_level'] != null ? int.tryParse(json['educational_level'].toString()) : null,
      stage: studentProfile['stage'],
      gradeId: grade['id'] != null ? int.tryParse(grade['id'].toString()) : null,
      gradeTitle: grade['title'],
    );
  }

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone': phone,
    'gender': gender,
  };
}
