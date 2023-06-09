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
      if (state is! LoginLoading) {
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
          }
          emit(LoginSuccess());
          emit(LoginForm());
        } on DioError catch (error) {
          emit(LoginError((error.response?.data as Map)["message"]));
          emit(LoginForm());
        }
      }
    });
    on<LoginAutoLoginEvent>((event, emit) async {
      GetIt.I<SharedPreferences>().getString("token");
      if (GetIt.I<SharedPreferences>().containsKey("token")) {
        emit(LoginSuccess());
      }
    });
  }
}
