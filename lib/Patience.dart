import 'Card.dart';
import 'Deck.dart';

///Patience (AKA Elevens) is a game about adding up to eleven
class Patience {

  Deck deck; //deck of cards
  List<PCard> gameCards; //list of up to 9 cards that are in play
  bool playing; //if the game is playing
  bool won; //if the game has been won
  bool failed; //if the game has been lost
  final Function wonCallback; //is called if the user wins
  final Function failCallback; //is called if the user loses

  Patience(this.wonCallback, this.failCallback);

  ///Restarts the game
  void restart() {
    initGame();
    startGame();
  }

  ///Initialises the game
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

  ///Starts the game
  void startGame() {
    gameCards[0] = deck.dealCard();
    gameCards[1] = deck.dealCard();
    playing = true;
  }

  ///Deals a card from the deck into the next available space
  void playNewCard() {
    for (int i = 0; i < 9; i++) {
      if (gameCards[i] == null) {
        gameCards[i] = deck.dealCard();
        checkIfFailed();
        return;
      }
    }
  }

  ///Deals a new card from the deck to the given space
  void playNewCardAt(int n) {
    gameCards[n] = deck.dealCard();
    if (deck.isEmpty()) {
      won = true;
      playing = false;
      wonCallback();
    }
  }

  ///Returns true if the user can no longer make any moves and there are 9 cards in play
  void checkIfFailed() {
    if (!gameCards.contains(null)) {
      if (!canMakeMove()) {
        failed = true;
        playing = false;
        failCallback();
      }
    }
  }

  ///Returns true if the user can make a move
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

  ///Gets a card in play from it's equivalent string
  PCard getCardFromString(String s) {
    for (int i = 0; i < 9; i++) {
      if (gameCards[i].getCard() == s) {
        return gameCards[i];
      }
    }
  }

  ///Compares two cards to see if they add up to eleven
  bool compareTwoCards(PCard card1, PCard card2) {
    return (card1.getNum() + card2.getNum()) == 11;
  }

  ///Compares three cards to see if they are a Jack, a Queen and a King
  bool compareThreeCards(PCard card1, PCard card2, PCard card3) {
    if ((card1.getNum() + card2.getNum() + card3.getNum()) == 36) { //J + Q + K = 11 + 12 + 13 = 36
      if (card1.getNum() != card2.getNum() && card1.getNum() != card3.getNum() && card2.getNum() != card3.getNum()) {
        return true;
      }
    }
    return false;
  }

  ///Returns the number of cards left in the deck
  int getCardsLeft() {
    return deck.getCardsLeft();
  }

  ///Returns true if the game is playing
  bool isPlaying() {
    return playing;
  }

  ///Ends the game
  void gameEnd() {
    playing = false;
  }

}