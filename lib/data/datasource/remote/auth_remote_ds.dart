import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmacy_arrival/core/error/excepteion.dart';
import 'package:pharmacy_arrival/core/platform/network_helper.dart';
import 'package:pharmacy_arrival/data/model/counteragent_dto.dart';
import 'package:pharmacy_arrival/data/model/user.dart';

abstract class AuthRemoteDS {
  Future<User> signin({
    required String login,
    required String password,
    required String deviceToken,
    required String deviceOs,
  });

  Future<List<CounteragentDTO>> getOrganizations();
  Future<List<CounteragentDTO>> getCountragents({
    int? userId,
  });
  Future<User> getProfile({
    required String accessToken,
  });
}

class AuthRemoteDSImpl extends AuthRemoteDS {
  final Dio dio;
  AuthRemoteDSImpl(this.dio);

  @override
  Future<User> signin({
    required String login,
    required String password,
    required String deviceToken,
    required String deviceOs,
  }) async {
    try {
      log('SignIn method called with deviceToken:]deviceOs: $deviceOs');
      final response = await dio.post(
        '$SERVER_/api/login',
        data: {
          'login': login,
          'password': password,
          'device_token': deviceToken,
          'device_os': deviceOs,
        },
      );

      final User user = User.fromJson(
        (response.data as Map<String, dynamic>)["user"] as Map<String, dynamic>,
      ).copyWith(
        accessToken:
            (response.data as Map<String, dynamic>)['access_token'] as String?,
      );
      log('signIn method in authremoteds:: ${response.statusCode}, ${response.data}, $login, $password,  $deviceOs, $deviceToken');
      return user;
    } on DioError catch (e) {
      log('##### signIn api error::: ${e.response}, ${e.error}');
      throw ServerException(
        message:
            (e.response!.data as Map<String, dynamic>)['message'] as String,
      );
    }
  }

  @override
  Future<List<CounteragentDTO>> getOrganizations() async {
    dio.options.headers['Accept'] = "application/json";

    try {
      final response = await dio.get('$SERVER_/api/organization');
      log('##### getOrganizations api:: ${response.statusCode}');

      return compute<List, List<CounteragentDTO>>(
        (List list) {
          return list
              .map((e) => CounteragentDTO.fromJson(e as Map<String, dynamic>))
              .toList();
        },
        response.data as List<dynamic>,
      );
    } on DioError catch (e) {
      log('##### getWarehouseArrivalOrders api error::: ${e.response}, ${e.error}');
      throw ServerException(
        message:
            (e.response!.data as Map<String, dynamic>)['message'] as String,
      );
    }
  }

  @override
  Future<List<CounteragentDTO>> getCountragents({
    int? userId,
  }) async {
    dio.options.headers['Accept'] = "application/json";

    try {
      final response = await dio.get(
        '$SERVER_/api/counteragent',
        queryParameters: {
          if (userId != null) 'user_id': userId,
        },
      );
      log('##### getCountragents api:: ${response.statusCode}');

      return compute<List, List<CounteragentDTO>>(
        (List list) {
          return list
              .map((e) => CounteragentDTO.fromJson(e as Map<String, dynamic>))
              .toList();
        },
        response.data as List<dynamic>,
      );
    } on DioError catch (e) {
      log('##### getWarehouseArrivalOrders api error::: ${e.response}, ${e.error}');
      throw ServerException(
        message:
            (e.response!.data as Map<String, dynamic>)['message'] as String,
      );
    }
  }

  @override
  Future<User> getProfile({required String accessToken}) async {
    dio.options.headers['authorization'] = 'Bearer $accessToken';
    dio.options.headers['Accept'] = "application/json";
    try {
      final response = await dio.post(
        '$SERVER_/api/profile',
      );

      log("##### getProfile api:: ${response.statusCode},${response.data}");
      return User.fromJson(
        (response.data as Map<String, dynamic>)['user'] as Map<String, dynamic>,
      );
    } on DioError catch (e) {
      log('$e');
      throw ServerException(
        message:
            (e.response!.data as Map<String, dynamic>)['message'] as String,
      );
    }
  }
}
