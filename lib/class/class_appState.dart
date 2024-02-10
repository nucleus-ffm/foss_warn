import '../enums/DataFetchStatus.dart';

class AppState {
  bool error = false; //if API call and parsing was successful
  bool mowasStatus = false;
  bool mowasParseStatus = false;
  bool katwarnStatus = false;
  bool katwarnParseStatus = false;
  bool biwappStatus = false;
  bool biwappParseStatus = false;
  bool dwdStatus = false;
  bool dwdParseStatus = false;
  bool lhpStatus = false;
  bool lhpParseStatus = false;
  DataFetchStatus dataFetchStatusOldAPI = DataFetchStatus.no_info;

  // ETags to check for changes in server data since data was fetched
  String mowasETag = "";
  String biwappETag = "";
  String katwarnETag = "";
  String dwdETag = "";
  String lhpETag = "";

  int mowasWarningsCount = 0;
  int katwarnWarningsCount = 0;
  int biwappWarningsCount = 0;
  int dwdWarningsCount = 0;
  int lhpWarningsCount = 0;
}