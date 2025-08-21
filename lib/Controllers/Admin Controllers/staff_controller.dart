import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class StaffController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? error;

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllStaffs() {
    return _firestore.collection('staff').orderBy('name').snapshots();
  }

  Future<void> deleteStaff(String staffId) async {
    await _firestore.collection('staff').doc(staffId).delete();
    await _firestore.collection('roles').doc(staffId).delete();
  }

  Future<void> updateStaff(
    String staffId,
    Map<String, String> updatedData,
  ) async {
    await _firestore.collection('staff').doc(staffId).update(updatedData);
  }

  Future<void> addStaff({
    required String name,
    required String email,
    required String password,
    required String assignedRouteId,
    required String assignedRouteName,
    required String assignedDriverId,
    required String assignedDriverName,
    required String destinationLatitude,
    required String destinationLongitude,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // 1. Create staff user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = result.user!.uid;

      // 2. Create role entry
      await _firestore.collection('roles').doc(uid).set({'role': 'staff'});

      // 3. Save staff data
      await _firestore.collection('staff').doc(uid).set({
        'role':"staff",
        'staffId': uid,
        'name': name,
        'email': email,
        'assignedRouteId': assignedRouteId,
        'assignedRouteName': assignedRouteName,
        'assignedDriverId': assignedDriverId,
        'assignedDriverName': assignedDriverName,
        'destinationLatitude': double.parse(destinationLatitude),
        'destinationLongitude': double.parse(destinationLongitude),
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
