module namespace player="xforms/bjx/player";

import module namespace api="xforms/bjx/api" at 'api.xq';
import module namespace card="xforms/bjx/card" at 'card.xq';
import module namespace chat="xforms/bjx/chat" at 'chat.xq';
import module namespace dealer="xforms/bjx/dealer" at 'dealer.xq';
import module namespace deck="xforms/bjx/deck" at 'deck.xq';
import module namespace game="xforms/bjx/game" at 'game.xq';
import module namespace hand="xforms/bjx/hand" at 'hand.xq';


declare
%updating
function player:joinGame($gameId as xs:integer, $name as xs:string) {
  let $game := $api:db/games/game[@id=$gameId]
  let $newPlayer := player:setName(player:newPlayer(), $name)
  let $trace := trace(concat($name, " joined game ", $gameId))
  let $msg := <message author="INFO">{$name} joined the game.</message>
  let $chat := $game/chat
  return (
    if (exists($game/player))
    then (
      insert node $msg into $chat,
      insert node $newPlayer into $game
    ) else (
      (: first player to join :)
      let $newGame := game:setChat(game:reset(game:setPlayers($game, ($newPlayer))), chat:addMessage($chat, $msg))
      return (
        replace node $game with $newGame
      )
    )
  )
};

declare
%updating
function player:leave($self) {
  let $game := $self/..
  return (
    insert node <message author="INFO">{$self/@name/data()} has left the game.</message> into $game/chat,
    delete node $self,
    if (count($game/player) >= 2)
    then (
      if ($self/@state = 'active')
      then (
        player:next($self)
      )
    )
  )
};

declare
%updating
function player:bet($self, $bet) {
  replace value of node $self/bet with $bet,
  player:next($self)
};

declare
%updating
function player:hit($self) {
  let $game := $self/..
  let $newHand := hand:addCard($self/hand, $game/dealer/deck/card[1])
  return (
    player:draw($self),
    if ($newHand/@value >= 21)
    then (
      if (player:isLast($self))
      then (
        game:evaluateAfterHit($game)
      )
      else (
        player:next($self)
      )
    )
  )
};

