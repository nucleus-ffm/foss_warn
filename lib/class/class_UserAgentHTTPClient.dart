
import 'package:http/http.dart' as http;

/// http client with uses the given value as userAgent
class UserAgentHttpClient extends http.BaseClient {
  final String userAgent;
  final http.Client _inner;

  UserAgentHttpClient(this.userAgent, this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['User-Agent'] = userAgent;
    return _inner.send(request);
  }
}