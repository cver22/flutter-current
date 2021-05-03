import 'package:flutter/material.dart';

class ModalLoadingIndicator extends StatelessWidget {
  final String loadingMessage;
  final bool activate;

  ModalLoadingIndicator({required this.loadingMessage, required this.activate});

  //TODO how to implement modal barrier with a message as I keep getting renderflex issues

  @override
  Widget build(BuildContext context) {
    return activate
        ? Stack(
            children: [
              Opacity(opacity: 0.5, child: ModalBarrier(dismissible: false, color: Colors.grey)),
              Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircularProgressIndicator(),
                ],
              ))
            ],
          )
        : Container();
  }
}
