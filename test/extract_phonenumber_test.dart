import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/services/url_launcher.dart';

void main() {
  test('test extractPhoneNumber without other chars', () {
    const String phoneNumber = "123948585";
    const String text = "Das ist ein $phoneNumber Beispieltext";

    expect(extractPhoneNumber(text), phoneNumber);
  });

  test('test extractPhoneNumber with space, slash and hypen', () {
    const String phoneNumber = "58675 / 557-0";
    const String wantedPhoneNumber = "586755570";
    const String text = "Das ist ein $phoneNumber Beispieltext";

    expect(extractPhoneNumber(text), wantedPhoneNumber);
  });

  test('test extractPhoneNumber with space and leading 0', () {
    const String phoneNumber = "04445 88878";
    const String wantedPhoneNumber = "0444588878";
    const String text = "Das ist ein $phoneNumber Beispieltext";

    expect(extractPhoneNumber(text), wantedPhoneNumber);
  });

  test('test extractPhoneNumber with leading 0', () {
    const String phoneNumber = "0444588878";
    const String text = "Das ist ein $phoneNumber Beispieltext";

    expect(extractPhoneNumber(text), phoneNumber);
  });

  test('test extractPhoneNumber with spaces and country code', () {
    const String phoneNumber = "+49 2128409 3948";
    const String wantedPhoneNumber = "+4921284093948";
    const String text = "Das ist ein $phoneNumber Beispieltext";

    expect(extractPhoneNumber(text), wantedPhoneNumber);
  });

  test('test extractPhoneNumber with invalid input', () {
    String text = "asdf 94 fahfgoahfafr  wer 13 sdfsf  sdf";

    expect(extractPhoneNumber(text), null);
  });
  test('test extractPhoneNUmber with 110', () {
    String text = "call 110";

    expect(extractPhoneNumber(text), "110");
  });
}
