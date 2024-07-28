import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mqgo_app/screens/cart/cart_screen.dart';
import 'package:mqgo_app/screens/common/explore_screen.dart';
import 'package:mqgo_app/screens/common/home.dart';
import 'package:mqgo_app/screens/auth/login.dart';
import 'package:mqgo_app/screens/services/services_screen.dart';
import 'package:mqgo_app/widgets/bottom_navigation_bar.dart';
import 'package:mqgo_app/widgets/order_history.dart';
import 'package:mqgo_app/widgets/space_booking_history.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
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

  String? userName;
  String? userEmail;
  String? userPhotoURL;
  String? userStatus = 'Student'; // Default user status
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getUserData();
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
          userPhotoURL = snapshot.data()?['photoUrl'];
          userStatus = snapshot.data()?['status'] ??
              'Student'; // Default to Student if not available
        });
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LogIn()),
    );
  }

  Future<void> _updateProfilePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });

      File imageFile = File(pickedFile.path);
      String fileName = '${FirebaseAuth.instance.currentUser!.uid}_profile.jpg';

      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child(fileName);

      UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);

      await uploadTask.whenComplete(() => null);

      String photoURL = await firebaseStorageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'photoUrl': photoURL});

      setState(() {
        userPhotoURL = photoURL;
        _isLoading = false;
      });
    }
  }

  void _editUserName() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Username'),
          content: TextField(
            controller: TextEditingController(text: userName),
            onChanged: (value) {
              setState(() {
                userName = value;
              });
            },
            decoration: InputDecoration(hintText: "Enter your new username"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _saveUserName();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveUserName() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'name': userName});
  }

  void _editUserStatus() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User Status'),
          content: DropdownButton<String>(
            value: userStatus,
            items: <String>['Student', 'Staff']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                userStatus = value!;
              });
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Save'),
              onPressed: () {
                _saveUserStatus();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveUserStatus() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'status': userStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Image.asset(
                    "images/profile.png",
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Positioned(
                    top: 60,
                    left: MediaQuery.of(context).size.width / 2 - 60,
                    child: GestureDetector(
                      onTap: _updateProfilePhoto,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                          border: Border.all(width: 3, color: Colors.white),
                        ),
                        child: Stack(
                          children: [
                            _isLoading
                                ? CircularProgressIndicator()
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: userPhotoURL != null
                                        ? Image.network(
                                            userPhotoURL!,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            'https://img.freepik.com/free-vector/user-circles-set_78370-4704.jpg?size=626&ext=jpg&ga=GA1.1.2033812370.1698461847&semt=ais',
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _editUserName,
                                child: Container(
                                  width: 25,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color:
                                        const Color.fromARGB(255, 255, 60, 60),
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (userName != null)
              ListTile(
                title: Text(
                  'Username',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(userName!),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: _editUserName,
                ),
              ),
            if (userEmail != null)
              ListTile(
                title: Text(
                  'Email',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(userEmail!),
              ),
            ListTile(
              title: Text(
                'User Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(userStatus!),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: _editUserStatus,
              ),
            ),
            SizedBox(height: 20),
            DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: TabBar(
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Color(0xFFF60C3B),
                      ),
                      tabs: [
                        Tab(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('Restaurant Orders'),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('Parking Spaces'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: TabBarView(
                      children: [
                        buildOrderHistory(context),
                        buildParkingHistory(context)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _logout,
        backgroundColor: Color(0xFFF60C3B),
        child: Icon(Icons.logout),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
