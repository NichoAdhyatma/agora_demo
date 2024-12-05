import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_sdk_example/models/user_agora.dart';
import 'package:flutter/material.dart';

import 'avatar_widget.dart';

class LocalVideoPreview extends StatelessWidget {
  const LocalVideoPreview({
    super.key,
    required RtcEngine engine,
    required this.user,
  }) : _engine = engine;

  final RtcEngine _engine;
  final UserAgora user;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        user.isCameraOn
            ? SizedBox(
          width: 200,
          height: 200,
          child: AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _engine,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
        )
            : AvatarWidget(uid: user.uid),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                user.isMicOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}