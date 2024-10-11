import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selc/models/about_me.dart';

class AboutMeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AboutMe> getAboutMeData() async {
    final doc = await _firestore.collection('about_me').doc('admin').get();
    if (doc.exists) {
      return AboutMe.fromMap(doc.data()!);
    }
    return AboutMe();
  }

  Future<void> updateAboutMeData(AboutMe aboutMe) async {
    await _firestore.collection('about_me').doc('admin').set(aboutMe.toMap());
  }

  Stream<AboutMe> getAboutMeStream() {
    return _firestore
        .collection('about_me')
        .doc('admin')
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return AboutMe.fromMap(doc.data()!);
      }
      return AboutMe();
    });
  }
}
