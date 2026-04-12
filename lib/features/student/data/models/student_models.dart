import 'package:flutter/foundation.dart';
import '../../../teacher/data/models/teacher_models.dart';

class StudentDashboardModel {
  final int totalBookings;
  final int attendedClasses;
  final int upcomingClasses;
  final int remainingClasses;
  final List<RecentActivityModel> recentActivity;

  StudentDashboardModel({
    required this.totalBookings,
    required this.attendedClasses,
    required this.upcomingClasses,
    required this.remainingClasses,
    required this.recentActivity,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final stats = data['stats'] ?? {};
    return StudentDashboardModel(
      totalBookings: stats['total_bookings'] ?? 0,
      attendedClasses: stats['attended_classes'] ?? 0,
      upcomingClasses: stats['upcoming_classes'] ?? 0,
      remainingClasses: stats['remaining_classes'] ?? 0,
      recentActivity: (data['recent_bookings'] as List? ?? data['recent_activity'] as List? ?? [])
          .map((e) => RecentActivityModel.fromJson(e))
          .toList(),
    );
  }
}

class RecentActivityModel {
  final int id;
  final String title;
  final String description;
  final String createdAt;
  final String type;

  RecentActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.type,
  });

  factory RecentActivityModel.fromJson(Map<String, dynamic> json) {
    return RecentActivityModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
      type: json['type'] ?? '',
    );
  }
}

class BookingModel {
  final int id;
  final String classTitle;
  final int classId;
  final String teacherName;
  final String? teacherAvatar;
  final String startTime;
  final String endTime;
  final String status;
  final String classStatus;
  final String? meetingUrl;
  final String? lessonMaterialUrl;
  final String? description;

  BookingModel({
    required this.id,
    required this.classTitle,
    required this.classId,
    required this.teacherName,
    this.teacherAvatar,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.classStatus,
    this.meetingUrl,
    this.lessonMaterialUrl,
    this.description,
  });

  bool get isUpcoming => status == 'scheduled' || status == 'pending';

  bool get canJoin {
    if (meetingUrl == null || meetingUrl!.isEmpty) return false;
    
    // Check class status first - if it's finished or cancelled, student can't join
    final clsS = classStatus.toLowerCase();
    if (clsS == 'completed' || clsS == 'finished' || clsS == 'cancelled') return false;
    
    if (status == 'ongoing') return true;
    
    try {
      final start = DateTime.parse(startTime);
      final now = DateTime.now();
      // Show link if it is 10 minutes or less to start
      return now.isAfter(start.subtract(const Duration(minutes: 10)));
    } catch (_) {
      return false;
    }
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // If it's a detail response, 'json' might be the class itself
    // If it's a booking list, 'json' has a 'class' key
    final cls = json['class'] ?? json;
    final teacher = cls['teacher'] ?? json['teacher'] ?? {};
    return BookingModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      classId: int.tryParse(cls['id']?.toString() ?? '') ?? int.tryParse(json['class_id']?.toString() ?? '') ?? 0,
      classTitle: cls['title'] ?? json['class_title'] ?? '',
      teacherName: teacher['name'] ?? teacher['full_name'] ?? '',
      teacherAvatar: teacher['avatar_url'],
      startTime: cls['start_time'] ?? json['start_time'] ?? '',
      endTime: cls['end_time'] ?? json['end_time'] ?? '',
      status: json['status'] ?? 'pending',
      classStatus: cls['status'] ?? json['status'] ?? 'pending',
      meetingUrl: cls['zoom_meeting_url'] ??
          cls['zoom_meeting_link'] ??
          cls['meeting_url'] ??
          json['zoom_meeting_url'] ??
          json['zoom_meeting_link'] ??
          json['meeting_url'] ??
          (cls['zoom_meeting'] is Map ? cls['zoom_meeting']['join_url'] : null),
      lessonMaterialUrl: cls['lesson_material_url'] ?? cls['lesson_material'] ?? json['lesson_material_url'] ?? json['lesson_material'],
      description: cls['description'] ?? cls['notes'] ?? json['description'] ?? json['notes'],
    );
  }

  factory BookingModel.fromTeacherClass(TeacherClassModel cls, TeacherModel teacher) {
    return BookingModel(
      id: cls.id,
      classId: cls.id,
      classTitle: cls.title,
      teacherName: teacher.name,
      teacherAvatar: teacher.avatarUrl,
      startTime: cls.startTime,
      endTime: cls.endTime,
      status: 'pending', // Default for preview
      classStatus: cls.status,
      description: cls.description ?? cls.notes, // Fallback to notes if description is null
      meetingUrl: cls.zoomMeetingUrl ?? cls.zoomMeeting?.joinUrl,
      lessonMaterialUrl: cls.lessonMaterialUrl,
    );
  }
}

