module namespace dealer="gruppe_xforms/blackjack/dealer";

import module namespace hand="gruppe_xforms/blackjack/hand" at 'Hand.xq';
import module namespace deck="gruppe_xforms/blackjack/deck" at 'Deck.xq';


declare variable $dealer:defaultHand := hand:newHand();
declare variable $dealer:defaultDeck := deck:shuffle(deck:newDeck());

declare function dealer:newDealer($hand, $deck) {
  <dealer>
  {$hand}
  {$deck}
  </dealer>
};

declare function dealer:newDealer() {
  dealer:newDealer($dealer:defaultHand, $dealer:defaultDeck)
};
