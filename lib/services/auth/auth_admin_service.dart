import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _adminCollection = 'admins';
  final String _adminDocId = 'admin';

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
}
