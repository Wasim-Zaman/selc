import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selc/models/banner.dart';

class BannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'banners';

  Stream<List<BannerModel>> getBannersStream() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BannerModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addBanner(BannerModel banner) async {
    await _firestore.collection(_collection).add(banner.toMap());
  }

  Future<void> updateBanner(String id, BannerModel banner) async {
    await _firestore.collection(_collection).doc(id).update(banner.toMap());
  }

  Future<void> deleteBanner(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<BannerModel> getBanner(String id) async {
    DocumentSnapshot doc =
        await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) {
      throw Exception('Banner not found');
    }
    return BannerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }
}
