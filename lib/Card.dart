///Holds data relating to the playing cards
class PCard {

  static final int DIAMOND = 1;
  static final int HEARTS = 2;
  static final int CLUBS = 3;
  static final int SPADE = 4;

  final int num; //number of the card
  final int suit; //suit of the card
  bool played = false; //if the card has been played

  PCard(this.num, this.suit);

  ///Sets if the card has been played or not to a given value
  void setPlayed(bool b) {
    played = b;
  }

  ///Returns true if the card has been played
  bool hasBeenPlayed() {
    return played;
  }

  ///Returns the number of the card
  int getNum() {
    return num;
  }

  ///Returns the suit of the card
  int getSuit() {
    return suit;
  }

  ///Returns the string equivalent of the card (i.e. Kd or 7h)
  String getCard() {
    String tempNum;
    switch (num) {
      case 1:
        tempNum = "A";
        break;
      case 11:
        tempNum = "J";
        break;
      case 12:
        tempNum = "Q";
        break;
      case 13:
        tempNum = "K";
        break;
      default:
        tempNum = num.toString();
        break;
    }

    String tempSuit;
    switch (suit) {
      case 1:
        tempSuit = "d";
        break;
      case 2:
        tempSuit = "h";
        break;
      case 3:
        tempSuit = "c";
        break;
      default:
        tempSuit = "s";
        break;
    }
    return tempNum + tempSuit;
  }

}