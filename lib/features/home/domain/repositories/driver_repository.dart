import 'package:bazzone_driver/features/home/domain/entities/driver_session.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';

abstract interface class DriverRepository {
  /// Mevcut oturum durumunu getirir (API: GET /driver/session).
  Future<DriverSession> getSession();

  /// Çevrimiçi ol (API: POST /driver/shift/start).
  Future<DriverSession> startWork();

  /// Çevrimdışı ol (API: POST /driver/shift/end).
  Future<DriverSession> finishWork();

  /// Siparişi kabul et (API: POST /orders/{id}/accept).
  Future<DriverSession> acceptOrder(String orderId);

  /// Siparişi reddet (API: POST /orders/{id}/decline).
  Future<DriverSession> declineOrder(String orderId);

  /// Aktif sipariş aşamasını ilerlet (API: PATCH /orders/{id}/phase).
  Future<DriverSession> advanceActiveOrder(String orderId);

  /// Siparişi tamamla (API: POST /orders/{id}/complete).
  Future<DriverSession> completeOrder(String orderId);

  /// WebSocket / SSE üzerinden gelen sipariş teklifleri.
  Stream<Order> watchOrderOffers();
}
