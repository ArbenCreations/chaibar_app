import 'package:flutter/cupertino.dart';

class MyNavigatorObserver extends NavigatorObserver {
  final Map<String, VoidCallback> callbacks = {};

  // Method to register a callback for a specific route
  void registerCallback(String routeName, VoidCallback callback) {
    callbacks[routeName] = callback;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Get the previous route name
    final previousRouteName = previousRoute?.settings.name;

    // If a callback exists for the previous route, invoke it
    if (previousRouteName != null && callbacks.containsKey(previousRouteName)) {
      callbacks[previousRouteName]?.call();
    }
  }
}
