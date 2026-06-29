import 'dart:async';

import 'package:bazzone_driver/features/home/data/datasources/driver_remote_datasource.dart';
import 'package:bazzone_driver/features/home/domain/entities/driver_session.dart';
import 'package:bazzone_driver/features/home/domain/entities/driver_shift_summary.dart';
import 'package:bazzone_driver/features/home/domain/entities/driver_work_status.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';

/// Mock veri kaynağı — API hazır olunca kaldırılır.
class DriverMockDataSource implements DriverRemoteDataSource {
  DriverSession _session = DriverSession.initial.copyWith(
    workStatus: DriverWorkStatus.offline,
    shiftSummary: const DriverShiftSummary(
      dateLabel: '06 Окт, 2025',
      earnings: '2000 с',
      ordersCount: 9,
    ),
  );

  final _orderOffersController = StreamController<Order>.broadcast();
  Timer? _offerSimulationTimer;

  @override
  Stream<Order> orderOffers() => _orderOffersController.stream;

  @override
  Future<DriverSession> fetchSession() async {
    await _simulateNetwork();
    if (_session.workStatus == DriverWorkStatus.online &&
        _session.offeredOrder == null &&
        _session.activeOrder == null) {
      _scheduleOfferSimulation();
    }
    return _session;
  }

  @override
  Future<DriverSession> startShift() async {
    await _simulateNetwork();
    _session = _session.copyWith(
      workStatus: DriverWorkStatus.online,
      clearOfferedOrder: true,
      clearActiveOrder: true,
    );
    _scheduleOfferSimulation();
    return _session;
  }

  @override
  Future<DriverSession> endShift() async {
    await _simulateNetwork();
    _cancelOfferSimulation();
    _session = _session.copyWith(
      workStatus: DriverWorkStatus.offline,
      clearOfferedOrder: true,
      clearActiveOrder: true,
    );
    return _session;
  }

  @override
  Future<DriverSession> acceptOrder(String orderId) async {
    await _simulateNetwork();
    final offer = _session.offeredOrder;
    if (offer == null || offer.id != orderId) return _session;

    _session = _session.copyWith(
      clearOfferedOrder: true,
      activeOrder: offer.copyWith(
        status: OrderStatus.active,
        activePhase: ActiveOrderPhase.headingToClient,
      ),
    );
    return _session;
  }

  @override
  Future<DriverSession> declineOrder(String orderId) async {
    await _simulateNetwork();
    if (_session.offeredOrder?.id == orderId) {
      _session = _session.copyWith(clearOfferedOrder: true);
    }
    return _session;
  }

  @override
  Future<DriverSession> advanceOrderPhase(String orderId) async {
    await _simulateNetwork();
    final active = _session.activeOrder;
    if (active == null || active.id != orderId) return _session;

    final nextPhase = switch (active.activePhase) {
      ActiveOrderPhase.headingToClient => ActiveOrderPhase.waitingForClient,
      ActiveOrderPhase.waitingForClient => ActiveOrderPhase.headingToDestination,
      ActiveOrderPhase.headingToDestination => ActiveOrderPhase.completed,
      ActiveOrderPhase.completed => ActiveOrderPhase.completed,
    };

    _session = _session.copyWith(
      activeOrder: active.copyWith(activePhase: nextPhase),
    );
    return _session;
  }

  @override
  Future<DriverSession> completeOrder(String orderId) async {
    await _simulateNetwork();
    if (_session.activeOrder?.id == orderId) {
      _session = _session.copyWith(clearActiveOrder: true);
    }
    return _session;
  }

  void _scheduleOfferSimulation() {
    _cancelOfferSimulation();
    _offerSimulationTimer = Timer(const Duration(seconds: 4), () {
      if (_session.workStatus != DriverWorkStatus.online) return;
      if (_session.offeredOrder != null || _session.activeOrder != null) return;
      _pushOrderOffer(Order.mockOffer);
    });
  }

  void _pushOrderOffer(Order order) {
    _session = _session.copyWith(offeredOrder: order);
    _orderOffersController.add(order);
  }

  void _cancelOfferSimulation() {
    _offerSimulationTimer?.cancel();
    _offerSimulationTimer = null;
  }

  Future<void> _simulateNetwork() =>
      Future<void>.delayed(const Duration(milliseconds: 400));

  void dispose() {
    _cancelOfferSimulation();
    _orderOffersController.close();
  }
}
