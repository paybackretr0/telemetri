import 'user_model.dart';
import 'activity_model.dart';

class Permission {
  final int id;
  final int userId;
  final int activityId;
  final String reason;
  final String? attachment;
  final String status;
  final int? approvedBy;
  final String? approvedAt;
  final String createdAt;
  final String updatedAt;
  final User? user;
  final Activity? activity;
  final User? approver;

  Permission({
    required this.id,
    required this.userId,
    required this.activityId,
    required this.reason,
    this.attachment,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.activity,
    this.approver,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return 0;
        }
      }
      return 0;
    }

    try {
      return Permission(
        id: parseId(json['id']),
        userId: parseId(json['user_id']),
        activityId: parseId(json['activity_id']),
        reason: json['reason'] ?? '',
        attachment: json['attachment'],
        status: json['status'] ?? 'pending',
        approvedBy:
            json['approved_by'] != null ? parseId(json['approved_by']) : null,
        approvedAt: json['approved_at'],
        createdAt: json['created_at'] ?? '',
        updatedAt: json['updated_at'] ?? '',
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        activity:
            json['activity'] != null
                ? Activity.fromJson(json['activity'])
                : null,
        approver:
            json['approver'] != null ? User.fromJson(json['approver']) : null,
      );
    } catch (e) {
      return Permission(
        id: 0,
        userId: 0,
        activityId: 0,
        reason: 'Error parsing permission',
        status: 'error',
        createdAt: '',
        updatedAt: '',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'activity_id': activityId,
      'reason': reason,
      'attachment': attachment,
      'status': status,
      'approved_by': approvedBy,
      'approved_at': approvedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }
}
