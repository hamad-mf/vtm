import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? error;

Stream<QuerySnapshot<Map<String, dynamic>>> getAllStudents() {
  return _firestore.collection('students').orderBy('name').snapshots();
}

Future<void> deleteStudent(String studentId) async {
  await _firestore.collection('students').doc(studentId).delete();
  await _firestore.collection('roles').doc(studentId).delete();
}

Future<void> updateStudent(String studentId, Map<String, String> updatedData) async {
  
  await _firestore.collection('students').doc(studentId).update(updatedData);
}

Future<void> addStudent({
  required String name,
  required String email,
  required String password,
  required String registrationNumber,
  required String mobileNumber,
  required String address,
  required String assignedRoute,
  required String paymentStatus,
  required String destinationLatitude,    // NEW
  required String destinationLongitude,   // NEW
}) async {
  isLoading = true;
  error = null;
  notifyListeners();

  try {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    String uid = result.user!.uid;

    await _firestore.collection('roles').doc(uid).set({'role': 'student'});

    await _firestore.collection('students').doc(uid).set({
      'studentId':uid,
      'name': name,
      'email': email,
      'registrationNumber': registrationNumber,
      'mobileNumber': mobileNumber,
      'address': address,
      'assignedRoute': assignedRoute,
      'paymentStatus': paymentStatus,
      'destinationLatitude': double.tryParse(destinationLatitude) ?? 0.0,
      'destinationLongitude': double.tryParse(destinationLongitude) ?? 0.0,
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