class SubscriptionModel {
  final int id;
  final String planName;
  final String teacherName;
  final String status;
  final String expiryDate;
  final int sessionsRemaining;
  final int totalSessions;

  SubscriptionModel({
    required this.id,
    required this.planName,
    required this.teacherName,
    required this.status,
    required this.expiryDate,
    required this.sessionsRemaining,
    required this.totalSessions,
  });

  bool get isExpired => status == 'expired';
  bool get isWarning => sessionsRemaining <= 1 && !isExpired;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] ?? {};
    final teacher = json['teacher'] ?? {};
    return SubscriptionModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      planName: plan['title'] ?? plan['name'] ?? json['plan_name'] ?? '',
      teacherName: teacher['name'] ?? teacher['full_name'] ?? '',
      status: json['status'] ?? 'active',
      expiryDate: json['expires_at'] ?? json['expiry_date'] ?? '',
      sessionsRemaining: int.tryParse(json['sessions_remaining']?.toString() ?? '') ?? 0,
      totalSessions: int.tryParse(json['total_sessions']?.toString() ?? '') ?? 0,
    );
  }
}

class PaymentModel {
  final int id;
  final int studentId;
  final int? planId;
  final String amount;
  final String status;
  final String? paymentMethod;
  final String? paymentPurpose;
  final String? transactionId;
  final String createdAt;
  final PlanModel? plan;

  PaymentModel({
    required this.id,
    required this.studentId,
    this.planId,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.paymentPurpose,
    this.transactionId,
    required this.createdAt,
    this.plan,
  });

  String get description => paymentPurpose ?? 'Payment';

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      studentId: int.tryParse(json['student_id']?.toString() ?? '') ?? 0,
      planId: json['plan_id'],
      amount: json['amount']?.toString() ?? '0',
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      paymentPurpose: json['payment_purpose'],
      transactionId: json['transaction_id'],
      createdAt: json['created_at'] ?? '',
      plan: json['plan'] != null ? PlanModel.fromJson(json['plan']) : null,
    );
  }
}

class SummaryModel {
  final int id;
  final String classTitle;
  final String teacherName;
  final String sessionDate;
  final String? content;
  final List<String> fileUrls;

  SummaryModel({
    required this.id,
    required this.classTitle,
    required this.teacherName,
    required this.sessionDate,
    this.content,
    required this.fileUrls,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    try {
      final cls = json['class'] ?? json['session'] ?? {};
      final teacher = cls['teacher'] ?? json['teacher'] ?? {};
      return SummaryModel(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        classTitle: cls['title'] ?? json['class_title'] ?? json['session_title'] ?? '',
        teacherName: teacher['name'] ?? teacher['full_name'] ?? '',
        sessionDate: json['session_date'] ?? json['date'] ?? json['created_at'] ?? '',
        content: json['content'] ?? json['summary'] ?? json['notes'],
        fileUrls: (json['files'] as List? ?? json['attachments'] as List? ?? [])
            .map((f) => f is Map ? (f['url']?.toString() ?? f['file_url']?.toString() ?? '') : f.toString())
            .toList(),
      );
    } catch (e) {
      debugPrint('SummaryModel.fromJson: Error parsing summary: $e | JSON: $json');
      rethrow;
    }
  }
}

class AssignmentModel {
  final int id;
  final int? classId;
  final String title;
  final String description;
  final String dueDate;
  final int maxScore;
  final String status;
  final List<String> fileUrls;
  final SubmissionModel? submission;

  AssignmentModel({
    required this.id,
    this.classId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.maxScore,
    required this.status,
    required this.fileUrls,
    this.submission,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      classId: int.tryParse(json['class_id']?.toString() ?? '') ?? int.tryParse(json['session_id']?.toString() ?? ''),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['due_date'] ?? '',
      maxScore: int.tryParse(json['max_score']?.toString() ?? '') ?? 100,
      status: json['status'] ?? 'active',
      fileUrls: (json['files'] as List? ?? json['attachments'] as List? ?? [])
          .map((f) => f is Map ? (f['url']?.toString() ?? f['file_url']?.toString() ?? '') : f.toString())
          .toList(),
      submission: json['submission'] != null
          ? SubmissionModel.fromJson(json['submission'])
          : null,
    );
  }
}

class SubmissionModel {
  final int id;
  final String? content;
  final int? score;
  final String submittedAt;
  final String createdAt;
  final List<String> fileUrls;
  final String studentName;
  final String? status;
  final String? feedback;

