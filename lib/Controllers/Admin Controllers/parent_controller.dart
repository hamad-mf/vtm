import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ParentController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? error;

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllParents() {
    return _firestore.collection('parents').orderBy('parentName').snapshots();
  }

  Future<void> deleteParent(String parentId) async {
    await _firestore.collection('parents').doc(parentId).delete();
    await _firestore.collection('roles').doc(parentId).delete();
  }

  Future<void> updateParent(
    String parentId,
    Map<String, String> updatedParentData,
  ) async {
    await _firestore
        .collection('parents')
        .doc(parentId)
        .update(updatedParentData);
  }

  // In ParentController
Stream<QuerySnapshot<Map<String, dynamic>>> getAllStudents() {
  return _firestore.collection('students').orderBy('name').snapshots();
}

Future<void> addParent({
  required String parentName,
  required String parentEmail,
  required String parentPassword,
  required String studentId,        // NEW
  required String studentName,      // NEW for display
  required String studentRegNo,     // OPTIONAL if you want in parent record
  required String parentMobileNo,
  required String parentAddress,
}) async {
  isLoading = true;
  error = null;
  notifyListeners();

  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: parentEmail,
      password: parentPassword,
    );

    String uid = result.user!.uid;

    // Create role entry
    await _firestore.collection('roles').doc(uid).set({'role': 'parent','userId':uid});

    // Save parent info
    await _firestore.collection('parents').doc(uid).set({
      'parentId': uid,
      'parentName': parentName,
      'email': parentEmail,
      'linkedStudentId': studentId, // store reference by id
      'linkedStudentName': studentName,
      'StudentRegNo': studentRegNo,
      'parentMobileNo': parentMobileNo,
      'parentAddress': parentAddress,
      'createdAt': FieldValue.serverTimestamp(),
    });
  } on FirebaseAuthException catch (e) {
    error = e.message;
  } catch (e) {
    error = 'Something went wrong: $e';
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

}
