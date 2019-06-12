module namespace hand="gruppe_xforms/blackjack/hand";

import module namespace card="gruppe_xforms/blackjack/card" at 'Card.xq';

declare function hand:newHand() {
  hand:newHand(())
};

declare function hand:newHand($cards) {
  <hand>
  {$cards}
  </hand>
};

declare function hand:setCards($self, $cards) {
  hand:newHand($cards)
};

declare function hand:addCard($self, $card) {
  let $newCards := ($self/card, $card)
  return hand:setCards($self, $newCards)
};

declare function hand:removeCard($self, $card) {
  let $newCards := (
    for $card2 in $self/card
    where not(card:equals($card, $card2))
    return $card2
  )
  return hand:setCards($self, $newCards)
};