import 'dart:async';

import 'package:bazzone_driver/features/home/domain/entities/driver_session.dart';
import 'package:bazzone_driver/features/home/domain/repositories/driver_repository.dart';
import 'package:bazzone_driver/features/home/presentation/bloc/home_event.dart';
import 'package:bazzone_driver/features/home/presentation/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'home_event.dart';
export 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._repository) : super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeStartWorkRequested>(_onStartWork);
    on<HomeFinishWorkRequested>(_onFinishWork);
    on<HomeAcceptOrderRequested>(_onAcceptOrder);
    on<HomeDeclineOrderRequested>(_onDeclineOrder);
    on<HomeAdvanceOrderRequested>(_onAdvanceOrder);
    on<HomeCompleteOrderRequested>(_onCompleteOrder);
    on<HomeOrderOfferReceived>(_onOrderOfferReceived);
  }

  final DriverRepository _repository;
  StreamSubscription? _orderOffersSubscription;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        action: HomeAction.loadingSession,
        clearError: true,
      ),
    );

    try {
      final session = await _repository.getSession();
      _listenOrderOffers();
      emit(
        state.copyWith(
          status: HomeStatus.ready,
          action: HomeAction.none,
          session: session,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          action: HomeAction.none,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _listenOrderOffers() {
    _orderOffersSubscription ??= _repository.watchOrderOffers().listen(
      (order) => add(HomeOrderOfferReceived(order)),
    );
  }

  Future<void> _onStartWork(
    HomeStartWorkRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _runSessionAction(
      emit,
      action: HomeAction.startingWork,
      task: _repository.startWork,
    );
  }

  Future<void> _onFinishWork(
    HomeFinishWorkRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _runSessionAction(
      emit,
      action: HomeAction.finishingWork,
      task: _repository.finishWork,
    );
  }

  Future<void> _onAcceptOrder(
    HomeAcceptOrderRequested event,
    Emitter<HomeState> emit,
  ) async {
    final orderId = state.session?.offeredOrder?.id;
    if (orderId == null) return;

    await _runSessionAction(
      emit,
      action: HomeAction.acceptingOrder,
      task: () => _repository.acceptOrder(orderId),
    );
  }

  Future<void> _onDeclineOrder(
    HomeDeclineOrderRequested event,
    Emitter<HomeState> emit,
  ) async {
    final orderId = state.session?.offeredOrder?.id;
    if (orderId == null) return;

    await _runSessionAction(
      emit,
      action: HomeAction.decliningOrder,
      task: () => _repository.declineOrder(orderId),
    );
  }

  Future<void> _onAdvanceOrder(
    HomeAdvanceOrderRequested event,
    Emitter<HomeState> emit,
  ) async {
    final orderId = state.session?.activeOrder?.id;
    if (orderId == null) return;

    await _runSessionAction(
      emit,
      action: HomeAction.advancingOrder,
      task: () => _repository.advanceActiveOrder(orderId),
    );
  }

  Future<void> _onCompleteOrder(
    HomeCompleteOrderRequested event,
    Emitter<HomeState> emit,
  ) async {
    final orderId = state.session?.activeOrder?.id;
    if (orderId == null) return;

    await _runSessionAction(
      emit,
      action: HomeAction.completingOrder,
      task: () => _repository.completeOrder(orderId),
    );
  }

  void _onOrderOfferReceived(
    HomeOrderOfferReceived event,
    Emitter<HomeState> emit,
  ) {
    final session = state.session;
    if (session == null || !session.isOnline) return;
    if (session.offeredOrder != null || session.activeOrder != null) return;

    emit(
      state.copyWith(
        session: session.copyWith(offeredOrder: event.order),
      ),
    );
  }

  Future<void> _runSessionAction(
    Emitter<HomeState> emit, {
    required HomeAction action,
    required Future<DriverSession> Function() task,
  }) async {
    emit(state.copyWith(action: action, clearError: true));

    try {
      final session = await task();
      emit(
        state.copyWith(
          status: HomeStatus.ready,
          action: HomeAction.none,
          session: session,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          action: HomeAction.none,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _orderOffersSubscription?.cancel();
    return super.close();
  }
}
