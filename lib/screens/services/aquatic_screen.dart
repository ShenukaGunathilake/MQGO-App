import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mqgo_app/screens/cart/cart_screen.dart';
import 'package:mqgo_app/screens/common/explore_screen.dart';
import 'package:mqgo_app/screens/common/home.dart';
import 'package:mqgo_app/screens/auth/login.dart';
import 'package:mqgo_app/screens/common/profile_screen.dart';
import 'package:mqgo_app/screens/services/services_screen.dart';
import 'package:mqgo_app/widgets/bottom_navigation_bar.dart';

class AquaticScreen extends StatefulWidget {
  const AquaticScreen({Key? key}) : super(key: key);

  @override
  State<AquaticScreen> createState() => _AquaticState();
}

class _AquaticState extends State<AquaticScreen> {
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    ServicesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  Future<bool> _checkAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user !=
        null; // Return true if user is authenticated, false otherwise
  }

  void _onTabTapped(int index) async {
    setState(() {
      _currentIndex = index;
    });

    bool isAuthenticated = await _checkAuthentication();

    if (isAuthenticated) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => _screens[index],
      ));
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogIn()),
      );
    }
  }

  void _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        setState(() {
          userName = snapshot.data()?['name'];
          userEmail = user.email;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Back'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aquatic Space',
                    style:
                        TextStyle(fontSize: 34.0, fontWeight: FontWeight.bold),
                  ),
                  Image.asset(
                    'images/pool.png',
                    width: 60.0,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Secure Your Spot!',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Secure Your Spot: Reserve Your Aquatic Space Effortlessly',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300),
                  ),
                  SizedBox(height: 8.0),
                  Image(
                    image: AssetImage('images/poolCard.jpg'),
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(height: 50.0),
                  Center(
                    child: Text(
                      'No Data Found!',
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
