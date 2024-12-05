import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_sdk_example/widgets/video/remote_video_preview.dart';
import 'package:flutter/material.dart';

import '../../models/user_agora.dart';
import 'local_video_preview.dart';

class VideoView extends StatelessWidget {
  const VideoView({
    super.key,
    required this.userRemote,
    required RtcEngine engine,
    required this.channelName,
    required this.userLocal,
  }) : _engine = engine;

  final List<UserAgora> userRemote;
  final UserAgora userLocal;
  final RtcEngine _engine;
  final String channelName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12.0,
        ),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            LocalVideoPreview(
              engine: _engine,
              user: userLocal,
            ),
            ...userRemote.map((user) {
              return RemoteVideoPreview(
                engine: _engine,
                channelName: channelName,
                user: user,
              );
            }),
          ],
        ),
      ),
    );
  }
}
