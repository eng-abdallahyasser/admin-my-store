import 'package:admin_my_store/app/models/restaurant_status.dart';
import 'package:admin_my_store/app/models/terms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class RestaurantStatusController extends GetxController {
  static RestaurantStatusController get instance => Get.find();

  final Rx<RestaurantStatus?> _restaurant = Rx<RestaurantStatus?>(null);
  RestaurantStatus? get restaurant => _restaurant.value;
  // Legacy list-based Terms (no longer used in UI)
  final RxList<Terms> terms = <Terms>[].obs;
  
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  // Privacy Policy (single doc)
  final RxString privacyTitle = ''.obs;
  final RxString privacyContent = ''.obs;
  final Rxn<Timestamp> privacyUpdatedAt = Rxn<Timestamp>();
  // Terms (single doc)
  final RxString termsTitleDoc = ''.obs;
  final RxString termsContentDoc = ''.obs;
  final Rxn<Timestamp> termsUpdatedAtDoc = Rxn<Timestamp>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchRestaurantData();
    // fetchTerms(); // no longer used in UI
    fetchPrivacyPolicy();
    fetchTermsDoc();
    _setupAutomaticStatusCheck();
  }
  Future<void> fetchTermsDoc() async {
  try {
    final doc = await _firestore.collection('app_config').doc('terms').get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      termsTitleDoc.value = data['title'] ?? '';
      termsContentDoc.value = data['content'] ?? '';
      termsUpdatedAtDoc.value = data['updatedAt'];
    } else {
      termsTitleDoc.value = '';
      termsContentDoc.value = '';
      termsUpdatedAtDoc.value = null;
    }
  } catch (e) {
    error.value = 'Failed to fetch terms doc: $e';
  }
}

