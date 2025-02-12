import 'package:flutter/material.dart';

class IntroductionBaseSlide extends StatelessWidget {
  const IntroductionBaseSlide({
    required this.imagePath,
    required this.title,
    required this.text,
    this.footer,
    super.key,
  });

  final String imagePath;
  final String title;
  final String text;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0).copyWith(top: 80.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.fitWidth,
              width: 220.0,
              height: 200.0,
              alignment: Alignment.bottomCenter,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 29.0,
                fontWeight: FontWeight.w300,
                height: 2.0,
              ),
            ),
            Text(
              text,
              style: TextStyle(
                color: Colors.grey,
                letterSpacing: 1.2,
                fontSize: 16.0,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            if (footer != null) ...[
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}
