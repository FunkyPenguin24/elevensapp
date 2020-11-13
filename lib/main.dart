import 'dart:async';
import 'package:flutter/material.dart';

import 'Card.dart';
import 'DataHandler.dart';
import 'Leaderboard.dart';
import 'Patience.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elevens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        canvasColor: Colors.green,
      ),
      home: MyHomePage(title: 'Elevens'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Patience game;
  PCard chosenCard;
  PCard chosenFaceCard1;
  PCard chosenFaceCard2;
  bool started = false;
  DateTime timeStarted;
  Duration timeDiff;
  Duration timePaused;
  Timer timer;
  bool top10time = false;
  DataHandler dh = new DataHandler();
  bool paused = false;

  initState() {
    super.initState();
    game = new Patience(gameWonCallback, gameFailedCallback);
    game.initGame();
    dh.loadTimes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            getCardWidget(),
            Visibility(
              visible: !game.playing,
              child: Column(
                children: [
                  Expanded(
                    child: Opacity(
                      opacity: (paused) ? 1.0 : 0.9,
                      child: getOverlay(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                tooltip: "Pause game",
                icon: Icon((paused) ? Icons.play_arrow : Icons.pause),
                onPressed: () {
                  if (started && !game.won && !game.failed) {
                    this.setState(() {
                      paused = !paused;
                      game.playing = !game.playing;
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: IconButton(
                tooltip: "Deal new card",
                icon: Icon(Icons.arrow_upward),
                color: (game.gameCards[8] == null) ? Colors.black : Colors.blueGrey,
                onPressed: () {
                  if (game.gameCards[8] == null && game.playing) {
                    this.setState(() {
                      game.playNewCard();
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: IconButton(
                tooltip: "Restart",
                icon: Icon(Icons.refresh),
                onPressed: () {
                  if (started) {
                    chosenCard = null;
                    this.setState(() {
                      top10time = false;
                      timeStarted = DateTime.now();
                      timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
                        if (game.playing) {
                          this.setState(() {
                            timeDiff = DateTime.now().difference(timeStarted);
                          });
                        } else if (paused) {
                          timeStarted = timeStarted.add(Duration(seconds: 1));
                        }
                      });
                      game.restart();
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: IconButton(
                tooltip: "Best times",
                icon: Icon(Icons.table_chart),
                onPressed: () {
                  if (!game.playing) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LeaderboardScreen(dh)),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getCardWidget() {
    List<Widget> listOfWidgets = new List<Widget>();

    listOfWidgets.add(Padding(padding: EdgeInsets.only(top: 16.0)));

    for (int y = 0; y < 3; y++) {
      listOfWidgets.add(Expanded(
        child: Row(
          children: [
            for (int x = 0; x < 3; x++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          if (!game.won && game.playing && started) {
                            if (game.gameCards[(y*3) + x] != null) {
                              cardPressed(game.gameCards[(y*3) + x]);
                            }
                          }
                        },
                        child: Image(image: AssetImage((game.gameCards[(y*3) + x] == null) ? 'assets/cards/cardBackBlue.png' : 'assets/cards/' + game.gameCards[(y*3) + x].getCard() + '.png')),
                      ),
                      Visibility(
                        visible: ([chosenCard, chosenFaceCard1, chosenFaceCard2].contains(game.gameCards[(y*3) + x]) && game.gameCards[(y*3) + x] != null),
                        child: Container(
                          alignment: Alignment.topRight,
                          child: Icon(Icons.select_all, color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ]
        ),
      ));
      if (y == 0) {
        if (game.won) {
          listOfWidgets.add(Text("You won!" + ((top10time) ? " You set a new top 10 time!" : "")));
        } else if (game.failed) {
          listOfWidgets.add(Text("There are no more moves to make :("));
        } else if (game.playing) {
          listOfWidgets.add(Text("Cards left: " + game.getCardsLeft().toString()));
        } else {
          listOfWidgets.add(Text(""));
        }
      }
      if (y == 1) {
        listOfWidgets.add(Text((timeDiff == null) ? "00:00" : "${timeDiff.toString().substring(2, 7)}"));
      }
    }

    return Column(
      children: listOfWidgets,
    );
  }

  Widget getOverlay() {
    if (!started)
      return getStartingOverlay();
    if (paused)
      return getPausedOverlay();
    return Container();
  }

  Widget getStartingOverlay() {
    return Container(
      alignment: Alignment.center,
      color: Colors.grey,
      padding: EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Elevens",
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          Text(""),
          Text("Pick 2 non-face cards that add up to eleven to replace them, or a Jack a Queen and a King\n"),
          Text("There may be up to 9 cards on the table at once, when all the cards in the deck are gone you have won\n"),
          Text("If cards remain in the deck but there are no cards that add up to eleven, you have lost"),
          FlatButton(
            child: Text("Start"),
            color: Colors.green,
            onPressed: () {
              this.setState(() {
                started = true;
                timeStarted = DateTime.now();
                timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
                  if (game.playing) {
                    this.setState(() {
                      timeDiff = DateTime.now().difference(timeStarted);
                    });
                  } else if (paused) {
                    timeStarted = timeStarted.add(Duration(seconds: 1));
                  }
                });
                game.startGame();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget getPausedOverlay() {
    return Container(
      alignment: Alignment.center,
      color: Colors.grey,
      padding: EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Game paused",
            style: TextStyle(
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  void gameWonCallback() async {
    timer.cancel();
    Entry e = new Entry(DateTime.now(), timeDiff.toString().substring(2, 7));
    bool top10 = await dh.saveTime(e);
    this.setState(() {
      top10time = top10;
    });
  }

  void gameFailedCallback() {
    timer.cancel();
    this.setState(() {
      paused = false;
    });
  }

  void cardPressed(PCard card) {
    if (card.getNum() > 10) {
      faceCardPressed(card);
    } else {
      nonFaceCardPressed(card);
    }
  }

  void nonFaceCardPressed(PCard card) {
    if (chosenCard == card) {
      this.setState(() {
        chosenCard = null;
      });
      return;
    }
    if (chosenFaceCard1 != null) {
      this.setState(() {
        chosenFaceCard1 = null;
        chosenFaceCard2 = null;
      });
    }
    if (chosenCard == null) {
      this.setState(() {
        chosenCard = card;
      });
    } else {
      bool passed = game.compareTwoCards(chosenCard.getCard(), card.getCard());
      if (passed) {
        this.setState(() {
          game.playNewCardAt(game.gameCards.indexOf(chosenCard));
          game.playNewCardAt(game.gameCards.indexOf(card));
          game.checkIfFailed();
        });
      }
      this.setState(() {
        chosenCard = null;
      });
    }
  }

  void faceCardPressed(PCard card) {
    if (chosenFaceCard2 == card) {
      this.setState(() {
        chosenFaceCard2 = null;
      });
      return;
    }
    if (chosenFaceCard1 == card) {
      this.setState(() {
        chosenFaceCard1 = null;
      });
      return;
    }
    if (chosenCard != null) {
      this.setState(() {
        chosenCard = null;
      });
    }

    if (chosenFaceCard1 == null) {
      this.setState(() {
        chosenFaceCard1 = card;
      });
    } else if (chosenFaceCard2 == null) {
      this.setState(() {
        chosenFaceCard2 = card;
      });
    } else {
      bool passed = game.compareThreeCards(chosenFaceCard1.getCard(), chosenFaceCard2.getCard(), card.getCard());
      if (passed) {
        this.setState(() {
          game.playNewCardAt(game.gameCards.indexOf(chosenFaceCard1));
          game.playNewCardAt(game.gameCards.indexOf(chosenFaceCard2));
          game.playNewCardAt(game.gameCards.indexOf(card));
          game.checkIfFailed();
        });
      }
      this.setState(() {
        chosenFaceCard1 = null;
        chosenFaceCard2 = null;
      });
    }
  }

}