declare
%updating
function player:draw($self) {
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
function player:stand($self) {
  player:next($self)
};

declare
%updating
function player:double($self) {
  let $newBet := $self/bet * 2
  return (
    replace value of node $self/bet with $newBet,
    player:draw($self),
    (: might trigger evaluate, but the drawn card is not recorded in the database yet .... :)
    if (player:isLast($self))
    then (
      game:evaluateAfterHit($self/..)
    ) else (
      player:next($self)
    )
  )
};
declare
%updating
function player:insurance($self){
  let $_ := ()
  return (
    replace value of node $self/@insurance with 'true'
  )
};

declare function player:nextPlayer($self) {
  let $game := $self/..
  return (
    if ($game/@state = 'playing')
    then (
      (: TODO test for count(hand/card) >= 2 :)
      $self/following-sibling::player[count(hand/card) >= 2 and bet > 0][position() = 1]
    ) else (
      $self/following-sibling::player[position() = 1]
    )
  )
};

declare function player:isLast($self) as xs:boolean {
  not(exists(player:nextPlayer($self)))
};

declare
%updating
function player:next($self) {
  let $game := $self/..
  (: TODO: skip players that just joined (bet 0 and 0 cards) :)
  let $nextPlayer := player:nextPlayer($self)
  return (
    if (exists($nextPlayer))
    then (
      replace value of node $self/@state with 'inactive',
      replace value of node $nextPlayer/@state with 'active'
    ) else (
      if ($game/@state = 'betting')
      then (
        game:play($game)
      ) else if ($game/@state = 'playing')
      then (
        game:evaluate($game)
      )
    )
  )
};

declare
%updating
function player:evaluate($self) {
  player:evaluate($self, $self/../dealer/hand/@value)
};

declare
%updating
function player:evaluateAfterHit($self) {
  let $game := $self/..
  let $deck := $game/dealer/deck
  let $hand := $self/hand
  let $handAfterHit := hand:addCard($hand, $deck/card[1])
  let $toBeat := $game/dealer/hand/@value
  let $result := hand:evaluate($handAfterHit, $toBeat)

  return (
    if ($result = 'won')
    then (
       if($self/@insurance = "true")
       then(
        replace value of node $self/@state with "won",
        replace value of node $self/balance with $self/balance/text() + ceiling(0.5 * $self/bet/text()),
        replace value of node $self/profit with ceiling(0.5 * $self/bet)
       )else(
        replace value of node $self/@state with "won",
        replace value of node $self/balance with $self/balance/text() + $self/bet/text(),
        replace value of node $self/profit with $self/bet
       )
    )
    else if ($result = 'tied')
    then (
      if(($self/@insurance = "true") and ($toBeat = 21) and (count($game/dealer/hand/card)=2) ) then (
        replace value of node $self/@state with "won",
        replace value of node $self/balance with $self/balance/text() + ceiling(0.5 * $self/bet/text()),
        replace value of node $self/profit with ceiling(0.5 * $self/bet)
      )
      else (
        if(($self/@insurance = "true")) then (
            replace value of node $self/@state with "lost",
            replace value of node $self/balance with $self/balance/text() - ceiling(0.5 * $self/bet/text()),
            replace value of node $self/profit with ceiling(0.5 * $self/bet)
        ) 
        else (
            replace value of node $self/@state with "tied",
            replace value of node $self/profit with 0
        )
      )  
    ) else (
      replace value of node $self/@state with "lost",
      if(($self/@insurance = "true") and ($toBeat = 21) and (count($game/dealer/hand/card)=2) ) then (
        replace value of node $self/balance with $self/balance/text() - floor(0.5 * $self/bet/text()),
        replace value of node $self/profit with ceiling(0.5 * $self/bet)
      )
      else (
        if(($self/@insurance = "true")) then (
            replace value of node $self/balance with $self/balance/text() - ceiling(1.5 * $self/bet/text()),
            replace value of node $self/profit with ceiling(1.5 * $self/bet)
        ) 
        else (
            replace value of node $self/balance with $self/balance/text() - $self/bet/text(),
            replace value of node $self/profit with $self/bet
        )
      )
    )
  )
};

declare
%updating
function player:evaluate($self, $toBeat) {
   let $game := $self/..
   let $dealer:=$game/dealer
   return(
   if ($self/hand/@value <= 21 and ($self/hand/@value > $toBeat or $toBeat > 21))
    then (
       if($self/@insurance = "true")
       then(
        replace value of node $self/@state with "won",
        replace value of node $self/balance with $self/balance/text() + ceiling(0.5 * $self/bet/text()),
        replace value of node $self/profit with ceiling(0.5 * $self/bet)
       )else(
        replace value of node $self/@state with "won",
        replace value of node $self/balance with $self/balance/text() + $self/bet/text(),
        replace value of node $self/profit with $self/bet
       )
    )
    else if ($self/hand/@value <= 21 and $self/hand/@value = $toBeat)
    then (
      (:insurance + tie -> 0.5 * Einsatz:)
      if(($self/@insurance = "true") and ($toBeat = 21) and (count($dealer/hand/card)=2) ) then (
        replace value of node $self/@state with "won",
        replace value of node $self/balance with $self/balance/text() + ceiling(0.5 * $self/bet/text()),
        replace value of node $self/profit with ceiling(0.5 * $self/bet)
      )
      else (
        if(($self/@insurance = "true")) then (
            replace value of node $self/@state with "lost",
            replace value of node $self/balance with $self/balance/text() - ceiling(0.5 * $self/bet/text()),
            replace value of node $self/profit with ceiling(0.5 * $self/bet)
        ) 
        else (
            replace value of node $self/@state with "tied",
            replace value of node $self/profit with 0
        )
      )  
    )
    else (
       (:insurance + Lose -> 0 * Einsatz:)
      replace value of node $self/@state with "lost",
      if(($self/@insurance = "true") and ($toBeat = 21) and (count($dealer/hand/card)=2) ) then (
        replace value of node $self/balance with $self/balance/text() - floor(0.5 * $self/bet/text()),
        replace value of node $self/profit with ceiling(0.5 * $self/bet)
      )
      else (
        if(($self/@insurance = "true")) then (
            replace value of node $self/balance with $self/balance/text() - ceiling(1.5 * $self/bet/text()),
            replace value of node $self/profit with ceiling(1.5 * $self/bet)
        ) 
        else (
            replace value of node $self/balance with $self/balance/text() - $self/bet/text(),
            replace value of node $self/profit with $self/bet
        )
      )
    )  
    )
};

declare variable $player:defaultName := "undefined";
declare variable $player:defaultState := "inactive";
declare variable $player:defaultBalance := 100;
declare variable $player:defaultBet := 0;
declare variable $player:defaultHand := hand:newHand();

declare function player:newPlayer($name, $state, $balance, $bet, $hand) {
  <player name="{$name}" state="{$state}" insurance='false'>
    <balance>{$balance}</balance>
    <bet>{$bet}</bet>
    <profit>0</profit>
    {$hand}
  </player>
};

declare function player:newPlayer() {
  player:newPlayer($player:defaultName, $player:defaultState, $player:defaultBalance, $player:defaultBet, $player:defaultHand)
};

declare function player:reset($self) {
  let $name := $self/@name
  let $state := $player:defaultState
  let $balance := $self/balance/text()
  let $bet := $player:defaultBet
  let $hand := $player:defaultHand
  return player:newPlayer($name, $state, $balance, $bet, $hand)
};

declare function player:setName($self, $name) {
  let $state := $self/@state
  let $balance := $self/balance/text()
  let $bet := $self/bet/text()
  let $hand := $self/hand
  return player:newPlayer($name, $state, $balance, $bet, $hand)
};

declare function player:setState($self, $state) {
  let $name := $self/@name
  let $balance := $self/balance/text()
  let $bet := $self/bet/text()
  let $hand := $self/hand
  return player:newPlayer($name, $state, $balance, $bet, $hand)
};


declare function player:setBalance($self, $balance) {
  let $name := $self/@name
  let $state := $self/@state
  let $bet := $self/bet/text()
  let $hand := $self/hand
  return player:newPlayer($name, $state, $balance, $bet, $hand)
};

declare function player:setBet($self, $bet) {
  let $name := $self/@name
  let $state := $self/@state
  let $balance := $self/balance/text()
  let $hand := $self/hand
  return player:newPlayer($name, $state, $balance, $bet, $hand)
};

declare function player:setHand($self, $hand) {
  let $name := $self/@name
  let $state := $self/@state
  let $balance := $self/balance/text()
  let $bet := $self/bet/text()
  return player:newPlayer($name, $state, $balance, $bet, $hand)
};