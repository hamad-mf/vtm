import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentRouteDetails extends StatelessWidget {
  const StudentRouteDetails({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF7B61A1);
    final studentId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        title: const Text(
          "My Route",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('students')
                .doc(studentId)
                .get(),
        builder: (context, studentSnap) {
          if (studentSnap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }
          if (!studentSnap.hasData || !studentSnap.data!.exists) {
            return const Center(
              child: Text(
                "Student profile not found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final studentData = studentSnap.data!.data() as Map<String, dynamic>;
          final assignedRouteId = studentData['assignedRouteId'];

          if (assignedRouteId == null || assignedRouteId.isEmpty) {
            return const Center(
              child: Text(
                "No route assigned",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Now fetch the route doc with matching routeId
          return StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('routes')
                    .where('routeId', isEqualTo: assignedRouteId)
                    .snapshots(),
            builder: (context, routeSnap) {
              if (routeSnap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }
              if (!routeSnap.hasData || routeSnap.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No route details found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              final data =
                  routeSnap.data!.docs.first.data() as Map<String, dynamic>;
              final stops =
                  (data['stops'] as List?)?.map((s) => s.toString()).toList() ??
                  [];
              final timings =
                  (data['timings'] as List?)
                      ?.map((t) => t.toString())
                      .toList() ??
                  [];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Route Name
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        data['routeName'] ?? 'Unnamed Route',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: primaryColor,
                        ),
                      ),
                      subtitle: Text(
                        "Assigned Vehicle: ${data['assignedVehicleId'] ?? '-'}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Start & End Points
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Start Point:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: primaryColor,
                            ),
                          ),
                          Text(data['startPoint']?['name'] ?? '-'),
                          const SizedBox(height: 8),
                          const Text(
                            "End Point:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: primaryColor,
                            ),
                          ),
                          Text(data['endPoint']?['name'] ?? '-'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Frequency
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      title: const Text(
                        "Frequency",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                      trailing: Text(
                        data['frequency'] ?? '-',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stops
                  // Card(
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   elevation: 3,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(12),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         const Text(
                  //           "Stops:",
                  //           style: TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 16,
                  //             color: primaryColor,
                  //           ),
                  //         ),
                  //         const SizedBox(height: 8),
                  //         if (stops.isEmpty)
                  //           const Text(
                  //             "No stops available",
                  //             style: TextStyle(fontSize: 14, color: Colors.black54),
                  //           )
                  //         else
                  //           for (int i = 0; i < stops.length; i++)
                  //             Padding(
                  //               padding: const EdgeInsets.symmetric(vertical: 4),
                  //               child: Text(
                  //                 "${i + 1}. ${stops[i]} "
                  //                 "${(i < timings.length) ? '(${timings[i]})' : ''}",
                  //                 style: const TextStyle(fontSize: 14),
                  //               ),
                  //             ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
