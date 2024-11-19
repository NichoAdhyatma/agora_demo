import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_sdk_example/config/agora.config.dart' as config;

// Application class
class BasicVoiceExample extends StatefulWidget {
  const BasicVoiceExample({super.key});

  @override
  _BasicVoiceExampleState createState() => _BasicVoiceExampleState();
}

// Application state class
class _BasicVoiceExampleState extends State<BasicVoiceExample> {
  int? _remoteUid;
  bool _localUserJoined = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  // Initialize
  Future<void> initAgora() async {
    // Get permission
    await [Permission.microphone].request();

    // Create an RtcEngine instance
    _engine = createAgoraRtcEngine();

    // Initialize RtcEngine and set the channel profile
    await _engine.initialize(RtcEngineContext(
      appId: config.appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    // Handle engine events
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('local user ${connection.localUid} joined');
          setState(() {
            _localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

    // Join a channel using a temporary token and channel name
    await _engine.joinChannel(
      token: config.token,
      channelId: config.channelId,
      options: const ChannelMediaOptions(
        // Automatically subscribe to all audio streams
          autoSubscribeAudio: true,
          // Publish microphone audio
          publishMicrophoneTrack: true,
          // Set user role to clientRoleBroadcaster (broadcaster) or clientRoleAudience (audience)
          clientRoleType: ClientRoleType.clientRoleBroadcaster),
      uid: 0, // When you set uid to 0, a user name is randomly generated by the engine
    );
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel(); // Leave the channel
    await _engine.release(); // Release resources
  }

  // Build the UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agora Voice Call',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Agora Voice Call'),
        ),
        body: const Center(
          child: Text('Have a voice call!'),
        ),
      ),
    );
  }
}