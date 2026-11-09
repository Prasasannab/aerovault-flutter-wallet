import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnalyticsEvent extends AnalyticsEvent {
  final String timeframe;
  const LoadAnalyticsEvent({this.timeframe = '1M'});

  @override
  List<Object?> get props => [timeframe];
}

class ChangeTimeframeEvent extends AnalyticsEvent {
  final String timeframe;
  const ChangeTimeframeEvent(this.timeframe);

  @override
  List<Object?> get props => [timeframe];
}
