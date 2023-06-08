import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginForm()) {
    on<LoginSubmitEvent>((event, emit) async {
      try {
        emit(LoginLoading());
        Response response = await GetIt.I<Dio>().post(
          '/login',
          data: {'email': event.email, 'password': event.password},
        );

        Map<String, dynamic> data = response.data;
        String token = data['token'];

        if (event.rememberMe) {
          await GetIt.I<SharedPreferences>().setString("token", token);
          print(token);
        }
        emit(LoginSuccess());
      } catch (error) {
        emit(LoginError(error.toString()));
      }
    });
    on<LoginAutoLoginEvent>((event, emit) async {
      if (GetIt.I<SharedPreferences>().getString("token") != null) {
        emit(LoginSuccess());
      }
    });
  }
}
