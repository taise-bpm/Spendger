// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/material.dart';

class IconHelper {
  static IconData getIcon(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }
}
