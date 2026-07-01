import 'package:bazzone_driver/features/home/domain/entities/driver_profile.dart';
import 'package:bazzone_driver/features/home/domain/entities/driver_shift_summary.dart';
import 'package:bazzone_driver/features/home/domain/entities/driver_work_status.dart';
import 'package:bazzone_driver/features/home/domain/entities/home_sheet_phase.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';

class DriverSession {
  const DriverSession({
    required this.workStatus,
    required this.profile,
    required this.shiftSummary,
    this.offeredOrder,
    this.activeOrder,
  });

  final DriverWorkStatus workStatus;
  final DriverProfile profile;
  final DriverShiftSummary shiftSummary;
  final Order? offeredOrder;
  final Order? activeOrder;

  bool get isOnline => workStatus == DriverWorkStatus.online;

  DriverWorkStatus get visualStatus {
    if (workStatus == DriverWorkStatus.offline) return DriverWorkStatus.offline;
    if (profile.balance < 100.0) return DriverWorkStatus.restricted;
    return DriverWorkStatus.online;
  }

  HomeSheetPhase get sheetPhase {
    if (activeOrder != null) return HomeSheetPhase.activeOrder;
    if (offeredOrder != null) return HomeSheetPhase.orderOffer;
    return HomeSheetPhase.driverSummary;
  }

  DriverSession copyWith({
    DriverWorkStatus? workStatus,
    DriverProfile? profile,
    DriverShiftSummary? shiftSummary,
    Order? offeredOrder,
    Order? activeOrder,
    bool clearOfferedOrder = false,
    bool clearActiveOrder = false,
  }) {
    return DriverSession(
      workStatus: workStatus ?? this.workStatus,
      profile: profile ?? this.profile,
      shiftSummary: shiftSummary ?? this.shiftSummary,
      offeredOrder: clearOfferedOrder ? null : (offeredOrder ?? this.offeredOrder),
      activeOrder: clearActiveOrder ? null : (activeOrder ?? this.activeOrder),
    );
  }

  static const initial = DriverSession(
    workStatus: DriverWorkStatus.offline,
    profile: DriverProfile.mock,
    shiftSummary: DriverShiftSummary(
      dateLabel: '',
      earnings: '2000 с',
      ordersCount: 9,
    ),
  );
}
