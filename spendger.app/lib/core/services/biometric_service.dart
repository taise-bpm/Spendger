import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static bool isAppLocked = false;
  static bool cachedBiometricEnabled = false;

  static bool get isBiometricEnabled => cachedBiometricEnabled;

  static Future<bool> canAuthenticate() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      final canAuth = await canAuthenticate();
      if (!canAuth) return true; // If not available on hardware, bypass gracefully

      return await _auth.authenticate(
        localizedReason: 'Please authenticate with Biometrics or Device PIN to open Spendger',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException {
      return true; // Fallback gracefully in case of platform issues on desktop/dev
    }
  }
}
