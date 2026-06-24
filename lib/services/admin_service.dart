import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage admin mode
/// Stores admin status locally (can be extended with backend authentication)
class AdminService {
  static const String _adminModeKey = 'admin_mode';

  // Default password - should be changed in production or fetched from backend
  static const String _defaultPassword = 'admin123';

  AdminService._();
  static final AdminService _instance = AdminService._();
  factory AdminService() => _instance;

  Future<bool> isAdminMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_adminModeKey) ?? false;
  }

  Future<bool> enableAdminMode(String password) async {
    // TODO: In production, validate password against backend
    if (password != _defaultPassword) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adminModeKey, true);
    return true;
  }

  Future<void> disableAdminMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adminModeKey, false);
  }

  Future<bool> validatePassword(String password) async {
    // TODO: In production, validate against backend
    return password == _defaultPassword;
  }
}
