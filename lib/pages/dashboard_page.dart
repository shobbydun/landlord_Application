import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:landify/components/dashboardtile.dart';
import 'package:landify/pages/addEditTenant.dart';
import 'package:landify/pages/bills/bill_screen.dart';
import 'package:landify/pages/profile_page.dart';
import 'package:landify/pages/reminder_automation.dart';
import 'package:landify/pages/reports_screen.dart';

class DashboardPage extends StatelessWidget {
  final int totalProperties = 15;
  final int totalTenants = 10;
  final int overdueTenants = 2;
  final double totalIncome = 5000.00;
  final double totalExpenses = 1200.00;

  // Function to get greeting based on the time of day
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 18) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  // Function to fetch the username and profile image from Firestore
  Future<Map<String, String?>> getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          String? username = userDoc['username'] ??
              "User"; // Default to "User" if no username found
          String? profileImageUrl =
              userDoc['profilePictureUrl']; // Fetch profile image URL
          return {
            'username': username?.toUpperCase(), // Ensure username is uppercase
            'profileImageUrl': profileImageUrl,
          };
        }
      } catch (e) {
        print("Error fetching user info: $e");
      }
    }
    return {
      'username': "USER",
      'profileImageUrl': null
    }; // Default fallback if user is not logged in or there is an error
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: FutureBuilder<Map<String, String?>>(
          future: getUserInfo(), // Fetch user info asynchronously
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child:
                      CircularProgressIndicator()); // Loading indicator while fetching
            } else if (snapshot.hasError) {
              return Center(child: Text("Error fetching user data"));
            } else if (snapshot.hasData) {
              String username =
                  snapshot.data?['username'] ?? "USER"; // Fallback username
              String? profileImageUrl = snapshot.data?['profileImageUrl'];
              return Column(
                children: [
                  // Header with Avatar
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Dashboard",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to ProfilePage when tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage()),
                            );
                          },
                          child: CircleAvatar(
                            radius: 27,
                            backgroundImage: profileImageUrl != null &&
                                    Uri.tryParse(profileImageUrl)?.isAbsolute ==
                                        true
                                ? NetworkImage(profileImageUrl)
                                : AssetImage('assets/cooldp.jpeg')
                                    as ImageProvider, // Default image if URL is not found
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Welcome Section
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${getGreeting()}, ",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          "$username!", // Display the fetched username in uppercase
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        // Large Tile at the Top
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: LargeDashboardTile(
                            backgroundColor: Colors.teal,
                            title: "Tenant & Property Overview",
                            data: [
                              {
                                'label': 'Total Properties',
                                'value': totalProperties.toString(),
                                'icon': Icons.home
                              },
                              {
                                'label': 'Total Tenants',
                                'value': totalTenants.toString(),
                                'icon': Icons.person
                              },
                              {
                                'label': 'Overdue Tenants',
                                'value': overdueTenants.toString(),
                                'icon': Icons.warning
                              },
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        // Smaller Tiles in GridView Below
                        Expanded(
                          child: GridView(
                            padding: EdgeInsets.symmetric(horizontal: 26),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                            children: [
                              DashboardTile(
                                backgroundColor: Colors.green,
                                title: "Earnings",
                                value:
                                    "\Kshs${(totalIncome - totalExpenses).toStringAsFixed(2)}",
                                icon: Icons.account_balance_wallet,
                              ),
                              DashboardTile(
                                backgroundColor: Colors.redAccent,
                                title: "Expenses",
                                value:
                                    "\Kshs${totalExpenses.toStringAsFixed(2)}",
                                icon: Icons.money_off,
                              ),
                            ],
                          ),
                        ),
                        //SizedBox(height: 10),
                        // Recent Activity Feed Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Recent Activity Feed",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Recent Activity: Log of Events
                                    Text(
                                      "Log of Recent Events:",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text("1. Rent Payment - Tenant A: \$500"),
                                    Text(
                                        "2. Maintenance Request - Tenant B: AC Issue"),
                                    Text(
                                        "3. Message from Tenant C: Requesting Lease Renewal"),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              // Updates from Tenants
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 2),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Updates from Tenants:",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text("1. Tenant A: Lease Expiry Reminder"),
                                    Text(
                                        "2. Tenant B: Complaints about plumbing issue"),
                                    Text(
                                        "3. Tenant C: Request for Parking Spot"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return Center(child: Text("No data available"));
          },
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_arrow,
        children: [
          SpeedDialChild(
            child: Icon(Icons.add),
            label: 'Add New Tenant',
            onTap: () {
              print("Navigating to Tenants Screen");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditTenantDialog(
                    onSave: (tenant) {
                      // Define the logic to handle saving the tenant, like adding to Firestore
                      FirebaseFirestore.instance
                          .collection('tenants')
                          .add(tenant.toMap())
                          .then((value) {
                        // After saving, you might want to show a success message or update the screen
                        print("Tenant Added Successfully");
                      });
                    },
                  ),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.notifications),
            label: 'Automate Reminder',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ReminderAutomation(), // Directly navigating
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.payment),
            label: 'Bills/Payments',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BillsScreen(), // Directly navigating
                ),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.analytics),
            label: 'Check Reports',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportsScreen(), // Directly navigating
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
