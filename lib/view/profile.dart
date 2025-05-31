import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:krivisha_app/view/dashboard/homeScreen.dart';

import '../utility/app_colors.dart'; // Import google_fonts

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> profileData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDummyData();
  }

  void _loadDummyData() {
    setState(() {
      profileData = {
        'emp_id': 'EMP12345',
        'fullName': 'John Doe',
        'mobileNumber': '+1-555-123-4567',
        'email': 'john.doe@example.com',
        'currentAddress': '123 Main St, Springfield',
        'permanentAddress': '456 Oak Ave, Springfield',
        'photoUrl': 'https://example.com/images/john_doe.jpg',
        'type': 'Employee',
        'alternateMobileNumber': '+1-555-987-6543',
        'city': 'Springfield',
        'state': 'Illinois',
        'country': 'USA',
        'designation': 'Software Engineer',
        'gender': 'Male',
        'ifscCode': 'ABCD0123456',
      };
      isLoading = false;
    });
  }

  Future<void> _refreshProfileData() async {
    setState(() => isLoading = true);
    await Future.delayed(Duration(seconds: 1)); // Simulate a refresh delay
    _loadDummyData();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyDashboard()),
        );

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile', style: GoogleFonts.inter(color: Colors.black)),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
        ),
        backgroundColor: Colors.grey[200],
        body: RefreshIndicator(
          onRefresh: _refreshProfileData,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child:
                isLoading
                    ? _buildLoadingSkeleton()
                    : _buildProfileDetails(screenWidth, screenHeight),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        CircleAvatar(radius: 55, backgroundColor: Colors.grey[300]),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: List.generate(5, (index) => _buildSkeletonItem()),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonItem() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(height: 20, color: Colors.grey[300]),
    );
  }

  Widget _buildProfileDetails(double screenWidth, double screenHeight) {
    return Column(
      children: [
        // Header with profile image
        Stack(
          children: [
            Container(
              height: screenHeight * 0.25,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.05,
              left: screenWidth * 0.05,
              child: GestureDetector(
                onTap: () => _viewProfileImage(context),
                child: CircleAvatar(
                  radius: screenWidth * 0.15,
                  backgroundImage: NetworkImage(profileData['photoUrl'] ?? ''),
                  backgroundColor: Colors.grey[300],
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.07,
              right: screenWidth * 0.05,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    profileData['designation'] ?? 'Not Provided',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    profileData['mobileNumber'] ?? 'Not Provided',
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    profileData['email'] ?? 'Not Provided',
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    profileData['city'] ?? 'Not Provided',
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Profile details section
        _buildProfileCard([
          _buildProfileItem(
            Icons.account_circle,
            'Full Name',
            profileData['fullName'],
          ),
          _buildProfileItem(
            Icons.phone_android,
            'Mobile Number',
            profileData['alternateMobileNumber'],
          ),
          _buildProfileItem(
            Icons.home,
            'Current Address',
            profileData['currentAddress'],
          ),
          _buildProfileItem(
            Icons.home,
            'Permanent Address',
            profileData['permanentAddress'],
          ),
          _buildProfileItem(Icons.location_city, 'City', profileData['city']),
          _buildProfileItem(Icons.map, 'State', profileData['state']),
          _buildProfileItem(Icons.public, 'Country', profileData['country']),
          _buildProfileItem(
            Icons.work,
            'Designation',
            profileData['designation'],
          ),
        ]),
      ],
    );
  }

  Widget _buildProfileCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10),
        ],
      ),
      child: Column(children: children),
    );
  }

  void _viewProfileImage(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: Image.network(
                profileData['photoUrl'] ?? '',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value ?? 'Not Provided',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
