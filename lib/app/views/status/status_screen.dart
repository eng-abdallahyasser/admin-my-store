import 'package:admin_my_store/app/controllers/status_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantStatusScreen extends StatelessWidget {
  RestaurantStatusScreen({super.key});

  final RestaurantStatusController _controller = Get.put(
    RestaurantStatusController(),
  );
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 768;
    
    return Scaffold(
      appBar: isLargeScreen ? null : AppBar(
        title: Text('Restaurant Status Management'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (_controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${_controller.error.value}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _controller.fetchRestaurantData(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_controller.restaurant == null) {
          return Center(child: Text('No restaurant data found'));
        }

        _messageController.text = _controller.restaurant!.closedMessage;

        // Main content layout
        Widget content = SingleChildScrollView(
          padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 1200, // Maximum width for very large screens
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLargeScreen) ...[
                  Text(
                    'Restaurant Status Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                ],
                
                // Use responsive layout for cards
                isLargeScreen 
                  ? _buildDesktopLayout(context)
                  : _buildMobileLayout(context),
              ],
            ),
          ),
        );

        // Center content on large screens
        if (isLargeScreen) {
          return Center(child: content);
        }

        return content;
      }),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Restaurant Status Toggle
        _buildStatusCard(),
        SizedBox(height: 20),
        // Closed Message
        _buildMessageCard(),
        SizedBox(height: 20),
        // Opening Hours
        _buildHoursCard(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column with status and message
        Expanded(
          child: Column(
            children: [
              _buildStatusCard(),
              SizedBox(height: 20),
              _buildMessageCard(),
            ],
          ),
        ),
        SizedBox(width: 20),
        // Right column with hours
        Expanded(
          child: _buildHoursCard(context),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restaurant Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _controller.restaurant!.isOpen
                        ? 'Restaurant is currently OPEN'
                        : 'Restaurant is currently CLOSED',
                    style: TextStyle(
                      fontSize: 16,
                      color: _controller.restaurant!.isOpen
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
                Switch(
                  value: _controller.restaurant!.isOpen,
                  onChanged: (value) {
                    _controller.updateRestaurantStatus(
                      value,
                      _controller.restaurant!.closedMessage,
                    );
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Closed Message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter message to show when restaurant is closed',
                labelText: 'Closed Message',
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  _controller.updateRestaurantStatus(
                    _controller.restaurant!.isOpen,
                    _messageController.text,
                  );
                },
                child: Text('Save Message'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opening Hours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildOpeningHoursList(context),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _showEditHoursDialog(context),
                child: Text('Edit Hours'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpeningHoursList(BuildContext context) {
    final hours = _controller.restaurant!.openingHours;
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final dayNames = {
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
      'sunday': 'Sun',
    };
    final fullDayNames = {
      'monday': 'Monday',
      'tuesday': 'Tuesday',
      'wednesday': 'Wednesday',
      'thursday': 'Thursday',
      'friday': 'Friday',
      'saturday': 'Saturday',
      'sunday': 'Sunday',
    };

    final bool useCompactDays = MediaQuery.of(context).size.width < 400;

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: days.map((day) {
        final dayData = hours[day] as Map<String, dynamic>? ?? {};
        final open = dayData['open'] ?? 'Closed';
        final close = dayData['close'] ?? 'Closed';

        return TableRow(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                useCompactDays ? dayNames[day]! : fullDayNames[day]!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(open == 'Closed' ? 'Closed' : '$open - $close'),
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showEditHoursDialog(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 768;
    
    if (isLargeScreen) {
      // Show a larger dialog for desktop/tablet
      Get.dialog(
        Dialog(
          insetPadding: EdgeInsets.all(40),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Opening Hours',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'This would open a detailed hours editor in a real implementation',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Cancel'),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Get.back(),
                        child: Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Standard dialog for mobile
      Get.defaultDialog(
        title: 'Edit Opening Hours',
        content: Text(
          'This would open a detailed hours editor in a real implementation',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('OK'),
          ),
        ],
      );
    }
  }
}