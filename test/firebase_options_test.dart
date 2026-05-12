import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/firebase_options.dart';

void main() {
  group('DefaultFirebaseOptions', () {
    test('returns android options when platform is android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(DefaultFirebaseOptions.currentPlatform, DefaultFirebaseOptions.android);
      debugDefaultTargetPlatformOverride = null;
    });

    test('returns ios options when platform is ios', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(DefaultFirebaseOptions.currentPlatform, DefaultFirebaseOptions.ios);
      debugDefaultTargetPlatformOverride = null;
    });

    test('returns windows options when platform is windows', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(DefaultFirebaseOptions.currentPlatform, DefaultFirebaseOptions.windows);
      debugDefaultTargetPlatformOverride = null;
    });

    test('throws UnsupportedError for macOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(() => DefaultFirebaseOptions.currentPlatform, throwsUnsupportedError);
      debugDefaultTargetPlatformOverride = null;
    });

    test('throws UnsupportedError for linux', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(() => DefaultFirebaseOptions.currentPlatform, throwsUnsupportedError);
      debugDefaultTargetPlatformOverride = null;
    });

    test('throws UnsupportedError for fuchsia', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      expect(() => DefaultFirebaseOptions.currentPlatform, throwsUnsupportedError);
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
