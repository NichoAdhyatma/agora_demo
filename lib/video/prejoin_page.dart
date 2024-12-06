import 'package:agora_sdk_example/video/basic_auth_token_example.dart';
import 'package:flutter/material.dart';

class PrejoinPage extends StatelessWidget {
  const PrejoinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prejoin Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const JoinChannelVideoToken(),
              ),
            );
          },
          child: const Text('Join Channel'),
        ),
      ),
    );
  }
}
