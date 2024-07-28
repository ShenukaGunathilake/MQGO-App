import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:mqgo_app/screens/cart/cart_screen.dart';
import 'package:mqgo_app/screens/common/explore_screen.dart';
import 'package:mqgo_app/screens/common/home.dart';
import 'package:mqgo_app/screens/auth/login.dart';
import 'package:mqgo_app/screens/common/profile_screen.dart';
import 'package:mqgo_app/screens/services/services_screen.dart';
import 'package:mqgo_app/widgets/bottom_navigation_bar.dart';
import 'package:intl/intl.dart';

class ParkingDetailScreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> data;

  const ParkingDetailScreen(
      {Key? key, required this.documentId, required this.data})
      : super(key: key);

  @override
  State<ParkingDetailScreen> createState() => _ParkingDetailScreenState();
}

class _ParkingDetailScreenState extends State<ParkingDetailScreen> {
  String? userName;
  String? userEmail;

  DateTime? startDate;
  DateTime? endDate;

  double _pricePerDay = 10.0;
  double _totalPrice = 0.0;

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

  Future<void> _bookParking() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('parking_space_bookings')
          .add({
        'userId': user.uid,
        'parkingSpaceId': int.parse(widget.documentId),
        'spaceName': widget.data['name'],
        'spaceImg': widget.data['img'],
        'startDate': startDate,
        'endDate': endDate,
        'totalPrice': _totalPrice,
        'createdAt': DateTime.now(),
      });
    }
  }

  void _calculatePrice() {
    if (startDate != null && endDate != null) {
      final daysSelected = endDate!.difference(startDate!).inDays + 1;
      _totalPrice = daysSelected * _pricePerDay;
    } else {
      _totalPrice = 0.0; // Reset price if dates are not selected
    }
  }

  @override
  Widget build(BuildContext context) {
    _calculatePrice(); // Calculate price whenever the build method is called

    return Scaffold(
      appBar: AppBar(
        title: Text('Back'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.data['img']),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Positioned(
                    top: 70,
                    left: 10,
                    child: Text(
                      'Parking Space',
                      style: TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 1),
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    right: 10,
                    child: Image.asset(
                      'images/car.png',
                      height: 100,
                      width: 100,
                    ),
                  ),
                  Positioned(
                    top: 115,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Your Spot!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Secure Your Spot: Reserve Your Parking Space Effortlessly.',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Space Type: ${widget.data['name']}',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 1),
                            );

                            if (picked != null && picked != startDate) {
                              setState(() {
                                startDate = picked;
                              });
                            }
                          },
                          child: Column(
                            children: [
                              Text(
                                'Start Date',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Color(0xFFF60C3B)),
                                  SizedBox(width: 5),
                                  Text(
                                    startDate != null
                                        ? DateFormat('yyyy-MM-dd')
                                            .format(startDate!)
                                        : 'Not selected',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            try {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate ??
                                    (startDate ??
                                        DateTime
                                            .now()), // Ensure initialDate >= firstDate
                                firstDate: startDate ?? DateTime.now(),
                                lastDate: DateTime(DateTime.now().year + 1),
                              );

                              if (picked != null && picked != endDate) {
                                setState(() {
                                  endDate = picked;
                                });
                              }
                            } catch (e) {
                              print('Error selecting end date: $e');
                            }
                          },
                          child: Column(
                            children: [
                              Text(
                                'End Date',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Color(0xFFF60C3B)),
                                  SizedBox(width: 5),
                                  Text(
                                    endDate != null
                                        ? DateFormat('yyyy-MM-dd')
                                            .format(endDate!)
                                        : 'Not selected',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Price',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '\$${_totalPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF60C3B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Image(
                    image: AssetImage('images/map2.png'),
                    fit: BoxFit.fitWidth,
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (startDate != null && endDate != null) {
                          await _bookParking();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Color.fromARGB(255, 71, 157, 18),
                              content: Text(
                                "Successfully added the booking. Payment Due Upon Arrival: Kindly Settle at the Counter Upon Your Arrival.",
                                style: TextStyle(fontSize: 18.0),
                              )));

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Color(0xFFF60C3B),
                              content: Text(
                                "Error booking the space. Try again!",
                                style: TextStyle(fontSize: 18.0),
                              )));
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                      ),
                      child: Text('Book Now'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
