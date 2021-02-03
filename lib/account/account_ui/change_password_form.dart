import 'package:expenses/account/account_model/account_state.dart';
import 'package:expenses/login_register/login_register_model/login__reg_status.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

import '../../env.dart';

class ChangePasswordForm extends StatefulWidget {
  final AccountState accountState;

  const ChangePasswordForm({Key key, @required this.accountState}) : super(key: key);

  @override
  _ChangePasswordFormState createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _verifyPasswordController = TextEditingController();
  final FocusNode _oldPasswordFocus = FocusNode();
  final FocusNode _newPasswordFocus = FocusNode();
  final FocusNode _verifyPasswordFocus = FocusNode();
  AccountState accountState;

  @override
  void initState() {
    _oldPasswordController.addListener(_onOldPasswordChanged);
    _newPasswordController.addListener(_onNewPasswordChanged);
    _verifyPasswordController.addListener(_onNewPasswordChanged);
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _verifyPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    accountState = widget.accountState;

    return Form(
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        children: [
          accountState.loginStatus == LoginStatus.failure
              ? Text('Failed to change password, please try again')
              : Container(),
          _passwordFormField(
            autoFocus: true,
            focusNode: _oldPasswordFocus,
            onFieldSubmitted: (term) {
              _fieldFocusChange(context, _oldPasswordFocus, _newPasswordFocus);
            },
            textInputAction: TextInputAction.next,
            controller: _oldPasswordController,
            label: 'Old Password',
            validator: (_) {
              return !accountState.isOldPasswordValid ? 'Minimum 10 characters' : null;
            },
          ),
          _passwordFormField(
            focusNode: _newPasswordFocus,
            onFieldSubmitted: (term) {
              _fieldFocusChange(context, _newPasswordFocus, _verifyPasswordFocus);
            },
            textInputAction: TextInputAction.next,
            controller: _newPasswordController,
            label: 'New Password',
            validator: (_) {
              return !accountState.isNewPasswordValid ? 'Minimum 10 characters' : null;
            },
          ),
          _passwordFormField(
            focusNode: _verifyPasswordFocus,
            textInputAction: TextInputAction.done,
            controller: _verifyPasswordController,
            label: 'Retype New Password',
            validator: (_) {
              return !accountState.newPasswordsMatch && _newPasswordController.text.length > 9
                  ? 'Passwords do not match'
                  : null;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [

              RaisedButton(
                elevation: RAISED_BUTTON_ELEVATION,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RAISED_BUTTON_CIRCULAR_RADIUS)),
                child: Text('Submit'),
                onPressed: accountState.loginStatus == LoginStatus.submitting ||
                    !accountState.newPasswordsMatch ||
                    _newPasswordController.text.length < 10
                    ? null
                    : () {
                  Env.userFetcher.updatePassword(
                      currentPassword: _oldPasswordController.text,
                      newPassword: _newPasswordController.text);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextFormField _passwordFormField({
    @required TextEditingController controller,
    @required String label,
    String Function(String) validator,
    @required TextInputAction textInputAction,
    void Function(String) onFieldSubmitted,
    FocusNode focusNode, bool autoFocus,
  }) {
    return TextFormField(
      autofocus: autoFocus ?? false,
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      textInputAction: textInputAction,
      controller: controller,
      decoration: InputDecoration(
        icon: Icon(Icons.lock),
        labelText: label,
      ),
      obscureText: true,
      autocorrect: false,
      validator: validator,
    );
  }

  void _onOldPasswordChanged() {
    setState(() {
      Env.store.dispatch(AccountValidateOldPassword(password: _oldPasswordController.text));
    });
  }

  void _onNewPasswordChanged() {
    setState(() {
      Env.store.dispatch(AccountValidateNewPassword(
          newPassword: _newPasswordController.text, verifyPassword: _verifyPasswordController.text));
    });
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
