
import 'package:flutter/material.dart';

class NotificationDialogWidget extends StatefulWidget {
  final titleText;
  final body;

  const NotificationDialogWidget({super.key, 
  required this.titleText, required this.body});

  @override
  State<NotificationDialogWidget> createState() => _NotificationDialogWidgetState();
}

class _NotificationDialogWidgetState extends State<NotificationDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.titleText),
      actions: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          label: const Text('Close'),
          icon: const Icon(Icons.close),)
      ],
      content: widget.body.toString().contains('.jpg') ? 
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Send you image.'),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.all(17),
            child: Image.network(widget.body.toString(), 
            width: 160, height: 160))
        ],
      ) : 
      widget.body.toString().contains('.docx') ||
      widget.body.toString().contains('.pdf') ||
      widget.body.toString().contains('.mp4') ||
      widget.body.toString().contains('.mp3') ||
      widget.body.toString().contains('.xlsx') ||
      widget.body.toString().contains('.pptx') ? 
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Send you file.'),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.all(17),
            child: Image.asset('file.png', 
            width: 160, height: 160))
        ],
      ) : 
      Text(widget.body)
    );
  }
}