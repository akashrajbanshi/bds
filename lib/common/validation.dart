import 'package:bds/common/utility.dart';
import 'package:bds/common/strings.dart';

class Validation {
  static checkStartTimeToEndTime(String startTime, String endTime) {
    if (startTime.isNotEmpty) {
      if (Utility.convertTimeStringToDateTime(endTime)
          .isBefore(Utility.convertTimeStringToDateTime(startTime))) {
        return true;
      }
    }
    return false;
  }

  static checkEndTimeToStartTime(String endTime, String startTime) {
    if (endTime.isNotEmpty) {
      if (Utility.convertTimeStringToDateTime(startTime)
          .isAfter(Utility.convertTimeStringToDateTime(endTime))) {
        return true;
      }
    }
    return false;
  }
}
