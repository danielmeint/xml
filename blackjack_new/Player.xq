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
function player:insurance($self){
  let $oldBet := $self/bet
  let $newBet := $oldBet * 2
  return (
    replace value of node $oldBet with $newBet,
    replace value of node $self/@insurance with 'true'
  )
};

declare 
%updating
function player:double($self){
  let $game := $self/..
  let $deck := $game/dealer/deck
  let $nextPlayer := $game/player[$self/@id + 1]
  let $oldBet := $self/bet
  let $newBet := $oldBet * 2
  let $oldHand := $self/hand
  let $newHand := hand:addCard($oldHand, $deck/card[1])

  return (
    if(exists($nextPlayer))
    then(
        helper:hit($self),
        helper:stand($self,$nextPlayer),
        replace value of node $oldBet with $newBet
    )
    else(
        replace value of node $oldBet with $newBet,
        replace value of node $oldHand with $newHand,
        replace value of node $self/@state with 'inactive',
        dealer:play($game,1),
        replace value of node $game/@state with 'toEvaluate'
    )
  )
};




