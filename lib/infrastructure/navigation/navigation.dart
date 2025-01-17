import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../config.dart';
import '../../presentation/screens.dart';
import 'bindings/controllers/controllers_bindings.dart';
import 'routes.dart';

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;
  const EnvironmentsBadge({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    var env = ConfigEnvironments.getEnvironments()['env'];
    return env != Environments.PRODUCTION
        ? Banner(
            location: BannerLocation.topStart,
            message: env!,
            color: env == Environments.QAS ? Colors.blue : Colors.purple,
            child: child,
          )
        : SizedBox(child: child);
  }
}

class Nav {
  static List<GetPage> routes = [
    GetPage(
        name: Routes.HOME,
        page: () => const HomeScreen(),
        binding: HomeControllerBinding(),
        transition: Transition.fadeIn),
    GetPage(
        name: Routes.MAIN_PAGES,
        page: () => const MainPagesScreen(),
        binding: MainPagesControllerBinding(),
        transition: Transition.fadeIn),
    GetPage(
        name: Routes.DETAIL_NEWS,
        page: () => const DetailNewsScreen(),
        binding: DetailNewsControllerBinding(),
        transition: Transition.fadeIn),
    GetPage(
        name: Routes.DASHBOARD,
        page: () => const DashboardScreen(),
        binding: DashboardControllerBinding(),
        transition: Transition.fadeIn),
  ];
}
