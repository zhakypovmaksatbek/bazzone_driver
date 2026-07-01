import 'package:bazzone_driver/core/constants/asset_const.dart';
import 'package:bazzone_driver/core/constants/map_const.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/home/domain/entities/driver_session.dart';
import 'package:bazzone_driver/features/home/domain/entities/driver_work_status.dart';
import 'package:bazzone_driver/features/home/domain/entities/home_sheet_phase.dart';
import 'package:bazzone_driver/features/home/domain/entities/order.dart';
import 'package:bazzone_driver/features/home/presentation/bloc/home_bloc.dart';
import 'package:bazzone_driver/features/home/presentation/utils/marker_painter.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_driver_sheet.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_floating_traffic_progress_card.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_map_top_bar.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_map_view.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_notification_overlay.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/home_sheet_content.dart';
import 'package:bazzone_driver/features/home/presentation/widgets/map_overlay_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GoogleMapController? _mapController;
  final HomeSheetController _sheetController = HomeSheetController();

  LatLng _currentPosition = MapConst.defaultLocation;
  final String _address = MapConst.defaultAddress;
  bool _isMapReady = false;

  BitmapDescriptor? _locationMarkerIcon;
  double _heading =
      45.0; // Heading direction matching mockup screenshot (Northeast)
  DriverWorkStatus _currentVisualStatus = DriverWorkStatus.offline;

  Set<Marker> get _markers {
    return {
      Marker(
        markerId: const MarkerId('current_location'),
        position: _currentPosition,
        icon: _locationMarkerIcon ?? BitmapDescriptor.defaultMarker,
        anchor: const Offset(0.5, 0.5),
        rotation: _heading,
        flat: true,
      ),
    };
  }

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
        _isPaidWaitingNotifier.value
            ? 'Начинается платное ожидание'
            : 'Вы на месте',
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final initialSession = context.read<HomeBloc>().state.session;
      if (initialSession != null) {
        _currentVisualStatus = initialSession.visualStatus;
      }
      _loadCustomMarker(_currentVisualStatus);
    });
  }

  void _loadCustomMarker(DriverWorkStatus status) {
    MarkerPainter.getNavigationArrow(size: 60.0, color: status.markerColor)
        .then((icon) {
          if (mounted) {
            setState(() {
              _locationMarkerIcon = icon;
            });
          }
        })
        .catchError((error) {
          debugPrint('Error loading custom marker: $error');
        });
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
    final config = HomeDriverSheet.getConfig(
      _currentPhase,
      _currentActivePhase,
    );
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
    final config = HomeDriverSheet.getConfig(
      _currentPhase,
      _currentActivePhase,
    );
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
      if (position.heading != 0) {
        _heading = position.heading;
      }
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
              current.session?.activeOrder?.activePhase ||
          previous.session?.workStatus != current.session?.workStatus ||
          previous.session?.activeOrder != current.session?.activeOrder,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }

        final session = state.session;
        if (session != null) {
          final visualStatus = session.visualStatus;
          if (visualStatus != _currentVisualStatus) {
            _currentVisualStatus = visualStatus;
            _loadCustomMarker(visualStatus);
          }
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
                    markers: _markers,
                    onMapCreated: _onMapCreated,
                  ),
                  if (!_isMapReady)
                    const ColoredBox(
                      color: ColorConst.lightGrey,
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // ── Low balance alert banner (Absolute Top) ──────
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: HomeNotificationOverlay(
                      balance: session.profile.balance,
                      onTopUpPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Переход к пополнению баланса...'),
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Üst bar ───────────────────────────────────
                  Positioned(
                    top: session.profile.balance < 100.0
                        ? MediaQuery.paddingOf(context).top + 48 + 8
                        : MediaQuery.paddingOf(context).top + 8,
                    left: 0,
                    right: 0,
                    child: HomeMapTopBar(
                      address: _address,
                      onMapTypeTap: () {},
                      onSearchTap: () {},
                    ),
                  ),

                  // ── Навигационный HUD (Navigation Guidance HUD) ──
                  // if (session.activeOrder != null &&
                  //     session.activeOrder!.activePhase !=
                  //         ActiveOrderPhase.completed)
                  //   Positioned(
                  //     top: session.profile.balance < 100.0
                  //         ? MediaQuery.paddingOf(context).top + 108
                  //         : MediaQuery.paddingOf(context).top + 68,
                  //     left: 0,
                  //     right: 0,
                  //     child: HomeNavigationOverlay(
                  //       isVisible: true,
                  //       streetName:
                  //           session.activeOrder!.activePhase ==
                  //               ActiveOrderPhase.headingToClient
                  //           ? 'ул. Льва Толстого (к клиенту)'
                  //           : 'пр. Чуй (к пункту назначения)',
                  //       distanceToTurn: 'через 350 м',
                  //       turnIcon:
                  //           session.activeOrder!.activePhase ==
                  //               ActiveOrderPhase.headingToClient
                  //           ? Icons.turn_left_rounded
                  //           : Icons.turn_right_rounded,
                  //       onOpenNavigator: () {
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           const SnackBar(
                  //             content: Text('Запуск внешнего навигатора...'),
                  //           ),
                  //         );
                  //       },
                  //     ),
                  //   ),
                  // ── Overlay butonlar ──────────────────────────
                  // Sadece sheet boyutu veya isPaidWaiting değişince rebuild.
                  // HomeView hiç rebuild olmaz.
                  Positioned.fill(
                    child: ListenableBuilder(
                      listenable: Listenable.merge([
                        _sheetController.sizeListenable,
                        _isPaidWaitingNotifier,
                      ]),
                      builder: (context, _) {
                        final sheetSize = _sheetController.size;
                        final screenHeight = MediaQuery.sizeOf(context).height;
                        final mapBottomPadding = sheetSize * screenHeight;
                        final config = HomeDriverSheet.getConfig(
                          sheetPhase,
                          activePhase,
                        );
                        final collapsedPadding = config.minSize * screenHeight;
                        final isDestination =
                            session.activeOrder?.activePhase ==
                            ActiveOrderPhase.headingToDestination;

                        // Sürükleme yüzdesi (0.0 = kapalı, 1.0 = 0.10 kadar yukarı çekilmiş)
                        final dragProgress =
                            ((sheetSize - config.minSize) / 0.10).clamp(
                              0.0,
                              1.0,
                            );
                        final trafficCardOpacity = 1.0 - dragProgress;

                        return Stack(
                          children: [
                            Positioned(
                              right: 16,
                              bottom:
                                  mapBottomPadding +
                                  12 +
                                  (isDestination
                                      ? 84.0 * trafficCardOpacity
                                      : 0.0),
                              child: IgnorePointer(
                                ignoring: sheetSize >= 0.6,
                                child: Opacity(
                                  opacity: (1.0 - ((sheetSize - 0.5) / 0.10))
                                      .clamp(0.0, 1.0),
                                  child: MapOverlayButton(
                                    path: AssetConst.filledLocation,
                                    onPressed: _animateToCurrentPosition,
                                  ),
                                ),
                              ),
                            ),
                            if (session.activeOrder != null &&
                                session.activeOrder!.activePhase !=
                                    ActiveOrderPhase.completed)
                              if (isDestination)
                                Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: collapsedPadding + 12,
                                  child: IgnorePointer(
                                    ignoring: dragProgress > 0.8,
                                    child: Opacity(
                                      opacity: trafficCardOpacity,
                                      child: HomeFloatingTrafficProgressCard(
                                        order: session.activeOrder!,
                                      ),
                                    ),
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
