import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });

  static const empty = AppUser(uid: '');

  factory AppUser.fromFirebaseUser(User? firebaseAppUser) {
    if (firebaseAppUser == null) {
      return AppUser.empty;
    }
    return AppUser(
      uid: firebaseAppUser.uid,
      email: firebaseAppUser.email,
      displayName: firebaseAppUser.displayName,
      photoURL: firebaseAppUser.photoURL,
    );
  }

  @override
  String toString() {
    if (this == AppUser.empty) {
      return 'AppUser: empty';
    }
    return 'AppUser(uid: $uid, email: $email, displayName: $displayName, photoURL: $photoURL)';
  }
}