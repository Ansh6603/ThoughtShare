import 'package:flutter/material.dart';

class CommentScreen extends StatelessWidget {
  final String comment;

  const CommentScreen({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment Details'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(comment),
          ),
        ],
      ),
    );
  }
}
