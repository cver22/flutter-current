import 'package:expenses/screens/register/register_screen.dart';
import 'package:expenses/services/user_repository.dart';
import 'package:flutter/material.dart';

class CreateAccountButton extends StatelessWidget {
  final FirebaseUserRepository _userRepository;

  const CreateAccountButton({Key key, FirebaseUserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text('Create an Account'),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return RegisterScreen(userRepository: _userRepository);
            },
          ),
        );
      },
    );
  }
}
