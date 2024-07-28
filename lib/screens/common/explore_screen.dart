import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mqgo_app/screens/cart/cart_screen.dart';
import 'package:mqgo_app/screens/common/home.dart';
import 'package:mqgo_app/screens/auth/login.dart';
import 'package:mqgo_app/screens/common/profile_screen.dart';
import 'package:mqgo_app/screens/services/services_screen.dart';
import 'package:mqgo_app/widgets/bottom_navigation_bar.dart';
import 'package:photo_view/photo_view.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreState();
}

class _ExploreState extends State<ExploreScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    ServicesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  late PhotoViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PhotoViewController();
  }

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

  void _zoomIn() {
    if (_controller != null) {
      _controller.scale = (_controller.scale ?? 1.0) + 0.5;
    }
  }

  void _zoomOut() {
    if (_controller != null) {
      _controller.scale = (_controller.scale ?? 1.0) - 0.5;
    }
  }

  void _resetZoom() {
    if (_controller != null) {
      _controller.scale = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoView(
            controller: _controller,
            imageProvider: NetworkImage(
                'https://firebasestorage.googleapis.com/v0/b/mqgoapp.appspot.com/o/mq-campus-map.png?alt=media&token=1a3cb787-4389-4dbb-b965-ed30860a7305'),
            minScale: PhotoViewComputedScale.contained * 3,
            maxScale: PhotoViewComputedScale.covered * 2,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: Text(
                'Explore Macquarie Uni',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: 10,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(225, 244, 67, 54),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.zoom_in, color: Colors.white),
                          onPressed: _zoomIn,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(225, 244, 67, 54),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.zoom_out, color: Colors.white),
                          onPressed: _zoomOut,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 0.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(225, 244, 67, 54),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.refresh, color: Colors.white),
                          onPressed: _resetZoom,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
