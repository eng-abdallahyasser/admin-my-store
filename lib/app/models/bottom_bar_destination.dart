import 'package:flutter/material.dart';

class BottomBarDestination {
  final String icon;
  final String route;
  final String label;
  final Widget routeWidget;

  BottomBarDestination({
    required this.icon,
    required this.route,
    required this.label,
    required this.routeWidget,
  });
}
