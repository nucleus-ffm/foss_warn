import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/class/class_references.dart';

void main() {
  test(
    'test references class parsing with correct data',
    () {
      String data =
          "trinet@caltech.edu,TRI13970876.1,2003-06-11T20:30:00-07:00";
      References expectedResult = References(
        sender: "trinet@caltech.edu",
        identifier: ["TRI13970876.1"],
        send: "2003-06-11T20:30:00-07:00",
      );
      References testReference = References.fromString(data);

      expect(testReference.sender, expectedResult.sender);
      expect(testReference.identifier, expectedResult.identifier);
      expect(testReference.send, expectedResult.send);
    },
  );

  test(
    'test references class parsing with biwapp data in wrong format',
    () {
      String data =
          "biw.BIWAPP-91770_ODc4ZGQ0Y2VlOGRiNmQxMg biw.BIWAPP-91770_YzVlMWQyN2NmNjU0MWY3Mg";
      References expectedResult = References(
        sender: "NA",
        identifier: [
          "biw.BIWAPP-91770_ODc4ZGQ0Y2VlOGRiNmQxMg",
          "biw.BIWAPP-91770_YzVlMWQyN2NmNjU0MWY3Mg",
        ],
        send: "NA",
      );
      References testReference = References.fromString(data);

      expect(testReference.sender, expectedResult.sender);
      expect(testReference.identifier, expectedResult.identifier);
      expect(testReference.send, expectedResult.send);
    },
  );
}
