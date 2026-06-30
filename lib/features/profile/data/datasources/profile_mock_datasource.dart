import 'package:bazzone_driver/features/profile/domain/entities/driver_car.dart';
import 'package:bazzone_driver/features/profile/domain/entities/driver_profile.dart';
import 'package:bazzone_driver/features/profile/domain/entities/profile_menu_item.dart';
import 'package:bazzone_driver/features/profile/domain/entities/profile_news_item.dart';
import 'package:bazzone_driver/features/profile/domain/entities/taxi_park_details.dart';
import 'package:bazzone_driver/features/profile/domain/entities/trip_history_item.dart';
import 'package:bazzone_driver/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ProfileMockDataSource {
  Future<DriverProfile> fetchProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    return DriverProfile(
      fullName: 'Кубаныч Алидинович Каримбеков',
      roleLabel: LocaleKeys.profile_page_driver.tr(),
      ordersCount: 4590,
      experienceYears: 10,
      rating: 4.7,
      carsSummary: 'Kia K5, Kia EV9',
      taxiParkName: 'BazZone Drivers',
    );
  }

  List<ProfileMenuItem> fetchMenuItems(DriverProfile profile) {
    return [
      ProfileMenuItem(
        type: ProfileMenuType.tripHistory,
        title: LocaleKeys.profile_page_trip_history.tr(),
        icon: Icons.history_rounded,
      ),
      ProfileMenuItem(
        type: ProfileMenuType.cars,
        title: LocaleKeys.profile_page_your_cars.tr(),
        subtitle: profile.carsSummary,
        icon: Icons.directions_car_outlined,
      ),
      ProfileMenuItem(
        type: ProfileMenuType.taxiPark,
        title: LocaleKeys.profile_page_taxi_park.tr(),
        subtitle: profile.taxiParkName,
        icon: Icons.business_center_outlined,
      ),
      ProfileMenuItem(
        type: ProfileMenuType.carDiagnostics,
        title: LocaleKeys.profile_page_car_diagnostics.tr(),
        icon: Icons.build_outlined,
      ),
      ProfileMenuItem(
        type: ProfileMenuType.photoDiagnostics,
        title: LocaleKeys.profile_page_photo_diagnostics.tr(),
        icon: Icons.photo_camera_outlined,
      ),
      ProfileMenuItem(
        type: ProfileMenuType.tariffs,
        title: LocaleKeys.profile_page_tariffs.tr(),
        icon: Icons.payments_outlined,
      ),
    ];
  }

  Future<List<ProfileNewsItem>> fetchNews() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return const [
      ProfileNewsItem(
        id: '1',
        title: 'BAZZONE\ndrivers',
        backgroundColor: Color(0xFFFF9500),
      ),
      ProfileNewsItem(
        id: '2',
        title: 'максимум\nвыгоды',
        backgroundColor: Color(0xFFFFCC00),
      ),
      ProfileNewsItem(
        id: '3',
        title: 'ТАРИФЫ',
        backgroundColor: Color(0xFF007AFF),
      ),
    ];
  }

  Future<List<DriverCar>> fetchCars() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    return const [
      DriverCar(
        id: '1',
        title: 'Hyundai Sonata 2022',
        subtitle: 'Седан, 8 поколения, 2.0',
        colorLabel: 'Черный',
        plateNumber: '01-KG-542',
        registrationCertificate: '1234567890123456',
        vinOrStateNumber: '1234567890123456',
      ),
      DriverCar(
        id: '2',
        title: 'Kia EV9 2023',
        subtitle: 'Electro AT (283 кВт) 4WD Premium +',
        colorLabel: 'Синий',
        plateNumber: '01-KG-542',
        registrationCertificate: '1234567890123456',
        vinOrStateNumber: '1234567890123456',
      ),
    ];
  }

  Future<TaxiParkDetails> fetchTaxiParkDetails() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    return TaxiParkDetails(
      name: 'BazZone Drivers',
      commissionPercent: 1,
      weekdaySchedule: '08:00 - 22:00',
      weekendSchedule: LocaleKeys.profile_taxi_park_page_day_off.tr(),
      address: 'Бишкек, Тунгуч',
      phone: '+996 700-000-000',
    );
  }

  Future<List<TripHistorySection>> fetchTripHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    return [
      TripHistorySection(
        title: LocaleKeys.profile_trip_history_page_today.tr(),
        trips: [
          TripHistoryItem(
            id: '1',
            distanceKm: 5,
            time: '22:32',
            route: 'Льва Толстого 12 | Жибек Жолу 3',
            earnedAmount: 200,
            date: today,
          ),
          TripHistoryItem(
            id: '2',
            distanceKm: 5,
            time: '22:32',
            route: 'Льва Толстого 12 | Жибек Жолу 3',
            earnedAmount: 200,
            date: today,
          ),
        ],
      ),
      TripHistorySection(
        title: LocaleKeys.profile_trip_history_page_yesterday.tr(),
        trips: [
          TripHistoryItem(
            id: '3',
            distanceKm: 5,
            time: '22:32',
            route: 'Льва Толстого 12 | Жибек Жолу 3',
            earnedAmount: 200,
            date: yesterday,
          ),
          TripHistoryItem(
            id: '4',
            distanceKm: 5,
            time: '22:32',
            route: 'Льва Толстого 12 | Жибек Жолу 3',
            earnedAmount: 200,
            date: yesterday,
          ),
        ],
      ),
    ];
  }
}
