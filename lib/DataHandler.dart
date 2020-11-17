import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert' as convert;

class DataHandler {
  List<Entry> times = [];
  List<CardCount> cards = [];

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

  saveTimes() async {
    final savePath = await getApplicationDocumentsDirectory();
    final file = await File("${savePath.path}/times.json").create(recursive: true);
    await file.writeAsString(convert.jsonEncode(times));
  }

  void loadCards() async {
    cards = [];
    final loadPath = await getApplicationDocumentsDirectory();
    final file = await File("${loadPath.path}/cards.json").create(recursive: true);
    String rawData = await file.readAsString();
    if (rawData != "" && rawData != null) {
      List<dynamic> rawList = convert.jsonDecode(rawData);
      for (int i = 0; i < rawList.length; i++) {
        CardCount c = CardCount.fromJson(rawList[i]);
        cards.add(c);
      }
    }
    sortCards();
  }

  saveCards() async {
    final savePath = await getApplicationDocumentsDirectory();
    final file = await File("${savePath.path}/cards.json").create(recursive: true);
    await file.writeAsString(convert.jsonEncode(cards));
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

  void sortCards() {
    bool sorted = false;
    do {
      sorted = true;
      for (int i = 0; i < cards.length-1; i++) {
        if (cards[i].cardsLeft > cards[i+1].cardsLeft) {
          CardCount tempCard = cards[i];
          cards[i] = cards[i+1];
          cards[i+1] = tempCard;
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

  Future<bool> saveCard(CardCount c) async {
    if (cards.length < 10) {
      cards.add(c);
      sortCards();
      await saveCards();
      return true;
    } else {
      if (cards[9].cardsLeft > c.cardsLeft) {
        cards[9] = c;
        sortCards();
        await saveCards();
        return true;
      } else {
        return false;
      }
    }
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

class CardCount {

  DateTime dayDone;
  int cardsLeft;

  CardCount(this.dayDone, this.cardsLeft);

  CardCount.fromJson(Map<String, dynamic> json)
    : dayDone = DateTime.parse(json["date"]),
      cardsLeft = json["cards"];

  Map<String, dynamic> toJson() =>
      {
        "date" : dayDone.toString(),
        "cards" : cardsLeft,
      };

}