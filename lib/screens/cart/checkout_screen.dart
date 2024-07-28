import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mqgo_app/screens/cart/cart_screen.dart';
import 'package:mqgo_app/screens/common/explore_screen.dart';
import 'package:mqgo_app/screens/common/home.dart';
import 'package:mqgo_app/screens/auth/login.dart';
import 'package:mqgo_app/screens/common/profile_screen.dart';
import 'package:mqgo_app/screens/services/services_screen.dart';
import 'package:mqgo_app/widgets/bottom_navigation_bar.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutState();
}

class _CheckoutState extends State<CheckoutScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    ServicesScreen(),
    CartScreen(),
    CheckoutScreen(),
  ];

  String? userName;
  String? userEmail;

  List<Map<String, dynamic>> restaurantCartData = [];

  late List<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    _getUserData();
    _isExpanded = [];
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

  void _toggleExpand(int index) {
    setState(() {
      _isExpanded[index] = !_isExpanded[index];
    });
  }

  void _placeOrder() {
    // Code to handle order placement
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose Payment Method',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _confirmOrder(payLater: false, items: restaurantCartData);
                },
                child: Text('Credit/Debit Card - 4290 XXXX XXXX XXXX'),
              ),
              ElevatedButton(
                onPressed: () {
                  _confirmOrder(payLater: true, items: restaurantCartData);
                },
                child: Text('Pay Later'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmOrder(
      {required bool payLater, required List<Map<String, dynamic>> items}) {
    FirebaseFirestore.instance.collection('my_restaurant_orders').add({
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'userName': userName,
      'userEmail': userEmail,
      'items': items,
      'timestamp': Timestamp.now(),
      'paymentReceived': !payLater,
      'paymentMethod': payLater ? 'PAY_LATER' : 'CARD',
    }).then((orderDoc) {
      // Handle success
      items.forEach((item) {
        FirebaseFirestore.instance
            .collection('cart')
            .doc(item['documentId'])
            .delete()
            .then((value) {
          // Handle success
          print('Item deleted from card');
        }).catchError((error) {
          // Handle error
          print('Error deleting item from card: $error');
        });
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfileScreen()),
      );
    }).catchError((error) {
      // Handle error
      print('Error placing order: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order. Please try again.')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = 0;
    restaurantCartData.forEach((item) {
      subtotal += item['totalPrice'];
    });
    double total = subtotal;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Text(
              'Checkout',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.grey[200],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                          ),
                          color: Colors.grey[400],
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        child: Text(
                          'Pickup',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        color: Colors.grey[200],
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: Text(
                        'Delivery',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Order Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('cart')
                    .where('userId',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .where('orderCheckout', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFF60C3B)),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No items in cart.'));
                  }
                  final cartData = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final documentId = doc.id;
                    return {
                      ...data,
                      'documentId': documentId,
                    };
                  }).toList();

                  final restaurantIds =
                      cartData.map((data) => data['restaurantId']).toSet();
                  // Initialize _isExpanded list based on the number of restaurants
                  if (_isExpanded.isEmpty) {
                    _isExpanded =
                        List.generate(restaurantIds.length, (index) => false);
                  }
                  return ListView.builder(
                    itemCount: restaurantIds.length,
                    itemBuilder: (context, index) {
                      final restaurantId = restaurantIds.elementAt(index);
                      restaurantCartData = cartData
                          .where((data) => data['restaurantId'] == restaurantId)
                          .toList();
                      print(restaurantCartData);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('restaurants')
                                .doc(restaurantId.toString())
                                .get(),
                            builder: (context, restaurantSnapshot) {
                              if (restaurantSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFF60C3B)),
                                );
                              }
                              if (restaurantSnapshot.hasError) {
                                return Text(
                                    'Error: ${restaurantSnapshot.error}');
                              }
                              if (!restaurantSnapshot.hasData ||
                                  !restaurantSnapshot.data!.exists) {
                                return Text('Restaurant not found');
                              }
                              final restaurantData = restaurantSnapshot.data!
                                  .data() as Map<String, dynamic>;
                              return Row(
                                children: [
                                  Image(
                                    image: NetworkImage(restaurantData['logo']),
                                    width: 60,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          restaurantData['name'],
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                            '${restaurantCartData.length} items'),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _isExpanded[index]
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                    ),
                                    onPressed: () {
                                      _toggleExpand(index);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          SizedBox(height: 10),
                          ...restaurantCartData.asMap().entries.map((entry) {
                            final itemData = entry.value;
                            final int itemIndex = entry.key;
                            return Visibility(
                              visible: _isExpanded[index],
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Add itemImage here
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                itemData['itemImage']),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            itemData['itemName'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Quantity: ${itemData['quantity']}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          Text(
                                            'Total: \$${itemData['totalPrice']}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '\$${subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: _placeOrder, // Call checkout method
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 0, 0, 0)),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                      ),
                      child: Text('Checkout Now'),
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
