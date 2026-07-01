import 'package:flutter/foundation.dart';

class ProfileState {
  ProfileState._();

  static final ValueNotifier<bool> isDiagnosticsCompleted = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> isSoundNotificationsEnabled = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> isDeliveryEnabled = ValueNotifier<bool>(false);

  // Tariffs addition switches
  static final ValueNotifier<bool> isChildSeatEnabled = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> isPetTransportEnabled = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> isFoodDeliveryEnabled = ValueNotifier<bool>(false);
}
