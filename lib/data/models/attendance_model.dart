class AttendanceResponse {
  final bool success;
  final String message;
  final Attendance? data;

  AttendanceResponse({required this.success, required this.message, this.data});

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? Attendance.fromJson(json['data']) : null,
    );
  }
}

class Attendance {
  final int id;
  final int userId;
  final String? activityType;
  final int? activityId;
  final int? meetingId;
  final String status;
  final String? checkInTime;
  final String? checkOutTime;
  final String? checkInLocation;
  final String? checkOutLocation;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final int? verifiedBy;

  Attendance({
    required this.id,
    required this.userId,
    this.activityType,
    this.activityId,
    this.meetingId,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    this.checkInLocation,
    this.checkOutLocation,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.verifiedBy,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      activityType: json['activity_type'],
      activityId: json['activity_id'],
      meetingId: json['meeting_id'],
      status: json['status'] ?? '',
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      checkInLocation: json['check_in_location'],
      checkOutLocation: json['check_out_location'],
      checkInLatitude:
          json['check_in_latitude'] != null
              ? double.tryParse(json['check_in_latitude'].toString())
              : null,
      checkInLongitude:
          json['check_in_longitude'] != null
              ? double.tryParse(json['check_in_longitude'].toString())
              : null,
      checkOutLatitude:
          json['check_out_latitude'] != null
              ? double.tryParse(json['check_out_latitude'].toString())
              : null,
      checkOutLongitude:
          json['check_out_longitude'] != null
              ? double.tryParse(json['check_out_longitude'].toString())
              : null,
      verifiedBy: json['verified_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'activity_type': activityType,
      'activity_id': activityId,
      'meeting_id': meetingId,
      'status': status,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'check_in_location': checkInLocation,
      'check_out_location': checkOutLocation,
      'check_in_latitude': checkInLatitude,
      'check_in_longitude': checkInLongitude,
      'check_out_latitude': checkOutLatitude,
      'check_out_longitude': checkOutLongitude,
      'verified_by': verifiedBy,
    };
  }
}
