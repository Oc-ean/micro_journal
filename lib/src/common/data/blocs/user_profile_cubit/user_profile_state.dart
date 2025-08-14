part of 'user_profile_cubit.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileLoaded extends UserProfileState {
  final UserModel user;

  const UserProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserProfileError extends UserProfileState {
  final String message;

  const UserProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}

class UserProfileUpdating extends UserProfileState {
  final UserModel currentUser;

  const UserProfileUpdating({required this.currentUser});

  @override
  List<Object?> get props => [currentUser];
}
