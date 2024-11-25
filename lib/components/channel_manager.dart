import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:dio/dio.dart';

class TokenResponse {
  final String token;

  TokenResponse.fromJson(Map<String, dynamic> json)
      : token = json['data'] as String;
}

/// Handles token fetching and channel management operations
class ChannelManager {
  final String hostUrl;
  final RtcEngine _engine;
  final Dio _dio;

  ChannelManager({
    required this.hostUrl,
    required RtcEngine engine,
  })  : _engine = engine,
        _dio = Dio(
          BaseOptions(
            baseUrl: hostUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

  /// Fetches token and optionally joins the channel
  ///
  /// [channelName] - Name of the channel to join or renew token for
  /// [needJoinChannel] - Whether to join channel after fetching token
  Future<void> handleTokenAndChannel({
    required String channelName,
    required bool needJoinChannel,
  }) async {
    try {
      final token = await _fetchToken(channelName);
      await _handleChannelOperation(token, channelName, needJoinChannel);
    } on DioException catch (e) {
      throw ChannelException(_handleDioError(e));
    }
  }

  /// Fetches token from the server
  Future<String> _fetchToken(String channelName) async {
    try {
      final response = await _dio.post(
        '', // Empty string since baseUrl is set
        data: {'channel_name': channelName},
      );

      return TokenResponse.fromJson(response.data).token;
    } on DioException catch (e) {
      throw ChannelException(_handleDioError(e));
    }
  }

  /// Handles different types of Dio errors
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Server is taking too long to respond.';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode ?? "Unknown"} - ${error.response?.statusMessage ?? ""}';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      default:
        return 'Network error: ${error.message}';
    }
  }

  /// Handles channel join or token renewal
  Future<void> _handleChannelOperation(
    String token,
    String channelName,
    bool needJoinChannel,
  ) async {
    if (needJoinChannel) {
      await _joinChannel(token, channelName);
    } else {
      await _engine.renewToken(token);
    }
  }

  /// Joins a channel with the given token
  Future<void> _joinChannel(String token, String channelName) async {
    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}

/// Custom exception for channel-related errors
class ChannelException implements Exception {
  final String message;

  ChannelException(this.message);

  @override
  String toString() => 'ChannelException: $message';
}
