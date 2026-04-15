class UserProfile {
  final String fullName;

  const UserProfile({
    required this.fullName,
  });

  UserProfile copyWith({
    String? fullName,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
    );
  }

  static const empty = UserProfile(
    fullName: '',
  );

  @override
  String toString() {
    if (this == UserProfile.empty) {
      return 'UserProfile: empty';
    }
    return 'UserProfile(fullName: $fullName)';
  }
}