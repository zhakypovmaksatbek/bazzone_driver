import 'dart:developer';

import 'package:flutter/foundation.dart';

void appDebugLog(String message, {bool? isLog = false}) {
  if (kDebugMode) {
    if (isLog == true) {
      log(message);
    } else {
      print(message);
    }
  }
}
