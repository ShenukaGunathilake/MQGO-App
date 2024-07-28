import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mqgo_app/screens/common/home.dart';
import 'package:mqgo_app/screens/auth/login.dart';
import 'package:mqgo_app/widgets/bottom_navigation_bar.dart';
import '../../common/explore_screen.dart';
import '../services_screen.dart';
import '../../cart/cart_screen.dart';
import '../../common/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  final String? restaurantImg;
  final String? restaurantDesc;
  final String? restaurantLogo;
  final String? restaurantGoogleRev;
  final String? restaurantName;
  final double? starCount;

  const RestaurantDetailScreen({
    Key? key,
    required this.restaurantId,
    this.restaurantImg =
        "https://firebasestorage.googleapis.com/v0/b/mqgoapp.appspot.com/o/Ezjl788VcAAAM1b%201.png?alt=media&token=8aeab6fb-0b44-4c16-a870-b4feb43e4900",
    this.restaurantDesc = '',
    this.restaurantLogo = '',
    this.restaurantGoogleRev = '',
    this.restaurantName = '',
    this.starCount = 0.0,
  }) : super(key: key);

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
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
      appBar: AppBar(
        title: Text('Restaurant Detail'),
      ),
      body: ListView(
        children: [
          SizedBox(
            width: double.infinity,
            height: 100,
            child: Image.network(
              widget.restaurantImg!,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.restaurantName!,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.network(
                    widget.restaurantLogo!,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.starCount.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    for (double i = 0; i < 5; i++)
                      Icon(
                        Icons.star,
                        color:
                            i < widget.starCount! ? Colors.yellow : Colors.grey,
                        size: 15,
                      ),
                    SizedBox(width: 8),
                    Text(
                      widget.restaurantGoogleRev!,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.restaurantDesc!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Featured Items',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('restaurent_items')
                      .where('restaurantId',
                          isEqualTo: int.parse(widget.restaurantId))
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFf60c3b)),
                        ),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text('No items found.'),
                      );
                    } else {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.6,
                        ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var item = snapshot.data!.docs[index];
                          bool isAvailable = item['availability'] ?? false;
                          return ItemCard(
                            item: item
                                as QueryDocumentSnapshot<Map<String, dynamic>>,
                            isAvailable: isAvailable,
                          );
                        },
                      );
                    }
                  },
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

class ItemCard extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> item;
  final bool isAvailable;

  const ItemCard({
    Key? key,
    required this.item,
    required this.isAvailable,
  }) : super(key: key);

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  int quantity = 0;

  void addToCart() async {
    double price = (widget.item['price'] as num).toDouble();
    double totalPrice = quantity * price;

    String userId = FirebaseAuth.instance.currentUser!.uid;

    Map<String, dynamic> cartItem = {
      'itemId': int.parse(widget.item.id),
      'itemName': widget.item['name'],
      'itemImage': widget.item['img'],
      'itemPrice': price,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'userId': userId,
      'orderCheckout': false,
      'restaurantId': widget.item['restaurantId'],
    };

    try {
      // Add data to Firebase collection 'cart'
      await FirebaseFirestore.instance.collection('cart').add(cartItem);
      // Reset quantity
      setState(() {
        quantity = 0;
      });
      // Show success toast
      Fluttertoast.showToast(
        msg: "Item added to cart successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      // Show error toast
      Fluttertoast.showToast(
        msg: "Error adding item to cart",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 420,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                widget.item['img'],
                height: 100,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Price: \$${widget.item['price']}',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  widget.isAvailable
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (quantity > 0) quantity--;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Color(0xFFD9D9D9)),
                                    ),
                                    child: Icon(Icons.remove),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Color(0xFFD9D9D9)),
                                  ),
                                  child: Text(
                                    '$quantity',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      quantity++;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: Color(0xFFD9D9D9)),
                                    ),
                                    child: Icon(Icons.add),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: quantity > 0 ? addToCart : null,
                              child: Text(
                                'Add to Cart',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFf60c3b),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Out of Stock',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
