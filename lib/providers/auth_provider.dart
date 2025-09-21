import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/local_auth_service.dart';
import '../constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _authToken;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get authToken => _authToken;
  bool get isAuthenticated => _currentUser != null && _authToken != null;
  bool get isCreator => _currentUser?.isCreator ?? false;

  // Initialize auth state
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Try to load current user session from local storage
      final currentUserData = await LocalAuthService.getCurrentUser();
      
      if (currentUserData != null) {
        _currentUser = currentUserData['user'];
        _authToken = currentUserData['token'];
        print('Loaded user from local storage: ${_currentUser?.email}');
      } else {
        // Fallback to old method for backward compatibility
        final prefs = await SharedPreferences.getInstance();
        _authToken = prefs.getString(AppConstants.authTokenKey);
        
        if (_authToken != null) {
          await _loadUserFromCache();
        }
      }
    } catch (e) {
      print('Auth initialization error: $e');
      // Don't set error, just continue without authentication
      _authToken = null;
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      if (result['success']) {
        _authToken = result['token'];
        _currentUser = result['user'];
        await _saveAuthData();
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );
      
      if (result['success']) {
        _authToken = result['token'];
        _currentUser = result['user'];
        await _saveAuthData();
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Login failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    try {
      if (_authToken != null) {
        await _authService.logout(_authToken!);
      }
    } catch (e) {
      // Continue with logout even if server call fails
    } finally {
      _currentUser = null;
      _authToken = null;
      await _clearAuthData();
      _setLoading(false);
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.resetPassword(email);
      if (result['success']) {
        return true;
      } else {
        _setError(result['message'] ?? 'Password reset failed');
        return false;
      }
    } catch (e) {
      _setError('Password reset failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? bio,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null || _authToken == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.updateProfile(
        token: _authToken!,
        userId: _currentUser!.id,
        displayName: displayName,
        bio: bio,
        profileImageUrl: profileImageUrl,
      );
      
      if (result['success']) {
        _currentUser = result['user'];
        await _saveUserToCache();
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Profile update failed');
        return false;
      }
    } catch (e) {
      _setError('Profile update failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Become a creator
  Future<bool> becomeCreator({
    required String uniqueUrl,
    String? bio,
  }) async {
    if (_currentUser == null || _authToken == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.becomeCreator(
        token: _authToken!,
        userId: _currentUser!.id,
        uniqueUrl: uniqueUrl,
        bio: bio,
      );
      
      if (result['success']) {
        _currentUser = result['user'];
        await _saveUserToCache();
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to become creator');
        return false;
      }
    } catch (e) {
      _setError('Failed to become creator. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verify token with server
  Future<void> _verifyToken() async {
    if (_authToken == null) return;
    
    try {
      final result = await _authService.verifyToken(_authToken!);
      if (result['success']) {
        _currentUser = result['user'];
        await _saveUserToCache();
      } else {
        await logout();
      }
    } catch (e) {
      // Token verification failed, logout user
      await logout();
    }
  }

  // Save authentication data to local storage
  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_authToken != null) {
      await prefs.setString(AppConstants.authTokenKey, _authToken!);
    }
    await _saveUserToCache();
  }

  // Save user to Hive cache
  Future<void> _saveUserToCache() async {
    if (_currentUser != null) {
      try {
        // Check if Hive adapters are available
        if (!Hive.isAdapterRegistered(0)) {
          return;
        }
        final userBox = await Hive.openBox<User>('users');
        await userBox.put(AppConstants.userCacheKey, _currentUser!);
      } catch (e) {
        print('Error saving user to cache: $e');
      }
    }
  }

  // Load user from Hive cache
  Future<void> _loadUserFromCache() async {
    try {
      // Check if Hive adapters are available
      if (!Hive.isAdapterRegistered(0)) {
        _currentUser = null;
        return;
      }
      final userBox = await Hive.openBox<User>('users');
      _currentUser = userBox.get(AppConstants.userCacheKey);
    } catch (e) {
      print('Error loading user from cache: $e');
      _currentUser = null;
    }
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authTokenKey);
    
    try {
      final userBox = await Hive.openBox<User>('users');
      await userBox.delete(AppConstants.userCacheKey);
    } catch (e) {
      // Ignore cache errors
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }
}
