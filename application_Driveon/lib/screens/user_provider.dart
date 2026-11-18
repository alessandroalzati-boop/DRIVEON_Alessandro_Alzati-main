// lib/screens/user_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  final Set<String> _favoriteVins = {};
  final Set<String> _rentedVins = {};

  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  Set<String> get favoriteVins => _favoriteVins;
  Set<String> get rentedVins => _rentedVins;

  static const String _favoriteStorageKey = 'favorite_vins';
  static const String _rentedStorageKey = 'rented_vins';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _favoriteVins.clear();
    _favoriteVins.addAll(prefs.getStringList(_favoriteStorageKey) ?? []);
    _rentedVins.clear();
    _rentedVins.addAll(prefs.getStringList(_rentedStorageKey) ?? []);
    _userName = prefs.getString(_userNameKey);
    _userEmail = prefs.getString(_userEmailKey);
    _isLoggedIn = _userName != null && _userName!.isNotEmpty;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setUserData({required String name, required String email}) async {
    _userName = name;
    _userEmail = email;
    _isLoggedIn = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);

    notifyListeners();
  }

  Future<void> logout() async {
    _userName = null;
    _userEmail = null;
    _isLoggedIn = false;
    _favoriteVins.clear();
    _rentedVins.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);

    notifyListeners();
  }

  Future<void> toggleFavorite(String vin) async {
    if (_favoriteVins.contains(vin)) {
      _favoriteVins.remove(vin);
    } else {
      _favoriteVins.add(vin);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoriteStorageKey, _favoriteVins.toList());

    notifyListeners();
  }

  Future<void> addRental(String vin) async {
    _rentedVins.add(vin);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_rentedStorageKey, _rentedVins.toList());

    notifyListeners();
  }

  Future<void> removeRental(String vin) async {
    _rentedVins.remove(vin);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_rentedStorageKey, _rentedVins.toList());

    notifyListeners();
  }
}

