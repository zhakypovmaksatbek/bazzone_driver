import 'package:bazzone_driver/features/home/domain/entities/order.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class HomeStarted extends HomeEvent {
  const HomeStarted();
}

final class HomeStartWorkRequested extends HomeEvent {
  const HomeStartWorkRequested();
}

final class HomeFinishWorkRequested extends HomeEvent {
  const HomeFinishWorkRequested();
}

final class HomeAcceptOrderRequested extends HomeEvent {
  const HomeAcceptOrderRequested();
}

final class HomeDeclineOrderRequested extends HomeEvent {
  const HomeDeclineOrderRequested();
}

final class HomeAdvanceOrderRequested extends HomeEvent {
  const HomeAdvanceOrderRequested();
}

final class HomeCompleteOrderRequested extends HomeEvent {
  const HomeCompleteOrderRequested();
}

final class HomeLocationUpdated extends HomeEvent {
  const HomeLocationUpdated(this.location);

  final LatLng location;
}

/// WebSocket / SSE üzerinden gelen sipariş teklifi.
final class HomeOrderOfferReceived extends HomeEvent {
  const HomeOrderOfferReceived(this.order);

  final Order order;
}
