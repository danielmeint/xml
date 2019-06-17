module namespace game="gruppe_xforms/blackjack/game";

import module namespace dealer="gruppe_xforms/blackjack/dealer" at 'Dealer.xq';
import module namespace player="gruppe_xforms/blackjack/player" at 'Player.xq';


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