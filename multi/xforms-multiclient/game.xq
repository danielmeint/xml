module namespace game='xforms/game';

import module namespace api="xforms/api" at 'api.xq';
import module namespace dealer="xforms/dealer" at 'dealer.xq';
import module namespace player="xforms/player" at 'player.xq';
import module namespace deck="xforms/deck" at 'deck.xq';
import module namespace chat="xforms/chat" at 'chat.xq';



declare
%updating
function game:updateCreate() {
  insert node game:newGame() into $api:db/games
};

declare
%updating
function game:delete($self) {
  delete node $self
};

declare
%updating
function game:play($self) {
  replace value of node $self/@state with 'playing',
  for $player at $index in $self/player
  return (
    if ($index = 1)
    then (replace value of node $player/@state with 'active')
    else (replace value of node $player/@state with 'inactive')
  ),
  dealer:deal($self/dealer)
};

declare
%updating
function game:evaluate($self,$caller) {
  let $regularPlayers := $self/player[count(hand/card) >= 2][position() != last()]
  let $lastPlayer := $self/player[count(hand/card) >= 2][position() = last()]
  return (
    for $p in $regularPlayers
    return (
      player:evaluate($p,0)
    ),
    player:evaluate($lastPlayer,$caller),
    replace value of node $self/@state with 'evaluated'
   )
};

declare function game:latestId() as xs:double {
  if (exists($api:db/games/game)) 
  then (max($api:db/games/game/@id)) 
  else (0)
};

declare
%updating
function game:newRound($self) {
  replace node $self with game:reset($self)
};


declare variable $game:defaultId := game:latestId() + 1;
declare variable $game:defaultState := "betting";
declare variable $game:defaultDealer := dealer:newDealer();
declare variable $game:defaultPlayers := ();
declare variable $game:defaultChat := chat:newChat();

declare function game:newGame($id, $state, $dealer, $players, $chat) {
  <game id="{$id}" state="{$state}">
    {$dealer}
    {$players}
    {$chat}
  </game>
};

declare function game:newGame() {
  game:newGame($game:defaultId, $game:defaultState, $game:defaultDealer, $game:defaultPlayers, $game:defaultChat)
};

declare function game:draw($self, $name) {
  <div>
    <p>Playing as: {$name}</p>
    <textarea style="width: 100%; height: 80%;">
      {$self}
    </textarea>
    <form action="/xforms-multiclient/games/{$self/@id}/newRound" method="POST" target="hiddenFrame">
      <input type="submit" value="newRound"/>
    </form>
    <form action="/xforms-multiclient/games/{$self/@id}/{$name}/bet" method="POST" target="hiddenFrame">
      <input type="number" name="bet"/>
      <input type="submit" value = "Bet"/>
    </form>
    <form action="/xforms-multiclient/games/{$self/@id}/{$name}/hit" method="POST" target="hiddenFrame">
      <input type="submit" value="Hit"/>
    </form>
    <form action="/xforms-multiclient/games/{$self/@id}/{$name}/stand" method="POST" target="hiddenFrame">
      <input type="submit" value="Stand"/>
    </form>
    <form action="/xforms-multiclient/games/{$self/@id}/{$name}/leave" method="POST">
      <input type="submit" value="Leave via POST (obsolete)"/>
    </form>
    <a href="/xforms-multiclient/games/{$self/@id}/{$name}/leave">Leave via GET</a>
    <iframe class="hidden hiddenFrame" name="hiddenFrame"/>
  </div>
};

declare function game:drawFull($self, $name) {
  let $xsl := doc('../static/xforms-static/xslt/game.xsl')
  let $map := map{ "name" : $name }
  return xslt:transform($self, $xsl, $map)
};

declare function game:reset($self) {
  let $id := $self/@id
  let $state := $game:defaultState
  let $dealer := $game:defaultDealer
  let $players := $self/player ! player:reset(.)
    let $players := (
    for $player in $players
    where $player/balance > 0
    return $player
  )
  let $players := if (count($players) > 0) then (player:setState($players[1], 'active'), subsequence($players, 2, count($players) - 1)) else ($players)
  let $chat := $self/chat
  return game:newGame($id, $state, $dealer, $players, $chat)
};

declare function game:setPlayers($self, $players) {
  let $id := $self/@id
  let $state := $self/@state
  let $dealer := $self/dealer
  let $chat := $self/chat
  return game:newGame($id, $state, $dealer, $players, $chat)
};

declare function game:setChat($self, $chat) {
  let $id := $self/@id
  let $state := $self/@state
  let $dealer := $self/dealer
  let $players := $self/player
  return game:newGame($id, $state, $dealer, $players, $chat)
};