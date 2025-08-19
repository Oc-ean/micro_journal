import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:micro_journal/src/common/common.dart';
part 'internet_state.dart';

class InternetCubit extends Cubit<InternetState> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  InternetCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(const InternetLoading()) {
    _checkConnection();
    _setupListener();
    ConnectionManager().registerCubit<InternetCubit>(() {
      checkAgain();
    });
  }

  Future<void> _checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateStatus(result);
    } catch (_) {
      emit(const InternetDisconnected());
    }
  }

  void _setupListener() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final wasDisconnected = state is InternetDisconnected;
    final isNowConnected =
        !(results.contains(ConnectivityResult.none) || results.isEmpty);

    if (isNowConnected) {
      emit(const InternetConnected());

      if (wasDisconnected) {
        Future.delayed(const Duration(seconds: 1), () {
          if (state is InternetConnected) {
            ConnectionManager().reconnectAll();
          }
        });
      }
    } else {
      emit(const InternetDisconnected());
    }
  }

  Future<bool> checkAgain() async {
    emit(const InternetLoading());
    try {
      final result = await _connectivity.checkConnectivity();
      final hasConnection =
          !(result.contains(ConnectivityResult.none) || result.isEmpty);

      if (hasConnection) {
        emit(const InternetConnected());
      } else {
        emit(const InternetDisconnected());
      }

      return hasConnection;
    } catch (_) {
      emit(const InternetDisconnected());
      return false;
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
