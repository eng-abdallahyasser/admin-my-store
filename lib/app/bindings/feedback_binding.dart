import 'package:get/get.dart';

import '../controllers/feedback_controller.dart';
import '../repo/feedback_repository.dart';

class FeedbackBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedbackRepository>(() => FeedbackRepository(), fenix: true);
    Get.lazyPut<FeedbackController>(() => FeedbackController(), fenix: true);
  }
}
