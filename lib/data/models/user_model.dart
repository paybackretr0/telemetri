class User {
  final int id;
  final String name;
  final String email;
  final String? profilePicture;
  final String? phoneNumber;
  final String? googleId;
  final String? nim;
  final String? jurusan;
  final String? nomorSeri;
  final String? jabatan;
  final String? divisi;
  final String? subDivisi;
  final String role;
  final List<DutySchedule>? dutySchedules;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.phoneNumber,
    this.googleId,
    this.nim,
    this.jurusan,
    this.nomorSeri,
    this.jabatan,
    this.divisi,
    this.subDivisi,
    required this.role,
    this.dutySchedules,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<DutySchedule>? dutySchedules;

    if (json['duty_schedules'] != null) {
      dutySchedules = List<DutySchedule>.from(
        json['duty_schedules'].map(
          (schedule) => DutySchedule.fromJson(schedule),
        ),
      );
    }

    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profile_picture'],
      phoneNumber: json['phone_number'],
      googleId: json['google_id'],
      nim: json['nim'],
      jurusan: json['jurusan'],
      nomorSeri: json['nomor_seri'],
      jabatan: json['jabatan'],
      divisi: json['divisi'],
      subDivisi: json['sub_divisi'],
      role: json['role'] ?? '',
      dutySchedules: dutySchedules,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture': profilePicture,
      'phone_number': phoneNumber,
      'google_id': googleId,
      'nim': nim,
      'jurusan': jurusan,
      'nomor_seri': nomorSeri,
      'jabatan': jabatan,
      'divisi': divisi,
      'sub_divisi': subDivisi,
      'role': role,
      'duty_schedules':
          dutySchedules?.map((schedule) => schedule.toJson()).toList(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? profilePicture,
    String? phoneNumber,
    String? googleId,
    String? nim,
    String? jurusan,
    String? nomorSeri,
    String? jabatan,
    String? divisi,
    String? subDivisi,
    String? role,
    List<DutySchedule>? dutySchedules,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      googleId: googleId ?? this.googleId,
      nim: nim ?? this.nim,
      jurusan: jurusan ?? this.jurusan,
      nomorSeri: nomorSeri ?? this.nomorSeri,
      jabatan: jabatan ?? this.jabatan,
      divisi: divisi ?? this.divisi,
      subDivisi: subDivisi ?? this.subDivisi,
      role: role ?? this.role,
      dutySchedules: dutySchedules ?? this.dutySchedules,
    );
  }
}

class DutySchedule {
  final int id;
  final String dayOfWeek;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final dynamic pivot;

  DutySchedule({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.pivot,
  });

  factory DutySchedule.fromJson(Map<String, dynamic> json) {
    return DutySchedule(
      id: json['id'],
      dayOfWeek: json['day_of_week'] ?? '',
      startTime:
          json['start_time'] != null
              ? DateTime.parse(json['start_time'])
              : DateTime.now(),
      endTime:
          json['end_time'] != null
              ? DateTime.parse(json['end_time'])
              : DateTime.now(),
      location: json['location'] ?? '',
      pivot: json['pivot'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day_of_week': dayOfWeek,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'pivot': pivot,
    };
  }
}
