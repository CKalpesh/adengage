import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  double screenHeight(double percent) {
    return MediaQuery.sizeOf(this).height * percent;
  }

  double screenWidth(double percent) {
    return MediaQuery.sizeOf(this).width * percent;
  }
}
