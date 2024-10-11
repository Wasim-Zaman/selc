// ignore_for_file: library_prefixes

import 'dart:math' as Math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selc/models/enrolled_students.dart';

class EnrolledStudentsServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'enrolled_students';
  final String _statsCollection = 'stats';
  final String _totalDocId = 'total_students';

  Stream<List<EnrolledStudent>> getEnrolledStudentsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EnrolledStudent.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addStudent(EnrolledStudent student) async {
    await _firestore.runTransaction((transaction) async {
      // Add the new student
      DocumentReference newStudentRef =
          _firestore.collection(_collection).doc();
      transaction.set(newStudentRef, student.toMap());

      // Update total count in subcollection
      DocumentReference totalRef = _firestore
          .collection(_collection)
          .doc(_totalDocId)
          .collection(_statsCollection)
          .doc(_totalDocId);
      DocumentSnapshot totalSnapshot = await transaction.get(totalRef);

      if (totalSnapshot.exists) {
        int currentTotal = totalSnapshot.get('count') as int;
        transaction.update(totalRef, {'count': currentTotal + 1});
      } else {
        transaction.set(totalRef, {'count': 1});
      }
    });
  }

  Future<void> updateStudent(String studentId, EnrolledStudent student) async {
    await _firestore
        .collection(_collection)
        .doc(studentId)
        .update(student.toMap());
  }

  Future<void> deleteStudent(String studentId) async {
    await _firestore.runTransaction((transaction) async {
      // Delete the student
      DocumentReference studentRef =
          _firestore.collection(_collection).doc(studentId);
      transaction.delete(studentRef);

      // Update total count in subcollection
      DocumentReference totalRef = _firestore
          .collection(_collection)
          .doc(_totalDocId)
          .collection(_statsCollection)
          .doc(_totalDocId);
      DocumentSnapshot totalSnapshot = await transaction.get(totalRef);

      if (totalSnapshot.exists) {
        int currentTotal = totalSnapshot.get('count') as int;
        transaction.update(totalRef, {'count': Math.max(0, currentTotal - 1)});
      }
    });
  }

  Future<EnrolledStudent?> getStudentById(String studentId) async {
    DocumentSnapshot doc =
        await _firestore.collection(_collection).doc(studentId).get();
    if (doc.exists) {
      return EnrolledStudent.fromMap(
          doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<List<EnrolledStudent>> getStudentsByLevel(String level) async {
    QuerySnapshot snapshot = await _firestore
        .collection(_collection)
        .where('level', isEqualTo: level)
        .get();
    return snapshot.docs
        .map((doc) =>
            EnrolledStudent.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<int> getTotalStudents() async {
    DocumentSnapshot totalSnapshot = await _firestore
        .collection(_collection)
        .doc(_totalDocId)
        .collection(_statsCollection)
        .doc(_totalDocId)
        .get();
    if (totalSnapshot.exists) {
      return totalSnapshot.get('count') as int;
    }
    return 0;
  }
}
