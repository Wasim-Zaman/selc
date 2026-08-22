import 'package:supabase_flutter/supabase_flutter.dart';

class UserModel {
  final String uid;
  final String? displayName;
  final String? email;
  final String? photoURL;
  final String? phoneNumber;
  final String? role;

  UserModel({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    this.phoneNumber,
    this.role,
  });

  factory UserModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata;
    return UserModel(
      uid: user.id,
      displayName: metadata?['full_name'] ?? metadata?['name'],
      email: user.email,
      photoURL: metadata?['avatar_url'] ?? metadata?['picture'],
      phoneNumber: user.phone,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      displayName: data['displayName'],
      email: data['email'],
      photoURL: data['photoURL'],
      phoneNumber: data['phoneNumber'],
      role: data['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }
}
