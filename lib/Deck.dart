import 'dart:math';

import 'Card.dart';

///Simulates a deck of cards
class Deck {

  final List<PCard> cards = new List<PCard>(52);
  int currentCard;

  ///Fills the deck with cards. The deck is generated unshuffled
  void populate() {
    currentCard = 0;
    int index = 0;
    for (int suit = PCard.DIAMOND; suit <= PCard.SPADE; suit++) {
      for (int num = 1; num <= 13; num++) {
        cards[index++] = new PCard(num, suit);
      }
    }
  }

  ///Uses a variation of the Fisher-Yates algorithm (AKA Knuth Shuffle) to mix the cards
  ///The algorithm swaps the first card in the deck with another random card, then does the same for the second card and so on.
  ///The random number is selected between the card being swapped and the end of the deck.
  ///This means any card can only be chosen to be swapped once.
  ///For more information on the algorithm see: https://www.i-programmer.info/programming/theory/2744-how-not-to-shuffle-the-kunth-fisher-yates-algorithm.html.
  void shuffle() {
    PCard tempCard;
    for (int i = 0; i < cards.length; i++) {
      Random r = new Random();
      int randomNum = (i + r.nextInt(52-i)); //gets a random number between i and the number of cards left
      tempCard = cards[i]; //stores the current card
      cards[i] = cards[randomNum]; //places the random card in the current card's spot
      cards[randomNum] = tempCard; //places the current card in the random card's spot
    }
    currentCard = 0;
  }

  ///Deals the top card from the deck
  PCard dealCard() {
    if (currentCard < cards.length) {
      return cards[currentCard++];
    } else {
      return null; //if there are no cards left return null
    }
  }

  ///Returns if the deck is empty or not
  bool isEmpty() {
    return (currentCard == cards.length);
  }

  ///Returns the number of cards remaining in the deck
  int getCardsLeft() {
    return (cards.length - currentCard);
  }

}