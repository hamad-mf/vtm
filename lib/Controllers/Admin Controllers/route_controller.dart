import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RouteController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? error;

  // Get all routes
  Stream<QuerySnapshot<Map<String, dynamic>>> getAllRoutes() {
    return _firestore.collection('routes').orderBy('routeName').snapshots();
  }

  // Get routes without assigned drivers
  Stream<QuerySnapshot<Map<String, dynamic>>> getUnassignedRoutes() {
    return _firestore
        .collection('routes')
        .where('assignedDriverId', isEqualTo: null)
        .orderBy('routeName')
        .snapshots();
  }

  // Add new route
  Future<void> addRoute({
    required String routeName,
    required String startPointName,
    required double startLatitude,
    required double startLongitude,
    required String endPointName,
    required double endLatitude,
    required double endLongitude,
    required List<Map<String, dynamic>> stops,
    required List<String> timings,
    required String frequency,
    String? assignedDriverId,
    String? assignedDriverName,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Create route document
      DocumentReference routeRef = await _firestore.collection('routes').add({
        'routeName': routeName,
        'startPoint': {
          'name': startPointName,
          'latitude': startLatitude,
          'longitude': startLongitude,
        },
        'endPoint': {
          'name': endPointName,
          'latitude': endLatitude,
          'longitude': endLongitude,
        },
        'stops': stops,
        'timings': timings,
        'frequency': frequency,
        'assignedDriverId': assignedDriverId,
        'assignedDriverName': assignedDriverName,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // If driver is assigned, update driver document
      if (assignedDriverId != null) {
        await _firestore.collection('drivers').doc(assignedDriverId).update({
          'isAssigned': true,
          'assignedRoute': routeRef.id,
        });
      }

      error = null;
    } catch (e) {
      error = 'Failed to add route: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Update route
  Future<void> updateRoute(String routeId, Map<String, dynamic> updatedData) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _firestore.collection('routes').doc(routeId).update(updatedData);
      error = null;
    } catch (e) {
      error = 'Failed to update route: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Delete route
  Future<void> deleteRoute(String routeId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Get route document to check assigned driver
      DocumentSnapshot routeDoc = await _firestore.collection('routes').doc(routeId).get();
      
      if (routeDoc.exists) {
        Map<String, dynamic> routeData = routeDoc.data() as Map<String, dynamic>;
        
        // If driver is assigned, unassign them
        if (routeData['assignedDriverId'] != null) {
          await _firestore.collection('drivers').doc(routeData['assignedDriverId']).update({
            'isAssigned': false,
            'assignedRoute': null,
          });
        }
      }

      // Delete route document
      await _firestore.collection('routes').doc(routeId).delete();
      
      error = null;
    } catch (e) {
      error = 'Failed to delete route: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Assign driver to route
  Future<void> assignDriverToRoute(String routeId, String driverId, String driverName) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Update route document
      await _firestore.collection('routes').doc(routeId).update({
        'assignedDriverId': driverId,
        'assignedDriverName': driverName,
      });

      // Update driver document
      await _firestore.collection('drivers').doc(driverId).update({
        'isAssigned': true,
        'assignedRoute': routeId,
      });

      error = null;
    } catch (e) {
      error = 'Failed to assign driver to route: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Unassign driver from route
  Future<void> unassignDriverFromRoute(String routeId, String driverId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Update route document
      await _firestore.collection('routes').doc(routeId).update({
        'assignedDriverId': null,
        'assignedDriverName': null,
      });

      // Update driver document
      await _firestore.collection('drivers').doc(driverId).update({
        'isAssigned': false,
        'assignedRoute': null,
      });

      error = null;
    } catch (e) {
      error = 'Failed to unassign driver from route: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Toggle route active status
  Future<void> toggleRouteStatus(String routeId, bool isActive) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _firestore.collection('routes').doc(routeId).update({
        'isActive': isActive,
      });
      error = null;
    } catch (e) {
      error = 'Failed to update route status: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Get route by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getRouteById(String routeId) async {
    return await _firestore.collection('routes').doc(routeId).get();
  }

  // Get driver details by route
  Future<DocumentSnapshot<Map<String, dynamic>>?> getDriverByRoute(String routeId) async {
    try {
      DocumentSnapshot routeDoc = await _firestore.collection('routes').doc(routeId).get();
      
      if (routeDoc.exists) {
        Map<String, dynamic> routeData = routeDoc.data() as Map<String, dynamic>;
        
        if (routeData['assignedDriverId'] != null) {
          return await _firestore.collection('drivers').doc(routeData['assignedDriverId']).get();
        }
      }
      
      return null;
    } catch (e) {
      error = 'Failed to get driver details: $e';
      return null;
    }
  }
}