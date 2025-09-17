import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/feedback.dart';
import '../repo/feedback_repository.dart';

class FeedbackController extends GetxController {
  final FeedbackRepository _repo = Get.find<FeedbackRepository>();

  final RxList<FeedbackItem> feedbacks = <FeedbackItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final RxString selectedType = FeedbackTypes.all.obs; // All, Suggestion, Bug, Complaint, Others
  StreamSubscription<List<FeedbackItem>>? _sub;

  List<String> get types => FeedbackTypes.listWithAll;

  @override
  void onInit() {
    super.onInit();
    _subscribe();
  }

  void _subscribe() {
    _sub?.cancel();
    _sub = _repo.streamAll().listen((items) {
      feedbacks.value = items;
    }, onError: (e) {
      error.value = 'Failed to load feedback: $e';
    });
  }

  List<FeedbackItem> get filtered {
    final t = selectedType.value;
    if (t == FeedbackTypes.all) return feedbacks;
    return feedbacks.where((f) => f.type == t).toList();
  }

  Future<void> refreshList() async {
    try {
      isLoading(true);
      feedbacks.value = await _repo.getAll();
    } catch (e) {
      error.value = 'Failed to refresh feedback: $e';
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteFeedback(FeedbackItem item) async {
    if (item.docId == null) return;
    try {
      await _repo.deleteByDocId(item.docId!);
      Get.snackbar('Deleted', 'Feedback removed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
    }
  }

  String formatTimestamp(Timestamp? ts) {
    if (ts == null) return '-';
    final dt = ts.toDate();
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
