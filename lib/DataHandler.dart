import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert' as convert;

///Used to load and save data from and to the user's phone
class DataHandler {
  List<Entry> times = [];
  List<CardCount> cards = [];

  ///Loads the user's top 10 times from their phone
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

  ///Saves the top 10 user's times stored by the application to the user's phone
  saveTimes() async {
    final savePath = await getApplicationDocumentsDirectory();
    final file = await File("${savePath.path}/times.json").create(recursive: true);
    await file.writeAsString(convert.jsonEncode(times));
  }

  ///Loads the top 10 fewest number of cards from the user's phone
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

  ///Saves the user's fewest 10 cards remaining to their phone
  saveCards() async {
    final savePath = await getApplicationDocumentsDirectory();
    final file = await File("${savePath.path}/cards.json").create(recursive: true);
    await file.writeAsString(convert.jsonEncode(cards));
  }

  ///Sorts the user's top 10 times from highest to lowest using a bubble sort algorithm
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

  ///Sorts the user's fewest 10 remaining cards from highest to lowest using a bubble sort algorithm
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

  ///Returns true if time1 is greater than time2
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

  ///Saves the given Entry object to the application and the user's phone
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

  ///Saves the given CardCount object to the application and the user's phone
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

///Holds data relating to the time a user completed the game in
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

///Holds data relating to the remaining cards a user had when they lost the game
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