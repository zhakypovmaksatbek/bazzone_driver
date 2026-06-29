import 'package:bazzone_driver/app/router/app_router.dart';
import 'package:bazzone_driver/features/home/data/datasources/driver_mock_datasource.dart';
import 'package:bazzone_driver/features/home/data/datasources/driver_remote_datasource.dart';
import 'package:bazzone_driver/features/home/data/repositories/driver_repository_impl.dart';
import 'package:bazzone_driver/features/home/domain/repositories/driver_repository.dart';
import 'package:bazzone_driver/features/home/presentation/bloc/home_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerSingleton<AppRouter>(AppRouter());

  // Home — API hazır olunca DriverMockDataSource → DriverRemoteDataSourceImpl
  getIt.registerLazySingleton<DriverMockDataSource>(DriverMockDataSource.new);
  getIt.registerLazySingleton<DriverRemoteDataSource>(
    () => getIt<DriverMockDataSource>(),
  );
  getIt.registerLazySingleton<DriverRepository>(
    () => DriverRepositoryImpl(getIt<DriverRemoteDataSource>()),
  );
  getIt.registerFactory<HomeBloc>(() => HomeBloc(getIt<DriverRepository>()));
}
