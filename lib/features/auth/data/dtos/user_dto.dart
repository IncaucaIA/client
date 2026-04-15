import 'package:incauca_labs/features/auth/domain/entities/user_profile.dart';

class UserDTO {
  final String id;
  final String fullName;

  const UserDTO({
    required this.id,
    required this.fullName,
  });

  factory UserDTO.fromMap(Map<String, dynamic> map, {required String id}) {

    return UserDTO(
      id: id,
      fullName: map['fullName'] ?? '',
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'fullName': fullName,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
    };
  }

  UserProfile toDomain() {
    return UserProfile(
      fullName: fullName,
    );
  }

  factory UserDTO.fromDomain(
    UserProfile profile, {
    required String id,
    required String email,
  }) {
    return UserDTO(
      id: id,
      fullName: profile.fullName,
    );
  }

}