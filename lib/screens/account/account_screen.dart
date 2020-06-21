import 'package:expenses/env.dart';
import 'file:///D:/version-control/flutter/expenses/lib/models/user.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = Env.store.state.authState.user.value;
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 30.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2.0, 3.0),
                      blurRadius: 3.0,
                    )
                  ]),
                  child: CircleAvatar(
                      radius: 60.0,
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl)
                          : null,
                      child: user.photoUrl == null
                          ? Icon(Icons.camera_alt, size: 60.0)
                          : null),
                ),
                SizedBox(height: 20.0),
                Text(user.displayName != null
                    ? user.displayName
                    : 'Name missing'),
                SizedBox(height: 20.0),
                Text(user.email != null ? user.email : 'Email missing'),
              ],
            ),
            FlatButton(
              child: Text('Logout'),
              onPressed: () {
                Env.userFetcher.signOut();
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
