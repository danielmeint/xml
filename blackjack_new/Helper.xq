module namespace helper = "gruppe_xforms/blackjack/helper";

import module namespace deck="gruppe_xforms/blackjack/deck" at 'Deck.xq';
import module namespace hand="gruppe_xforms/blackjack/hand" at 'Hand.xq';


declare function helper:showGame($gameId) {
  let $redir := concat("/blackjack/", $gameId)
  return web:redirect($redir)
};

declare function helper:getOptimalSum($values as xs:integer*) {
  if (sum($values) le 21 or not(some $x in $values satisfies $x eq 11))
  then (
    sum($values)
  )
  else (
    (: remove the first 11, append a 1, and recursively recalculate :)
    let $firstIndex := index-of($values, 11)[1]
    let $newValues := ($values[not(position() eq $firstIndex)], 1)
    return helper:getOptimalSum($newValues)
  )
};

declare function helper:drawTo17($hand, $deck) {
  if ($hand/@value >= 17)
  then (
    <result>
      {$hand}
      {$deck}
    </result>
  ) else (
    let $result := deck:drawCard($deck)
    let $newCard := $result/card
    let $newDeck := $result/deck
    let $newHand := hand:addCard($hand, $newCard)
    return helper:drawTo17($newHand, $newDeck)
  )
};

declare
%updating
function helper:replaceAll($oldNodes, $newNodes) {
  for $node at $index in $oldNodes
  return (
    replace node $node with $newNodes[$index]
  )
};