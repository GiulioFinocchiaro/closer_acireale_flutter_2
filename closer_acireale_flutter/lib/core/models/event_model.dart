class Event {
  final int id;
  final String eventName;
  final String eventDescription;
  final String? eventDate;
  final String? location;
  final String? link;

  Event({
    required this.id,
    required this.eventName,
    required this.eventDescription,
    this.eventDate,
    this.location,
    this.link,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      eventName: json['event_name'] ?? json['name'] ?? '',
      eventDescription: json['event_description'] ?? json['description'] ?? '',
      eventDate: json['event_date'],
      location: json['location'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'event_name': eventName,
      'event_description': eventDescription,
    };

    if (eventDate != null) data['event_date'] = eventDate;
    if (location != null) data['location'] = location;
    if (link != null) data['link'] = link;

    return data;
  }
}