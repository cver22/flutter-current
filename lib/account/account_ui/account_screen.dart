import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/common_widgets/app_button.dart';
import '../../auth_user/models/app_user.dart';
import '../../env.dart';
import '../../qr_reader/qr_model/qr_model.dart';
import '../../store/actions/auth_actions.dart';
import '../../store/actions/logs_actions.dart';
import '../../store/connect_state.dart';
import '../../utils/db_consts.dart';
import '../../utils/expense_routes.dart';
import '../../utils/utils.dart';
import 'change_password_controller.dart';

//AccountScreen contains user information, picture, QR code, password changes, logout
class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  bool showQRCode = false;
  bool showPasswordFields = false;
  bool editDisplayName = false;
  late AppUser user;

  @override
  void initState() {
    user = Env.store.state.authState.user.value;
    _displayNameController.value = TextEditingValue(text: user.displayName ?? '');
    super.initState();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectState(
        where: notIdentical,
        map: (state) => state.authState,
        builder: (dynamic authState) {
          return WillPopScope(
            onWillPop: () async {
              Get.back();
              return false;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text('Account'),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => {
                    Get.back(),
                  },
                ),
              ),
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    _showAvatar(),
                    SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _showEditDisplayName(),
                        SizedBox(width: 5.0),
                        _showEditDisplayIcon(),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    _showUserEmail(),
                    SizedBox(height: 10.0),
                    ChangePasswordController(),
                    SizedBox(height: 20.0),
                    _showQRCode(),
                    SizedBox(height: 10.0),
                    _logoutButton(),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _showAvatar() {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
        BoxShadow(
          color: Colors.black,
          offset: Offset(2.0, 3.0),
          blurRadius: 3.0,
        )
      ]),
      child: CircleAvatar(
          radius: 60.0,
          backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null ? Icon(Icons.camera_alt, size: 60.0) : null),
    );
  }

  Widget _showEditDisplayName() {
    return editDisplayName
        ? Container(
            width: 100.0,
            child: TextField(
              autofocus: true,
              controller: _displayNameController,
              decoration: InputDecoration(labelText: 'User Name:'),
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
            ),
          )
        : Text(user.displayName != null && user.displayName!.length > 0 ? user.displayName! : 'Please enter a name');
  }

  Widget _showEditDisplayIcon() {
    return editDisplayName
        ? IconButton(
            icon: Icon(
              Icons.check_outlined,
              size: EMOJI_SIZE,
            ),
            onPressed: () {
              String displayName = _displayNameController.value.text;
              if (displayName != user.displayName) {
                Env.userFetcher.updateDisplayName(displayName: displayName);
                Env.store.dispatch(AuthUpdateDisplayName(displayName: displayName));
                Env.store.dispatch(LogUpdateLogMember());
                user = Env.store.state.authState.user.value;
              }
              setState(() {
                editDisplayName = false;
              });
            },
          )
        : IconButton(
            icon: Icon(
              Icons.edit_outlined,
              size: EMOJI_SIZE,
            ),
            onPressed: () {
              setState(() {
                editDisplayName = true;
              });
            },
          );
  }

  Widget _showUserEmail() {
    return Text(user.email != null ? user.email! : 'Email missing');
  }

  Widget _showQRCode() {
    return showQRCode
        ? Column(
            children: [
              Text('Scan to add user to the log.'),
              SizedBox(height: 10.0),
              QrImage(
                data: jsonEncode(QRModel(uid: user.id, name: user.displayName ?? 'No Name').toJson()).toString(),
                size: 200,
                version: 8,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            ],
          )
        : AppButton(
            child: Text('Show my QR Code'),
            onPressed: () {
              setState(() {
                showQRCode = true;
              });
            },
          );
  }

  Widget _logoutButton() {
    return TextButton(
      child: Text('Logout'),
      onPressed: () {
        Env.userFetcher.signOut();
        Get.offAllNamed(ExpenseRoutes.home);
        //Navigator.popUntil(context, ModalRoute.withName(ExpenseRoutes.home));
      },
    );
  }
}
