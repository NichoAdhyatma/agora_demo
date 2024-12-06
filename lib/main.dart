import 'package:agora_sdk_example/video/basic_auth_token_example.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

void main() => runApp(
      DevicePreview(
        builder: (BuildContext context) => const BasicAuthTokenExample(),
      ),
    );
