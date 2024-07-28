import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mqgo_app/screens/cart/checkout_screen.dart';
import 'package:mqgo_app/screens/common/explore_screen.dart';
import 'package:mqgo_app/screens/common/home.dart';
import 'package:mqgo_app/screens/auth/login.dart';
import 'package:mqgo_app/screens/common/profile_screen.dart';
import 'package:mqgo_app/screens/services/services_screen.dart';
import 'package:mqgo_app/widgets/bottom_navigation_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _currentIndex = 0;
  bool _isLoading = false;

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
      body: Stack(
        children: [
          Visibility(
            visible: !_isLoading,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cart',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('cart')
                              .where('userId',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser?.uid)
                              .where('orderCheckout', isEqualTo: false)
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.hasData) {
                              int itemCount = snapshot.data!.docs.length;
                              return Text('$itemCount Item(s)');
                            }
                            return Text('0 items');
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('cart')
                          .where('userId',
                              isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                          .where('orderCheckout', isEqualTo: false)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No items in the cart.',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }
                        List<DocumentSnapshot> documents = snapshot.data!.docs;

                        double subtotal = 0;
                        for (var doc in documents) {
                          subtotal += doc['totalPrice'];
                        }

                        double tax = subtotal * 0.1; // Assuming 10% tax
                        double total = subtotal;

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: documents.length,
                                itemBuilder: (context, index) {
                                  DocumentSnapshot document = documents[index];
                                  Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;
                                  int quantity = data['quantity'];
                                  double itemPrice = data['itemPrice'];
                                  double totalPrice = quantity * itemPrice;
                                  return Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          child:
                                              Image.network(data['itemImage']),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['itemName'],
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: Icon(Icons.remove),
                                                    onPressed: () {
                                                      if (quantity > 1) {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection('cart')
                                                            .doc(document.id)
                                                            .update({
                                                          'quantity':
                                                              quantity - 1,
                                                          'totalPrice':
                                                              totalPrice -
                                                                  itemPrice,
                                                        });
                                                      }
                                                    },
                                                  ),
                                                  Text('$quantity'),
                                                  IconButton(
                                                    icon: Icon(Icons.add),
                                                    onPressed: () {
                                                      FirebaseFirestore.instance
                                                          .collection('cart')
                                                          .doc(document.id)
                                                          .update({
                                                        'quantity':
                                                            quantity + 1,
                                                        'totalPrice':
                                                            totalPrice +
                                                                itemPrice,
                                                      });
                                                    },
                                                  ),
                                                  Spacer(),
                                                  IconButton(
                                                    icon: Icon(Icons.delete),
                                                    onPressed: () {
                                                      FirebaseFirestore.instance
                                                          .collection('cart')
                                                          .doc(document.id)
                                                          .delete();
                                                      Fluttertoast.showToast(
                                                        msg:
                                                            "Item deleted from cart",
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.BOTTOM,
                                                        backgroundColor:
                                                            Color.fromARGB(255,
                                                                35, 164, 0),
                                                        textColor: Colors.white,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                      onPressed:
                                          _checkout, // Call checkout method
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Color.fromARGB(255, 0, 0, 0)),
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.white),
                                      ),
                                      child: Text('Go to Checkout'),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: _isLoading,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF60C3B)),
              ),
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

  // Function to handle checkout
  void _checkout() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('orderCheckout', isEqualTo: false)
        .get();

    for (QueryDocumentSnapshot doc in cartSnapshot.docs) {
      await doc.reference.update({'orderCheckout': true});
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CheckoutScreen()),
    );

    setState(() {
      _isLoading = false; // Set loading state to false after checkout
    });
  }
}
