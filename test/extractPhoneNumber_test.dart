import 'package:flutter_test/flutter_test.dart';

import 'package:foss_warn/services/urlLauncher.dart';

void main() {
  test('test if phone numbers are correctly detected', () {
    String test1 = "asdfahfgoahfafr 123948585 qdfwQR";
    expect(extractPhoneNumber(test1), "123948585");
  });

  test('test if phone numbers are correctly detected', () {
    String test1 = "asdfahfgoahfafr 58675 / 557-0 sdfsfd";
    expect(extractPhoneNumber(test1), "586755570");
  });

  test('test if phone numbers are correctly detected', () {
    String test1 = "asdfahfgoahfafr 04445 88878";
    expect(extractPhoneNumber(test1), "0444588878");
  });
  test('test if phone numbers are correctly detected', () {
    String test1 = "asdfahfgoahfafr 0444588878";
    expect(extractPhoneNumber(test1), "0444588878");
  });
  test('test if phone numbers are correctly detected', () {
    String test1 = "asdfahfgoahfafr +49 2128409 3948 sdfsf  sdf";
    expect(extractPhoneNumber(test1), "+4921284093948");
  });
  test('test if the result is correct, if there is no valid input', () {
    String test1 = "asdf 94 fahfgoahfafr  wer 13 sdfsf  sdf";
    expect(extractPhoneNumber(test1), "no valid phone number");
  });

}