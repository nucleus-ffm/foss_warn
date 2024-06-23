import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/services/urlLauncher.dart';

void main() {
  test('test extractWebAddress with protocol', () {
    final String url1 = "http://example.com";
    final String url2 = "https://example.com";
    final String url3 = "http://example.com/text1";
    expect(extractWebAddress(url1).toString(), url1);
    expect(extractWebAddress(url2).toString(), url2);
    expect(extractWebAddress(url3).toString(), url3);


    final String url4 = "https://example.com/text2";
    final String url5 = "http://example.com/path1/subpath";
    final String url6 = "https://example.com/path2/subpath2";
    expect(extractWebAddress(url4).toString(), url4);
    expect(extractWebAddress(url5).toString(), url5);
    expect(extractWebAddress(url6).toString(), url6);
  });

  test('test extractWebAddress without protocol', () {
    final String url1 = "example.com";
    final String url1_exp = "http://example.com";
    final String url2 = "example.com/path1";
    final String url2_exp = "http://example.com/path1";
    final String url3 = "example.com/path1/subpath";
    final String url3_exp = "http://example.com/path1/subpath";
    expect(extractWebAddress(url1).toString(), url1_exp);
    expect(extractWebAddress(url2).toString(), url2_exp);
    expect(extractWebAddress(url3).toString(), url3_exp);
  });

  test('test extractWebAddress with protocol and subdomains', () {
    final String url1 = "http://test.example.com";
    final String url2 = "https://information.texttexttext.example.com";
    final String url3 = "https://help.ministry.somesub.example.com";
    final String urlWWW = "http://www.example.com";
    expect(extractWebAddress(url1).toString(), url1);
    expect(extractWebAddress(url2).toString(), url2);
    expect(extractWebAddress(url3).toString(), url3);
    expect(extractWebAddress(urlWWW).toString(), urlWWW);

    final String url4 = "http://test.example.com/path1";
    final String url5 = "https://information.texttexttext.example.com/path1";
    final String url6 = "https://help.ministry.somesub.example.com/path1";
    final String urlWWW2 = "http://www.example.com/path1";
    final String url7 = "http://test.example.com/path2/subpath";
    final String url8 = "https://information.texttexttext.example.com/path2/subpath";
    final String url9 = "https://help.ministry.somesub.example.com/path2/subpath";
    final String urlWWW3 = "http://www.example.com/path1/subpath";
    expect(extractWebAddress(url4).toString(), url4);
    expect(extractWebAddress(url5).toString(), url5);
    expect(extractWebAddress(url6).toString(), url6);
    expect(extractWebAddress(url7).toString(), url7);
    expect(extractWebAddress(url8).toString(), url8);
    expect(extractWebAddress(url9).toString(), url9);
    expect(extractWebAddress(urlWWW2).toString(), urlWWW2);
    expect(extractWebAddress(urlWWW3).toString(), urlWWW3);
  });

  test('test extractWebAddress without protocol and with subdomains', () {
    final String url1 = "test.example.com";
    final String url1_exp = "http://test.example.com";
    final String url2 = "information.texttexttext.example.com";
    final String url2_exp = "http://information.texttexttext.example.com";
    final String url3 = "help.ministry.somesub.example.com";
    final String url3_exp = "http://help.ministry.somesub.example.com";
    final String urlWWW = "www.example.com";
    final String urlWWW_exp = "http://www.example.com";
    expect(extractWebAddress(url1).toString(), url1_exp);
    expect(extractWebAddress(url2).toString(), url2_exp);
    expect(extractWebAddress(url3).toString(), url3_exp);
    expect(extractWebAddress(urlWWW).toString(), urlWWW_exp);

    final String url4 = "test.example.com/path1";
    final String url4_exp = "http://test.example.com/path1";
    final String url5 = "information.texttexttext.example.com/path1";
    final String url5_exp = "http://information.texttexttext.example.com/path1";
    final String url6 = "help.ministry.somesub.example.com/path1";
    final String url6_exp = "http://help.ministry.somesub.example.com/path1";
    final String urlWWW2 = "www.example.com/path1";
    final String urlWWW2_exp = "http://www.example.com/path1";
    final String url7 = "test.example.com/path1/subpath";
    final String url7_exp = "http://test.example.com/path1/subpath";
    final String url8 = "information.texttexttext.example.com/path1/subpath";
    final String url8_exp = "http://information.texttexttext.example.com/path1/subpath";
    final String url9 = "help.ministry.somesub.example.com/path1/subpath";
    final String url9_exp = "http://help.ministry.somesub.example.com/path1/subpath";
    final String urlWWW3 = "www.example.com/path/subpath";
    final String urlWWW3_exp = "http://www.example.com/path/subpath";
    expect(extractWebAddress(url4).toString(), url4_exp);
    expect(extractWebAddress(url5).toString(), url5_exp);
    expect(extractWebAddress(url6).toString(), url6_exp);
    expect(extractWebAddress(url7).toString(), url7_exp);
    expect(extractWebAddress(url8).toString(), url8_exp);
    expect(extractWebAddress(url9).toString(), url9_exp);
    expect(extractWebAddress(urlWWW2).toString(), urlWWW2_exp);
    expect(extractWebAddress(urlWWW3).toString(), urlWWW3_exp);
  });

  test('test extractWebAddress with html hyperlink tag', () {
    final String url1 = "http://example.com";
    final String str1 = '<a href="$url1">Linktext</a>';
    expect(extractWebAddress(str1).toString(), url1);
  });

  test('test extractWebAddress with invalid address', () {
    final String url1 = "lorem ipsum";
    final String url2 = "https://ex ample .co m";
    expect(extractWebAddress(url1), null);
    expect(extractWebAddress(url2), null);
  });

  test('test extractWebAddress with invalid html hyperlink tag', () {
    final String url1 = "lorem ipsum";
    final String url2 = "https://ex ample .co m";
    final String str1 = '<a href="$url1">Linktext</a>';
    final String str2 = '<a href="$url2">Linktext</a>';
    expect(extractWebAddress(str1), null);
    expect(extractWebAddress(str2), null);
  });

  test('test extractWebAddress with email with protocol', () {
    final String url1 = "mailto://mail@example.com";
    final String url2 = "mailto://mail.mail@example.example.com";
    expect(extractWebAddress(url1).toString(), url1);
    expect(extractWebAddress(url2).toString(), url2);
  });

  test('test extractWebAddress with email without protocol', () {
    final String url1 = "mail@example.com";
    final String url1_exp =  "mailto://mail@example.com";
    final String url2 = "mail.mail@example.example.com";
    final String url2_exp =  "mailto://mail.mail@example.example.com";
    expect(extractWebAddress(url1).toString(), url1_exp);
    expect(extractWebAddress(url2).toString(), url2_exp);
  });

}