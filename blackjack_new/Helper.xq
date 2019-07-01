module namespace helper = "gruppe_xforms/blackjack/helper";

import module namespace deck="gruppe_xforms/blackjack/deck" at 'Deck.xq';
import module namespace hand="gruppe_xforms/blackjack/hand" at 'Hand.xq';
import module namespace dealer="gruppe_xforms/blackjack/dealer" at 'Dealer.xq';


declare function helper:showGame($gameId) {
  let $redir := concat("/blackjack/", $gameId)
  return web:redirect($redir)
};

declare function helper:showGames() {
  let $redir := "/blackjack/all"
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

declare
%updating
function helper:evaluateGame($game) {
  let $players := $game/player
  let $toBeat := $game/dealer/hand/@value
  return (
    helper:evaluatePlayers($players, $toBeat),
    replace value of node $game/@state with 'evaluated'
  )
};

declare
%updating
function helper:evaluatePlayers($players, $toBeat) {
  for $player in $players
  return helper:evaluatePlayer($player, $toBeat)
};

declare
%updating
function helper:evaluatePlayer($player, $toBeat as xs:integer) {
   if ($player/hand/@value <= 21 and ($player/hand/@value > $toBeat or $toBeat > 21))
    then (
      (:insurance + win -> 2 * Einsatz:)
      if(($player/@insurance = "true") and ($toBeat = 21) )
      then (
        replace value of node $player/@state with "won",
        replace value of node $player/balance with $player/balance/text() + $player/bet/text() + $player/bet/text()
      )
      else (
        replace value of node $player/@state with "won",
        replace value of node $player/balance with $player/balance/text() + $player/bet/text()
    )
    )
    else if ($player/hand/@value <= 21 and $player/hand/@value = $toBeat)
    then (
      (:insurance + tie -> 1 * Einsatz:)
      if(($player/@insurance = "true") and ($toBeat = 21) ) then (
        replace value of node $player/@state with "won",
        replace value of node $player/balance with $player/balance/text() + $player/bet/text()
      )
      else (
      replace value of node $player/@state with "tied"
    )  
  )
    else (
       (:insurance + Lose -> 0 * Einsatz:)
      if(($player/@insurance = "true") and ($toBeat = 21) ) then (
        replace value of node $player/@state with "won"
      )
      else (
      replace value of node $player/@state with "lost",
      replace value of node $player/balance with $player/balance/text() - $player/bet/text()
    )  
)
};

declare 
%updating
function helper:play($game,$bets){
  let $oldPlayers := $game/player
  return (
    replace value of node $game/@state with 'playing',
    helper:replaceAll($oldPlayers/bet/text(), $bets),
    replace value of node $game/head(player)/@state with 'active',
    helper:deal($game) 
  )
};

declare
%updating
function helper:deal($game) {
  for $player at $index in ($game/player, $game/dealer)
  let $oldHand := $player/hand
  let $deck := $game/dealer/deck
  let $newHand := hand:addCard(hand:addCard($oldHand, $deck/card[$index * 2 - 1]), $deck/card[$index * 2])
  return (
    replace node $oldHand with $newHand,
    delete node $deck/card[$index * 2 - 1],
    delete node $deck/card[$index * 2]
  )
};

