import 'package:bazzone_driver/features/home/data/datasources/driver_remote_datasource.dart';
import 'package:bazzone_driver/features/home/domain/entities/driver_session.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';
import 'package:bazzone_driver/features/home/domain/repositories/driver_repository.dart';

class DriverRepositoryImpl implements DriverRepository {
  DriverRepositoryImpl(this._remoteDataSource);

  final DriverRemoteDataSource _remoteDataSource;

  @override
  Future<DriverSession> getSession() => _remoteDataSource.fetchSession();

  @override
  Future<DriverSession> startWork() => _remoteDataSource.startShift();

  @override
  Future<DriverSession> finishWork() => _remoteDataSource.endShift();

  @override
  Future<DriverSession> acceptOrder(String orderId) =>
      _remoteDataSource.acceptOrder(orderId);

  @override
  Future<DriverSession> declineOrder(String orderId) =>
      _remoteDataSource.declineOrder(orderId);

  @override
  Future<DriverSession> advanceActiveOrder(String orderId) =>
      _remoteDataSource.advanceOrderPhase(orderId);

  @override
  Future<DriverSession> completeOrder(String orderId) =>
      _remoteDataSource.completeOrder(orderId);

  @override
  Stream<Order> watchOrderOffers() => _remoteDataSource.orderOffers();
}
