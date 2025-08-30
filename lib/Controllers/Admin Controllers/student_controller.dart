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
    try {
      await _firestore.collection('students').doc(studentId).delete();
      await _firestore.collection('roles').doc(studentId).delete();
    } catch (e) {
      print('Error deleting student: $e');
      rethrow;
    }
  }

  Future<void> updateStudent(
    String studentId,
    Map<String, dynamic> updatedData,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      await _firestore.collection('students').doc(studentId).update(updatedData);
      
      // Also update the roles collection if name was updated
      if (updatedData.containsKey('name')) {
        await _firestore.collection('roles').doc(studentId).update({
          'name': updatedData['name'],
        });
      }
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      print('Error updating student: $e');
      rethrow;
    }
  }

  /// Enhanced update method with validation and better error handling
  Future<bool> updateStudentDetails({
    required BuildContext context,
    required String studentId,
    required String name,
    required String email,
    required String registrationNumber,
    required String mobileNumber,
    required String address,
    required String assignedRouteId,
    required String assignedRouteName,
    required String assignedDriverId,
    required String assignedDriverName,
    required String paymentStatus,
    required double destinationLatitude,
    required double destinationLongitude,
    required DateTime feeExpiryDate,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      // Validate input data
      if (name.trim().isEmpty ||
          email.trim().isEmpty ||
          registrationNumber.trim().isEmpty ||
          mobileNumber.trim().isEmpty ||
          address.trim().isEmpty) {
        throw Exception('All required fields must be filled');
      }

      // Validate coordinates
      if (destinationLatitude < -90 || destinationLatitude > 90) {
        throw Exception('Invalid latitude value');
      }
      if (destinationLongitude < -180 || destinationLongitude > 180) {
        throw Exception('Invalid longitude value');
      }

      // Prepare update data
      Map<String, dynamic> updateData = {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'registrationNumber': registrationNumber.trim(),
        'mobileNumber': mobileNumber.trim(),
        'address': address.trim(),
        'assignedRoute': assignedRouteName.trim(),
        'assignedRouteId': assignedRouteId,
        'assignedDriverId': assignedDriverId,
        'assignedDriverName': assignedDriverName.trim(),
        'paymentStatus': paymentStatus,
        'destinationLatitude': destinationLatitude,
        'destinationLongitude': destinationLongitude,
        'feeExpiryDate': Timestamp.fromDate(feeExpiryDate),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update student document
      await _firestore.collection('students').doc(studentId).update(updateData);

      // Update roles collection
      await _firestore.collection('roles').doc(studentId).update({
        'name': name.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Student updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating student: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Get single student details
  Future<Map<String, dynamic>?> getStudentById(String studentId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('students')
          .doc(studentId)
          .get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting student: $e');
      return null;
    }
  }

  /// Check if email is already in use by another student
  Future<bool> isEmailAvailable(String email, {String? excludeStudentId}) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('students')
          .where('email', isEqualTo: email.trim().toLowerCase())
          .get();
      
      if (excludeStudentId != null) {
        // When updating, exclude the current student's email
        return query.docs.every((doc) => doc.id == excludeStudentId);
      }
      
      return query.docs.isEmpty;
    } catch (e) {
      print('Error checking email availability: $e');
      return false;
    }
  }

  /// Check if registration number is already in use
  Future<bool> isRegistrationNumberAvailable(String regNum, {String? excludeStudentId}) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('students')
          .where('registrationNumber', isEqualTo: regNum.trim())
          .get();
      
      if (excludeStudentId != null) {
        return query.docs.every((doc) => doc.id == excludeStudentId);
      }
      
      return query.docs.isEmpty;
    } catch (e) {
      print('Error checking registration number availability: $e');
      return false;
    }
  }

  Future<void> addStudent({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String registrationNumber,
    required String mobileNumber,
    required String address,
    required String assignedRouteId,
    required String assignedRouteName,
    required String assignedDriverId,
    required String assignedDriverName,
    required String paymentStatus,
    required String destinationLatitude,
    required String destinationLongitude,
    required DateTime feeExpiryDate,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      // Create user account
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // Add student data to Firestore
      await _firestore.collection('students').doc(uid).set({
        'studentId': uid,
        'name': name,
        'email': email,
        'registrationNumber': registrationNumber,
        'mobileNumber': mobileNumber,
        'address': address,
        'assignedRoute': assignedRouteName,
        'assignedDriverId': assignedDriverId,
        'assignedDriverName': assignedDriverName,
        'paymentStatus': paymentStatus,
        'destinationLatitude': double.parse(destinationLatitude),
        'destinationLongitude': double.parse(destinationLongitude),
        'feeExpiryDate': Timestamp.fromDate(feeExpiryDate),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'assignedRouteId': assignedRouteId,
      });

      // Add user role
      await _firestore.collection('roles').doc(uid).set({
        'name': name,
        'fcmToken': null,
        'role': 'student',
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Student added successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error adding student: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Checks if student's fee has expired and updates payment status accordingly
  static Future<String> checkAndUpdateFeeStatus(String studentUid) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get student document
      DocumentSnapshot studentDoc =
          await firestore.collection('students').doc(studentUid).get();

      if (!studentDoc.exists) {
        return 'Pending'; // Default status if document doesn't exist
      }

      final data = studentDoc.data() as Map<String, dynamic>;
      final Timestamp? feeExpiryTimestamp = data['feeExpiryDate'];
      final String currentPaymentStatus = data['paymentStatus'] ?? 'Pending';

      if (feeExpiryTimestamp == null) {
        // If no expiry date is set, return current status
        return currentPaymentStatus;
      }

      final DateTime feeExpiryDate = feeExpiryTimestamp.toDate();
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime expiry = DateTime(
        feeExpiryDate.year,
        feeExpiryDate.month,
        feeExpiryDate.day,
      );

      String newStatus = currentPaymentStatus;

      // CORRECTED Fee expiry logic
      if (today.isAfter(expiry)) {
        // Fee has expired - check if still in grace period (10 days after expiry)
        final int daysAfterExpiry = today.difference(expiry).inDays;

        if (daysAfterExpiry <= 10) {
          // Still within 10-day grace period after expiry
          if (currentPaymentStatus == 'Paid') {
            newStatus = 'Grace';
          }
          // If already Grace, Pending, or Overdue, keep as is during grace period
        } else {
          // Grace period has ended (more than 10 days after expiry)
          newStatus = 'Overdue';
        }
      } else {
        // Fee hasn't expired yet
        if (currentPaymentStatus == 'Grace' ||
            currentPaymentStatus == 'Overdue') {
          // If admin manually set Grace/Overdue but fee hasn't expired, keep as Paid
          newStatus = 'Paid';
        }
        // If Paid or Pending and not expired, keep as is
      }

      // Update status in Firestore if it changed
      if (newStatus != currentPaymentStatus) {
        await firestore.collection('students').doc(studentUid).update({
          'paymentStatus': newStatus,
          'statusUpdatedAt': FieldValue.serverTimestamp(),
        });

        print(
          'Updated payment status for $studentUid: $currentPaymentStatus → $newStatus',
        );
      }

      return newStatus;
    } catch (e) {
      print('Error checking fee status: $e');
      return 'Pending'; // Default fallback status
    }
  }

  /// Gets student payment status with real-time fee checking
  static Future<Map<String, dynamic>> getStudentStatusInfo(
    String studentUid,
  ) async {
    try {
      final String currentStatus = await checkAndUpdateFeeStatus(studentUid);

      // Get updated student data
      final DocumentSnapshot studentDoc =
          await FirebaseFirestore.instance
              .collection('students')
              .doc(studentUid)
              .get();

      if (!studentDoc.exists) {
        return {
          'paymentStatus': 'Pending',
          'feeExpiryDate': null,
          'daysUntilExpiry': null,
          'isGraceActive': false,
          'shouldShowBanner': false, // NEW: for 7-day warning banner
        };
      }

      final data = studentDoc.data() as Map<String, dynamic>;
      final Timestamp? feeExpiryTimestamp = data['feeExpiryDate'];

      DateTime? feeExpiryDate;
      int? daysUntilExpiry;
      bool shouldShowBanner = false;

      if (feeExpiryTimestamp != null) {
        feeExpiryDate = feeExpiryTimestamp.toDate();
        final DateTime now = DateTime.now();
        final DateTime today = DateTime(now.year, now.month, now.day);
        final DateTime expiry = DateTime(
          feeExpiryDate.year,
          feeExpiryDate.month,
          feeExpiryDate.day,
        );

        daysUntilExpiry = expiry.difference(today).inDays;

        // Show banner 7 days before expiry (but keep status as Paid)
        if (daysUntilExpiry <= 7 &&
            daysUntilExpiry >= 0 &&
            currentStatus == 'Paid') {
          shouldShowBanner = true;
        }
      }

      return {
        'paymentStatus': currentStatus,
        'feeExpiryDate': feeExpiryDate,
        'daysUntilExpiry': daysUntilExpiry,
        'isGraceActive': currentStatus == 'Grace',
        'shouldShowBanner': shouldShowBanner, // NEW: for banner display logic
      };
    } catch (e) {
      print('Error getting student status info: $e');
      return {
        'paymentStatus': 'Pending',
        'feeExpiryDate': null,
        'daysUntilExpiry': null,
        'isGraceActive': false,
        'shouldShowBanner': false,
      };
    }
  }

  /// Batch update all students' fee statuses (useful for scheduled tasks)
  static Future<void> batchUpdateAllStudentFeeStatuses() async {
    try {
      final QuerySnapshot studentsQuery =
          await FirebaseFirestore.instance.collection('students').get();

      final List<Future<void>> updateTasks =
          studentsQuery.docs.map((doc) async {
            await checkAndUpdateFeeStatus(doc.id);
          }).toList();

      await Future.wait(updateTasks);
      print('Batch update completed for ${studentsQuery.docs.length} students');
    } catch (e) {
      print('Error in batch update: $e');
    }
  }
}