import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String loadingMessage;

  LoadingIndicator({@required this.loadingMessage});


  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            Text(loadingMessage),
          ],
        ));
  }
}
