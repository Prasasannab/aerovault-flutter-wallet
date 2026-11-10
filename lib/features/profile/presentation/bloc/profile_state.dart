import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final String? feedbackMessage;

  const ProfileLoaded({
    required this.profile,
    this.feedbackMessage,
  });

  ProfileLoaded copyWith({
    UserProfile? profile,
    String? feedbackMessage,
  }) {
    return ProfileLoaded(
      profile: profile ?? this.profile,
      feedbackMessage: feedbackMessage,
    );
  }

  @override
  List<Object?> get props => [profile, feedbackMessage];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
