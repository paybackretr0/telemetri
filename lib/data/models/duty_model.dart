import 'user_model.dart';

class Duty {
  final int id;
  final String dayOfWeek;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String createdAt;
  final String updatedAt;
  final List<User>? users;

  Duty({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    this.users,
  });

  factory Duty.fromJson(Map<String, dynamic> json) {
    List<User>? usersList;
    if (json['users'] != null) {
      usersList =
          (json['users'] as List)
              .map((userJson) => User.fromJson(userJson))
              .toList();
    }

    return Duty(
      id: json['id'],
      dayOfWeek: json['day_of_week'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      location: json['location'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      users: usersList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_of_week': dayOfWeek,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'users': users?.map((user) => user.id).toList(),
    };
  }
}
