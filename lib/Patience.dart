import 'Card.dart';
import 'Deck.dart';

class Patience {

  Deck deck;
  List<PCard> gameCards;
  bool playing;
  bool won;
  bool failed;
  final Function wonCallback;
  final Function failCallback;

  Patience(this.wonCallback, this.failCallback);

  void restart() {
    initGame();
    startGame();
  }

  void initGame() {
    playing = false;
    won = false;
    failed = false;
    deck = new Deck();
    deck.populate();
    for (int i = 0; i < 9; i++) //shuffles the deck 8 times
      deck.shuffle();
    gameCards = new List<PCard>(9);
  }

  void startGame() {
    gameCards[0] = deck.dealCard();
    gameCards[1] = deck.dealCard();
    playing = true;
  }

  void playNewCard() {
    for (int i = 0; i < 9; i++) {
      if (gameCards[i] == null) {
        gameCards[i] = deck.dealCard();
        checkIfFailed();
        return;
      }
    }
  }

  void playNewCardAt(int n) {
    gameCards[n] = deck.dealCard();
    if (deck.isEmpty()) {
      won = true;
      playing = false;
      wonCallback();
    }
  }

  void checkIfFailed() {
    if (!gameCards.contains(null)) {
      if (!canMakeMove()) {
        failed = true;
        playing = false;
        failCallback();
      }
    }
  }

  bool canMakeMove() {
    for (int i = 0; i < 9; i++) {
      for (int j = i; j < 9; j++) {
        if (gameCards[i].getNum() < 11) {
          if (compareTwoCards(gameCards[i], gameCards[j])) {
            return true;
          }
        } else { //if face card
          bool jack = false, queen = false, king = false;
          for (int r = 0; r < 9; r++) {
            if (gameCards[r].getNum() == 11)
              jack = true;
            if (gameCards[r].getNum() == 12)
              queen = true;
            if (gameCards[r].getNum() == 13)
              king = true;
            if (jack && queen && king)
              return true;
          }
        }
      }
    }
    return false;
  }

  PCard getCardFromString(String s) {
    for (int i = 0; i < 9; i++) {
      if (gameCards[i].getCard() == s) {
        return gameCards[i];
      }
    }
  }

  bool compareTwoCards(PCard card1, PCard card2) {
    return (card1.getNum() + card2.getNum()) == 11;
  }

  bool compareThreeCards(PCard card1, PCard card2, PCard card3) {
    if ((card1.getNum() + card2.getNum() + card3.getNum()) == 36) { //J + Q + K = 11 + 12 + 13 = 36
      if (card1.getNum() != card2.getNum() && card1.getNum() != card3.getNum() && card2.getNum() != card3.getNum()) {
        return true;
      }
    }
    return false;
  }

  int getCardsLeft() {
    return deck.getCardsLeft();
  }

  bool isPlaying() {
    return playing;
  }

  void gameEnd() {
    playing = false;
  }

}