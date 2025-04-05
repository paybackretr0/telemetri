class Activity {
  final int id;
  final String title;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final DateTime startTime;
  final DateTime endTime;
  final String qrCode;
  final int attendanceTypeId;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    required this.endTime,
    required this.qrCode,
    required this.attendanceTypeId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getter untuk kompatibilitas dengan dropdown (mereferensikan .name)
  String get name => title;

  factory Activity.fromJson(Map<String, dynamic> json) {
    try {
      return Activity(
        id: json['id'] is String ? int.parse(json['id']) : (json['id'] ?? 0),
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        location: json['location'] ?? '',
        latitude:
            (json['latitude'] is num)
                ? (json['latitude'] as num).toDouble()
                : 0.0,
        longitude:
            (json['longitude'] is num)
                ? (json['longitude'] as num).toDouble()
                : 0.0,
        startTime:
            json['start_time'] != null
                ? DateTime.parse(json['start_time'])
                : DateTime.now(),
        endTime:
            json['end_time'] != null
                ? DateTime.parse(json['end_time'])
                : DateTime.now(),
        qrCode: json['qr_code'] ?? '',
        attendanceTypeId:
            json['attendance_type_id'] is String
                ? int.parse(json['attendance_type_id'])
                : (json['attendance_type_id'] ?? 0),
        createdBy:
            json['created_by'] is String
                ? int.parse(json['created_by'])
                : (json['created_by'] ?? 0),
        createdAt:
            json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : DateTime.now(),
        updatedAt:
            json['updated_at'] != null
                ? DateTime.parse(json['updated_at'])
                : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing Activity from JSON: $e');
      print('Problematic JSON: $json');
      // Return a default Activity object in case of parsing error
      return Activity(
        id: 0,
        title: 'Error parsing activity',
        description: 'Could not parse activity data',
        location: '',
        latitude: 0.0,
        longitude: 0.0,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        qrCode: '',
        attendanceTypeId: 0,
        createdBy: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'qr_code': qrCode,
      'attendance_type_id': attendanceTypeId,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
