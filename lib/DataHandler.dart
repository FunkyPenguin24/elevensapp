import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert' as convert;

class DataHandler {
  List<Entry> times = [];

  void loadTimes() async {
    times = [];
    final loadPath = await getApplicationDocumentsDirectory();
    final file = await File("${loadPath.path}/times.json").create(recursive: true);
    String rawEntries = await file.readAsString();
    if (rawEntries != "" && rawEntries != null) {
      List<dynamic> rawList = convert.jsonDecode(rawEntries);
      for (int i = 0; i < rawList.length; i++) {
        Entry e = Entry.fromJson(rawList[i]);
        times.add(e);
      }
    }
    sortTimes();
  }

  void sortTimes() {
    bool sorted = false;
    do {
      sorted = true;
      for (int i = 0; i < times.length-1; i++) {
        if (timeIsGreaterThan(times[i].time, times[i+1].time)) {
          Entry temp = times[i];
          times[i] = times[i+1];
          times[i+1] = temp;
          sorted = false;
        }
      }
    } while (!sorted);
  }

  bool timeIsGreaterThan(String time1, String time2) {
    int minute1 = int.parse(time1.substring(0, 2));
    int minute2 = int.parse(time2.substring(0, 2));
    if (minute1 != minute2) {
      return (minute1 > minute2);
    } else {
      int second1 = int.parse(time1.substring(3));
      int second2 = int.parse(time2.substring(3));
      return (second1 > second2);
    }
  }

  Future<bool> saveTime(Entry e) async {
    if (times.length < 10) {
      times.add(e);
      sortTimes();
      await saveTimes();
      return true;
    } else {
      if (timeIsGreaterThan(times[9].time, e.time)) {
        times[9] = e;
        sortTimes();
        await saveTimes();
        return true;
      } else {
        return false;
      }
    }
  }

  saveTimes() async {
    final savePath = await getApplicationDocumentsDirectory();
    final file = await File("${savePath.path}/times.json").create(recursive: true);
    await file.writeAsString(convert.jsonEncode(times));
  }

}

class Entry {

  DateTime dayDone;
  String time;

  Entry(this.dayDone, this.time);

  Entry.fromJson(Map<String, dynamic> json)
      : dayDone = DateTime.parse(json["date"]),
        time = json["time"];

  Map<String, dynamic> toJson() =>
      {
        "date" : dayDone.toString(),
        "time" : time,
      };

}