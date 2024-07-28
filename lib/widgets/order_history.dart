import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Widget buildOrderHistory(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('my_restaurant_orders')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text(
          'Error: ${snapshot.error}',
          style: TextStyle(color: Colors.red), // Error text color
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
        return Text(
          'No orders found.',
          style: TextStyle(color: Colors.black87), // Text color
        );
      }

      return ListView(
        children: snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          List<dynamic> items = data['items'];
          String paymentMethod =
              data['paymentMethod'] == 'PAY_LATER' ? 'Pay Later' : 'Card';
          return Card(
            margin: EdgeInsets.all(10),
            elevation: 4, // Card elevation
            child: ExpansionTile(
              title: Text(
                'Order No: ${document.id}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: items.asMap().entries.map<Widget>((entry) {
                int index = entry.key;
                Map<String, dynamic> item = entry.value;
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        item['itemName'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Quantity: ${item['quantity']}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: Text(
                        'Total: \$${item['totalPrice']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      leading: Image.network(
                        item['itemImage'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Payment Method: $paymentMethod',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Payment Received: ${data['paymentReceived'] ? 'Yes' : 'No'}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    if (index != items.length - 1) Divider(),
                  ],
                );
              }).toList(),
            ),
          );
        }).toList(),
      );
    },
  );
}
