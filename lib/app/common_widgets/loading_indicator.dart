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
            Text(loadingMessage, style: TextStyle(height: 20.0),),
            SizedBox(height: 10.0,),
            CircularProgressIndicator(),
          ],
        ));
  }
}
