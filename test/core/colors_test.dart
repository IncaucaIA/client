import 'package:flutter_test/flutter_test.dart';
import 'package:incauca_labs/core/colors.dart';
import 'package:flutter/material.dart';

void main() {
  group('AppColors', () {
    test('constants should be correct', () {
      expect(AppColors.primary, const Color(0xFF103080));
      expect(AppColors.accent, const Color(0xFFFCCE07));
      expect(AppColors.secondary, const Color(0xFF009540));
      expect(AppColors.tertiary, const Color(0xFF0065B3));
      expect(AppColors.success, const Color(0xFF009540));
      expect(AppColors.warning, const Color(0xFFFCCE07));
      expect(AppColors.background, const Color(0xFFF4F6F9));
      expect(AppColors.dark, const Color(0xFF0A1E45));

      // Instantiate to cover the constructor
      final instance = AppColors();
      expect(instance, isNotNull);
    });
  });
}
