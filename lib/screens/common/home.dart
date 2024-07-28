import 'package:flutter/material.dart';
import 'package:mqgo_app/screens/cart/cart_screen.dart';
import 'package:mqgo_app/screens/common/explore_screen.dart';
import 'package:mqgo_app/screens/auth/login.dart';
import 'package:mqgo_app/screens/common/profile_screen.dart';
import 'package:mqgo_app/screens/services/services_screen.dart';
import 'package:mqgo_app/widgets/bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    ServicesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

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

  Future<bool> _checkAuthentication() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogIn()),
      );
      return false;
    } else {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        setState(() {
          userName = snapshot.data()?['name'] ?? '';
        });
        print('Name: $userName');
        return true;
      } else {
        print('User data not found in Firestore');
        return false;
      }
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
            HomeUIx(userName: userName),
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

class HomeUIx extends StatelessWidget {
  final String? userName;
  const HomeUIx({Key? key, this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20.0),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [
                Row(
                  children: [
                    Image.asset(
                      'images/roundedMqLogo.png',
                      width: 50,
                      height: 50,
                    ),
                    SizedBox(width: 10),
                    Text(
                      getGreeting(userName),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ]),
              Image.asset(
                'images/notificationIcon.png',
                width: 30,
                height: 30,
              ),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'What’s New?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 210,
            child: HorizontalScrollView(),
          ),
          SizedBox(
            height: 20.0,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Explore life at MQ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            child: ExploreView(),
          ),
        ]));
  }

  String getGreeting(String? userName) {
    if (userName == null) {
      // If userName is null, return a generic greeting
      return 'Hello! 👋';
    } else {
      var now = DateTime.now();
      var hour = now.hour;
      if (hour < 12) {
        return 'Good Morning,\n$userName 👋';
      } else if (hour < 18) {
        return 'Good Afternoon,\n$userName 👋';
      } else {
        return 'Good Evening,\n$userName 👋';
      }
    }
  }
}

class HorizontalScrollView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        EventCard(
          image: 'images/event1.png',
          name: 'Open Day',
          date: '10 August 2024',
        ),
        EventCard(
          image: 'images/event2.png',
          name: 'Creative Writing Masterclass',
          date: 'On demand',
        ),
        EventCard(
          image: 'images/event3.png',
          name: 'Non-School Information Session',
          date: 'On demand',
        ),
        EventCard(
          image: 'images/event4.png',
          name: 'Macquarie MD Evening',
          date: 'Wednesday 17 April 2024',
        ),
        EventCard(
          image: 'images/event5.png',
          name: 'Redefining panel discussion',
          date: 'On demand',
        ),
      ],
    );
  }
}

class EventCard extends StatelessWidget {
  final String image;
  final String name;
  final String date;

  EventCard({
    required this.image,
    required this.name,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              image,
              width: 190,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 5),
          Text(
            '$name',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFF60C3B),
            ),
          ),
          Text(
            date,
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}

class ExploreView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExploreCard(
            image: 'images/exploreImg1.png',
            name: 'Campus facilities',
            description:
                'Find out where you can enjoy food and drink, exercise and enjoy our beautiful campus.',
          ),
          ExploreCard(
            image: 'images/exploreImg2.png',
            name: 'Supporting sexual and gender diversity',
            description:
                'Macquarie is a safe space for all LGBTIQA+ students where they can flourish and thrive.',
          ),
          ExploreCard(
            image: 'images/exploreImg3.png',
            name: 'Student spaces',
            description:
                'We have many places on campus you can hangout, study and work together.',
          ),
          ExploreCard(
            image: 'images/exploreImg4.png',
            name: 'Clubs and societies',
            description:
                'Over 90 groups created and run by students. Connect with people who share your passion.',
          ),
        ],
      ),
    );
  }
}

class ExploreCard extends StatelessWidget {
  final String image;
  final String name;
  final String description;

  ExploreCard({
    required this.image,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            image,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 10),
          Text(
            '$name',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFF60C3B),
              fontSize: 18,
            ),
          ),
          SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
