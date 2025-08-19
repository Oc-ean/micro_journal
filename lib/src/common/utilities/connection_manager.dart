import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectionManager {
  static final ConnectionManager _instance = ConnectionManager._internal();
  final Map<Type, VoidCallback> _cubitReconnectCallbacks = {};

  factory ConnectionManager() => _instance;

  ConnectionManager._internal();

  void registerCubit<T extends Cubit<Object?>>(VoidCallback reconnectCallback) {
    _cubitReconnectCallbacks[T] = reconnectCallback;
  }

  void reconnectAll() {
    for (final callback in _cubitReconnectCallbacks.values) {
      callback();
    }
  }

  void reconnect<T extends Cubit<Object?>>() {
    _cubitReconnectCallbacks[T]?.call();
  }
}
