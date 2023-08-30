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
  MyHomePage({this.title = "Elevens"});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late Patience game; //handles the game mechanics
  PCard? chosenCard; //currently selected card (Card is already an object in flutter so had to call it PCard)
  PCard? chosenFaceCard1; //currently selected face card
  PCard? chosenFaceCard2; //second currently selected face card
  bool started = false; //if the game has started
  late DateTime timeStarted; //time the game started
  Duration? timeDiff; //difference between the time started and now
  late Timer timer; //times the game
  bool top10time = false; //if the user's time is in their top 10
  DataHandler dh = new DataHandler(); //handles loading and saving of data
  bool paused = false; //if the game is paused

  initState() {
    super.initState();
    game = new Patience(gameWonCallback, gameFailedCallback);
    game.initGame();
    dh.loadTimes();
    dh.loadCards();
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
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green,
        fixedColor: Colors.black,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            label: (paused) ? "Play" : "Pause",
            icon: Icon((paused) ? Icons.play_arrow : Icons.pause, color: Colors.black),
          ),
          BottomNavigationBarItem(
            label: "Deal card",
            icon: Icon(Icons.arrow_upward, color: (game.gameCards.contains(null)) ? Colors.black : Colors.blueGrey),
          ),
          BottomNavigationBarItem(
            label: "Restart",
            icon: Icon(Icons.refresh, color: Colors.black),
          ),
          BottomNavigationBarItem(
            label: "Best times",
            icon: Icon(Icons.table_chart, color: Colors.black),
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              if (started && !game.won && !game.failed) {
                this.setState(() {
                  paused = !paused;
                  game.playing = !game.playing;
                });
              }
              break;
            case 1:
              if (game.gameCards.contains(null) && game.playing) {
                this.setState(() {
                  game.playNewCard();
                });
              }
              break;
            case 2:
              restart();
              break;
            case 3:
              gotoBestTimes();
              break;
          }
        },
      ),
    );
  }

  ///Returns the widgets that display the playing cards
  Widget getCardWidget() {
    List<Widget> listOfWidgets = [];

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
                              cardPressed(game.gameCards[(y*3) + x]!);
                            } else {
                              this.setState(() {
                                game.playNewCardAt((y*3) + x);
                                game.checkIfFailed();
                              });
                            }
                          }
                        },
                        child: Image(image: AssetImage((game.gameCards.isEmpty || game.gameCards[(y*3) + x] == null) ? 'assets/cards/cardBackBlue.png' : 'assets/cards/' + game.gameCards[(y*3) + x]!.getCard() + '.png')),
                      ),
                      Visibility(
                        visible: (game.gameCards.isNotEmpty && [chosenCard, chosenFaceCard1, chosenFaceCard2].contains(game.gameCards[(y*3) + x]) && game.gameCards[(y*3) + x] != null),
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
          listOfWidgets.add(FittedBox(fit: BoxFit.fitHeight, child: Text("You won!" + ((top10time) ? " You set a new top 10 time!" : ""))));
        } else if (game.failed) {
          listOfWidgets.add(FittedBox(fit: BoxFit.fitHeight, child: Text("The game is lost with ${game.getCardsLeft()} cards left")));
        } else if (game.playing) {
          listOfWidgets.add(FittedBox(fit: BoxFit.fitHeight, child: Text("Cards left: " + game.getCardsLeft().toString())));
        } else {
          listOfWidgets.add(Text(""));
        }
      }
      if (y == 1) {
        listOfWidgets.add(FittedBox(fit: BoxFit.fitHeight, child: Text((timeDiff == null) ? "00:00" : "${timeDiff.toString().substring(2, 7)}")));
      }
    }

    return Column(
      children: listOfWidgets,
    );
  }

  ///Returns the current overlay that should be displaying
  Widget getOverlay() {
    if (!started)
      return getStartingOverlay();
    if (paused)
      return getPausedOverlay();
    return Container();
  }

  ///Returns the starting overlay, a transparent grey background with the game's description on it
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
            "Elevens\n",
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          Text("Pick 2 non-face cards that add up to eleven to replace them, or a Jack a Queen and a King\n"),
          Text("There may be up to 9 cards on the table at once, when all the cards in the deck are gone you have won\n"),
          Text("If cards remain in the deck but there are no cards that add up to eleven, you have lost\n"),
          Text("These rules can also be found on the pause screen"),
          TextButton(
            child: Text("Start"),
            //color: Colors.green,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.green),
              foregroundColor: MaterialStateProperty.all(Colors.black),
            ),
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

  ///Returns the paused overlay, a fully grey background with "Game Paused" on it
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
            "Game paused\n",
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          Text(
            "How to play\n",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Text("Pick 2 non-face cards that add up to eleven to replace them, or a Jack a Queen and a King\n"),
          Text("There may be up to 9 cards on the table at once, when all the cards in the deck are gone you have won\n"),
          Text("If cards remain in the deck but there are no cards that add up to eleven, you have lost"),
        ],
      ),
    );
  }

  ///Restarts the game
  void restart() {
    if (started && !paused) {
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
  }

  ///Goes to the best times screen
  void gotoBestTimes() {
    if (!game.playing) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LeaderboardScreen(dh)),
      );
    }
  }

  ///Tries to save the user's time and shows the won dialog
  void gameWonCallback() async {
    timer.cancel();
    Entry e = new Entry(DateTime.now(), timeDiff.toString().substring(2, 7));
    bool top10 = await dh.saveTime(e);
    this.setState(() {
      top10time = top10;
    });
    showWinDialog(top10);
  }

  ///Shows the won dialog
  showWinDialog(bool top10) {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Game won!"),
            content: Text("Congratulations, you beat the game with a time of ${timeDiff.toString().substring(2, 7)}!" + ((top10) ? "\nThat's one of your top 10 best times!" : "\nTry again and see if you can get one of your top 10 times")),
            actions: [
              TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  }
              ),
              TextButton(
                  child: Text("Restart"),
                  onPressed: () {
                    Navigator.pop(context);
                    restart();
                  }
              ),
              TextButton(
                  child: Text("Best times"),
                  onPressed: () {
                    Navigator.pop(context);
                    gotoBestTimes();
                  }
              ),
            ],
          );
        }
    );
  }

  ///Tries to save the number of cards left and shows the lose dialog
  void gameFailedCallback() async {
    timer.cancel();
    CardCount c = new CardCount(DateTime.now(), game.getCardsLeft());
    bool top10 = await dh.saveCard(c);
    this.setState(() {
      paused = false;
    });
    showFailDialog(top10);
  }

  ///Shows the lose dialog
  showFailDialog(bool top10) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game lost"),
          content: Text("You can make no more moves so you have lost the game with a total of ${game.getCardsLeft()} cards remaining, restart to try again!" + ((top10) ? "\nThat's one of the fewest 10 remaining cards you've got!" : "")),
          actions: [
            TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                }
            ),
            TextButton(
                child: Text("Restart"),
                onPressed: () {
                  Navigator.pop(context);
                  restart();
                }
            ),
            TextButton(
                child: Text("Best times"),
                onPressed: () {
                  Navigator.pop(context);
                  gotoBestTimes();
                }
            ),
          ],
        );
      }
    );
  }

  ///Deals with a card press
  void cardPressed(PCard card) {
    if (card.getNum() > 10) {
      faceCardPressed(card);
    } else {
      nonFaceCardPressed(card);
    }
  }

  ///Deals with a non face card being pressed - if one is already selected then compares them
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
      bool passed = game.compareTwoCards(chosenCard!, card);
      if (passed) {
        this.setState(() {
          game.playNewCardAt(game.gameCards.indexOf(chosenCard!));
          game.playNewCardAt(game.gameCards.indexOf(card));
          game.checkIfFailed();
        });
      }
      this.setState(() {
        chosenCard = null;
      });
    }
  }

  ///Deals with a face card being pressed - if two are already selected then compares them
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
      bool passed = game.compareThreeCards(chosenFaceCard1!, chosenFaceCard2!, card);
      if (passed) {
        this.setState(() {
          game.playNewCardAt(game.gameCards.indexOf(chosenFaceCard1!));
          game.playNewCardAt(game.gameCards.indexOf(chosenFaceCard2!));
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
