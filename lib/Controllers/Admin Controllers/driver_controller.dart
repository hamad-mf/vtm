import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? error;

  // Get all drivers
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllDrivers() {
    return _firestore.collection('drivers').orderBy('name').snapshots();
  }

  // Get available drivers (not assigned to any route) - FIXED VERSION
  Stream<QuerySnapshot<Map<String, dynamic>>> getAvailableDrivers() {
    // Remove the orderBy to avoid index issues and handle ordering in the UI if needed
    return _firestore
        .collection('drivers')
        .where('isAssigned', isEqualTo: false)
        .snapshots();
  }

  // Alternative method without orderBy for troubleshooting
  Stream<QuerySnapshot<Map<String, dynamic>>> getAvailableDriversDebug() {
    return _firestore
        .collection('drivers')
        .snapshots()
        .map((snapshot) => snapshot);
  }

  // Add new driver - ENHANCED VERSION
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
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = result.user!.uid;

      // Add role to roles collection
      await _firestore.collection('roles').doc(uid).set({'role': 'driver'});

      // Add driver details with explicit field values
      Map<String, dynamic> driverData = {
        'name': name,
        'email': email,
        'employeeId': employeeId,
        'contactNumber': contactNumber,
        'licenseNumber': licenseNumber,
        'licenseType': licenseType,
        'licenseExpiry': Timestamp.fromDate(licenseExpiry),
        'assignedBusId': assignedBusId,
        'isAssigned': false, // Explicitly set as false
        'assignedRoute': null, // Explicitly set as null
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('drivers').doc(uid).set(driverData);

      print('Driver created with isAssigned: false'); // Debug log
      error = null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}'); // Debug log
      error = e.message;
    } catch (e) {
      print('General error: $e'); // Debug log
      error = 'Something went wrong: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Update driver
  Future<void> updateDriver(String driverId, Map<String, dynamic> updatedData) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Add updatedAt timestamp
      updatedData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('drivers').doc(driverId).update(updatedData);
      error = null;
    } catch (e) {
      error = 'Failed to update driver: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Delete driver
  Future<void> deleteDriver(String driverId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // First check if driver is assigned to any route
      DocumentSnapshot driverDoc = await _firestore.collection('drivers').doc(driverId).get();
      
      if (driverDoc.exists) {
        Map<String, dynamic> driverData = driverDoc.data() as Map<String, dynamic>;
        
        // If driver is assigned to a route, update the route to remove driver assignment
        if (driverData['assignedRoute'] != null) {
          await _firestore.collection('routes').doc(driverData['assignedRoute']).update({
            'assignedDriverId': null,
            'assignedDriverName': null,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Delete driver document
      await _firestore.collection('drivers').doc(driverId).delete();
      
      // Delete from roles collection
      await _firestore.collection('roles').doc(driverId).delete();
      
      error = null;
    } catch (e) {
      error = 'Failed to delete driver: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Assign driver to route
  Future<void> assignDriverToRoute(String driverId, String routeId, String routeName) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Get driver data first
      DocumentSnapshot driverDoc = await _firestore.collection('drivers').doc(driverId).get();
      if (!driverDoc.exists) {
        error = 'Driver not found';
        return;
      }

      String driverName = (driverDoc.data() as Map<String, dynamic>)['name'];

      // Use batch write for atomicity
      WriteBatch batch = _firestore.batch();

      // Update driver document
      batch.update(_firestore.collection('drivers').doc(driverId), {
        'isAssigned': true,
        'assignedRoute': routeId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update route document
      batch.update(_firestore.collection('routes').doc(routeId), {
        'assignedDriverId': driverId,
        'assignedDriverName': driverName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      error = null;
    } catch (e) {
      error = 'Failed to assign driver: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Unassign driver from route
  Future<void> unassignDriverFromRoute(String driverId, String routeId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Use batch write for atomicity
      WriteBatch batch = _firestore.batch();

      // Update driver document
      batch.update(_firestore.collection('drivers').doc(driverId), {
        'isAssigned': false,
        'assignedRoute': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update route document
      batch.update(_firestore.collection('routes').doc(routeId), {
        'assignedDriverId': null,
        'assignedDriverName': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      error = null;
    } catch (e) {
      error = 'Failed to unassign driver: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Debug method to check all drivers and their isAssigned status
  Future<void> debugDriversStatus() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('drivers').get();
      print('=== DRIVER DEBUG INFO ===');
      print('Total drivers: ${snapshot.docs.length}');
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('Driver: ${data['name']}, isAssigned: ${data['isAssigned']}, assignedRoute: ${data['assignedRoute']}');
      }
      
      // Also check available drivers query
      QuerySnapshot availableSnapshot = await _firestore
          .collection('drivers')
          .where('isAssigned', isEqualTo: false)
          .get();
      print('Available drivers count: ${availableSnapshot.docs.length}');
    } catch (e) {
      print('Debug error: $e');
    }
  }
}