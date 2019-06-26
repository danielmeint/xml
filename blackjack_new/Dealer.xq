module namespace dealer="gruppe_xforms/blackjack/dealer";

import module namespace hand="gruppe_xforms/blackjack/hand" at 'Hand.xq';
import module namespace deck="gruppe_xforms/blackjack/deck" at 'Deck.xq';
import module namespace helper="gruppe_xforms/blackjack/helper" at 'Helper.xq';


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


declare
%updating
function dealer:play($game,$deckOffset){
  let $dealer := $game/dealer
  let $oldHand := $dealer/hand
  let $oldDeck := $dealer/deck
  return (
    if($deckOffset=1)then(
      let $result := helper:drawTo17($oldHand, $oldDeck)
      let $newHand := $result/hand
      let $newDeck := $result/deck
      return(
      replace node $oldHand with $newHand,
      replace node $oldDeck with $newDeck,
      delete node $oldDeck/card[1]
    ))
    else(
      let $result := helper:drawTo17($oldHand, $oldDeck)
      let $newHand := $result/hand
      let $newDeck := $result/deck
      return(
      replace node $oldHand with $newHand,
      replace node $oldDeck with $newDeck
    ))
  )
};