import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VehicleController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? error;

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllVehicles() {
    return _firestore.collection('vehicles').orderBy('busId').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAvailableVehicles() {
    return _firestore
        .collection('vehicles')
        .where('assignedRouteId', isEqualTo: null)
        .where('assignedDriverId', isEqualTo: null)
        .where('status', isEqualTo: 'Active')
        .snapshots();
  }

  Future<void> addVehicle({
    required String busId,
    required String vehicleNumber,
    required String type,
    required int capacity,
    required DateTime registrationExpiry,
    required DateTime insuranceExpiry,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      Map<String, dynamic> data = {
        'busId': busId,
        'vehicleNumber': vehicleNumber,
        'type': type,
        'capacity': capacity,
        'registrationExpiry': Timestamp.fromDate(registrationExpiry),
        'insuranceExpiry': Timestamp.fromDate(insuranceExpiry),
        'status': 'Active',
        'assignedRouteId': null,
        'assignedDriverId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp()
      };
      await _firestore.collection('vehicles').doc(busId).set(data);
    } catch (e) {
      error = 'Failed to add vehicle: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVehicle(String vehicleId, Map<String, dynamic> updatedData) async {
    isLoading = true;
    try {
      updatedData['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('vehicles').doc(vehicleId).update(updatedData);
    } catch (e) {
      error = 'Failed to update vehicle: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    isLoading = true;
    try {
      DocumentSnapshot doc =
          await _firestore.collection('vehicles').doc(vehicleId).get();
      final data = doc.data() as Map<String, dynamic>?;
      if (data?['assignedDriverId'] != null || data?['assignedRouteId'] != null) {
        throw Exception('Cannot delete a vehicle assigned to a driver or route');
      }
      await _firestore.collection('vehicles').doc(vehicleId).delete();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
