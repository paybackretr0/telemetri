class CalendarEvent {
  final String summary;
  final Reminders reminders;
  final Creator creator;
  final String kind;
  final String htmlLink;
  final String created;
  final String iCalUID;
  final EventDateTime start;
  final String description;
  final String eventType;
  final int sequence;
  final Organizer organizer;
  final String etag;
  final String location;
  final EventDateTime end;
  final String id;
  final String updated;
  final String status;

  CalendarEvent({
    required this.summary,
    required this.reminders,
    required this.creator,
    required this.kind,
    required this.htmlLink,
    required this.created,
    required this.iCalUID,
    required this.start,
    required this.description,
    required this.eventType,
    required this.sequence,
    required this.organizer,
    required this.etag,
    required this.location,
    required this.end,
    required this.id,
    required this.updated,
    required this.status,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      summary: json['summary'] ?? '',
      reminders: Reminders.fromJson(json['reminders'] ?? {'useDefault': true}),
      creator: Creator.fromJson(
        json['creator'] ?? {'self': false, 'email': ''},
      ),
      kind: json['kind'] ?? '',
      htmlLink: json['htmlLink'] ?? '',
      created: json['created'] ?? '',
      iCalUID: json['iCalUID'] ?? '',
      start: EventDateTime.fromJson(
        json['start'] ?? {'dateTime': '', 'timeZone': ''},
      ),
      description: json['description'] ?? '',
      eventType: json['eventType'] ?? 'default',
      sequence: json['sequence'] ?? 0,
      organizer: Organizer.fromJson(
        json['organizer'] ?? {'self': false, 'email': ''},
      ),
      etag: json['etag'] ?? '',
      location: json['location'] ?? '',
      end: EventDateTime.fromJson(
        json['end'] ?? {'dateTime': '', 'timeZone': ''},
      ),
      id: json['id'] ?? '',
      updated: json['updated'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'reminders': reminders.toJson(),
      'creator': creator.toJson(),
      'kind': kind,
      'htmlLink': htmlLink,
      'created': created,
      'iCalUID': iCalUID,
      'start': start.toJson(),
      'description': description,
      'eventType': eventType,
      'sequence': sequence,
      'organizer': organizer.toJson(),
      'etag': etag,
      'location': location,
      'end': end.toJson(),
      'id': id,
      'updated': updated,
      'status': status,
    };
  }
}

class Reminders {
  final bool useDefault;

  Reminders({required this.useDefault});

  factory Reminders.fromJson(Map<String, dynamic> json) {
    return Reminders(useDefault: json['useDefault'] ?? true);
  }

  Map<String, dynamic> toJson() {
    return {'useDefault': useDefault};
  }
}

class Creator {
  final bool self;
  final String email;

  Creator({required this.self, required this.email});

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(self: json['self'] ?? false, email: json['email'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'self': self, 'email': email};
  }
}

class Organizer {
  final bool self;
  final String email;

  Organizer({required this.self, required this.email});

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(self: json['self'] ?? false, email: json['email'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'self': self, 'email': email};
  }
}

class EventDateTime {
  final String dateTime;
  final String timeZone;

  EventDateTime({required this.dateTime, required this.timeZone});

  factory EventDateTime.fromJson(Map<String, dynamic> json) {
    return EventDateTime(
      dateTime: json['dateTime'] ?? '',
      timeZone: json['timeZone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'dateTime': dateTime, 'timeZone': timeZone};
  }
}

class CalendarResponse {
  final bool success;
  final List<CalendarEvent> events;

  CalendarResponse({required this.success, required this.events});

  factory CalendarResponse.fromJson(Map<String, dynamic> json) {
    List<CalendarEvent> eventsList = [];
    if (json['events'] != null) {
      eventsList =
          (json['events'] as List)
              .map((event) => CalendarEvent.fromJson(event))
              .toList();
    }

    return CalendarResponse(
      success: json['success'] ?? false,
      events: eventsList,
    );
  }
}
