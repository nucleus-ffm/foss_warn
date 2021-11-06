import 'package:flutter/material.dart';
import 'services/welcomeScreenItems.dart';
import 'package:app_settings/app_settings.dart';
import 'main.dart';
import 'SettingsView.dart';
import 'services/saveAndLoadSharedPreferences.dart';
import 'widgets/DisclaimerDialog.dart';
import 'widgets/privacyDialog.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  _WelcomeViewState createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  double currentPage = 0.0;
  final _pageViewController = new PageController();
  bool disclaimerConfirm = false;
  GlobalKey<NavigatorState> navigatorKey2 = GlobalKey<NavigatorState>();

  List<Widget> slides = welcomeScreenItems
      .map((item) => Container(
          padding: EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              item['image'] != ""
                  ? Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Image.asset(
                        item['image'],
                        fit: BoxFit.fitWidth,
                        width: 220.0,
                        height: 200.0,
                        alignment: Alignment.bottomCenter,
                      ),
                    )
                  : SizedBox(
                      height: 45,
                    ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Text(item['header'],
                            style: TextStyle(
                                fontSize: 34.0,
                                fontWeight: FontWeight.w300,
                                color: Color(0XFF3F3D56),
                                height: 2.0)),
                        Text(
                          item['description'],
                          style: TextStyle(
                              color: Colors.grey,
                              letterSpacing: 1.2,
                              fontSize: 16.0,
                              height: 1.3),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        item['action'] != ""
                            ? item['action'] == "batteryOptimization"
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          AppSettings
                                              .openBatteryOptimizationSettings();
                                        },
                                        child: Text(
                                          "Akkuoptimerung ausschalten",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        style: TextButton.styleFrom(
                                            backgroundColor: Colors.blue),
                                      )
                                    ],
                                  )
                                : item['action'] == "disclaimer"
                                    ? Column(
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              showDialog(
                                                context:
                                                    navigatorKey.currentContext!,
                                                builder: (BuildContext context) {
                                                  return DisclaimerDialog();
                                                },
                                              );
                                            },
                                            child: Text("Haftungsausschluss", style: TextStyle(color: Colors.white),),
                                          style: TextButton.styleFrom(
                                              backgroundColor: Colors.blue),),
                                        TextButton(
                                            onPressed: () {
                                              showDialog(
                                                context:
                                                navigatorKey.currentContext!,
                                                builder: (BuildContext context) {
                                                  return PrivacyDialog();
                                                },
                                              );
                                            },
                                            child: Text("Datenschutz", style: TextStyle(color: Colors.white),),
                                          style: TextButton.styleFrom(
                                              backgroundColor: Colors.blue),),
                                      ],
                                    )
                                    : SizedBox()
                            : SizedBox(
                                height: 50,
                              )
                      ],
                    ),
                  ),
                ),
              )
            ],
          )))
      .toList();
  List<Widget> indicator() => List<Widget>.generate(
      slides.length,
      (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 3.0),
            height: 10.0,
            width: 10.0,
            decoration: BoxDecoration(
                color: currentPage.round() == index
                    ? Color(0XFF256075)
                    : Color(0XFF256075).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.0)),
          ));

  @override
  Widget build(BuildContext context) {
    print(welcomeScreenItems[1]['image']);


    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: _pageViewController,
              itemCount: slides.length,
              itemBuilder: (BuildContext context, int index) {
                _pageViewController.addListener(() {
                  setState(() {
                    currentPage = _pageViewController.page!;
                  });
                });
                return slides[index];
              },
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 70.0),
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: currentPage == slides.length - 1
                      ? TextButton(
                          onPressed: () {
                            showWelcomeScreen = false;
                            saveSettings();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => ScaffoldView(),
                              ),
                              //(route) => false,
                            );

                            /*Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScaffoldView(),
                              ),
                            );*/
                            //Navigator.pop(context);
                          },
                          child: Text(
                            "Einrichtung beenden",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.blue))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: indicator(),
                        ),
                ))
          ],
        ),
      ),
    );
  }
}
