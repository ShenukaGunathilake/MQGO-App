import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mqgo_app/screens/services/aquatic_screen.dart';
import 'package:mqgo_app/screens/services/ask_mq_screen.dart';
import 'package:mqgo_app/screens/cart/cart_screen.dart';
import 'package:mqgo_app/screens/common/explore_screen.dart';
import 'package:mqgo_app/screens/services/fitness_screen.dart';
import 'package:mqgo_app/screens/common/home.dart';
import 'package:mqgo_app/screens/auth/login.dart';
import 'package:mqgo_app/screens/services/parking-spaces/parking_screen.dart';
import 'package:mqgo_app/screens/common/profile_screen.dart';
import 'package:mqgo_app/screens/services/restaurants/restaurants_screen.dart';
import 'package:mqgo_app/screens/services/study_screen.dart';
import 'package:mqgo_app/widgets/bottom_navigation_bar.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 40.0,
            ),
            ServicesUIx(),
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

class ServicesUIx extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'What’s available for you',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'We are committed to providing outstanding service for students, staff, and anyone using our app.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildImageButton('images/restaurantsBtn.png', context),
              _buildImageButton('images/parkingSpaceBtn.png', context),
              _buildImageButton('images/askMqBtn.png', context),
              _buildImageButton('images/studySpaceBtn.png', context),
              _buildImageButton('images/fitnessBtn.png', context),
              _buildImageButton('images/aquaticBtn.png', context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageButton(String imagePath, BuildContext context) {
    void navigateToScreen(Widget screen) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }

    // Determine which screen to navigate based on the image path
    Widget destinationScreen;
    switch (imagePath) {
      case 'images/restaurantsBtn.png':
        destinationScreen = RestaurantScreen();
        break;
      case 'images/parkingSpaceBtn.png':
        destinationScreen = ParkingScreen();
        break;
      case 'images/studySpaceBtn.png':
        destinationScreen = StudyScreen();
        break;
      case 'images/askMqBtn.png':
        destinationScreen = AskMqScreen();
        break;
      case 'images/fitnessBtn.png':
        destinationScreen = FitnessScreen();
        break;
      case 'images/aquaticBtn.png':
        destinationScreen = AquaticScreen();
        break;
      default:
        destinationScreen =
            ServicesScreen(); // Default screen if no match found
    }

    return GestureDetector(
      onTap: () {
        navigateToScreen(destinationScreen);
      },
      child: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: double.infinity, // Set width to fill the container
              fit: BoxFit.cover, // Ensure image covers the full width
            ),
          ],
        ),
      ),
    );
  }
}
