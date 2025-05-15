import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeviceUtility {
  static double getScreenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

  static double getScreenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double getStatusBarHeight() {
    return MediaQuery.of(Get.context!).padding.top;
  }

  static double getBottomBarHeight() {
    return MediaQuery.of(Get.context!).padding.bottom;
  }

  static double getAppBarHeight() {
    return AppBar().preferredSize.height;
  }

  static double getPixelRatio() {
    return MediaQuery.of(Get.context!).devicePixelRatio;
  }

  static bool isLandscapeOrientation() {
    return MediaQuery.of(Get.context!).orientation == Orientation.landscape;
  }

  static bool isPortraitOrientation() {
    return MediaQuery.of(Get.context!).orientation == Orientation.portrait;
  }
}
