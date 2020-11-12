import 'package:flutter/material.dart';

class ErrorContent extends StatelessWidget {
  final String errorMessage;

  const ErrorContent({Key key, this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: <Widget>[
        Icon(Icons.error),
        Text(errorMessage ?? 'Something went wrong'),
      ],
    ));
  }
}
