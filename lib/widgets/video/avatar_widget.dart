import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.uid,
  });

  final int uid;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 45,
            child: Icon(
              Icons.person,
              size: 45,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            "$uid",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }
}