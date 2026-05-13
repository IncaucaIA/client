/// Test credentials loaded from dart-defines at compile time.
/// These are injected via --dart-define-from-file=.env.e2e.*
class E2EConfig {
  static const testEmail = String.fromEnvironment(
    'E2E_TEST_EMAIL',
    defaultValue: 'test@sivia.local',
  );
  static const testPassword = String.fromEnvironment(
    'E2E_TEST_PASSWORD',
    defaultValue: 'test123',
  );
}
