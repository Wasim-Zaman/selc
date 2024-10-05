import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _adminCollection = 'admins';
  final String _adminDocId = 'admin';

  static const String _isAdminLoggedInKey = 'isAdminLoggedIn';

  Future<bool> signInAdmin(String phoneNumber, String password) async {
    try {
      DocumentSnapshot adminDoc =
          await _firestore.collection(_adminCollection).doc(_adminDocId).get();

      if (!adminDoc.exists) {
        // Create admin document if it doesn't exist
        await _firestore.collection(_adminCollection).doc(_adminDocId).set({
          'phoneNumber': dotenv.env['ADMIN_PHONE_NUMBER'],
          'password': dotenv.env['ADMIN_PASSWORD'],
        });
        adminDoc = await _firestore
            .collection(_adminCollection)
            .doc(_adminDocId)
            .get();
      }

      Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;

      if (adminData['phoneNumber'] == phoneNumber &&
          adminData['password'] == password) {
        return true;
      }

      return false;
    } catch (e) {
      print('Error signing in admin: $e');
      return false;
    }
  }

  Future<bool> isAdminLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAdminLoggedInKey) ?? false;
  }

  Future<void> setAdminLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isAdminLoggedInKey, value);
  }
}
