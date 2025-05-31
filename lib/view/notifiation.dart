import 'package:flutter/material.dart';
import 'package:krivisha_app/view/dashboard/homeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For SharedPreferences
import 'package:shimmer/shimmer.dart';

import '../utility/app_colors.dart'; // For shimmer effect

// Define a global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationItemData> _allNotifications = [];
  List<NotificationItemData> _displayedNotifications = [];
  bool _isLoading = true;
  bool _hasMore = true; // Indicates if there are more items to load
  final int _initialLoadCount = 9; // Number of items to load initially
  int _currentLoadCount = 9; // Number of items currently loaded

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _fetchNotifications();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotifications() async {
    try {
      // Dummy notifications with Lorem Ipsum data
      final List<NotificationItemData> dummyNotifications = [
        NotificationItemData(
          message: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          timeAgo: '1 hour ago',
          icon: Icons.notifications,
          appRedirectionUrl: 'leave approved',
          recordId: 'leave_001',
        ),
        NotificationItemData(
          message:
              'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
          timeAgo: '2 hours ago',
          icon: Icons.notifications,
          appRedirectionUrl: 'task assigned',
          recordId: 'task_001',
        ),
        NotificationItemData(
          message:
              'Ut enim ad minim veniam, quis nostrud exercitation ullamco.',
          timeAgo: '3 hours ago',
          icon: Icons.notifications,
          appRedirectionUrl: 'sitevisit detail',
          recordId: 'visit_001',
        ),
        NotificationItemData(
          message: 'Duis aute irure dolor in reprehenderit in voluptate velit.',
          timeAgo: '4 hours ago',
          icon: Icons.notifications,
          appRedirectionUrl: 'attendance',
          recordId: 'att_001',
        ),
        NotificationItemData(
          message:
              'Excepteur sint occaecat cupidatat non proident, sunt in culpa.',
          timeAgo: '1 day ago',
          icon: Icons.notifications,
          appRedirectionUrl: 'completed tasks',
          recordId: 'task_002',
        ),
        NotificationItemData(
          message: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          timeAgo: '2 days ago',
          icon: Icons.notifications,
          appRedirectionUrl: 'pending visits',
          recordId: 'visit_002',
        ),
        NotificationItemData(
          message:
              'Sed ut perspiciatis unde omnis iste natus error sit voluptatem.',
          timeAgo: '3 days ago',
          icon: Icons.notifications,
          appRedirectionUrl: 'all visits',
          recordId: 'visit_003',
        ),
        NotificationItemData(
          message:
              'Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut.',
          timeAgo: '4 hours ago',
          icon: Icons.notifications,
          appRedirectionUrl: 'leave rejected',
          recordId: 'leave_002',
        ),
        NotificationItemData(
          message:
              'Neque porro quisquam est qui dolorem ipsum quia dolor sit amet.',
          timeAgo: '5 hours ago',
          icon: Icons.notifications,
          appRedirectionUrl: 'completed tasks',
          recordId: 'task_003',
        ),
        NotificationItemData(
          message:
              'At vero eos et accusamus et iusto odio dignissimos ducimus.',
          timeAgo: '6 hours ago',
          icon: Icons.notifications,
          appRedirectionUrl: 'sitevisit detail',
          recordId: 'visit_004',
        ),
        NotificationItemData(
          message: 'Et harum quidem rerum facilis est et expedita distinctio.',
          timeAgo: '1 day ago',
          icon: Icons.notifications,
          appRedirectionUrl: 'all tasks',
          recordId: 'task_004',
        ),
      ];

      setState(() {
        _allNotifications = dummyNotifications;
        _displayedNotifications =
            dummyNotifications.take(_initialLoadCount).toList();
        _isLoading = false;
        _hasMore = dummyNotifications.length > _initialLoadCount;
      });
    } catch (e, stackTrace) {
      final prefs = await SharedPreferences.getInstance();
      final String? employeeId = prefs.getString('id');
      if (employeeId == null) {
        print('No user ID found.');
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
        return;
      }

      print('Stack Trace: $stackTrace');
      print('Error fetching notifications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    return 'Just now'; // Replace this with actual date formatting logic
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _isLoading = true;
      _currentLoadCount = _initialLoadCount; // Reset to initial load count
      _displayedNotifications = [];
    });
    await _fetchNotifications();
  }

  void _loadMore() {
    setState(() {
      final remainingNotifications =
          _allNotifications.skip(_currentLoadCount).toList();
      final newLoadCount = _currentLoadCount + _initialLoadCount;
      _displayedNotifications.addAll(
        remainingNotifications.take(_initialLoadCount).toList(),
      );
      _currentLoadCount = newLoadCount;
      _hasMore = remainingNotifications.length > _initialLoadCount;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_hasMore && !_isLoading) {
        _loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_sharp, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyDashboard()),
                  );
                },
              ),
              const Text(
                'Notifications',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        body:
            _isLoading
                ? _buildShimmer()
                : _displayedNotifications.isEmpty
                ? Center(
                  child: Text(
                    'No notifications available',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _refreshNotifications,
                  child: Scrollbar(
                    thickness:
                        10.0, // Adjust the thickness of the scrollbar here
                    radius: Radius.circular(
                      8.0,
                    ), // Adjust the radius of the scrollbar thumb
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16.0),
                      itemCount: _displayedNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = _displayedNotifications[index];
                        return NotificationItem(
                          message: notification.message,
                          timeAgo: notification.timeAgo,
                          icon: notification.icon,
                          appRedirectionUrl: notification.appRedirectionUrl,
                          recordId: notification.recordId,
                        );
                      },
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.grey[300]),
            title: Container(color: Colors.grey[300], height: 16.0),
            subtitle: Container(color: Colors.grey[300], height: 14.0),
            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
          ),
        );
      },
    );
  }
}

class NotificationItem extends StatelessWidget {
  final String message;
  final String timeAgo;
  final IconData icon;
  final String appRedirectionUrl;
  final String recordId;

  const NotificationItem({
    Key? key,
    required this.message,
    required this.timeAgo,
    required this.icon,
    required this.appRedirectionUrl,
    required this.recordId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          try {} catch (e) {
            print('Error handling notification click: $e');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            color: Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Icon with Border
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 0.5),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow Icon for Redirection
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationItemData {
  final String message;
  final String timeAgo;
  final IconData icon;
  final String appRedirectionUrl;
  final String recordId;

  NotificationItemData({
    required this.message,
    required this.timeAgo,
    required this.icon,
    required this.appRedirectionUrl,
    required this.recordId,
  });
}
