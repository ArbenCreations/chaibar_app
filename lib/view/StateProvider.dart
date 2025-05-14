import 'package:flutter/material.dart';

class ChaiBarInfoStateProvider extends InheritedWidget {
  final AnimationController slideController;
  final AnimationController rotateController;

  const ChaiBarInfoStateProvider({
    super.key,
    required this.slideController,
    required this.rotateController,
    required super.child,
  });

  static ChaiBarInfoStateProvider of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ChaiBarInfoStateProvider>();

    return result!;
  }

  @override
  bool updateShouldNotify(covariant ChaiBarInfoStateProvider oldWidget) => false;
}
