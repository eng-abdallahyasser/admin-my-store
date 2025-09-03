import 'package:admin_my_store/app/models/restaurant_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class RestaurantStatusController extends GetxController {
  static RestaurantStatusController get instance => Get.find();

  final Rx<RestaurantStatus?> _restaurant = Rx<RestaurantStatus?>(null);
  RestaurantStatus? get restaurant => _restaurant.value;
  
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchRestaurantData();
  }

  // Fetch restaurant data from Firestore
  Future<void> fetchRestaurantData() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      DocumentSnapshot doc = await _firestore
          .collection('status')
          .doc('main_restaurant') // Replace with your restaurant ID
          .get();
      
      if (doc.exists) {
        _restaurant.value = RestaurantStatus.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        error.value = 'Restaurant data not found';
      }
    } catch (e) {
      error.value = 'Failed to fetch restaurant data: $e';
    } finally {
      isLoading.value = false;
    }
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

  // Update opening hours
  Future<void> updateOpeningHours(Map<String, dynamic> openingHours) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      await _firestore
          .collection('status')
          .doc('main_restaurant')
          .update({
            'openingHours': openingHours,
          });
      
      // Update local state
      if (_restaurant.value != null) {
        _restaurant.value = RestaurantStatus(
          id: _restaurant.value!.id,
          name: _restaurant.value!.name,
          isOpen: _restaurant.value!.isOpen,
          closedMessage: _restaurant.value!.closedMessage,
          openingHours: openingHours,
        );
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

  // Check if restaurant is open based on opening hours
  bool get isRestaurantOpen {
    if (_restaurant.value == null) return false;
    
    // If manually closed, return false
    if (!_restaurant.value!.isOpen) return false;
    
    // Check opening hours logic here if needed
    // You can implement time-based checking using the openingHours map
    
    return true;
  }
}