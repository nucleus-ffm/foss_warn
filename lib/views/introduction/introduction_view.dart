import 'package:flutter/material.dart';
import 'package:foss_warn/main.dart';
import 'package:foss_warn/services/fpas.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/views/introduction/slides/alarm_permission.dart';
import 'package:foss_warn/views/introduction/slides/battery_optimization.dart';
import 'package:foss_warn/views/introduction/slides/disclaimer.dart';
import 'package:foss_warn/views/introduction/slides/finish.dart';
import 'package:foss_warn/views/introduction/slides/fpas_server_select.dart';
import 'package:foss_warn/views/introduction/slides/notification_permission.dart';
import 'package:foss_warn/views/introduction/slides/places.dart';
import 'package:foss_warn/views/introduction/slides/warning_levels.dart';
import 'package:foss_warn/views/introduction/slides/welcome.dart';

class IntroductionView extends StatefulWidget {
  const IntroductionView({super.key});

  @override
  State<IntroductionView> createState() => _IntroductionViewState();
}

class _IntroductionViewState extends State<IntroductionView> {
  int currentPage = 0;
  final PageController pageController = PageController();

  ServerSettings? selectedServerSettings;
  bool hasNotificationPermission = false;
  bool hasAlarmPermission = false;

  void onPageSwitch() {
    if (pageController.page == null) {
      return;
    }

    currentPage = pageController.page!.round();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    pageController.addListener(onPageSwitch);
  }

  @override
  void dispose() {
    pageController.removeListener(onPageSwitch);
    pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void onServerSelected(ServerSettings serverSettings) {
      selectedServerSettings = serverSettings;
      setState(() {});

      userPreferences.fossPublicAlertServerUrl = serverSettings.url;
      userPreferences.fossPublicAlertServerOperator = serverSettings.operator;
      userPreferences.fossPublicAlertServerPrivacyNotice =
          serverSettings.privacyNotice;
      userPreferences.fossPublicAlertServerTermsOfService =
          serverSettings.termsOfService;
    }

    Future<void> onRequestNotificationPermissionPressed() async {
      hasNotificationPermission =
          await NotificationService().requestNotificationPermission() ?? false;

      setState(() {});
    }

    Future<void> onRequestAlarmPermissionPressed() async {
      hasAlarmPermission =
          await NotificationService().requestExactAlarmPermission() ?? false;

      setState(() {});
      await NotificationService().init();
    }

    Future<void> onFinishPressed() async {
      userPreferences.showWelcomeScreen = false;
      setState(() {});

      // TODO(PureTryOut): replace for go_router
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomeView(),
        ),
      );
    }

    var introductionPages = [
      IntroductionWelcomeSlide(),
      IntroductionFPASServerSelectionSlide(
        selectedServerSettings: selectedServerSettings,
        onServerSelected: onServerSelected,
      ),
      IntroductionDisclaimerSlide(),
      IntroductionNotificationPermissionSlide(
        hasPermission: hasNotificationPermission,
        onPermissionChanged: onRequestNotificationPermissionPressed,
      ),
      IntroductionAlarmPermissionSlide(
        hasPermission: hasAlarmPermission,
        onPermissionChanged: onRequestAlarmPermissionPressed,
      ),
      IntroductionBatteryOptimizationSlide(),
      IntroductionPlacesSlide(),
      IntroductionWarningLevelsSlide(),
      IntroductionFinishsSlide(onFinishPressed: onFinishPressed),
    ];

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: introductionPages.length,
                  itemBuilder: (context, index) => introductionPages[index],
                ),
                if (currentPage != introductionPages.length - 1) ...[
                  _PageProgressDots(
                    pageCount: introductionPages.length,
                    currentPage: currentPage,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PageProgressDots extends StatelessWidget {
  const _PageProgressDots({
    required this.pageCount,
    required this.currentPage,
  });

  final int pageCount;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(top: 70.0),
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Visibility(
          // hide the step indicator if the keyboard is open
          visible: mediaQuery.viewInsets.bottom == 0 ? true : false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pageCount,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 3.0),
                height: 10.0,
                width: 10.0,
                decoration: BoxDecoration(
                  color: currentPage == index
                      ? Color(0XFF256075)
                      : Color(0XFF256075).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
