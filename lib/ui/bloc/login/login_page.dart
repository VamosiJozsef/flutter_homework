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

  late LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc();
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
    return true;
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
      content: Text('Error'),
      duration: Duration(milliseconds: 300),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
        buildWhen: (context, state) => state is LoginForm,
        listenWhen: (context, state) {
          if (state is LoginError || state is LoginSuccess) {
            return true;
          }
          return false;
        },
        listener: (context, state) => {
          if (state is LoginError) {
            showErrorMessage(state.message)
          },
          print("KAKA_LOGINPAGE"),
          if (state is LoginSuccess) {

            Navigator.pushReplacementNamed(context, "/list")
          }
        },
        builder: (context, state) {
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
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                      ),
                      const Text('Remember me'),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => {
                      if (login()) {
                        context.read<LoginBloc>().add(LoginSubmitEvent(
                            _emailController.text,
                            _passwordController.text,
                            _rememberMe)
                        )},
                        GetIt.I<SharedPreferences>().containsKey("token")
                    },
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
