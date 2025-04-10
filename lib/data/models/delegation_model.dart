import 'package:telemetri/data/models/user_model.dart';
import 'package:telemetri/data/models/duty_model.dart';

class Delegation {
  final int id;
  final int requesterId;
  final int delegateId;
  final int dutyScheduleId;
  final DateTime delegationDate;
  final String reason;
  final String status;
  final int? approvedBy;
  final DateTime? approvedAt;
  final String createdAt;
  final String updatedAt;
  final User? requester;
  final User? delegate;
  final Duty? dutySchedule;
  final User? approver;
  final String? attachment;

  Delegation({
    required this.id,
    required this.requesterId,
    required this.delegateId,
    required this.dutyScheduleId,
    required this.delegationDate,
    required this.reason,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.requester,
    this.delegate,
    this.dutySchedule,
    this.approver,
    this.attachment,
  });

  factory Delegation.fromJson(Map<String, dynamic> json) {
    return Delegation(
      id: json['id'],
      requesterId: json['requester_id'],
      delegateId: json['delegate_id'],
      dutyScheduleId: json['duty_schedule_id'],
      delegationDate: DateTime.parse(json['delegation_date']),
      reason: json['reason'],
      status: json['status'],
      approvedBy: json['approved_by'],
      approvedAt:
          json['approved_at'] != null
              ? DateTime.parse(json['approved_at'])
              : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      requester:
          json['requester'] != null ? User.fromJson(json['requester']) : null,
      delegate:
          json['delegate'] != null ? User.fromJson(json['delegate']) : null,
      dutySchedule:
          json['duty_schedule'] != null
              ? Duty.fromJson(json['duty_schedule'])
              : null,
      approver:
          json['approver'] != null ? User.fromJson(json['approver']) : null,
      attachment: json['attachment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester_id': requesterId,
      'delegate_id': delegateId,
      'duty_schedule_id': dutyScheduleId,
      'delegation_date': delegationDate.toIso8601String(),
      'reason': reason,
      'status': status,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'approver_id': approver?.id,
    };
  }
}
