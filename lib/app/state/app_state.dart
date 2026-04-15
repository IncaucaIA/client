part of 'app_bloc.dart';

final class AppState extends Equatable {
  const AppState({
    this.user = AppUser.empty,
    this.profile = UserProfile.empty,
  });

  final AppUser user;
  final UserProfile profile;

  @override
  List<Object?> get props => [user, profile];

  AppState copyWith({
    AppUser? user,
    UserProfile? profile,
  }) {
    return AppState(
      user: user ?? this.user,
      profile: profile ?? this.profile,
    );
  }
}