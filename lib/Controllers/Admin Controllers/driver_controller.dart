import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? error;

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllDrivers() {
    return _firestore.collection('drivers').orderBy('name').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAvailableDrivers() {
    return _firestore
        .collection('drivers')
        .where('isAssigned', isEqualTo: false)
        .snapshots();
  }

  Future<void> addDriver({
    required String name,
    required String email,
    required String password,
    required String employeeId,
    required String contactNumber,
    required String licenseNumber,
    required String licenseType,
    required DateTime licenseExpiry,
    required String assignedBusId,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      DocumentSnapshot busDoc =
          await _firestore.collection('vehicles').doc(assignedBusId).get();
      if (!busDoc.exists) {
        throw Exception("Assigned bus not found");
      }
      if (busDoc['assignedDriverId'] != null) {
        throw Exception("This bus is already assigned to another driver");
      }

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String uid = result.user!.uid;

      await _firestore.collection('roles').doc(uid).set({'role': 'driver'});

      Map<String, dynamic> driverData = {
        'name': name,
        'email': email,
        'employeeId': employeeId,
        'contactNumber': contactNumber,
        'licenseNumber': licenseNumber,
        'licenseType': licenseType,
        'licenseExpiry': Timestamp.fromDate(licenseExpiry),
        'assignedBusId': assignedBusId,
        'isAssigned': false,
        'assignedRoute': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('drivers').doc(uid).set(driverData);

      await _firestore.collection('vehicles').doc(assignedBusId).update({
        'assignedDriverId': uid,
        'assignedRouteId': null
      });
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDriver(String driverId, Map<String, dynamic> updatedData) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      updatedData['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('drivers').doc(driverId).update(updatedData);
    } catch (e) {
      error = 'Failed to update driver: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDriver(String driverId) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      DocumentSnapshot driverDoc =
          await _firestore.collection('drivers').doc(driverId).get();
      if (driverDoc.exists) {
        final data = driverDoc.data() as Map<String, dynamic>;
        final busId = data['assignedBusId'];
        final routeId = data['assignedRoute'];

        if (routeId != null) {
          await _firestore.collection('routes').doc(routeId).update({
            'assignedDriverId': null,
            'assignedDriverName': null,
            'assignedVehicleId': null
          });
        }
        if (busId != null) {
          await _firestore.collection('vehicles').doc(busId).update({
            'assignedDriverId': null,
            'assignedRouteId': null
          });
        }
      }
      await _firestore.collection('drivers').doc(driverId).delete();
      await _firestore.collection('roles').doc(driverId).delete();
    } catch (e) {
      error = 'Failed to delete driver: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
