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
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  LatLng _currentPosition = MapConst.defaultLocation;
  final String _address = MapConst.defaultAddress;
  bool _isMapReady = false;
  double _sheetExtent = 0.45;
  double _minChildSize = 0.12;
  double _maxChildSize = 0.85;
  HomeSheetPhase? _lastSheetPhase;
  ActiveOrderPhase? _lastActivePhase;
  bool _shouldAnimateToMaxAfterResolve = false;
  bool _isPaidWaiting = false;

  String _getOverlayBannerText(ActiveOrderPhase phase) {
    return switch (phase) {
      ActiveOrderPhase.headingToClient => 'Ехать 4 мин',
      ActiveOrderPhase.waitingForClient => _isPaidWaiting ? 'Начинается платное ожидание' : 'Вы на месте',
      ActiveOrderPhase.headingToDestination => 'Ехать 4 мин',
      ActiveOrderPhase.completed => '',
    };
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru');
    _sheetController.addListener(_onSheetExtentChanged);
    _initLocation();
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetExtentChanged);
    _sheetController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSheetExtentChanged() {
    if (!_sheetController.isAttached) return;
    final size = _sheetController.size;
    if ((size - _sheetExtent).abs() < 0.001) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_sheetController.isAttached) return;
      final nextSize = _sheetController.size;
      if ((nextSize - _sheetExtent).abs() < 0.001) return;
      setState(() => _sheetExtent = nextSize);
    });
  }

  void _onSizesResolved(HomeSheetSizes sizes) {
    final minChanged = (sizes.minChildSize - _minChildSize).abs() > 0.001;
    final maxChanged = (sizes.maxChildSize - _maxChildSize).abs() > 0.001;

    if (minChanged || maxChanged) {
      setState(() {
        _minChildSize = sizes.minChildSize;
        _maxChildSize = sizes.maxChildSize;
      });
    }

    if (_shouldAnimateToMaxAfterResolve) {
      _shouldAnimateToMaxAfterResolve = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateSheetTo(sizes.maxChildSize);
      });
    }
  }

  Future<void> _animateSheetTo(double size) async {
    if (!_sheetController.isAttached) return;
    await _sheetController.animateTo(
      size.clamp(_minChildSize, _maxChildSize),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

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
    setState(() => _isMapReady = true);
    _animateToCurrentPosition();
  }

  void _onSheetPhaseChanged(HomeSheetPhase phase) {
    if (_lastSheetPhase == phase) return;
    _lastSheetPhase = phase;
  }

  void _expandSheet() {
    if (!_sheetController.isAttached) return;
    _animateSheetTo(_maxChildSize);
  }

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
        if (val != _isPaidWaiting) {
          setState(() {
            _isPaidWaiting = val;
          });
        }
      },
    );
  }

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }

        final phase = state.sheetPhase;
        if (phase == null) return;

        final activePhase = state.session?.activeOrder?.activePhase;

        if (phase != _lastSheetPhase) {
          _lastActivePhase = activePhase;
          _shouldAnimateToMaxAfterResolve = true;
          _isPaidWaiting = false;
          _onSheetPhaseChanged(phase);
          return;
        }

        if (activePhase != null && activePhase != _lastActivePhase) {
          _lastActivePhase = activePhase;
          _shouldAnimateToMaxAfterResolve = true;
          _isPaidWaiting = false;
          setState(() {});
        }
      },
      builder: (context, state) {
        final session = state.session;
        final sheetPhase = session?.sheetPhase ?? HomeSheetPhase.driverSummary;
        final fallbackExtent = HomeDriverSheet.targetSizeFor(
          sheetPhase,
          context,
        );
        final sheetExtent = _sheetController.isAttached
            ? _sheetExtent
            : fallbackExtent;
        final isSheetExpanded = HomeDriverSheet.isSingleSizePhase(sheetPhase)
            ? true
            : (sheetExtent - _minChildSize) > (_maxChildSize - _minChildSize) * 0.5;

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

        final sheetContent = _buildSheetContent(
          session: session,
          isBusy: state.isBusy,
          action: state.action,
          isExpanded: isSheetExpanded,
        );

        return Scaffold(
          backgroundColor: ColorConst.white,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final mapBottomPadding = sheetExtent * constraints.maxHeight;

              return Stack(
                children: [
                  HomeMapView(
                    currentPosition: _currentPosition,
                    bottomPadding: mapBottomPadding,
                    onMapCreated: _onMapCreated,
                  ),
                  if (!_isMapReady)
                    const ColoredBox(
                      color: ColorConst.lightGrey,
                      child: Center(child: CircularProgressIndicator()),
                    ),
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
                  Positioned(
                    right: 16,
                    bottom: mapBottomPadding + 16,
                    child: MapOverlayButton(
                      path: AssetConst.filledLocation,
                      onPressed: _animateToCurrentPosition,
                    ),
                  ),
                  if (session.activeOrder != null &&
                      session.activeOrder!.activePhase != ActiveOrderPhase.completed)
                    Positioned(
                      left: 16,
                      right: 80,
                      bottom: mapBottomPadding + 16,
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: ColorConst.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.chevron_left, color: ColorConst.black, size: 28),
                              onPressed: () {
                                _animateSheetTo(_minChildSize);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 48,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ColorConst.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                _getOverlayBannerText(session.activeOrder!.activePhase),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: ColorConst.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  HomeDriverSheet(
                    controller: _sheetController,
                    phase: sheetPhase,
                    stateKey: session.activeOrder?.activePhase,
                    initialChildSize: fallbackExtent,
                    onSizesResolved: _onSizesResolved,
                    measureCollapsed: _buildSheetContent(
                      session: session,
                      isBusy: state.isBusy,
                      action: state.action,
                      isExpanded: false,
                    ),
                    measureExpanded: _buildSheetContent(
                      session: session,
                      isBusy: state.isBusy,
                      action: state.action,
                      isExpanded: true,
                    ),
                    child: sheetContent,
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
