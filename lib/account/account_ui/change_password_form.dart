import 'package:expenses/login_register/login_register_model/login_reg_state.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../env.dart';

class ChangePasswordForm extends StatefulWidget {
  final VoidCallback showPasswordFields;

  const ChangePasswordForm({Key key, this.showPasswordFields}) : super(key: key);

  @override
  _ChangePasswordFormState createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _verifyPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {


    /*Widget _showPasswordEdit() {
      return FutureBuilder<bool>(
        future: Env.userFetcher.isUserSignedInWithEmail(),
        builder: (BuildContext context, AsyncSnapshot<bool> isSignedInWithEmail) {
          if (isSignedInWithEmail.hasData && isSignedInWithEmail.data) {
            //user signed in with email
            if (showPasswordFields) {
              return
            } else {
              return RaisedButton(
                elevation: RAISED_BUTTON_ELEVATION,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RAISED_BUTTON_CIRCULAR_RADIUS)),
                child: Text('Change Password'),
                onPressed: () {
                  setState(() {
                    showPasswordFields = true;
                  });
                },
              );
            }
          }
          return Container();
        },
      );
    }*/




    return ConnectState<AccountState>(
        where: notIdentical,
        map: (state) => state.accountState,
        builder: (accountState) {



          return Form(
            key: _formKey,
            child: Column(
              children: [
                _passwordFormField(controller: _oldPasswordController, label: 'Old Password'),
                _passwordFormField(controller: _newPasswordController, label: 'New Password'),
                _passwordFormField(
                    controller: _verifyPasswordController,
                    label: 'Retype New Password',
                    validator: (value) {
                      if (_newPasswordController.text != _verifyPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    RaisedButton(
                      elevation: RAISED_BUTTON_ELEVATION,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RAISED_BUTTON_CIRCULAR_RADIUS)),
                      child: Text('Submit'),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  TextFormField _passwordFormField(
      {@required TextEditingController controller, @required String label, String Function(String) validator}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        icon: Icon(Icons.lock),
        labelText: label,
      ),
      obscureText: true,
      autocorrect: false,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[\s\S]{10,}$'))],
      validator: validator,
    );
  }
}
