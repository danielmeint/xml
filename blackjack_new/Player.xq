module namespace player="gruppe_xforms/blackjack/player";

import module namespace hand="gruppe_xforms/blackjack/hand" at 'Hand.xq';
import module namespace deck="gruppe_xforms/blackjack/deck" at 'Deck.xq';
import module namespace helper="gruppe_xforms/blackjack/helper" at 'Helper.xq';
import module namespace dealer="gruppe_xforms/blackjack/dealer" at 'Dealer.xq';

declare variable $player:defaultId := "undefined";
declare variable $player:defaultName := "undefined";
declare variable $player:defaultState := "inactive";
declare variable $player:defaultBalance := 100;
declare variable $player:defaultBet := 0;
declare variable $player:defaultInsurance := "false";
declare variable $player:defaultHand := hand:newHand();

declare function player:newPlayer($id, $name, $state, $balance, $bet, $hand,$insurance) {
  <player id="{$id}" name="{$name}" state="{$state}" insurance="{$insurance}">
    <balance>{$balance}</balance>
    <bet>{$bet}</bet>
    {$hand}
  </player>
};

declare function player:newPlayer() {
  player:newPlayer($player:defaultId, $player:defaultName, $player:defaultState, $player:defaultBalance, $player:defaultBet, $player:defaultHand,$player:defaultInsurance)
};

declare function player:reset($self) {
  let $id := $self/@id
  let $name := $self/@name
  let $state := "inactive"
  let $balance := $self/balance/text()
  let $bet := $player:defaultBet
  let $hand := $player:defaultHand
  let $insurance := "false"
  return( 
    if($balance='0')
    then()
    else(
        player:newPlayer($id, $name, $state, $balance, $bet, $hand,$insurance)
    )
  )
};

declare function player:setId($self, $id) {
  let $name := $self/@name
  let $state := $self/@state
  let $balance := $self/balance/text()
  let $bet := $self/bet/text()
  let $hand := $self/hand
  let $insurance := $self/@insurance
  return player:newPlayer($id, $name, $state, $balance, $bet, $hand,$insurance)
};

declare function player:setName($self, $name) {
  let $id := $self/@id
  let $state := $self/@state
  let $balance := $self/balance/text()
  let $bet := $self/bet/text()
  let $hand := $self/hand
  let $insurance := $self/@insurance
  return player:newPlayer($id, $name, $state, $balance, $bet, $hand,$insurance)
};

declare function player:setState($self, $state) {
  let $id := $self/@id
  let $name := $self/@name
  let $balance := $self/balance/text()
  let $bet := $self/bet/text()
  let $hand := $self/hand
  let $insurance := $self/@insurance
  return player:newPlayer($id, $name, $state, $balance, $bet, $hand,$insurance)
};


declare function player:setBalance($self, $balance) {
  let $id := $self/@id
  let $name := $self/@name
  let $state := $self/@state
  let $bet := $self/bet/text()
  let $hand := $self/hand
  let $insurance := $self/@insurance
  return player:newPlayer($id, $name, $state, $balance, $bet, $hand,$insurance)
};

declare function player:setBet($self, $bet) {
  let $id := $self/@id
  let $name := $self/@name
  let $state := $self/@state
  let $balance := $self/balance/text()
  let $hand := $self/hand
  let $insurance := $self/@insurance
  return player:newPlayer($id, $name, $state, $balance, $bet, $hand,$insurance)
};

declare function player:setHand($self, $hand) {
  let $id := $self/@id
  let $name := $self/@name
  let $state := $self/@state
  let $balance := $self/balance/text()
  let $bet := $self/bet/text()
  let $insurance := $self/@insurance
  return player:newPlayer($id, $name, $state, $balance, $bet, $hand,$insurance)
};

declare 
%updating
function player:insurance($game){
  let $currPlayer := $game/player[@state='active']
  let $oldBet := $currPlayer/bet
  let $newBet := $oldBet * 2
  return (
    replace value of node $oldBet with $newBet,
    replace value of node $currPlayer/@insurance with 'true'
  )
};

declare 
%updating
function player:double($game){
  let $currPlayer := $game/player[@state='active']
  let $position := index-of($game/player/@id , $game/player[@state='active']/@id)
  let $nextPosition := $position +1
  let $nextPlayer := $game/player[$nextPosition]
  let $deck := $game/dealer/deck
  let $oldBet := $currPlayer/bet
  let $newBet := $oldBet * 2
  let $oldHand := $currPlayer/hand
  (: this is empty for some reason :)
  let $resultTuple := deck:drawCard($deck)
  let $newCard := $resultTuple/card
  let $newDeck := $resultTuple/deck
  let $newHand := hand:addCard($oldHand, $newCard)
  let $players := $game/player

  return (
    if(exists($nextPlayer))
    then(
        player:hit($currPlayer),
        player:stand($game),
        replace value of node $oldBet with $newBet
    )
    else(
        replace value of node $oldBet with $newBet,
        replace node $oldHand with $newHand,
        replace value of node $currPlayer/@state with 'inactive',
        dealer:play($game,1),
        replace value of node $game/@state with 'toEvaluate'
    )
  )
};


declare 
%updating
function player:hit($self){
  let $game := $self/..
  let $oldHand := $self/hand
  let $oldDeck := $game/dealer/deck
  let $resultTuple := deck:drawCard($oldDeck)
  let $newCard := $resultTuple/card
  let $newDeck := $resultTuple/deck
  let $newHand := hand:addCard($oldHand, $newCard)
  return (
    replace node $oldHand with $newHand,
    replace node $oldDeck with $newDeck
  )
};

declare
%updating
function player:stand($game){
  let $currPlayer := $game/player[@state='active']
  let $position := index-of($game/player/@id , $game/player[@state='active']/@id)
  let $nextPosition := $position +1
  let $nextPlayer := $game/player[$nextPosition]
  return (
    replace value of node $currPlayer/@state with 'inactive',
    if (exists($nextPlayer))
    then (
      replace value of node $nextPlayer/@state with 'active'
    ) else (
      (: everybody played :)
      dealer:play($game,0),
      replace value of node $game/@state with 'toEvaluate'
    )
  )
};