  SubmissionModel({
    required this.id,
    this.content,
    this.score,
    required this.submittedAt,
    required this.createdAt,
    required this.fileUrls,
    this.studentName = '',
    this.status,
    this.feedback,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map ? json['user'] : null;
    return SubmissionModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      content: json['content'],
      score: json['score'] != null ? int.tryParse(json['score'].toString()) : null,
      submittedAt: json['submitted_at'] ?? json['created_at'] ?? '',
      createdAt: json['created_at'] ?? json['submitted_at'] ?? '',
      fileUrls: (json['files'] as List? ?? [])
          .map((f) => (f is Map ? f['url'] : f)?.toString() ?? '')
          .where((url) => url.isNotEmpty)
          .toList(),
      studentName: json['student_name'] ?? user?['name'] ?? '',
      status: json['status'],
      feedback: json['feedback'],
    );
  }
}

class TeacherModel {
  final int id;
  final String name;
  final String? avatarUrl;
  final String? subject;
  final String? bio;
  final double rating;
  final int reviewCount;
  final List<TeacherClassModel> classes;
  final List<int> bookedClassIds;

  TeacherModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.subject,
    this.bio,
    required this.rating,
    required this.reviewCount,
    this.classes = const [],
    this.bookedClassIds = const [],
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final teacherData = data['teacher'] ?? data;
    final List<int> bookedIds = (data['booked_class_ids'] as List?)
            ?.map((e) => int.tryParse(e.toString()) ?? 0)
            .where((id) => id != 0)
            .toList() ??
        [];

    return TeacherModel(
      id: int.tryParse(teacherData['id']?.toString() ?? '') ?? 0,
      name: teacherData['name'] ?? teacherData['full_name'] ?? teacherData['display_name'] ?? '',
      avatarUrl: teacherData['avatar_url'],
      subject: teacherData['subject']?.toString(),
      bio: teacherData['bio'],
      rating: double.tryParse(teacherData['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(teacherData['review_count']?.toString() ?? '') ?? 0,
      classes: (teacherData['classes'] as List? ?? [])
          .map((e) => TeacherClassModel.fromJson(e))
          .toList(),
      bookedClassIds: bookedIds,
    );
  }
}


class SubjectModel {
  final int id;
  final String title;
  final String? description;
  final String? status;
  final String? iconClass;
  final String? colorClass;
  final String? imageUrl;

  SubjectModel({
    required this.id,
    required this.title,
    this.description,
    this.status,
    this.iconClass,
    this.colorClass,
    this.imageUrl,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'],
      status: json['status'],
      iconClass: json['icon_class'],
      colorClass: json['color_class'],
      imageUrl: json['image_url'] ?? json['image'],
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? (json['data'] is Map ? json['data']['message'] : json['data']?.toString() ?? ''),
      type: json['type'] ?? 'info',
      isRead: json['read_at'] != null || json['is_read'] == true,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class PlanModel {
  final int id;
  final String title;
  final String? description;
  final double price;
  final String? formattedPrice;
  final String? typeLabel;
  final int? classLimit;
  final String? status;

  PlanModel({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.formattedPrice,
    this.typeLabel,
    this.classLimit,
    this.status,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'],
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      formattedPrice: json['formatted_price'],
      typeLabel: json['type_label'],
      classLimit: int.tryParse(json['class_limit']?.toString() ?? '') ?? int.tryParse(json['session_count']?.toString() ?? '') ?? int.tryParse(json['sessions']?.toString() ?? ''),
      status: json['status'],
    );
  }
}

class SubscriptionSummaryModel {
  final int totalSubscriptions;
  final int totalRemainingClasses;
  final bool hasUnlimited;

  SubscriptionSummaryModel({
    required this.totalSubscriptions,
    required this.totalRemainingClasses,
    required this.hasUnlimited,
  });

  factory SubscriptionSummaryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return SubscriptionSummaryModel(
      totalSubscriptions: data['total_subscriptions'] ?? 0,
      totalRemainingClasses: data['total_remaining_classes'] ?? 0,
      hasUnlimited: data['has_unlimited'] ?? false,
    );
  }
}

class SessionModel {
  final int id;
  final String classTitle;
  final String teacherName;
  final String date;
  final String status;

  SessionModel({
    required this.id,
    required this.classTitle,
    required this.teacherName,
    required this.date,
    required this.status,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    final cls = json['class'] ?? {};
    final teacher = cls['teacher'] ?? json['teacher'] ?? {};
    return SessionModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      classTitle: cls['title'] ?? json['class_title'] ?? '',
      teacherName: teacher['name'] ?? teacher['full_name'] ?? '',
      date: json['attended_at'] ?? json['date'] ?? '',
      status: json['status'] ?? 'attended',
    );
  }
}

class FileModel {
  final int id;
  final String name;
  final String url;
  final String type;
  final String? size;
  final String createdAt;

  FileModel({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    this.size,
    required this.createdAt,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? json['title'] ?? 'File',
      url: json['url'] ?? '',
      type: json['type'] ?? 'document',
      size: json['size'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
