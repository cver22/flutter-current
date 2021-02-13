import 'package:expenses/account/account_model/account_state.dart';
import 'package:expenses/account/account_ui/change_password_form.dart';
import 'package:expenses/login_register/login_register_model/login__reg_status.dart';
import 'package:expenses/store/actions/my_actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../env.dart';


//controls if the password change fields are visible due to the sign in method and if the password chang is successful
class ChangePasswordController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectState<AccountState>(
        where: notIdentical,
        map: (state) => state.accountState,
        builder: (accountState) {
          if (accountState.isUserSignedInWithEmail) {
            if ( accountState.showPasswordForm) {
              return ChangePasswordForm(accountState: accountState);
            } else if (accountState.loginStatus == LoginStatus.success) {
              return Text('Password changed!');
            } else if (accountState.loginStatus == LoginStatus.submitting) {
              return Row(mainAxisSize: MainAxisSize.min,
                children: [Text('Changing password...    '),CircularProgressIndicator(),],
              );
            } else {
              return RaisedButton(
                elevation: RAISED_BUTTON_ELEVATION,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RAISED_BUTTON_CIRCULAR_RADIUS)),
                child: Text('Change Password'),
                onPressed: () {
                  Env.store.dispatch(ShowHidePasswordForm());
                },
              );
            }
          } else {
            return Container();
          }
        });
  }
}
