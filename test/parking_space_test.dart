import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqgo_app/widgets/space_booking_history.dart'; // assuming this is where your buildParkingHistory function resides

void main() {
  testWidgets('Widget Renders Correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) {
          return buildParkingHistory(context);
        },
      ),
    ));

    expect(find.text('Booking No:'), findsOneWidget);
    expect(find.text('No bookings found.'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Widget Shows No Bookings Message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) {
          return buildParkingHistory(context);
        },
      ),
    ));

    expect(find.text('No bookings found.'), findsOneWidget);
    expect(find.text('Booking No:'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Widget Shows Loading Indicator', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) {
          return buildParkingHistory(context);
        },
      ),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Booking No:'), findsNothing);
    expect(find.text('No bookings found.'), findsNothing);
  });

  testWidgets('Widget Shows Error Message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) {
          return StreamBuilder<QuerySnapshot>(
            stream: null,
            builder: (context, snapshot) {
              return buildParkingHistory(context);
            },
          );
        },
      ),
    ));

    expect(find.text('Error:'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Booking No:'), findsNothing);
    expect(find.text('No bookings found.'), findsNothing);
  });
}
