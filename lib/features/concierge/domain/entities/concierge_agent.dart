import 'package:equatable/equatable.dart';

class ConciergeAgent extends Equatable {
  final String id;
  final String name;
  final String title;
  final String location;
  final String avatarUrl;
  final bool isOnline;
  final String responseTimeSla;

  const ConciergeAgent({
    required this.id,
    required this.name,
    required this.title,
    required this.location,
    required this.avatarUrl,
    required this.isOnline,
    required this.responseTimeSla,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        title,
        location,
        avatarUrl,
        isOnline,
        responseTimeSla,
      ];
}
