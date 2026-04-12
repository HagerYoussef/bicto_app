class TeacherDashboardModel {
  final int totalClasses;
  final int todaysClasses;
  final int totalStudents;
  final dynamic attendanceAverage;
  final List<TeacherClassModel> classes;

  TeacherDashboardModel({
    required this.totalClasses,
    required this.todaysClasses,
    required this.totalStudents,
    this.attendanceAverage,
    required this.classes,
  });

  factory TeacherDashboardModel.fromJson(Map<String, dynamic> json) {
    // Handle case where json is a paginated response with 'data' as list
    if (json['data'] is List) {
      final List<dynamic> list = json['data'];
      return TeacherDashboardModel(
        totalClasses: json['total'] ?? json['meta']?['total'] ?? list.length,
        todaysClasses: list.length, // Fallback
        totalStudents: 0,
        classes: list.map((e) => TeacherClassModel.fromJson(e)).toList(),
      );
    }

    final data = json['data'] ?? json;
    
    // If it's a map but has no 'classes' key, and root has 'data' which is used above.
    // This part handles a specialized dashboard object
    return TeacherDashboardModel(
      totalClasses: int.tryParse(data['total_classes']?.toString() ?? '') ?? int.tryParse(data['total']?.toString() ?? '') ?? 0,
      todaysClasses: int.tryParse(data['todays_classes']?.toString() ?? '') ?? 0,
      totalStudents: int.tryParse(data['total_students']?.toString() ?? '') ?? 0,
      attendanceAverage: data['attendance_average'] ?? data['attendance_percentage'] ?? 0,
      classes: (data['classes'] as List? ?? [])
          .map((e) => TeacherClassModel.fromJson(e))
          .toList(),
    );
  }
}

class TeacherClassModel {
  final int id;
  final int? subjectId;
  final String title;
  final String? description;
  final String? subject;
  final String startTime;
  final String endTime;
  final String status;
  final int? maxStudents;
  final int? enrolledCount;
  final String? notes;
  final String? zoomMeetingUrl;
  final ZoomMeetingModel? zoomMeeting;
  final bool enableZoom;
  final String? coverUrl;
  final String? lessonMaterialUrl;
  final int? durationMinutes;
  final String? formattedDuration;

  TeacherClassModel({
    required this.id,
    this.subjectId,
    required this.title,
    this.description,
    this.subject,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.maxStudents,
    this.enrolledCount,
    this.notes,
    this.zoomMeetingUrl,
    this.zoomMeeting,
    this.enableZoom = true,
    this.coverUrl,
    this.lessonMaterialUrl,
    this.durationMinutes,
    this.formattedDuration,
  });

  factory TeacherClassModel.fromJson(Map<String, dynamic> json) {
    return TeacherClassModel(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      subjectId: json['subject_id'] is int ? json['subject_id'] : int.tryParse(json['subject_id']?.toString() ?? ''),
      title: json['title'] ?? '',
      description: json['description'],
      subject: json['subject'] is Map 
          ? (json['subject']['title'] ?? json['subject']['name']) 
          : (json['subject_name'] ?? json['subject']?.toString()),
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      status: json['status'] ?? 'scheduled',
      maxStudents: json['max_students'] is int ? json['max_students'] : int.tryParse(json['max_students']?.toString() ?? ''),
      enrolledCount: json['enrolled_count'] is int ? json['enrolled_count'] : (int.tryParse(json['enrolled_count']?.toString() ?? '') ?? json['attendances_count']),
      notes: json['notes'],
      zoomMeetingUrl: json['zoom_meeting_link'] ?? json['zoom_meeting_url'],
      zoomMeeting: json['zoom_meeting'] != null 
          ? ZoomMeetingModel.fromJson(json['zoom_meeting']) 
          : (json['meeting_id'] != null ? ZoomMeetingModel.fromJson(json) : null),
      enableZoom: json['enable_zoom'] == true || json['enable_zoom'] == 1 || json['zoom_meeting_link'] != null,
      coverUrl: json['cover_url'] ?? json['image_url'],
      lessonMaterialUrl: json['lesson_material_url'] ?? json['lesson_material'],
      durationMinutes: json['duration_minutes'] is int ? json['duration_minutes'] : int.tryParse(json['duration_minutes']?.toString() ?? ''),
      formattedDuration: json['formatted_duration'],
    );
  }

  bool get canEditOrDelete {
    final s = status.toLowerCase();
    // Allow edit/delete if it's still scheduled or was cancelled. 
    // We only prevent it once it has "started" or is "finished".
    return s == 'scheduled' || s == 'cancelled';
  }

  bool get isOngoing {
    final s = status.toLowerCase();
    return s == 'started' || s == 'active' || s == 'ongoing';
  }

  bool get isFinished {
    final s = status.toLowerCase();
    return s == 'finished' || s == 'completed';
  }

  bool get isScheduled {
    return status.toLowerCase() == 'scheduled';
  }

  bool get canStart => isScheduled;
  bool get canFinish => isOngoing;
}


class AttendanceModel {
  final int studentId;
  final String studentName;
  final String status; // attended, missed, cancelled
  final String? notes;

  AttendanceModel({
    required this.studentId,
    required this.studentName,
    required this.status,
    this.notes,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] ?? {};
    return AttendanceModel(
      studentId: json['student_id'] is int 
          ? json['student_id'] 
          : (int.tryParse(json['student_id']?.toString() ?? '') ?? (student['id'] is int ? student['id'] : (int.tryParse(student['id']?.toString() ?? '') ?? 0))),
      studentName: student['full_name'] ?? student['name'] ?? json['student_name'] ?? '',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
    );
  }
}

class ZoomMeetingModel {
  final int id;
  final String title;
  final String startTime;
  final String? startUrl;
  final String joinUrl;
  final String? meetingId;
  final String? meetingPassword;

  ZoomMeetingModel({
    required this.id,
    required this.title,
    required this.startTime,
    this.startUrl,
    required this.joinUrl,
    this.meetingId,
    this.meetingPassword,
  });

  factory ZoomMeetingModel.fromJson(Map<String, dynamic> json) {
    return ZoomMeetingModel(
      id: json['id'] is int 
          ? json['id'] 
          : (int.tryParse(json['id']?.toString() ?? '') ?? 0),
      title: json['title'] ?? '',
      startTime: json['start_time'] ?? '',
      startUrl: json['start_url'] ?? json['zoom_meeting_link'],
      joinUrl: json['join_url'] ?? json['zoom_meeting_link'] ?? '',
      meetingId: json['meeting_id']?.toString(),
      meetingPassword: json['meeting_password']?.toString(),
    );
  }
}
