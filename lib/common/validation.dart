import 'package:bds/common/utility.dart';
import 'package:bds/common/strings.dart';

class Validation {
  static checkStartTimeToEndTime(String startTime, String endTime) {
    if (startTime.isNotEmpty) {
      if (Utility.convertStringToDateTime(endTime)
          .isBefore(Utility.convertStringToDateTime(startTime))) {
        return true;
      }
    }
    return false;
  }

  static checkEndTimeToStartTime(String endTime, String startTime) {
    if (endTime.isNotEmpty) {
      if (Utility.convertStringToDateTime(startTime)
          .isAfter(Utility.convertStringToDateTime(endTime))) {
        return true;
      }
    }
    return false;
  }
}
