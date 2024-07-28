import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mqgo_app/widgets/bottom_navigation_bar.dart';

void main() {
  testWidgets('Widget Renders Correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {},
      ),
    ));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Your Cart'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Initial State Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CustomBottomNavigationBar(
        currentIndex: 2, // Example currentIndex
        onTap: (index) {},
      ),
    ));

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Services'),
        findsOneWidget); // Assuming currentIndex is set to 2
  });

  testWidgets('Tap Functionality Test', (WidgetTester tester) async {
    int tappedIndex = -1;

    await tester.pumpWidget(MaterialApp(
      home: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          tappedIndex = index;
        },
      ),
    ));

    await tester.tap(find.text('Services')); // Tap on a specific item
    expect(tappedIndex, 2); // Assuming Services item has index 2
  });

  testWidgets('Navigation Bar Items Text Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {},
      ),
    ));

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Your Cart'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Tap Functionality Changes Index Test',
      (WidgetTester tester) async {
    int tappedIndex = -1;

    await tester.pumpWidget(MaterialApp(
      home: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          tappedIndex = index;
        },
      ),
    ));

    await tester.tap(find.text('Your Cart')); // Tap on a specific item
    expect(tappedIndex, 3); // Assuming Your Cart item has index 3
  });

  testWidgets('Tap Functionality Callback Test', (WidgetTester tester) async {
    int tappedIndex = -1;

    await tester.pumpWidget(MaterialApp(
      home: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          tappedIndex = index;
        },
      ),
    ));

    await tester.tap(find.text('Profile')); // Tap on a specific item
    expect(tappedIndex, 4); // Assuming Profile item has index 4
  });

  testWidgets('Current Index Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CustomBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {},
      ),
    ));

    expect(find.text('Services'), findsOneWidget);
  });

  testWidgets('Tap Functionality Callback Test', (WidgetTester tester) async {
    int tappedIndex = -1;

    await tester.pumpWidget(MaterialApp(
      home: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          tappedIndex = index;
        },
      ),
    ));

    await tester.tap(find.text('Profile')); // Tap on a specific item
    expect(tappedIndex, 4); // Assuming Profile item has index 4
  });

  testWidgets('Current Index Test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CustomBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {},
      ),
    ));

    expect(find.text('Services'), findsOneWidget);
  });

  testWidgets('Correct Navigation Index Test', (WidgetTester tester) async {
    int selectedIndex = -1;

    await tester.pumpWidget(MaterialApp(
      home: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          selectedIndex = index;
        },
      ),
    ));

    await tester.tap(find.text('Explore')); // Tap on a specific item
    expect(selectedIndex, 1); // Assuming Explore item has index 1
  });
}
