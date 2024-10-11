// ignore_for_file: library_prefixes, depend_on_referenced_packages, unused_import

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
    try {
      // First, get a new document reference
      final docRef = _firestore.collection('enrolled_students').doc();

      // Then, set the data for this document
      await docRef.set(student.toMap()..['id'] = docRef.id);
    } catch (e) {
      print('Error adding student: $e');
      rethrow;
    }
  }

  Future<void> updateStudent(String studentId, EnrolledStudent student) async {
    await _firestore
        .collection(_collection)
        .doc(studentId)
        .update(student.toMap());
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      await _firestore.collection('enrolled_students').doc(studentId).delete();
    } catch (e) {
      print('Error deleting student: $e');
      rethrow;
    }
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

  Future<List<EnrolledStudent>> getStudentsByYear(int year) async {
    QuerySnapshot snapshot = await _firestore
        .collection(_collection)
        .where('enrollmentDate',
            isGreaterThanOrEqualTo: DateTime(year, 1, 1).toIso8601String())
        .where('enrollmentDate',
            isLessThan: DateTime(year + 1, 1, 1).toIso8601String())
        .get();
    return snapshot.docs
        .map((doc) =>
            EnrolledStudent.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<int> getStudentCountByYear(int year) async {
    DocumentSnapshot yearSnapshot = await _firestore
        .collection(_collection)
        .doc(_totalDocId)
        .collection(_statsCollection)
        .doc(year.toString())
        .get();
    if (yearSnapshot.exists) {
      return yearSnapshot.get('count') as int;
    }
    return 0;
  }

  Future<void> _updateTotalCount(Transaction transaction, int increment) async {
    DocumentReference totalRef = _firestore
        .collection(_collection)
        .doc(_totalDocId)
        .collection(_statsCollection)
        .doc(_totalDocId);
    DocumentSnapshot totalSnapshot = await transaction.get(totalRef);

    if (totalSnapshot.exists) {
      int currentTotal = totalSnapshot.get('count') as int;
      transaction.update(totalRef, {'count': currentTotal + increment});
    } else {
      transaction.set(totalRef, {'count': increment});
    }
  }

  Future<void> _updateYearCount(
      Transaction transaction, int year, int increment) async {
    DocumentReference yearRef = _firestore
        .collection(_collection)
        .doc(_totalDocId)
        .collection(_statsCollection)
        .doc(year.toString());
    DocumentSnapshot yearSnapshot = await transaction.get(yearRef);

    if (yearSnapshot.exists) {
      int currentCount = yearSnapshot.get('count') as int;
      transaction.update(yearRef, {'count': currentCount + increment});
    } else {
      transaction.set(yearRef, {'count': increment});
    }
  }
}
