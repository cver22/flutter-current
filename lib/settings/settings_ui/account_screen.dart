import 'package:expenses/auth_user/models/user.dart';
import 'package:expenses/env.dart';
import 'file:///D:/version-control/flutter/expenses/lib/qr_reader/qr_model/qr_model.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = Env.store.state.authState.user.value;
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Center(
        child: SingleChildScrollView(
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
                        backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl) : null,
                        child: user.photoUrl == null ? Icon(Icons.camera_alt, size: 60.0) : null),
                  ),
                  SizedBox(height: 20.0),
                  Text(user.displayName != null ? user.displayName : 'Name missing'),
                  SizedBox(height: 20.0),
                  Text(user.email != null ? user.email : 'Email missing'),
                ],
              ),
              FlatButton(
                child: Text('Logout'),
                onPressed: () {
                  Env.userFetcher.signOut();
                  Get.offAllNamed(ExpenseRoutes.home);
                  //Navigator.popUntil(context, ModalRoute.withName(ExpenseRoutes.home));
                },
              ),
              SizedBox(height: 30.0),
              Text('Scan to add user to the log.'),
              SizedBox(height: 10.0),
              QrImage(
                data: QRModel(uid: user.id, name: user.displayName ?? 'No Name').toJson().toString(),
                size: 250,
                version: 8,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
