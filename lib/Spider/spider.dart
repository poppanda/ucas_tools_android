import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class CourseInfo {
  // String courseName;
  final int _courseWeekDay, _courseWeek;
  final String _startTime, _endTime;
  final String _courseLocation;
  CourseInfo(this._courseWeekDay, this._courseWeek, this._startTime,
      this._endTime, this._courseLocation);
  @override
  String toString() {
    return "_courseWeekDay = $_courseWeekDay, _courseWeek = $_courseWeek, _startTime = $_startTime, _endTime = $_endTime, _courseLocation = $_courseLocation";
  }

  String get location {
    return _courseLocation;
  }

  DateTime get startTimeFormatted {
    return DateTime(2023, 9, 4).add(Duration(
        days: (_courseWeek - 1) * 7 + _courseWeekDay - 1,
        hours: int.parse(_startTime.split(":")[0]),
        minutes: int.parse(_startTime.split(":")[1])));
  }

  DateTime get endTimeFormatted {
    return DateTime(2023, 9, 4).add(Duration(
        days: (_courseWeek - 1) * 7 + _courseWeekDay - 1,
        hours: int.parse(_endTime.split(":")[0]),
        minutes: int.parse(_endTime.split(":")[1])));
  }
}

Future<String> requestData(String url, String cookie) async {
  var header = {
    "User-Agent":
        'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36',
    "Cookie": cookie,
  };
  var response = await http.get(Uri.parse(url), headers: header);
  if (response.statusCode == 200) {
    return response.body;
  }
  return '<html>error! status: ${response.statusCode}</html>';
}

Future<(String, List<CourseInfo>)> getCourseInfo(
    String courseId, String cookie) async {
  const weekday = {
        "星期一": 1,
        "星期二": 2,
        "星期三": 3,
        "星期四": 4,
        "星期五": 5,
        "星期六": 6,
        "星期日": 7,
      },
      timeDuration = {
        "1": ["8:30", "9:20"],
        "2": ["9:20", "10:10"],
        "3": ["10:30", "11:20"],
        "4": ["11:20", "12:10"],
        "5": ["13:30", "14:20"],
        "6": ["14:20", "15:10"],
        "7": ["15:30", "16:20"],
        "8": ["16:20", "17:10"],
        "9": ["18:10", "19:00"],
        "10": ["19:00", "19:50"],
        "11": ["20:10", "21:00"],
        "12": ["21:00", "21:50"],
      };
  var html = await requestData(
      "https://jwxkts2.ucas.ac.cn/course/coursetime/$courseId", cookie);
  Document document = parse(html);
  List<Element> elements = document.querySelectorAll('.mc-body > p');
  var courseName = elements[0].text.replaceAll("课程名称：", "");
  elements = document.querySelectorAll('.mc-body > table > tbody > tr');
  List<CourseInfo> courseInfo = [];
  for (int i = 0; i < elements.length; i += 3) {
    var rawCourseTime = elements[i].children[1].text;
    var retCourseLocation = elements[i + 1].children[1].text;
    var rawCourseWeek = elements[i + 2].children[1].text;
    var retCourseDay = rawCourseTime.split("： ")[0];
    var tmpCourseTime =
        rawCourseTime.split("： 第")[1].replaceAll("节。", "").split("、");
    var retCourseTime = [
      timeDuration[tmpCourseTime[0]]![0],
      timeDuration[tmpCourseTime[tmpCourseTime.length - 1]]![1],
    ];
    var retCourseWeek = rawCourseWeek.split("、");
    for (var retWeek in retCourseWeek) {
      courseInfo.add(CourseInfo(weekday[retCourseDay]!, int.parse(retWeek),
          retCourseTime[0], retCourseTime[1], retCourseLocation));
    }
  }
  // log(courseInfo.toString());
  return (courseName, courseInfo);
}

Future<Map<String, List<CourseInfo>>> getCoursesInfo(String cookie) async {
  log("Spider: Getting info");
  var html;
  try {
    html = await requestData(
        "https://jwxkts2.ucas.ac.cn/courseManage/main", cookie);
  } catch (e) {
    log("Spider: Error");
    return {};
  }
  log("Spider: Parsing info");
  Document document = parse(html);
  List<Element> elements =
      document.querySelectorAll('.mc-body > table > tbody > tr > td > a');
  Map<String, List<CourseInfo>> coursesInfo = {};
  log("Spider: Parsing course info");
  for (Element element in elements) {
    if (element.attributes.containsKey('href') &&
        element.attributes['href']!.startsWith("/course/coursetime")) {
      var courseId =
          element.attributes['href']!.replaceAll("/course/coursetime/", "");
      var (courseName, courseInfo) = await getCourseInfo(courseId, cookie);
      coursesInfo[courseName] = courseInfo;
    }
  }
  log("Spider: return course info");
  return coursesInfo;
}

void main(List<String> args) {
  getCoursesInfo(
      "JSESSIONID=94F4E377B2F5A5A6180C9C2DB4A7B778; sepuser=\"bWlkPTg4YTdiNDE1LThmZDItNDJhNi1hMzg5LTIwMDMzNTcxN2MwYQ== \"");
}