Future<void> saveTermsDoc({required String title, required String content}) async {
  try {
    isLoading.value = true;
    error.value = '';
    await _firestore.collection('app_config').doc('terms').set({
      'title': title,
      'content': content,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await fetchTermsDoc();
    Get.snackbar(
      'Success',
      'Terms saved',
      snackPosition: SnackPosition.BOTTOM,
    );
  } catch (e) {
    error.value = 'Failed to save terms: $e';
    Get.snackbar(
      'Error',
      'Failed to save terms',
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isLoading.value = false;
  }
}

  // Fetch restaurant data from Firestore
  Future<void> fetchRestaurantData() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      DocumentSnapshot doc = await _firestore
          .collection('status')
          .doc('main_restaurant')
          .get();
      
      if (doc.exists) {
        _restaurant.value = RestaurantStatus.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        
        // If in auto mode, check and update status based on time
        if (_restaurant.value!.autoMode) {
          _updateStatusBasedOnTime();
        }
      } else {
        // Create default restaurant document if it doesn't exist
        await _createDefaultRestaurant();
      }
    } catch (e) {
      error.value = 'Failed to fetch restaurant data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Create default restaurant document
  Future<void> _createDefaultRestaurant() async {
    try {
      Map<String, dynamic> defaultHours = {
        'monday': {'open': '07:00', 'close': '23:00', 'enabled': true},
        'tuesday': {'open': '07:00', 'close': '23:00', 'enabled': true},
        'wednesday': {'open': '07:00', 'close': '23:00', 'enabled': true},
        'thursday': {'open': '07:00', 'close': '23:00', 'enabled': true},
        'friday': {'open': '07:00', 'close': '23:00', 'enabled': true},
        'saturday': {'open': '08:00', 'close': '23:00', 'enabled': true},
        'sunday': {'open': '08:00', 'close': '22:00', 'enabled': true},
      };
      
      await _firestore
          .collection('status')
          .doc('main_restaurant')
          .set({
            'name': 'Your Restaurant',
            'isOpen': true,
            'closedMessage': 'We are currently closed. Please check our opening hours.',
            'openingHours': defaultHours,
            'autoMode': true,
            'minAppVersion': '1.0.0',
          });
      
      // Fetch the newly created document
      await fetchRestaurantData();
    } catch (e) {
      error.value = 'Failed to create restaurant: $e';
    }
  }

  // Set up periodic status checking
  void _setupAutomaticStatusCheck() {
    // Check status every minute when in auto mode
    ever(_restaurant, (restaurant) {
      if (restaurant != null && restaurant.autoMode) {
        _updateStatusBasedOnTime();
      }
    });
  }

  // Update status based on current time and configured hours
  void _updateStatusBasedOnTime() {
    if (_restaurant.value == null) return;
    
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1=Monday, 7=Sunday
    final currentHour = now.hour;
    final currentMinute = now.minute;
    
    // Convert to minutes since midnight for easier comparison
    final currentTimeInMinutes = currentHour * 60 + currentMinute;
    
    // Get weekday name
    final weekdays = {
      1: 'monday',
      2: 'tuesday', 
      3: 'wednesday',
      4: 'thursday',
      5: 'friday',
      6: 'saturday',
      7: 'sunday',
    };
    
    final currentDay = weekdays[currentWeekday]!;
    final daySchedule = _restaurant.value!.openingHours[currentDay] as Map<String, dynamic>?;
    
    // Check if the day is enabled
    final isDayEnabled = daySchedule?['enabled'] ?? true;
    if (!isDayEnabled) {
      // Day is disabled, restaurant should be closed
      if (_restaurant.value!.isOpen) {
        updateRestaurantStatus(false, _restaurant.value!.closedMessage);
      }
      return;
    }
    
    // Get opening and closing times
    final openTimeStr = daySchedule?['open'] ?? '07:00';
    final closeTimeStr = daySchedule?['close'] ?? '23:00';
    
    // Parse times
    final openParts = openTimeStr.split(':');
    final closeParts = closeTimeStr.split(':');
    
    final openHour = int.parse(openParts[0]);
    final openMinute = int.parse(openParts[1]);
    final closeHour = int.parse(closeParts[0]);
    final closeMinute = int.parse(closeParts[1]);
    
    // Convert to minutes
    final openTimeInMinutes = openHour * 60 + openMinute;
    final closeTimeInMinutes = closeHour * 60 + closeMinute;
    
    bool shouldBeOpen;
    
    if (closeTimeInMinutes > openTimeInMinutes) {
      // Normal case: close time is after open time (e.g., 7 AM to 11 PM)
      shouldBeOpen = currentTimeInMinutes >= openTimeInMinutes && 
                     currentTimeInMinutes < closeTimeInMinutes;
    } else {
      // Special case: close time is next day (e.g., 7 AM to 3 AM next day)
      shouldBeOpen = currentTimeInMinutes >= openTimeInMinutes || 
                     currentTimeInMinutes < closeTimeInMinutes;
    }
    
    // Only update if status needs to change
    if (_restaurant.value!.isOpen != shouldBeOpen) {
      updateRestaurantStatus(shouldBeOpen, _restaurant.value!.closedMessage);
    }
  }

  // Get next status change time
  String get nextStatusChange {
    if (_restaurant.value == null) return 'Unknown';
    
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final currentHour = now.hour;
    final currentMinute = now.minute;
    final currentTimeInMinutes = currentHour * 60 + currentMinute;
    
    // Get weekday name mapping
    final weekdays = {
      1: 'monday', 2: 'tuesday', 3: 'wednesday', 4: 'thursday',
      5: 'friday', 6: 'saturday', 7: 'sunday',
    };
    
    final dayNames = {
      'monday': 'Monday', 'tuesday': 'Tuesday', 'wednesday': 'Wednesday',
      'thursday': 'Thursday', 'friday': 'Friday', 'saturday': 'Saturday',
      'sunday': 'Sunday',
    };
    
    // Check today's schedule first
    final currentDay = weekdays[currentWeekday]!;
    final todaySchedule = _restaurant.value!.openingHours[currentDay] as Map<String, dynamic>?;
    final isTodayEnabled = todaySchedule?['enabled'] ?? true;
    
    if (isTodayEnabled) {
      final openTimeStr = todaySchedule?['open'] ?? '07:00';
      final closeTimeStr = todaySchedule?['close'] ?? '23:00';
      
      final openParts = openTimeStr.split(':');
      final closeParts = closeTimeStr.split(':');
      
      final openTimeInMinutes = int.parse(openParts[0]) * 60 + int.parse(openParts[1]);
      final closeTimeInMinutes = int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);
      
      if (_restaurant.value!.isOpen) {
        // Currently open, next change is at closing time
        if (currentTimeInMinutes < closeTimeInMinutes || closeTimeInMinutes < openTimeInMinutes) {
          return 'Today at $closeTimeStr';
        }
      } else {
        // Currently closed, next change is at opening time
        if (currentTimeInMinutes < openTimeInMinutes) {
          return 'Today at $openTimeStr';
        }
      }
    }
    
    // If no change today, find the next enabled day
    for (int i = 1; i <= 7; i++) {
      int nextDayIndex = (currentWeekday + i - 1) % 7 + 1;
      String nextDay = weekdays[nextDayIndex]!;
      var nextDaySchedule = _restaurant.value!.openingHours[nextDay] as Map<String, dynamic>?;
      
      if (nextDaySchedule?['enabled'] ?? true) {
        String openTime = nextDaySchedule?['open'] ?? '07:00';
        String dayName = dayNames[nextDay]!;
        
        if (i == 1) return 'Tomorrow at $openTime';
        return '$dayName at $openTime';
      }
    }
    
    return 'No scheduled openings';
  }

  // Update restaurant status
  Future<void> updateRestaurantStatus(bool isOpen, String closedMessage) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _firestore
          .collection('status')
          .doc('main_restaurant')
          .update({
            'isOpen': isOpen,
            'closedMessage': closedMessage,
          });
      
      // Update local state
      if (_restaurant.value != null) {
        _restaurant.value = RestaurantStatus(
          id: _restaurant.value!.id,
          name: _restaurant.value!.name,
          isOpen: isOpen,
          closedMessage: closedMessage,
          openingHours: _restaurant.value!.openingHours,
          autoMode: _restaurant.value!.autoMode,
          minAppVersion: _restaurant.value!.minAppVersion,
        );
      }
      
      Get.snackbar(
        'Success',
        'Restaurant status updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Failed to update restaurant status: $e';
      Get.snackbar(
        'Error',
        'Failed to update restaurant status',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update opening hours for a specific day
  Future<void> updateOpeningHours(
    String day, 
    String openTime, 
    String closeTime, 
    bool enabled
  ) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      // Create updated hours map
      final updatedHours = Map<String, dynamic>.from(_restaurant.value!.openingHours);
      updatedHours[day] = {
        'open': openTime,
        'close': closeTime,
        'enabled': enabled,
      };
      
      await _firestore
          .collection('status')
          .doc('main_restaurant')
          .update({
            'openingHours': updatedHours,
          });
      
      // Update local state
      if (_restaurant.value != null) {
        _restaurant.value = RestaurantStatus(
          id: _restaurant.value!.id,
          name: _restaurant.value!.name,
          isOpen: _restaurant.value!.isOpen,
          closedMessage: _restaurant.value!.closedMessage,
          openingHours: updatedHours,
          autoMode: _restaurant.value!.autoMode,
          minAppVersion: _restaurant.value!.minAppVersion,
        );
      }
      
      // If in auto mode, update status based on new hours
      if (_restaurant.value!.autoMode) {
        _updateStatusBasedOnTime();
      }
      
      Get.snackbar(
        'Success',
        'Opening hours updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Failed to update opening hours: $e';
      Get.snackbar(
        'Error',
        'Failed to update opening hours',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle between auto and manual mode
  Future<void> toggleAutoMode(bool autoMode) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _firestore
          .collection('status')
          .doc('main_restaurant')
          .update({
            'autoMode': autoMode,
          });
      
      // Update local state
      if (_restaurant.value != null) {
        _restaurant.value = RestaurantStatus(
          id: _restaurant.value!.id,
          name: _restaurant.value!.name,
          isOpen: _restaurant.value!.isOpen,
          closedMessage: _restaurant.value!.closedMessage,
          openingHours: _restaurant.value!.openingHours,
          autoMode: autoMode,
          minAppVersion: _restaurant.value!.minAppVersion,
        );
      }
      
      // If switching to auto mode, update status based on time
      if (autoMode) {
        _updateStatusBasedOnTime();
      }
      
      Get.snackbar(
        'Success',
        'Mode changed to ${autoMode ? 'Auto' : 'Manual'}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Failed to change mode: $e';
      Get.snackbar(
        'Error',
        'Failed to change mode',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update minimum app version required for mobile app
  Future<void> updateMinAppVersion(String version) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _firestore
          .collection('status')
          .doc('main_restaurant')
          .update({'minAppVersion': version});

      if (_restaurant.value != null) {
        _restaurant.value = RestaurantStatus(
          id: _restaurant.value!.id,
          name: _restaurant.value!.name,
          isOpen: _restaurant.value!.isOpen,
          closedMessage: _restaurant.value!.closedMessage,
          openingHours: _restaurant.value!.openingHours,
          autoMode: _restaurant.value!.autoMode,
          minAppVersion: version,
        );
      }

      Get.snackbar(
        'Success',
        'Minimum app version updated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Failed to update minimum app version: $e';
      Get.snackbar(
        'Error',
        'Failed to update minimum app version',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // TERMS MANAGEMENT
  Future<void> fetchTerms() async {
    try {
      final qs = await _firestore
          .collection('terms')
          .orderBy('updatedAt', descending: true)
          .get();
      terms.value = qs.docs
          .map((d) => Terms.fromMap(d.id, d.data()))
          .toList();
    } catch (e) {
      error.value = 'Failed to fetch terms: $e';
    }
  }

  Future<void> addOrUpdateTerm({
    String? id,
    required String title,
    required String content,
    required String version,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      final data = {
        'title': title,
        'content': content,
        'version': version,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (id == null) {
        await _firestore.collection('terms').add(data);
      } else {
        await _firestore.collection('terms').doc(id).update(data);
      }
      await fetchTerms();
      Get.snackbar(
        'Success',
        id == null ? 'Term added' : 'Term updated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Failed to save term: $e';
      Get.snackbar(
        'Error',
        'Failed to save term',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTerm(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _firestore.collection('terms').doc(id).delete();
      await fetchTerms();
      Get.snackbar(
        'Success',
        'Term deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Failed to delete term: $e';
      Get.snackbar(
        'Error',
        'Failed to delete term',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // PRIVACY POLICY MANAGEMENT (single document: app_config/privacy_policy)
  Future<void> fetchPrivacyPolicy() async {
    try {
      final doc = await _firestore.collection('app_config').doc('privacy_policy').get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        privacyTitle.value = data['title'] ?? '';
        privacyContent.value = data['content'] ?? '';
        privacyUpdatedAt.value = data['updatedAt'];
      } else {
        privacyTitle.value = '';
        privacyContent.value = '';
        privacyUpdatedAt.value = null;
      }
    } catch (e) {
      error.value = 'Failed to fetch privacy policy: $e';
    }
  }

  Future<void> savePrivacyPolicy({required String title, required String content}) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _firestore.collection('app_config').doc('privacy_policy').set({
        'title': title,
        'content': content,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await fetchPrivacyPolicy();
      Get.snackbar(
        'Success',
        'Privacy Policy saved',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Failed to save privacy policy: $e';
      Get.snackbar(
        'Error',
        'Failed to save privacy policy',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}