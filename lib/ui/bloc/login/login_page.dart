import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_homework/ui/bloc/login/login_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPageBloc extends StatefulWidget {
  const LoginPageBloc({super.key});

  @override
  State<LoginPageBloc> createState() => _LoginPageBlocState();
}

class _LoginPageBlocState extends State<LoginPageBloc> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  String? _emailError;
  String? _passwordError;
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    context.read<LoginBloc>().add(LoginAutoLoginEvent());
  }

  bool login() {
    String email = _emailController.text;
    String password = _passwordController.text;

    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (!validateEmail(email)) {
      setState(() {
        _emailError = 'Invalid email format';
      });
    }

    if (password.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters long';
      });
    }

    if (_emailError != null || _passwordError != null){
      return false;
    }
    _enabled = true;
    return true;
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 300),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
        buildWhen: (context, state) => state is LoginForm || state is LoginLoading,
        listenWhen: (context, state) {
          if (state is LoginError || state is LoginSuccess) {
            return true;
          }
          return false;
        },
        listener: (context, state) => {
          if (state is LoginError) {
            setState(() {
              _enabled = true;
            }),
            showErrorMessage(state.message)
          },
          if (state is LoginSuccess) {
            setState(() {
              _enabled = true;
            }),
            Navigator.pushReplacementNamed(context, "/list")
          },
        },
        builder: (context, state) {
          if (state is LoginLoading) {
            _enabled = false;
          }
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text('Login'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    enabled: _enabled,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: _emailError,
                    ),
                    onChanged: (_) {
                      setState(() {
                        _emailError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    enabled: _enabled,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: _passwordError,
                    ),
                    obscureText: true,
                    onChanged: (_) {
                      setState(() {
                        _passwordError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: _enabled ? (value) {
                          setState(() {
                            _rememberMe = value!;
                          });} : null,
                      ),
                      const Text('Remember me'),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _enabled ? () {
                      if (login()) {
                        print("login");
                        context.read<LoginBloc>().add(LoginSubmitEvent(
                          _emailController.text,
                          _passwordController.text,
                          _rememberMe,
                        ));
                      }
                      try{
                        GetIt.I<SharedPreferences>().containsKey("token");
                      } catch (error) {
                        print("Error");
                      }
                    } : null,
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          );
        },
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  bool validateEmail(String email) {
    String pattern = r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,7}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }
}
