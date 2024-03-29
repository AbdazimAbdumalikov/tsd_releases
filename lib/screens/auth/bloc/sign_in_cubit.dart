import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pharmacy_arrival/core/error/failure.dart';
import 'package:pharmacy_arrival/data/model/user.dart';
import 'package:pharmacy_arrival/domain/repositories/auth_repository.dart';
import 'package:pharmacy_arrival/domain/usecases/sign_in_user.dart';

part 'sign_in_state.dart';
part 'sign_in_cubit.freezed.dart';

class SignInCubit extends Cubit<SignInState> {
  SignInCubit(
    this._signInUser,
    this._authRepository,
  ) : super(const SignInState.initialState());
  final SignInUser _signInUser;
  final AuthRepository _authRepository;

  Future<void> getUserFromCache() async {
    emit(const SignInState.loadingState());
    final failureOrUser = await _authRepository.getUserFromCahce();

    failureOrUser.fold(
      (l) {
        emit(SignInState.errorState(message: mapFailureToMessageBack(l)));
      },
      (r) {
        emit(SignInState.loadedState(user: r));
      },
    );
  }

  Future<void> signIn({
    required String phone,
    required String password,
    required String deviceToken,
    required String deviceOs,
  }) async {
    emit(const SignInState.loadingState());
    String deviceOs = Platform.isAndroid ? 'Android' : 'iOS';
    final failureOrUser = await _signInUser(
      SignInUserParams(
        login: phone,
        password: password,
        deviceToken: deviceToken ?? "", // Проверка на null и присвоение значения по умолчанию
        deviceOs: deviceOs,
      ),
    );

    failureOrUser.fold(
      (l) {
        emit(SignInState.errorState(message: mapFailureToMessageBack(l)));
      },
      (r) {
        emit(SignInState.loadedState(user: r));
      },
    );
  }
}
