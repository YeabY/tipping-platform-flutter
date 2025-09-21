import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/user.dart';
import 'local_auth_service.dart';

class AuthService {
  static const String _baseUrl = AppConstants.baseUrl;

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Use local authentication service
      final result = await LocalAuthService.registerUser(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      if (result['success']) {
        // Store the current user session
        await LocalAuthService.storeCurrentUser(result['user'], result['token']);
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed. Please try again.',
      };
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Use local authentication service
      final result = await LocalAuthService.loginUser(
        email: email,
        password: password,
      );
      
      if (result['success']) {
        // Store the current user session
        await LocalAuthService.storeCurrentUser(result['user'], result['token']);
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed. Please try again.',
      };
    }
  }

  // Logout user
  Future<Map<String, dynamic>> logout(String token) async {
    try {
      // Clear the current user session
      await LocalAuthService.clearCurrentUser();
      return {'success': true};
    } catch (e) {
      return {'success': false};
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      return await LocalAuthService.resetPassword(email);
    } catch (e) {
      return {
        'success': false,
        'message': 'Password reset failed. Please try again.',
      };
    }
  }

  // Verify token
  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/${AppConstants.apiVersion}/auth/verify'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConstants.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Token verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Token verification failed',
      };
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String userId,
    String? displayName,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      return await LocalAuthService.updateUserProfile(
        userId: userId,
        displayName: displayName,
        bio: bio,
        profileImageUrl: profileImageUrl,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Profile update failed. Please try again.',
      };
    }
  }

  // Become a creator
  Future<Map<String, dynamic>> becomeCreator({
    required String token,
    required String userId,
    required String uniqueUrl,
    String? bio,
  }) async {
    try {
      return await LocalAuthService.updateUserProfile(
        userId: userId,
        uniqueUrl: uniqueUrl,
        bio: bio,
        isCreator: true,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to become creator. Please try again.',
      };
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/${AppConstants.apiVersion}/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(AppConstants.apiTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': User.fromJson(data['user']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get user profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
}
