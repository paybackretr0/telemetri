class History {
  final String id;
  final String type;
  final String title;
  final DateTime date;
  final String status;
  final String? checkInTime;
  final String? checkOutTime;
  final String activityType;
  final DateTime createdAt;

  History({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.status,
    this.checkInTime,
    this.checkOutTime,
    required this.activityType,
    required this.createdAt,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['id'].toString(),
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      status: json['status'] ?? '',
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      activityType: json['activity_type'] ?? '',
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'date': date,
      'checkIn': checkInTime,
      'checkOut': checkOutTime,
      'status': status,
    };
  }
}

class HistoryResponse {
  final bool success;
  final String message;
  final HistoryData? data;

  HistoryResponse({required this.success, required this.message, this.data});

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    return HistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? HistoryData.fromJson(json['data']) : null,
    );
  }
}

class HistoryData {
  final int currentPage;
  final List<History> data;
  final int from;
  final int lastPage;
  final int perPage;
  final int to;
  final int total;

  HistoryData({
    required this.currentPage,
    required this.data,
    required this.from,
    required this.lastPage,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory HistoryData.fromJson(Map<String, dynamic> json) {
    List<History> historyList = [];
    if (json['data'] != null) {
      historyList = List<History>.from(
        (json['data'] as List).map((item) => History.fromJson(item)),
      );
    }

    return HistoryData(
      currentPage: json['current_page'] ?? 1,
      data: historyList,
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}
