module namespace game="gruppe_xforms/blackjack/game";

import module namespace dealer="gruppe_xforms/blackjack/dealer" at 'Dealer.xq';
import module namespace player="gruppe_xforms/blackjack/player" at 'Player.xq';
import module namespace helper="gruppe_xforms/blackjack/helper" at 'Helper.xq';


declare variable $game:defaultId := "undefined";
declare variable $game:defaultState := "undefined";
declare variable $game:defaultDealer := dealer:newDealer();
declare variable $game:defaultPlayers := ();

declare function game:newGame($id, $state, $dealer, $players) {
  <game id="{$id}" state="{$state}">
    {$dealer}
    {$players}
  </game>
};

declare function game:newGame() {
  game:newGame($game:defaultId, $game:defaultState, $game:defaultDealer, $game:defaultPlayers)
};

declare function game:reset($self) {
  let $id := $self/@id
  let $state := "init"
  let $dealer := $game:defaultDealer
  let $players := $self/player ! player:reset(.)
  return game:newGame($id, $state, $dealer, $players)
};

declare function game:setId($self, $id) {
  let $state := $self/@state
  let $dealer := $self/dealer
  let $players := $self/player
  return game:newGame($id, $state, $dealer, $players)
};

declare function game:setState($self, $state) {
  let $id := $self/@id
  let $dealer := $self/dealer
  let $players := $self/player
  return game:newGame($id, $state, $dealer, $players)
};

declare function game:setDealer($self, $dealer) {
  let $id := $self/@id
  let $state := $self/@state
  let $players := $self/player
  return game:newGame($id, $state, $dealer, $players)
};

declare function game:setPlayers($self, $players) {
  let $id := $self/@id
  let $state := $self/@state
  let $dealer := $self/dealer
  return game:newGame($id, $state, $dealer, $players)
};


declare 
%updating
function game:play($game,$bets){
  let $oldPlayers := $game/player
  let $firstPlayer := $oldPlayers[1]
  return (
    if(exists($firstPlayer))then(
        replace value of node $game/@state with 'playing',
        helper:replaceAll($oldPlayers/bet/text(), $bets),
        replace value of node $firstPlayer/@state with 'active',
        dealer:deal($game) 
    )else(
        
    )
  )
};

declare
%updating
function game:evaluateGame($game) {
  let $players := $game/player
  let $toBeat := $game/dealer/hand/@value
  return (
    game:evaluatePlayers($players, $toBeat),
    replace value of node $game/@state with 'evaluated'
  )
};

declare
%updating
function game:evaluatePlayers($players, $toBeat) {
  for $player in $players
  return game:evaluatePlayer($player, $toBeat)
};

declare
%updating
function game:evaluatePlayer($player, $toBeat as xs:integer) {
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