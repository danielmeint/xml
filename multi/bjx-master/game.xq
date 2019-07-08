module namespace game='xforms/bjx/game';

import module namespace api="xforms/bjx/api" at 'api.xq';
import module namespace dealer="xforms/bjx/dealer" at 'dealer.xq';
import module namespace player="xforms/bjx/player" at 'player.xq';
import module namespace deck="xforms/bjx/deck" at 'deck.xq';
import module namespace chat="xforms/bjx/chat" at 'chat.xq';



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
function game:evaluate($self) {
  for $player in $self/player[count(hand/card) >= 2]
  return (
    (: BUG: last player might have doubled, so we do not have his last card in the DB yet :)
    player:evaluate($player)
  ),
  replace value of node $self/@state with 'evaluated'
};

declare
%updating
function game:evaluateAfterHit($self) {
  let $regularPlayers := $self/player[count(hand/card) >= 2][position() != last()]
  let $lastPlayer := $self/player[count(hand/card) >= 2][position() = last()]
  return (
    for $p in $regularPlayers
    return (
      player:evaluate($p)
    ),
    player:evaluateAfterHit($lastPlayer),
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
    <form action="/bjx/games/{$self/@id}/newRound" method="POST" target="hiddenFrame">
      <input type="submit" value="newRound"/>
    </form>
    <form action="/bjx/games/{$self/@id}/{$name}/bet" method="POST" target="hiddenFrame">
      <input type="number" name="bet"/>
      <input type="submit" value = "Bet"/>
    </form>
    <form action="/bjx/games/{$self/@id}/{$name}/hit" method="POST" target="hiddenFrame">
      <input type="submit" value="Hit"/>
    </form>
    <form action="/bjx/games/{$self/@id}/{$name}/stand" method="POST" target="hiddenFrame">
      <input type="submit" value="Stand"/>
    </form>
    <form action="/bjx/games/{$self/@id}/{$name}/leave" method="POST">
      <input type="submit" value="Leave via POST (obsolete)"/>
    </form>
    <a href="/bjx/games/{$self/@id}/{$name}/leave">Leave via GET</a>
    <iframe class="hidden hiddenFrame" name="hiddenFrame"/>
  </div>
};

declare function game:drawFull($self, $name) {
  let $xsl := doc('../static/bjx/xslt/game.xsl')
  let $map := map{ "name" : $name }
  return xslt:transform($self, $xsl, $map)
};

declare function game:reset($self) {
  let $id := $self/@id
  let $state := $game:defaultState
  let $dealer := $game:defaultDealer
  let $players := $self/player ! player:reset(.)
  let $players := (player:setState($players[1], 'active'), subsequence($players, 2, count($players) - 1))
  let $chat := $self/chat
  return game:newGame($id, $state, $dealer, $players, $chat)
};

declare function game:setId($self, $id) {
  let $state := $self/@state
  let $dealer := $self/dealer
  let $players := $self/player
  let $chat := $self/chat
  return game:newGame($id, $state, $dealer, $players, $chat)
};

declare function game:setState($self, $state) {
  let $id := $self/@id
  let $dealer := $self/dealer
  let $players := $self/player
  let $chat := $self/chat
  return game:newGame($id, $state, $dealer, $players, $chat)
};

declare function game:setDealer($self, $dealer) {
  let $id := $self/@id
  let $state := $self/@state
  let $players := $self/player
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