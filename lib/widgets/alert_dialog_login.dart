import 'package:flutter/material.dart';

class AlertDialogLogin extends StatelessWidget {
  const AlertDialogLogin({Key? key, required this.title, required this.content}) : super(key: key);

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(
            "Fechar",
            style: TextStyle(
              color: Color.fromARGB(255, 4, 125, 141),
            ),
          ),
        )
      ],
    );
  }
}
