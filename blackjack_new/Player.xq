module namespace player="gruppe_xforms/blackjack/player";

import module namespace hand="gruppe_xforms/blackjack/hand" at 'Hand.xq';

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
  return player:newPlayer($id, $name, $state, $balance, $bet, $hand,$insurance)
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