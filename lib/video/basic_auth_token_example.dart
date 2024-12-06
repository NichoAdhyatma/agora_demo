import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_sdk_example/components/channel_manager.dart';
import 'package:agora_sdk_example/models/user_agora.dart';
import 'package:agora_sdk_example/video/prejoin_page.dart';
import 'package:agora_sdk_example/widgets/video/video_view.dart';
import 'package:flutter/material.dart';
import 'package:agora_sdk_example/config/agora.config.dart' as config;
import 'package:permission_handler/permission_handler.dart';

/// This widget is the root of your application.
class BasicAuthTokenExample extends StatelessWidget {
  /// Construct the [BasicAuthTokenExample]
  const BasicAuthTokenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Agora SDK Example',
      debugShowCheckedModeBanner: false,
      home: PrejoinPage(),
    );
  }
}

class JoinChannelVideoToken extends StatefulWidget {
  const JoinChannelVideoToken({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<JoinChannelVideoToken> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final RtcEngine _engine;

  bool _isAgoraEngineReady = false;

  static const String hostUrl =
      'https://ghoul-bursting-calf.ngrok-free.app/api/get_rtc_token';

  String channelName = 'agora-test';

  String appId = config.appId;

  UserAgora userLocal = UserAgora(
    uid: 0,
    isJoinedChannel: false,
  );

  List<UserAgora> userRemote = [];

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  Future<void> _initEngine() async {
    await [Permission.camera, Permission.microphone].request();

    _engine = createAgoraRtcEngine();

    await _engine.initialize(
      RtcEngineContext(
        appId: appId,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            userLocal =
                UserAgora(uid: connection.localUid ?? 0, isJoinedChannel: true);
          });
        },
        onUserJoined: (RtcConnection connection, int rUid, int elapsed) {
          setState(() {
            userRemote.add(
              UserAgora(
                uid: rUid,
              ),
            );
          });
        },
        onUserOffline:
            (RtcConnection connection, int rUid, UserOfflineReasonType reason) {
          setState(() {
            userRemote.removeWhere((element) => element.uid == rUid);
          });
        },
        onUserMuteVideo: (RtcConnection connection, int rUid, bool muted) {
          log("User Mute Video: $rUid, $muted");
          var user = userRemote.firstWhere((element) => element.uid == rUid);

          setState(() {
            user.isCameraOn = !muted;
          });
        },
        onUserMuteAudio: (RtcConnection connection, int rUid, bool muted) {
          log("User Mute Audio: $rUid, $muted");
          var user = userRemote.firstWhere((element) => element.uid == rUid);

          setState(() {
            user.isMicOn = !muted;
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          setState(() {
            userLocal.isJoinedChannel = false;
            userRemote.clear();
          });
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          _fetchTokenAndJoinChannel(
            fetchTokenUrl: hostUrl,
            channelName: channelName,
            needJoinChannel: false,
          );
        },
        onRequestToken: (RtcConnection connection) {
          _fetchTokenAndJoinChannel(
            fetchTokenUrl: hostUrl,
            channelName: channelName,
            needJoinChannel: false,
          );
        },
      ),
    );

    await _engine.enableVideo();

    await _engine.enableAudio();

    await _engine.startPreview();

    await _fetchTokenAndJoinChannel(
      fetchTokenUrl: hostUrl,
      channelName: channelName,
      needJoinChannel: true,
    );

    setState(() {
      _isAgoraEngineReady = true;
    });
  }

  Future<void> _fetchTokenAndJoinChannel({
    required String fetchTokenUrl,
    required String channelName,
    required bool needJoinChannel,
  }) async {
    final channelManager = ChannelManager(
      hostUrl: hostUrl,
      engine: _engine,
    );

    try {
      await channelManager.handleTokenAndChannel(
        channelName: channelName,
        needJoinChannel: true,
      );
    } on ChannelException catch (e) {
      log('Channel operation failed: ${e.message}');
    } finally {
      channelManager.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      endDrawer: buildDrawerToolBar(context),
      body: (!_isAgoraEngineReady && !userLocal.isJoinedChannel)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                VideoView(
                  engine: _engine,
                  channelName: channelName,
                  userLocal: userLocal,
                  userRemote: userRemote,
                ),
                buildToolBar(context)
              ],
            ),
    );
  }

  Align buildToolBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: IntrinsicWidth(
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () async {
                  await _engine.enableLocalAudio(!userLocal.isMicOn);

                  setState(() {
                    userLocal.isMicOn = !userLocal.isMicOn;
                  });
                },
                icon: Icon(
                  userLocal.isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await _engine.enableLocalVideo(!userLocal.isCameraOn);

                  setState(() {
                    userLocal.isCameraOn = !userLocal.isCameraOn;
                  });
                },
                icon: Icon(
                  userLocal.isCameraOn
                      ? Icons.videocam_rounded
                      : Icons.videocam_off_rounded,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await _engine.switchCamera();

                  setState(() {
                    userLocal.isCameraSwitch = !userLocal.isCameraSwitch;
                  });
                },
                icon: const Icon(
                  Icons.flip_camera_ios_rounded,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await _engine.leaveChannel();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Drawer buildDrawerToolBar(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              const Text("Local User Information"),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'UID: ${userLocal.uid}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Text("Remote User Information"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: userRemote.map((user) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'UID: ${user.uid}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Connected Users: ${userRemote.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
