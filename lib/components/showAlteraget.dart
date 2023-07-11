import 'package:flutter/material.dart';

show_loading(context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          height: 50,
          child: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      );
    },
  );
}
