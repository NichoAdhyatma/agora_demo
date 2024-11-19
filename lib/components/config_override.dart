// Fill in the app ID obtained from the Agora Console
const appId = "9904937daa4b4dea818b3ff574e5d5be";
// Fill in the temporary token generated from Agora Console
const token = "007eJxTYNDKWM7rWKqz6755wy8LI6/zJc+zZswXyOsOl2nkmTe5zF6BwdLSwMTS2DwlMdEkySQlNdHC0CLJOC3N1Nwk1TTFNClVTN8mvSGQkcG4PYKFkQECQXxWhqTUpMRiBgYAvk4c+A==";
// Fill in the channel name you used to generate the token
const channel = "bebas";


/// Key of APP ID
const keyAppId = 'TEST_APP_ID';

/// Key of Channel ID
const keyChannelId = 'TEST_CHANNEL_ID';

/// Key of token
const keyToken = 'TEST_TOKEN';

ExampleConfigOverride? _gConfigOverride;

/// This class allow override the config(appId/channelId/token) in the example.
class ExampleConfigOverride {
  ExampleConfigOverride._();

  factory ExampleConfigOverride() {
    _gConfigOverride = _gConfigOverride ?? ExampleConfigOverride._();
    return _gConfigOverride!;
  }
  final Map<String, String> _overridedConfig = {};

  /// Get the expected APP ID
  String getAppId() {
    return _overridedConfig[keyAppId] ??
        // Allow pass an `appId` as an environment variable with name `TEST_APP_ID` by using --dart-define
        const String.fromEnvironment(keyAppId, defaultValue: appId);
  }

  /// Get the expected Channel ID
  String getChannelId() {
    return _overridedConfig[keyChannelId] ??
        // Allow pass a `token` as an environment variable with name `TEST_TOKEN` by using --dart-define
        const String.fromEnvironment(keyChannelId,
            defaultValue: channel);
  }

  /// Get the expected Token
  String getToken() {
    return _overridedConfig[keyToken] ??
        // Allow pass a `channelId` as an environment variable with name `TEST_CHANNEL_ID` by using --dart-define
        const String.fromEnvironment(keyToken, defaultValue: token);
  }

  /// Override the config(appId/channelId/token)
  void set(String name, String value) {
    _overridedConfig[name] = value;
  }

  /// Internal testing flag
  bool get isInternalTesting =>
      const bool.fromEnvironment('INTERNAL_TESTING', defaultValue: false);
}