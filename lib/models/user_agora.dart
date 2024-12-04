class UserAgora {
  int uid;
  bool isCameraOn;
  bool isMicOn;
  bool isCameraSwitch;
  bool isJoinedChannel;

  UserAgora({
    required this.uid,
    this.isCameraOn = true,
    this.isMicOn = true,
    this.isCameraSwitch = false,
    this.isJoinedChannel = false,
  });
}
