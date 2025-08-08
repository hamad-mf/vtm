import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RouteController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? error;

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllRoutes() {
    return _firestore.collection('routes').orderBy('routeName').snapshots();
  }

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
    notifyListeners();
    try {
      final routeRef = _firestore.collection('routes').doc();

      final routeData = {
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
        'assignedVehicleId': null,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await routeRef.set(routeData);

      if (assignedDriverId != null) {
        final driverDoc =
            await _firestore.collection('drivers').doc(assignedDriverId).get();
        final busId = driverDoc['assignedBusId'];

        await _firestore.collection('drivers').doc(assignedDriverId).update({
          'isAssigned': true,
          'assignedRoute': routeRef.id
        });

        if (busId != null) {
          await _firestore.collection('vehicles').doc(busId).update({
            'assignedRouteId': routeRef.id
          });

          await routeRef.update({'assignedVehicleId': busId});
        }
      }
    } catch (e) {
      error = 'Failed to add route: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> assignDriverToRoute(
      String routeId, String driverId, String driverName) async {
    isLoading = true;
    notifyListeners();
    try {
      final driverDoc =
          await _firestore.collection('drivers').doc(driverId).get();
      final busId = driverDoc['assignedBusId'];

      if (busId == null) {
        throw Exception('Driver has no assigned vehicle');
      }

      final busDoc =
          await _firestore.collection('vehicles').doc(busId).get();
      if (busDoc['assignedRouteId'] != null) {
        throw Exception('Vehicle already assigned to another route');
      }

      final batch = _firestore.batch();
      batch.update(_firestore.collection('routes').doc(routeId), {
        'assignedDriverId': driverId,
        'assignedDriverName': driverName,
        'assignedVehicleId': busId
      });
      batch.update(_firestore.collection('drivers').doc(driverId), {
        'isAssigned': true,
        'assignedRoute': routeId
      });
      batch.update(_firestore.collection('vehicles').doc(busId), {
        'assignedRouteId': routeId
      });

      await batch.commit();
    } catch (e) {
      error = 'Failed to assign driver to route: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> unassignDriverFromRoute(String routeId, String driverId) async {
    isLoading = true;
    notifyListeners();
    try {
      final driverDoc =
          await _firestore.collection('drivers').doc(driverId).get();
      final busId = driverDoc['assignedBusId'];

      final batch = _firestore.batch();
      batch.update(_firestore.collection('routes').doc(routeId), {
        'assignedDriverId': null,
        'assignedDriverName': null,
        'assignedVehicleId': null
      });
      batch.update(_firestore.collection('drivers').doc(driverId), {
        'isAssigned': false,
        'assignedRoute': null
      });
      if (busId != null) {
        batch.update(_firestore.collection('vehicles').doc(busId), {
          'assignedRouteId': null
        });
      }

      await batch.commit();
    } catch (e) {
      error = 'Failed to unassign driver: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteRoute(String routeId) async {
    isLoading = true;
    notifyListeners();
    try {
      final routeDoc =
          await _firestore.collection('routes').doc(routeId).get();
      if (routeDoc.exists) {
        final data = routeDoc.data() as Map<String, dynamic>;
        final driverId = data['assignedDriverId'];
        final vehicleId = data['assignedVehicleId'];

        if (driverId != null) {
          await _firestore.collection('drivers').doc(driverId).update({
            'isAssigned': false,
            'assignedRoute': null
          });
        }
        if (vehicleId != null) {
          await _firestore.collection('vehicles').doc(vehicleId).update({
            'assignedRouteId': null
          });
        }
      }
      await _firestore.collection('routes').doc(routeId).delete();
    } catch (e) {
      error = 'Failed to delete route: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle route active status
  /// On deactivation, unassign driver & vehicle to free them up
  Future<void> toggleRouteStatus(String routeId, bool isActive) async {
    isLoading = true;
    notifyListeners();
    try {
      final routeDoc =
          await _firestore.collection('routes').doc(routeId).get();
      if (!routeDoc.exists) {
        error = 'Route not found';
        return;
      }

      final data = routeDoc.data() as Map<String, dynamic>;
      final driverId = data['assignedDriverId'];
      final vehicleId = data['assignedVehicleId'];

      await _firestore.collection('routes').doc(routeId).update({
        'isActive': isActive,
      });

      if (!isActive) {
        // On deactivation, free driver and vehicle
        final batch = _firestore.batch();

        if (driverId != null) {
          batch.update(_firestore.collection('drivers').doc(driverId), {
            'isAssigned': false,
            'assignedRoute': null
          });
        }
        if (vehicleId != null) {
          batch.update(_firestore.collection('vehicles').doc(vehicleId), {
            'assignedRouteId': null
          });
        }
        batch.update(_firestore.collection('routes').doc(routeId), {
          'assignedDriverId': null,
          'assignedDriverName': null,
          'assignedVehicleId': null,
        });

        await batch.commit();
      }
    } catch (e) {
      error = 'Failed to update route status: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
