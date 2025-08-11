import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  Future<void> updateStudent(
    String studentId,
    Map<String, String> updatedData,
  ) async {
    await _firestore.collection('students').doc(studentId).update(updatedData);
  }

  Future<void> addStudent({
    required String assignedDriverId,
    required String assignedDriverName,
    required String name,
    required String email,
    required String password,
    required String registrationNumber,
    required String mobileNumber,
    required String address,
    required String assignedRoute,
    required String paymentStatus,
    required String destinationLatitude, // NEW
    required String destinationLongitude, // NEW
    required BuildContext context,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    var querySnapshot =
        await _firestore
            .collection('students')
            .where('registrationNumber', isEqualTo: registrationNumber)
            .get();
    if (querySnapshot.docs.isNotEmpty) {
      // Show error: duplicate registration number
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Register number is already in use")),
      );
      isLoading = false;
      notifyListeners();
    } else {
      // Proceed to add student or parent

      try {
        UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String uid = result.user!.uid;

        await _firestore.collection('roles').doc(uid).set({'role': 'student'});

        await _firestore.collection('students').doc(uid).set({
          'assignedDriverId': assignedDriverId,
          'assignedDriverName': assignedDriverName,
          'studentId': uid,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Student added successfully"),
            backgroundColor: Color(0xff4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
        Navigator.pop(context);
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
}
