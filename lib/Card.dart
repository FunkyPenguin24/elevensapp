class PCard {

  static final int DIAMOND = 1;
  static final int HEARTS = 2;
  static final int CLUBS = 3;
  static final int SPADE = 4;

  final int num;
  final int suit;
  bool played = false;

  PCard(this.num, this.suit);

  void setPlayed(bool b) {
    played = b;
  }

  bool hasBeenPlayed() {
    return played;
  }

  int getNum() {
    return num;
  }

  int getSuit() {
    return suit;
  }

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