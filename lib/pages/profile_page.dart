import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:landify/authentication/auth_page.dart';
import 'package:landify/pages/maintenance_repairs.dart';
import 'package:landify/pages/properties_page.dart';
import 'package:landify/pages/rent_screen.dart';
import 'package:landify/pages/settings_screen.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _picker = ImagePicker();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  String? email;
  String? profileImageUrl;
  bool isEditing = false;

  // Fetch user data from Firestore
Future<void> _getUserData() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        setState(() {
          _usernameController.text = userDoc['username'];
          email = userDoc['email'];
          _phoneController.text = userDoc['phone'] ?? '';
          profileImageUrl = userDoc['profilePictureUrl'];
        });
      } else {
        // Create a new document if it doesn't exist
        await userDocRef.set({
          'username': '',  // Default empty username or any other initial values
          'email': user.email,
          'phone': '',
          'profilePictureUrl': '',
        });

        print('New user document created');
      }
    }
  } catch (e) {
    print('Error fetching user data: $e');
  }
}


  // Pick a new profile image and upload it to Firebase Storage
  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        String fileName = 'profile_pics/${DateTime.now().millisecondsSinceEpoch}.jpg';
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.ref().child(fileName);
        UploadTask uploadTask = ref.putFile(File(pickedFile.path));

        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Save the image URL to Firestore
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'profilePictureUrl': downloadUrl,
          });

          setState(() {
            profileImageUrl = downloadUrl;
          });
        }
      }
    } catch (e) {
      print('Error picking and uploading image: $e');
    }
  }

  // Save updated username and phone number
  Future<void> _saveUserData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'username': _usernameController.text.toUpperCase(), // Always save in uppercase
        'phone': _phoneController.text.isNotEmpty ? _phoneController.text : null,
      });
      setState(() {
        isEditing = false; // Exit edit mode
      });
    } catch (e) {
      print('Error saving user data: $e');
    }
  }
  }


  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: Colors.grey[300],

      body: SingleChildScrollView(  // This allows scrolling
        child: Padding(
          padding: const EdgeInsets.all(23.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom AppBar Content - Title, Back Button, Logout Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context); // Go back to the previous screen
                    },
                  ),
                  Text(
                    "Landlord Profile",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      _confirmLogout(context);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Profile Section
              Center(
                child: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImageUrl != null && Uri.tryParse(profileImageUrl!)?.isAbsolute == true
                        ? NetworkImage(profileImageUrl!)
                        : AssetImage('assets/cooldp.jpeg') as ImageProvider,
                    child: profileImageUrl == null
                        ? Icon(Icons.camera_alt, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 10),
              
              // Username Section with Decoration (Uppercase)
              Center(
                child: isEditing
                    ? TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(12),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _usernameController.text.toUpperCase(),  // Ensure it is always uppercase
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
              SizedBox(height: 5),

              // Centered Email Section
              Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    email ?? "...",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ),
              ),
              SizedBox(height: 5),

              // Centered Phone Section
              Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isEditing
                      ? TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(12),
                          ),
                        )
                      : Text(
                          _phoneController.text.isNotEmpty ? _phoneController.text : "No phone number",
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                ),
              ),
              
              SizedBox(height: 20),

              // Edit or Save Button
              isEditing
                  ? ElevatedButton(
                      onPressed: _saveUserData,
                      child: Text('Save Changes'),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditing = true; // Enable editing mode
                        });
                      },
                      child: Text('Edit Profile'),
                    ),

              SizedBox(height: 20),

             // Grid Layout for Profile Options
              GridView.builder(
                shrinkWrap: true,  // Ensures the GridView does not take up too much space
                physics: NeverScrollableScrollPhysics(), // Prevents the GridView from scrolling
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1, // Aspect ratio for each grid item
                ),
                itemCount: 4, // Number of items in the grid
                itemBuilder: (context, index) {
                  return Card(
                    
                    elevation: 5,
                    child: InkWell(
                      onTap: () {
                        _navigateToPage(context, index);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            _getIconForPage(index),
                            size: 40,
                            color: Colors.blue,
                          ),
                          SizedBox(height: 10),
                          Text(
                            _getTitleForPage(index),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 5),
                          Text(
                            _getSubtitleForPage(index),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  // Method to show logout confirmation dialog
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _logout(context); // Log out the user
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  // Firebase sign out and navigate to the authentication page
  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();  // Sign out from Firebase
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthPage()),
      );
    } catch (e) {
      print("Sign out error: $e");
      // Optionally, show a message to the user if sign-out fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }

  // Method to handle navigation based on index
  void _navigateToPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PropertiesPage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RentScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MaintenanceRepairs()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen()),
        );
        break;
      default:
        break;
    }
  }

  // Get the appropriate icon for each page
  IconData _getIconForPage(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.money;
      case 2:
        return Icons.build;
      case 3:
        return Icons.settings;
      default:
        return Icons.help;
    }
  }

  // Get the appropriate title for each page
  String _getTitleForPage(int index) {
    switch (index) {
      case 0:
        return "My Properties";
      case 1:
        return "Rental Income";
      case 2:
        return "Maintenance Requests";
      case 3:
        return "Settings";
      default:
        return "Unknown";
    }
  }

  // Get the appropriate subtitle for each page
  String _getSubtitleForPage(int index) {
    switch (index) {
      case 0:
        return "Manage and view your properties";
      case 1:
        return "View your rental income summary";
      case 2:
        return "Track your property maintenance requests";
      case 3:
        return "Manage your profile and preferences";
      default:
        return "Unknown";
    }
  }
}
