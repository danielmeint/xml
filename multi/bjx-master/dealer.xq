module namespace dealer='xforms/dealer';

import module namespace api="xforms/api" at 'api.xq';
import module namespace deck="xforms/deck" at 'deck.xq';

import module namespace hand="xforms/hand" at 'hand.xq';

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
function dealer:deal($self) {
  let $game := $self/..
  
  (: give self ALL cards necessary (previously drawn after players have played) :)
  let $result := deck:drawTo17($self/hand, $self/deck)
  let $offset := count($result/hand/card)
  
  return (
    replace node $self/hand with $result/hand,
    for $card at $index in $result/hand/card
    return (
      delete node $self/deck/card[$index]
    ),
    for $player at $index in $game/player
    let $newHand := hand:addCard(hand:addCard($player/hand, $self/deck/card[$offset + ($index * 2) - 1]), $self/deck/card[$offset + ($index * 2)])
    return (
      replace node $player/hand with $newHand,
      delete node $self/deck/card[$offset + ($index * 2) - 1],
      delete node $self/deck/card[$offset + ($index * 2)]
    )
  )
};

declare function dealer:evaluateInsurance($self, $playerIsInsurance as xs:integer, $bet as xs:double,$playerWon as xs:integer){
    let $dealerHasTwoCards := if ((count($self/hand/card)=2 and data($self/hand/@value) = 21)and $playerWon < 1) then ( 0.5 ) else ( -0.5 )
    return($playerIsInsurance*$dealerHasTwoCards*$bet)
};