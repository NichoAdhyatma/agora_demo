import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtc_engine/agora_rtc_engine_debug.dart';
import 'package:agora_sdk_example/components/channel_manager.dart';
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
      home: JoinChannelVideoToken(),
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

  bool _isReadyPreview = false;

  bool isJoined = false;

  int localUID = 0;

  Set<int> remoteUid = {};

  static const String hostUrl =
      'https://ghoul-bursting-calf.ngrok-free.app/api/get_rtc_token';

  String channelName = 'agora-test';

  String appId = config.appId;

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
            localUID = connection.localUid ?? 0;
            isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int rUid, int elapsed) {
          setState(() {
            remoteUid.add(rUid);
          });
        },
        onUserOffline:
            (RtcConnection connection, int rUid, UserOfflineReasonType reason) {
          setState(() {
            remoteUid.removeWhere((element) => element == rUid);
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          setState(() {
            isJoined = false;
            remoteUid.clear();
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
            needJoinChannel: true,
          );
        },
      ),
    );

    await _engine.enableVideo();

    await _engine.startPreview();

    await _fetchTokenAndJoinChannel(
      fetchTokenUrl: hostUrl,
      channelName: channelName,
      needJoinChannel: true,
    );

    setState(() {
      _isReadyPreview = true;
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
        title: const Text('Agora SDK Example'),
        actions: [
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text('Toggle Camera'),
                  onTap: () async {
                    await _engine.enableLocalVideo(!_isReadyPreview);
                    setState(() {
                      _isReadyPreview = !_isReadyPreview;
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.mic),
                  title: const Text('Toggle Audio'),
                  onTap: () async {
                    await _engine.enableLocalAudio(!isJoined);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.switch_camera),
                  title: const Text('Switch Camera'),
                  onTap: () async {
                    await _engine.switchCamera();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Leave Channel'),
                  onTap: () async {
                    await _engine.leaveChannel();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                const Spacer(),
                const Text("Local User Information"),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'UID: $localUID',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Text("Remote User Information"),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: remoteUid.map((e) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'UID: $e',
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
                    'Connected Users: ${remoteUid.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: (!_isReadyPreview)
          ? Container()
          : Stack(
              children: [
                LocalVideoPreview(engine: _engine),
                RemoteVideoPreview(
                  remoteUid: remoteUid,
                  engine: _engine,
                  channelName: channelName,
                ),
              ],
            ),
    );
  }
}

class RemoteVideoPreview extends StatelessWidget {
  const RemoteVideoPreview({
    super.key,
    required this.remoteUid,
    required RtcEngine engine,
    required this.channelName,
  }) : _engine = engine;

  final Set<int> remoteUid;
  final RtcEngine _engine;
  final String channelName;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.of(
            remoteUid.map(
              (e) => SizedBox(
                width: 120,
                height: 120,
                child: AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine,
                    canvas: VideoCanvas(uid: e),
                    connection: RtcConnection(
                      channelId: channelName,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LocalVideoPreview extends StatelessWidget {
  const LocalVideoPreview({
    super.key,
    required RtcEngine engine,
  }) : _engine = engine;

  final RtcEngine _engine;

  @override
  Widget build(BuildContext context) {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }
}
