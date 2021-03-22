import 'package:flutter/material.dart';

import '../../app/common_widgets/app_button.dart';
import '../../env.dart';
import '../../login_register/login_register_model/login__reg_status.dart';
import '../../store/actions/account_actions.dart';
import '../../store/connect_state.dart';
import '../../utils/utils.dart';
import '../account_model/account_state.dart';
import 'change_password_form.dart';

//controls if the password change fields are visible due to the sign in method and if the password chang is successful
class ChangePasswordController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConnectState<AccountState>(
        where: notIdentical,
        map: (state) => state.accountState,
        builder: (accountState) {
          if (accountState.isUserSignedInWithEmail) {
            if (accountState.showPasswordForm) {
              return ChangePasswordForm(accountState: accountState);
            } else if (accountState.loginStatus == LoginStatus.success) {
              return Text('Password changed!');
            } else if (accountState.loginStatus == LoginStatus.submitting) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Changing password...    '),
                  CircularProgressIndicator(),
                ],
              );
            } else {
              return AppButton(
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
