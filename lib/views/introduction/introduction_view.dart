import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/main.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:foss_warn/views/introduction/slides/alarm_permission.dart';
import 'package:foss_warn/views/introduction/slides/battery_optimization.dart';
import 'package:foss_warn/views/introduction/slides/disclaimer.dart';
import 'package:foss_warn/views/introduction/slides/finish.dart';
import 'package:foss_warn/views/introduction/slides/fpas_server_info.dart';
import 'package:foss_warn/views/introduction/slides/notification_permission.dart';
import 'package:foss_warn/views/introduction/slides/places.dart';
import 'package:foss_warn/views/introduction/slides/unifiedpush.dart';
import 'package:foss_warn/views/introduction/slides/warning_levels.dart';
import 'package:foss_warn/views/introduction/slides/welcome.dart';

const int pageSwitchDurationInMilliseconds = 500;

class IntroductionView extends StatefulWidget {
  const IntroductionView({
    required this.onFinished,
    super.key,
  });

  final VoidCallback onFinished;

  @override
  State<IntroductionView> createState() => _IntroductionViewState();
}

class _IntroductionViewState extends State<IntroductionView>
    with WidgetsBindingObserver {
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

    WidgetsBinding.instance.addObserver(this);

    pageController.addListener(onPageSwitch);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    pageController.removeListener(onPageSwitch);
    pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var localisation = context.localizations;

    // TODO(PureTryOut): replace this for a fullproof solution to retrieve the keyboardOpen status
    // This will work fine on Android for the most part, however insets being bigger than 0 doesn't necessarily mean it's the keyboard.
    // The keyboard can also be floating in which case this will also report keyboardClosed, even though it's definitely open.
    // We should probably use a native platform API to request the keyboard status from the platform.
    var keyboardOpen = mediaQuery.viewInsets.bottom > 0;

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

      widget.onFinished();
    }

    void onPagePrevious() {
      pageController.animateToPage(
        currentPage - 1,
        duration:
            const Duration(milliseconds: pageSwitchDurationInMilliseconds),
        curve: Curves.easeInOut,
      );
    }

    void onPageNext() {
      pageController.animateToPage(
        currentPage + 1,
        duration:
            const Duration(milliseconds: pageSwitchDurationInMilliseconds),
        curve: Curves.easeInOut,
      );
    }

    var introductionPages = [
      const IntroductionWelcomeSlide(),
      const IntroductionFPASServerInfoSlide(),
      const IntroductionUnifiedpushSlide(),
      const IntroductionDisclaimerSlide(),
      if (Platform.isAndroid) ...[
        IntroductionNotificationPermissionSlide(
          hasPermission: hasNotificationPermission,
          onPermissionChanged: onRequestNotificationPermissionPressed,
        ),
        IntroductionAlarmPermissionSlide(
          hasPermission: hasAlarmPermission,
          onPermissionChanged: onRequestAlarmPermissionPressed,
        ),
        const IntroductionBatteryOptimizationSlide(),
      ],
      const IntroductionPlacesSlide(),
      const IntroductionWarningLevelsSlide(),
      IntroductionFinishsSlide(onFinishPressed: onFinishPressed),
    ];

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Stack(
              children: [
                Row(
                  children: [
                    Visibility(
                      maintainSize: false,
                      maintainSemantics: false,
                      maintainAnimation: true,
                      maintainState: true,
                      // TODO(PureTryOut): check for screen sizes instead
                      visible: !Platform.isAndroid && currentPage >= 1.0,
                      child: TextButton(
                        onPressed: onPagePrevious,
                        child:
                            Text(localisation.welcome_view_navigation_previous),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: pageController,
                        itemCount: introductionPages.length,
                        itemBuilder: (context, index) =>
                            introductionPages[index],
                      ),
                    ),
                    Visibility(
                      maintainSize: false,
                      maintainSemantics: false,
                      maintainAnimation: true,
                      maintainState: true,
                      // TODO(PureTryOut): check for screen sizes instead
                      visible: !Platform.isAndroid &&
                          currentPage < introductionPages.length - 1,
                      child: TextButton(
                        onPressed: onPageNext,
                        child: Text(localisation.welcome_view_navigation_next),
                      ),
                    ),
                  ],
                ),
                if (currentPage != introductionPages.length - 1 &&
                    !keyboardOpen) ...[
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
        margin: const EdgeInsets.only(top: 70.0),
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Visibility(
          // hide the step indicator if the keyboard is open
          visible: mediaQuery.viewInsets.bottom == 0 ? true : false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pageCount,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                height: 10.0,
                width: 10.0,
                decoration: BoxDecoration(
                  color: currentPage == index
                      ? const Color(0XFF256075)
                      : const Color(0XFF256075).withValues(alpha: 0.2),
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
