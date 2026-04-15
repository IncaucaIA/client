class UserInitialRegistrationInputDTO {
  final bool isActive;
  final DateTime createdAt;

  UserInitialRegistrationInputDTO()
      : isActive = true,
        createdAt = DateTime.now().toUtc();

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}