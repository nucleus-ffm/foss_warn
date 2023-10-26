import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/services/urlLauncher.dart';

void main() {
  test('test extractWebAddress with protocol', () {
    final String url1 = "http://example.com";
    final String url2 = "https://example.com";
    final String url3 = "http://example.com/text1";
    expect(extractWebAddress(url1), url1);
    expect(extractWebAddress(url2), url2);
    expect(extractWebAddress(url3), url3);


    final String url4 = "https://example.com/text2";
    final String url5 = "http://example.com/path1/subpath";
    final String url6 = "https://example.com/path2/subpath2";
    expect(extractWebAddress(url4), url4);
    expect(extractWebAddress(url5), url5);
    expect(extractWebAddress(url6), url6);
  });

  test('test extractWebAddress without protocol', () {
    final String url1 = "example.com";
    final String url2 = "example.com/path1";
    final String url3 = "example.com/path1/subpath";
    expect(extractWebAddress(url1), url1);
    expect(extractWebAddress(url2), url2);
    expect(extractWebAddress(url3), url3);
  });

  test('test extractWebAddress with protocol and subdomains', () {
    final String url1 = "http://test.example.com";
    final String url2 = "https://information.texttexttext.example.com";
    final String url3 = "https://help.ministry.somesub.example.com";
    final String urlWWW = "http://www.example.com";
    expect(extractWebAddress(url1), url1);
    expect(extractWebAddress(url2), url2);
    expect(extractWebAddress(url3), url3);
    expect(extractWebAddress(urlWWW), urlWWW);

    final String url4 = "http://test.example.com/path1";
    final String url5 = "https://information.texttexttext.example.com/path1";
    final String url6 = "https://help.ministry.somesub.example.com/path1";
    final String urlWWW2 = "http://www.example.com/path1";
    final String url7 = "http://test.example.com/path2/subpath";
    final String url8 = "https://information.texttexttext.example.com/path2/subpath";
    final String url9 = "https://help.ministry.somesub.example.com/path2/subpath";
    final String urlWWW3 = "http://www.example.com/path1/subpath";
    expect(extractWebAddress(url4), url4);
    expect(extractWebAddress(url5), url5);
    expect(extractWebAddress(url6), url6);
    expect(extractWebAddress(url7), url7);
    expect(extractWebAddress(url8), url8);
    expect(extractWebAddress(url9), url9);
    expect(extractWebAddress(urlWWW2), urlWWW2);
    expect(extractWebAddress(urlWWW3), urlWWW3);
  });

  test('test extractWebAddress without protocol and with subdomains', () {
    final String url1 = "test.example.com";
    final String url2 = "information.texttexttext.example.com";
    final String url3 = "help.ministry.somesub.example.com";
    final String urlWWW = "www.example.com";
    expect(extractWebAddress(url1), url1);
    expect(extractWebAddress(url2), url2);
    expect(extractWebAddress(url3), url3);
    expect(extractWebAddress(urlWWW), urlWWW);

    final String url4 = "test.example.com/path1";
    final String url5 = "information.texttexttext.example.com/path1";
    final String url6 = "help.ministry.somesub.example.com/path1";
    final String urlWWW2 = "www.example.com/path1";
    final String url7 = "test.example.com/path1/subpath";
    final String url8 = "information.texttexttext.example.com/path1/subpath";
    final String url9 = "help.ministry.somesub.example.com/path1/subpath";
    final String urlWWW3 = "www.example.com/path/subpath";
    expect(extractWebAddress(url4), url4);
    expect(extractWebAddress(url5), url5);
    expect(extractWebAddress(url6), url6);
    expect(extractWebAddress(url7), url7);
    expect(extractWebAddress(url8), url8);
    expect(extractWebAddress(url9), url9);
    expect(extractWebAddress(urlWWW2), urlWWW2);
    expect(extractWebAddress(urlWWW3), urlWWW3);
  });

  test('test extractWebAddress with html hyperlink tag', () {
    final String url1 = "http://example.com";
    final String str1 = '<a href="$url1">Linktext</a>';
    expect(extractWebAddress(str1), url1);
  });

  test('test extractWebAddress with invalid address', () {
    final String url1 = "lorem ipsum";
    final String url2 = "https://ex ample .co m";
    expect(extractWebAddress(url1), "invalid");
    expect(extractWebAddress(url2), "invalid");
  });

  test('test extractWebAddress with html hyperlink tag', () {
    final String url1 = "lorem ipsum";
    final String url2 = "https://ex ample .co m";
    final String str1 = '<a href="$url1">Linktext</a>';
    final String str2 = '<a href="$url2">Linktext</a>';
    expect(extractWebAddress(str1), "invalid");
    expect(extractWebAddress(str2), "invalid");
  });

}