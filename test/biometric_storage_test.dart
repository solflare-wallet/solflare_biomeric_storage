import 'package:biometric_storage/src/biometric_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel = MethodChannel('biometric_storage');

  TestWidgetsFlutterBinding.ensureInitialized();

  /// Value returned by the mocked native `canAuthenticate` call.
  var nativeResponse = 'ErrorUnknown';

  setUp(() {
    nativeResponse = 'ErrorUnknown';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'canAuthenticate') {
        return nativeResponse;
      }
      throw PlatformException(code: 'NotImplemented');
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('canAuthenticate', () async {
    final result = await BiometricStorage().canAuthenticate();
    expect(result, CanAuthenticateResponse.unsupported);
  });

  group('canAuthenticate response mapping', () {
    const expected = <String, CanAuthenticateResponse>{
      'Success': CanAuthenticateResponse.success,
      'ErrorHwUnavailable': CanAuthenticateResponse.errorHwUnavailable,
      'ErrorNoBiometricEnrolled':
          CanAuthenticateResponse.errorNoBiometricEnrolled,
      'ErrorNoHardware': CanAuthenticateResponse.errorNoHardware,
      'ErrorPasscodeNotSet': CanAuthenticateResponse.errorPasscodeNotSet,
      'ErrorLockout': CanAuthenticateResponse.errorLockout,
      'ErrorSecurityUpdateRequired':
          CanAuthenticateResponse.errorSecurityUpdateRequired,
      'ErrorIdentityCheckNotActive':
          CanAuthenticateResponse.errorIdentityCheckNotActive,
      'ErrorNotEnabledForApps': CanAuthenticateResponse.errorNotEnabledForApps,
      'ErrorUnsupported': CanAuthenticateResponse.unsupported,
      'ErrorUnknown': CanAuthenticateResponse.unsupported,
      'ErrorStatusUnknown': CanAuthenticateResponse.statusUnknown,
    };

    for (final entry in expected.entries) {
      test('maps ${entry.key} to ${entry.value}', () async {
        nativeResponse = entry.key;
        expect(await BiometricStorage().canAuthenticate(), entry.value);
      });
    }

    /// Android 16 (API 36) returns `BIOMETRIC_ERROR_NOT_ENABLED_FOR_APPS` (21).
    /// Before this fix the native side threw, and the dart side threw a
    /// `StateError` for any name it did not know.
    /// https://github.com/authpass/biometric_storage/issues/148
    test('does not throw for a response name it does not know', () async {
      nativeResponse = 'ErrorFromAFutureAndroidRelease';
      expect(
        await BiometricStorage().canAuthenticate(),
        CanAuthenticateResponse.statusUnknown,
      );
    });
  });
}
