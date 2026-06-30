import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/core/constants/asset_const.dart';
import 'package:bazzone_driver/core/constants/map_const.dart';
import 'package:bazzone_driver/core/di/injection.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/home/domain/entities/driver_session.dart';
import 'package:bazzone_driver/features/home/domain/entities/home_sheet_phase.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';
import 'package:bazzone_driver/features/home/presentation/bloc/home_bloc.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_driver_sheet.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_map_top_bar.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_map_view.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_sheet_content.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/map_overlay_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/date_symbol_data_local.dart';

@RoutePage(name: 'HomeRoute')
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  GoogleMapController? _mapController;
  final HomeSheetController _sheetController = HomeSheetController();

  LatLng _currentPosition = MapConst.defaultLocation;
  final String _address = MapConst.defaultAddress;
  bool _isMapReady = false;

  // ── Phase tracking (for _onSizeChanged config calculation) ──────
  HomeSheetPhase _currentPhase = HomeSheetPhase.driverSummary;
  ActiveOrderPhase? _currentActivePhase;

  // ── ValueNotifier'lar: setState yok, yalnızca ilgili builder rebuild ──
  /// Sheet yarı noktasını geçince true → sadece content area rebuild olur.
  final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier(false);

  /// Ücretli bekleme durumu → sadece overlay banner rebuild olur.
  final ValueNotifier<bool> _isPaidWaitingNotifier = ValueNotifier(false);

  // ── Overlay banner text ────────────────────────────────────────

  String _getOverlayBannerText(ActiveOrderPhase phase) {
    return switch (phase) {
      ActiveOrderPhase.headingToClient => 'Ехать 4 мин',
      ActiveOrderPhase.waitingForClient =>
        _isPaidWaitingNotifier.value ? 'Начинается платное ожидание' : 'Вы на месте',
      ActiveOrderPhase.headingToDestination => 'Ехать 4 мин',
      ActiveOrderPhase.completed => '',
    };
  }

  // ── Lifecycle ──────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru');
    // sizeListenable: ValueListenable → listener build fazında çağrılsa bile
    // sadece descendant ValueListenableBuilder'lar rebuild olur, _HomeView değil.
    _sheetController.sizeListenable.addListener(_onSizeChanged);
    _initLocation();
  }

  @override
  void dispose() {
    _sheetController.sizeListenable.removeListener(_onSizeChanged);
    _sheetController.dispose();
    _isExpandedNotifier.dispose();
    _isPaidWaitingNotifier.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ── Size listener ──────────────────────────────────────────────

  /// Sheet boyutu değişince yalnızca _isExpandedNotifier güncellenir.
  /// setState YOK → _HomeView rebuild yok.
  void _onSizeChanged() {
    final size = _sheetController.size;
    final config = HomeDriverSheet.getConfig(_currentPhase, _currentActivePhase);
    final isExpanded =
        (size - config.minSize) > (config.maxSize - config.minSize) * 0.5;
    if (_isExpandedNotifier.value != isExpanded) {
      _isExpandedNotifier.value = isExpanded;
    }
  }

  // ── Sheet helpers ──────────────────────────────────────────────

  Future<void> _animateSheetTo(double size) async {
    if (!_sheetController.isAttached) return;
    await _sheetController.animateTo(
      size.clamp(0.10, 0.95),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _expandSheet() {
    if (!_sheetController.isAttached) return;
    final config = HomeDriverSheet.getConfig(_currentPhase, _currentActivePhase);
    _animateSheetTo(config.maxSize);
  }

  // ── Location ───────────────────────────────────────────────────

  Future<void> _initLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    if (!mounted) return;

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    await _animateToCurrentPosition();
  }

  Future<void> _animateToCurrentPosition() async {
    final controller = _mapController;
    if (controller == null) return;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: MapConst.defaultZoom),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() => _isMapReady = true); // Tek seferlik — kabul edilebilir
    _animateToCurrentPosition();
  }

  // ── Sheet content builder ──────────────────────────────────────

  HomeSheetContent _buildSheetContent({
    required DriverSession session,
    required bool isBusy,
    required HomeAction action,
    required bool isExpanded,
  }) {
    return HomeSheetContent(
      session: session,
      isBusy: isBusy,
      action: action,
      isExpanded: isExpanded,
      onExpandSheet: _expandSheet,
      onWaitingStateChanged: (val) {
        // setState yok: sadece _isPaidWaitingNotifier güncellenir
        _isPaidWaitingNotifier.value = val;
      },
    );
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          previous.sheetPhase != current.sheetPhase ||
          previous.errorMessage != current.errorMessage ||
          previous.session?.activeOrder?.activePhase !=
              current.session?.activeOrder?.activePhase,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }

        final phase = state.sheetPhase ?? HomeSheetPhase.driverSummary;
        final activePhase = state.session?.activeOrder?.activePhase;

        if (phase != _currentPhase || activePhase != _currentActivePhase) {
          _currentPhase = phase;
          _currentActivePhase = activePhase;
          _isPaidWaitingNotifier.value = false;

          final config = HomeDriverSheet.getConfig(phase, activePhase);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _animateSheetTo(config.initialSize);
          });
        }
      },
      builder: (context, state) {
        final session = state.session;
        final sheetPhase = session?.sheetPhase ?? HomeSheetPhase.driverSummary;
        final activePhase = session?.activeOrder?.activePhase;

        if (state.status == HomeStatus.loading && session == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (session == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: ColorConst.white,
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // ── Harita ────────────────────────────────────
                  HomeMapView(
                    currentPosition: _currentPosition,
                    bottomPadding: 0,
                    onMapCreated: _onMapCreated,
                  ),
                  if (!_isMapReady)
                    const ColoredBox(
                      color: ColorConst.lightGrey,
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // ── Üst bar ───────────────────────────────────
                  SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        HomeMapTopBar(
                          address: _address,
                          onMapTypeTap: () {},
                          onSearchTap: () {},
                        ),
                      ],
                    ),
                  ),

                  // ── Overlay butonlar ──────────────────────────
                  // Sadece sheet boyutu veya isPaidWaiting değişince rebuild.
                  // _HomeView hiç rebuild olmaz.
                  Positioned.fill(
                    child: ListenableBuilder(
                      listenable: Listenable.merge([
                        _sheetController.sizeListenable,
                        _isPaidWaitingNotifier,
                      ]),
                      builder: (context, _) {
                        final sheetSize = _sheetController.size;
                        final mapBottomPadding =
                            sheetSize * constraints.maxHeight;
                        return Stack(
                          children: [
                            Positioned(
                              right: 16,
                              bottom: mapBottomPadding + 16 +
                                  (session.activeOrder?.activePhase ==
                                          ActiveOrderPhase.headingToDestination
                                      ? 84.0
                                      : 0.0),
                              child: MapOverlayButton(
                                path: AssetConst.filledLocation,
                                onPressed: _animateToCurrentPosition,
                              ),
                            ),
                            if (session.activeOrder != null &&
                                session.activeOrder!.activePhase !=
                                    ActiveOrderPhase.completed)
                              if (session.activeOrder!.activePhase ==
                                  ActiveOrderPhase.headingToDestination)
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: mapBottomPadding + 16,
                                  child: _FloatingTrafficProgressCard(
                                    order: session.activeOrder!,
                                  ),
                                )
                              else
                                Positioned(
                                  left: 16,
                                  right: 80,
                                  bottom: mapBottomPadding + 16,
                                  child: Container(
                                    height: 48,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: ColorConst.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.1,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _getOverlayBannerText(
                                        session.activeOrder!.activePhase,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: ColorConst.black,
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        );
                      },
                    ),
                  ),

                  // ── Bottom sheet ──────────────────────────────
                  // isExpanded değişince yalnızca bu ValueListenableBuilder
                  // ve içindeki sheetContent rebuild olur.
                  ValueListenableBuilder<bool>(
                    valueListenable: _isExpandedNotifier,
                    builder: (context, isExpanded, _) {
                      final sheetContent = _buildSheetContent(
                        session: session,
                        isBusy: state.isBusy,
                        action: state.action,
                        isExpanded: isExpanded,
                      );
                      return HomeDriverSheet(
                        controller: _sheetController,
                        phase: sheetPhase,
                        activePhase: activePhase,
                        child: sheetContent,
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
// _FloatingTrafficProgressCard
// ─────────────────────────────────────────────────────────

class _FloatingTrafficProgressCard extends StatelessWidget {
  const _FloatingTrafficProgressCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final arrivalTime = DateTime.now().add(
      Duration(minutes: (order.distanceToPointKm * 3).round()),
    );
    final arrivalStr =
        "${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}";

    final durationMin = (order.distanceToPointKm * 3).round();
    final durationStr = context.locale.languageCode == 'ky'
        ? "$durationMin мүн"
        : "$durationMin мин";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: ColorConst.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${order.distanceToPointKm} км",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.black,
                ),
              ),
              Text(
                arrivalStr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.black,
                ),
              ),
              Text(
                durationStr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ColorConst.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.play_arrow, color: ColorConst.black, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 6,
                    child: Row(
                      children: [
                        Expanded(flex: 5, child: Container(color: ColorConst.success)),
                        Expanded(flex: 1, child: Container(color: Colors.yellow)),
                        Expanded(flex: 1, child: Container(color: ColorConst.error)),
                        Expanded(flex: 4, child: Container(color: ColorConst.success)),
                        Expanded(flex: 1, child: Container(color: Colors.yellow)),
                        Expanded(flex: 2, child: Container(color: ColorConst.success)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ColorConst.black, width: 2),
                  color: ColorConst.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
