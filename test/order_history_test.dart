import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:mqgo_app/widgets/order_history.dart';

void main() {
  // Initialize Firebase before running tests
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    await FirebaseAppCheck.instance.activate();
  });

  testWidgets('Widget Renders Correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => buildTestWidget(context),
      ),
    ));

    expect(find.text('Order No:'), findsOneWidget);
    expect(find.text('No orders found.'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Widget Shows No Orders Message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => buildTestWidget(context),
      ),
    ));

    expect(find.text('No orders found.'), findsOneWidget);
    expect(find.text('Order No:'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Widget Shows Loading Indicator', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => buildTestWidget(context),
      ),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Order No:'), findsNothing);
    expect(find.text('No orders found.'), findsNothing);
  });

  testWidgets('Widget Shows Error Message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => buildTestErrorWidget(context),
      ),
    ));

    expect(find.text('Error:'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Order No:'), findsNothing);
    expect(find.text('No orders found.'), findsNothing);
  });
}

Widget buildTestWidget(BuildContext context) {
  return buildOrderHistory(context);
}

Widget buildTestErrorWidget(BuildContext context) {
  // Providing an empty stream to simulate an error
  final Stream<QuerySnapshot> errorStream = Stream.empty();

  return StreamBuilder<QuerySnapshot>(
    stream: errorStream,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        // Use debugPrint to print the error only during debugging
        debugPrint('Error: ${snapshot.error}');
        // Returning an empty container to hide the error message during tests
        return Container();
      }
      // Returning the order history widget even in error case for consistency
      return buildOrderHistory(context);
    },
  );
}
