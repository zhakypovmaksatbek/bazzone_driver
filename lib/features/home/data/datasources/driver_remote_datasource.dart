import 'package:bazzone_driver/features/home/domain/entities/driver_session.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';

/// Gerçek API entegrasyonunda bu arayüz [DriverRemoteDataSourceImpl] ile değiştirilir.
abstract interface class DriverRemoteDataSource {
  Future<DriverSession> fetchSession();

  Future<DriverSession> startShift();

  Future<DriverSession> endShift();

  Future<DriverSession> acceptOrder(String orderId);

  Future<DriverSession> declineOrder(String orderId);

  Future<DriverSession> advanceOrderPhase(String orderId);

  Future<DriverSession> completeOrder(String orderId);

  Stream<Order> orderOffers();
}
