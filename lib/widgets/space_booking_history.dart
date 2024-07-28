import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

Widget buildParkingHistory(BuildContext context) {
  final DateFormat dateFormat = DateFormat('MMM d, yyyy');

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('parking_space_bookings')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text(
            'Error: ${snapshot.error}',
            style: TextStyle(color: Colors.red),
          ),
        );
      }

      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF60C3B)),
          ),
        );
      }

      if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Text(
            'No bookings found.',
            style: TextStyle(color: Colors.black87),
          ),
        );
      }

      return ListView.builder(
        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
          final DocumentSnapshot document = snapshot.data!.docs[index];
          final Map<String, dynamic> data =
              document.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              child: ExpansionTile(
                title: Text(
                  'Booking No: ${document.id}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  ListTile(
                    title: Text(
                      'Space Name: ${data['spaceName']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date: ${dateFormat.format(data['startDate'].toDate())}',
                        ),
                        Text(
                          'End Date: ${dateFormat.format(data['endDate'].toDate())}',
                        ),
                        Text(
                          'Total Price: \$${data['totalPrice']}',
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('parking_space_bookings')
                            .doc(document.id)
                            .delete();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
