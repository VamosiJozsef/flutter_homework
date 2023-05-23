import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class LoginException extends Equatable implements Exception{
  final String message;

  const LoginException(this.message);

  @override
  List<Object?> get props => [message];
}

class LoginModel extends ChangeNotifier{
  var isLoading = false;

  Future login(String email, String password, bool rememberMe) async {

  }

  Future<bool> tryAutoLogin() async {
    throw UnimplementedError('Missing implementation!');
  }
}