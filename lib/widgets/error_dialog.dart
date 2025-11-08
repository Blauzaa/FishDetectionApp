import 'package:flutter/material.dart';

void showErrorDialog(BuildContext context, String errorMessage) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text('Terjadi Kesalahan'),
          ],
        ),
        content: Text(errorMessage),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(dialogContext).pop(); 
            },
          ),
        ],
      );
    },
  );
}