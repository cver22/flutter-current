import 'package:cached_network_image/cached_network_image.dart';
import 'package:expenses/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:expenses/models/user/user.dart';
import 'package:expenses/services/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BlocBuilder<AuthenticationBloc, AuthenticationState>(
                // ignore: missing_return
                builder: (context, state) {
              if (state is Authenticated) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(2.0, 3.0),
                          blurRadius: 3.0,
                        )
                      ]),
                      child: CircleAvatar(
                          radius: 60.0,
                          backgroundImage: state.user.photoUrl != null
                              ? NetworkImage(state.user.photoUrl)
                              : null,
                          child: state.user.photoUrl == null
                              ? Icon(Icons.camera_alt, size: 60.0)
                              : null),
                    ),
                    SizedBox(height: 20.0),
                    Text(state.user.displayName != null ? state.user.displayName : 'Name missing'),
                    SizedBox(height: 20.0),
                    Text(state.user.email != null ? state.user.email : 'Email missing'),
                  ],
                );
              }
            }),
            FlatButton(
              child: Text('Logout'),
              onPressed: () {
                BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
