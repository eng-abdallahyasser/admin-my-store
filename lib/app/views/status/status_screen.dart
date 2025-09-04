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
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Status Management'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 700;
          return Obx(() {
            if (_controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (_controller.restaurant == null) {
              return Center(child: Text('No restaurant data found'));
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
            _messageController.text = _controller.restaurant!.closedMessage;

            if (isMobile) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _autoManualModeToggle(),
                    SizedBox(height: 20),
                    _restaurantStatusToggle(),
                    SizedBox(height: 20),
                    _closedMessage(),
                    SizedBox(height: 20),
                    _hoursConfigration(),
                  ],
                ),
              );
            }
            return SingleChildScrollView(
              padding: EdgeInsets.all(60),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _autoManualModeToggle(),
                        SizedBox(height: 20),
                        _restaurantStatusToggle(),
                        SizedBox(height: 20),
                        _closedMessage(),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(child:_hoursConfigration(), )
                  
                ],
              ),
            );
          });
        },
      ),
    );
  }

  List<Widget> _buildDayScheduleEditors() {
    final days = [
      {'key': 'monday', 'name': 'Monday'},
      {'key': 'tuesday', 'name': 'Tuesday'},
      {'key': 'wednesday', 'name': 'Wednesday'},
      {'key': 'thursday', 'name': 'Thursday'},
      {'key': 'friday', 'name': 'Friday'},
      {'key': 'saturday', 'name': 'Saturday'},
      {'key': 'sunday', 'name': 'Sunday'},
    ];

    return days.map((day) {
      final dayKey = day['key']!;
      final dayName = day['name']!;
      final daySchedule =
          _controller.restaurant!.openingHours[dayKey]
              as Map<String, dynamic>? ??
          {};

      final openTime = daySchedule['open'] ?? '07:00';
      final closeTime = daySchedule['close'] ?? '23:00';
      final enabled = daySchedule['enabled'] ?? true;

      return _DayScheduleEditor(
        dayName: dayName,
        dayKey: dayKey,
        openTime: openTime,
        closeTime: closeTime,
        enabled: enabled,
        onScheduleChanged: (open, close, enabled) {
          _controller.updateOpeningHours(dayKey, open, close, enabled);
        },
      );
    }).toList();
  }

  _autoManualModeToggle() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operation Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _controller.restaurant!.autoMode
                        ? 'Automatic Mode (Follows Schedule Below)'
                        : 'Manual Mode',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          _controller.restaurant!.autoMode
                              ? Colors.blue
                              : Colors.orange,
                    ),
                  ),
                ),
                Switch(
                  value: _controller.restaurant!.autoMode,
                  onChanged: (value) {
                    _controller.toggleAutoMode(value);
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),
            if (_controller.restaurant!.autoMode) ...[
              SizedBox(height: 16),
              Text(
                'Next status change: ${_controller.nextStatusChange}',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _restaurantStatusToggle() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restaurant Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      color:
                          _controller.restaurant!.isOpen
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ),
                Switch(
                  value: _controller.restaurant!.isOpen,
                  onChanged:
                      _controller.restaurant!.autoMode
                          ? null // Disable in auto mode
                          : (value) {
                            _controller.updateRestaurantStatus(
                              value,
                              _controller.restaurant!.closedMessage,
                            );
                          },
                  activeColor: Colors.green,
                ),
              ],
            ),
            if (_controller.restaurant!.autoMode)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Status is automatically managed based on schedule',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _closedMessage() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Closed Message',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  _hoursConfigration() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opening Hours Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Set custom opening and closing times for each day:',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            ..._buildDayScheduleEditors(),
          ],
        ),
      ),
    );
  }
}

// Widget for editing a single day's schedule
class _DayScheduleEditor extends StatefulWidget {
  final String dayName;
  final String dayKey;
  final String openTime;
  final String closeTime;
  final bool enabled;
  final Function(String, String, bool) onScheduleChanged;

  const _DayScheduleEditor({
    required this.dayName,
    required this.dayKey,
    required this.openTime,
    required this.closeTime,
    required this.enabled,
    required this.onScheduleChanged,
  });

  @override
  __DayScheduleEditorState createState() => __DayScheduleEditorState();
}

class __DayScheduleEditorState extends State<_DayScheduleEditor> {
  late String _openTime;
  late String _closeTime;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _openTime = widget.openTime;
    _closeTime = widget.closeTime;
    _enabled = widget.enabled;
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          isOpenTime ? _parseTimeOfDay(_openTime) : _parseTimeOfDay(_closeTime),
    );

    if (picked != null) {
      final timeStr =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      setState(() {
        if (isOpenTime) {
          _openTime = timeStr;
        } else {
          _closeTime = timeStr;
        }
      });

      widget.onScheduleChanged(_openTime, _closeTime, _enabled);
    }
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: _enabled,
                  onChanged: (value) {
                    setState(() {
                      _enabled = value ?? false;
                    });
                    widget.onScheduleChanged(_openTime, _closeTime, _enabled);
                  },
                ),
                Text(
                  widget.dayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _enabled ? Colors.black : Colors.grey,
                  ),
                ),
                Spacer(),
                if (!_enabled)
                  Text(
                    'Closed',
                    style: TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            if (_enabled) ...[
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Opens at',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_openTime),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context, false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Closes at',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_closeTime),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
