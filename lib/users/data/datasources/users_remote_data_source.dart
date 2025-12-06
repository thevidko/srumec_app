import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:srumec_app/core/network/api_endpoints.dart';
import 'package:srumec_app/users/models/user_profile.dart';

class UsersRemoteDataSource {
  final Dio dio;

  UsersRemoteDataSource(this.dio);

  Future<UserProfile> getUserProfile(String userId) async {
    final url = '${ApiEndpoints.baseUrl}${UserEndpoints.base}$userId';

    debugPrint("🔍 Stahuji profil uživatele: $url");

    try {
      final response = await dio.get(url);
      return UserProfile.fromJson(response.data);
    } catch (e) {
      debugPrint("Chyba při stahování profilu uživatele $userId: $e");
      rethrow;
    }
  }
}
