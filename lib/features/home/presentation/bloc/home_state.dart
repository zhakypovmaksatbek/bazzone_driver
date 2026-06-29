import 'package:bazzone_driver/features/home/domain/entities/driver_session.dart';
import 'package:bazzone_driver/features/home/domain/entities/home_sheet_phase.dart';

enum HomeStatus { initial, loading, ready, failure }

enum HomeAction {
  none,
  loadingSession,
  startingWork,
  finishingWork,
  acceptingOrder,
  decliningOrder,
  advancingOrder,
  completingOrder,
}

class HomeState {
  const HomeState({
    this.status = HomeStatus.initial,
    this.action = HomeAction.none,
    this.session,
    this.errorMessage,
  });

  final HomeStatus status;
  final HomeAction action;
  final DriverSession? session;
  final String? errorMessage;

  HomeSheetPhase? get sheetPhase => session?.sheetPhase;

  bool get isBusy => action != HomeAction.none;

  HomeState copyWith({
    HomeStatus? status,
    HomeAction? action,
    DriverSession? session,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      action: action ?? this.action,
      session: session ?? this.session,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
