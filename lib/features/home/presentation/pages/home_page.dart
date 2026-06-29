import 'package:auto_route/auto_route.dart';
import 'package:bazzone_driver/core/constants/asset_const.dart';
import 'package:bazzone_driver/core/constants/map_const.dart';
import 'package:bazzone_driver/core/di/injection.dart';
import 'package:bazzone_driver/core/theme/color_const.dart';
import 'package:bazzone_driver/features/home/domain/entities/home_sheet_phase.dart';
import 'package:bazzone_driver/features/home/domain/entities/order_status.dart';
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
  double _sheetExtent = HomeDriverSheet.minSize;
  HomeSheetPhase? _lastSheetPhase;
  ActiveOrderPhase? _lastActiveOrderPhase;

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

  Future<void> _animateSheetTo(double size) async {
    if (!_sheetController.isAttached) return;
    await _sheetController.animateTo(
      size,
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

  void _onSheetPhaseChanged(
    HomeSheetPhase phase,
    ActiveOrderPhase? activeOrderPhase,
  ) {
    if (_lastSheetPhase == phase &&
        _lastActiveOrderPhase == activeOrderPhase) {
      return;
    }
    _lastSheetPhase = phase;
    _lastActiveOrderPhase = activeOrderPhase;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_sheetController.isAttached) return;
      _animateSheetTo(
        HomeDriverSheet.targetSizeFor(
          phase,
          context,
          activeOrderPhase: activeOrderPhase,
        ),
      );
    });
  }

  void _expandSheetForPhase(
    HomeSheetPhase phase,
    ActiveOrderPhase? activeOrderPhase,
  ) {
    if (!_sheetController.isAttached) return;
    _animateSheetTo(
      HomeDriverSheet.targetSizeFor(
        phase,
        context,
        activeOrderPhase: activeOrderPhase,
      ),
    );
  }

  void _collapseSheet() {
    if (!_sheetController.isAttached) return;
    _animateSheetTo(HomeDriverSheet.minSize);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          previous.sheetPhase != current.sheetPhase ||
          previous.session?.activeOrder?.activePhase !=
              current.session?.activeOrder?.activePhase ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        final phase = state.sheetPhase;
        if (phase != null) {
          _onSheetPhaseChanged(phase, state.session?.activeOrder?.activePhase);
        }
      },
      builder: (context, state) {
        final session = state.session;
        final sheetPhase = session?.sheetPhase ?? HomeSheetPhase.driverSummary;
        final activeOrderPhase = session?.activeOrder?.activePhase;
        final fallbackExtent = HomeDriverSheet.targetSizeFor(
          sheetPhase,
          context,
          activeOrderPhase: activeOrderPhase,
        );
        final sheetExtent = _sheetController.isAttached
            ? _sheetExtent
            : fallbackExtent;
        final isSheetCollapsed = HomeDriverSheet.isCollapsedExtent(sheetExtent);

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
                  HomeDriverSheet(
                    controller: _sheetController,
                    phase: sheetPhase,
                    activeOrderPhase: activeOrderPhase,
                    initialChildSize: fallbackExtent,
                    isCollapsed: isSheetCollapsed,
                    onCollapse: _collapseSheet,
                    onExpand: () =>
                        _expandSheetForPhase(sheetPhase, activeOrderPhase),
                    child: HomeSheetContent(
                      session: session,
                      isBusy: state.isBusy,
                      action: state.action,
                      isCollapsed: isSheetCollapsed,
                      onExpandSheet: () =>
                          _expandSheetForPhase(sheetPhase, activeOrderPhase),
                    ),
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
