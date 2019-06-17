module namespace hand="gruppe_xforms/blackjack/hand";

import module namespace card="gruppe_xforms/blackjack/card" at 'Card.xq';
import module namespace helper="gruppe_xforms/blackjack/helper" at 'Helper.xq';


declare function hand:newHand() {
  hand:newHand(())
};

declare function hand:newHand($cards) {
  let $hand   := <hand>{$cards}</hand>
  let $value  := hand:getValue($hand)
  return hand:newHand($cards, $value)
};

declare function hand:newHand($cards, $value) {
  <hand value="{$value}">{$cards}</hand>
};

declare function hand:setCards($self, $cards) {
  hand:newHand($cards)
};

declare function hand:setValue($self, $value) {
  let $cards := $self/card
  return hand:newHand($cards, $value)
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

declare function hand:getValue($self) {
  let $numValues := $self/card ! card:getNumericalValue(.)
  return helper:getOptimalSum($numValues)
};