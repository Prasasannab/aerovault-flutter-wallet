import '../../domain/entities/concierge_agent.dart';

class ConciergeAgentModel extends ConciergeAgent {
  const ConciergeAgentModel({
    required super.id,
    required super.name,
    required super.title,
    required super.location,
    required super.avatarUrl,
    required super.isOnline,
    required super.responseTimeSla,
  });

  factory ConciergeAgentModel.fromJson(Map<String, dynamic> json) {
    return ConciergeAgentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      avatarUrl: json['avatar_url'] as String,
      isOnline: json['is_online'] as bool? ?? true,
      responseTimeSla: json['response_time_sla'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'location': location,
      'avatar_url': avatarUrl,
      'is_online': isOnline,
      'response_time_sla': responseTimeSla,
    };
  }
}
