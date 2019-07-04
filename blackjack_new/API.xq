module namespace api = "gruppe_xforms/blackjack/API";

import module namespace player="gruppe_xforms/blackjack/player" at 'Player.xq';
import module namespace hand="gruppe_xforms/blackjack/hand" at 'Hand.xq';
import module namespace card="gruppe_xforms/blackjack/card" at 'Card.xq';
import module namespace deck="gruppe_xforms/blackjack/deck" at 'Deck.xq';
import module namespace game="gruppe_xforms/blackjack/game" at 'Game.xq';
import module namespace dealer="gruppe_xforms/blackjack/dealer" at 'Dealer.xq';
import module namespace helper="gruppe_xforms/blackjack/helper" at 'Helper.xq';



declare variable $api:startingBudget := 100;
declare variable $api:db := db:open("blackjack");

declare
%rest:path("blackjack")
%rest:GET
%output:method("html")
function api:entry() {
  doc("../static/blackjack/menu.html")
};

(: Setup the database and load the model :)
declare
%rest:path("blackjack/setup")
%rest:GET
%output:method("html")
%updating
function api:setup(){
    let $model := doc('model.xml')
    let $html  := <div>
      <p>Database successfully setup!</p>
      <a href="/blackjack/new">Create New Game!</a>
    </div>
    return(
      db:create("blackjack", $model),
      update:output($html)
  )
};

declare
%rest:path("/blackjack/new")
%rest:GET
%output:method("html")
function api:newGame() {
    doc("newGame.html")
};

declare
%rest:path("/blackjack/start")
%rest:POST
%rest:form-param("player1", "{$player1}")
%rest:form-param("player2", "{$player2}")
%rest:form-param("player3", "{$player3}")
%rest:form-param("player4", "{$player4}")
%rest:form-param("player5", "{$player5}")
%updating
function api:start($player1, $player2, $player3, $player4, $player5) {
  let $players := (
    for $name in ($player1, $player2, $player3, $player4, $player5)
    where not($name eq "")
    return player:setName(player:newPlayer(), $name)
  )
  (: let $firstPlayer := player:setState($players[1], 'active')
  let $players := ($firstPlayer, subsequence($players, 2, count($players) - 1)) :)
  let $players := (
    for $player at $index in $players
    return player:setId($player, $index)
  )
  let $latestId := $api:db/games/@latestId
  let $id := $latestId + 1
  let $game := game:newGame($id, "betting", dealer:newDealer(), $players)
  return (
    replace value of node $latestId with $id,
    insert node $game into $api:db/games,
    update:output(helper:showGame($id))
  )
};

declare
%rest:path("/blackjack/all")
%rest:GET
%output:method("html")
function api:showAll() {
  let $stylesheet := doc("../static/blackjack/lobby.xsl")
  let $data := <data><screen>games</screen>{$api:db/games}</data>
  return xslt:transform($data, $stylesheet)
};

declare
%rest:path("/blackjack/all/raw")
%rest:GET
function api:showAllRaw() {
    $api:db
};

declare
%rest:path("blackjack/highscores")
%rest:GET
%output:method("html")
function api:highscores() {
  let $stylesheet := doc("../static/blackjack/lobby.xsl")
  let $data := <data><screen>highscores</screen>{$api:db/games}</data>
  return xslt:transform($data, $stylesheet)
};

declare
%rest:path("blackjack/highscores/raw")
%rest:GET
function api:highscoresRaw() {
  let $sortedPlayers := (
    for $player in $api:db//player
    order by $player/balance
    return $player
  )
  return <data>{$sortedPlayers}</data>
};


declare
%rest:path("/blackjack/{$gameId=[0-9]+}")
%rest:GET
%output:method("html")
function api:show($gameId as xs:integer) {
  let $game := $api:db/games/game[@id=$gameId]
  let $stylesheet := doc("../static/blackjack/game.xsl")
  let $transformedGame := xslt:transform($game, $stylesheet)
  return $transformedGame
};

declare
%rest:path("/blackjack/{$gameId=[0-9]+}/raw")
%rest:GET
function api:showRaw($gameId) {
    $api:db/games/game[@id=$gameId]
};

declare
%rest:path("/blackjack/{$gameId=[0-9]+}/reset")
%rest:GET
%updating
function api:reset($gameId) {
  let $oldGame := $api:db/games/game[@id=$gameId]
  let $newGame := game:setState(game:reset($oldGame), 'betting')
  return (
    replace node $oldGame with $newGame,
    update:output(helper:showGame($gameId))
  )
};

declare
%rest:path("/blackjack/{$gameId=[0-9]+}/play")
%rest:POST
%rest:form-param("player_1_bet", "{$p1_bet}")
%rest:form-param("player_2_bet", "{$p2_bet}")
%rest:form-param("player_3_bet", "{$p3_bet}")
%rest:form-param("player_4_bet", "{$p4_bet}")
%rest:form-param("player_5_bet", "{$p5_bet}")
%updating
function api:play($gameId, $p1_bet, $p2_bet, $p3_bet, $p4_bet, $p5_bet) {
  let $bets := ($p1_bet, $p2_bet, $p3_bet, $p4_bet, $p5_bet)
  let $game := $api:db/games/game[@id=$gameId]
  return (
    game:play($game,$bets),
    update:output(helper:showGame($gameId)) 
  )
};

declare
%rest:path("blackjack/{$gameId=[0-9]+}/hit")
%rest:GET
%updating
function api:hit($gameId as xs:integer){
  let $game := $api:db/games/game[@id = $gameId]
  let $currPlayer := $game/player[@state='active']
  return (
    player:hit($currPlayer),
    update:output(helper:showGame($gameId))
  )
    
};

declare
%rest:path("blackjack/{$gameId=[0-9]+}/stand")
%rest:GET
%updating
function api:stand($gameId as xs:integer) {
  let $game := $api:db/games/game[@id=$gameId]
  return (
    player:stand($game),
    update:output(helper:showGame($gameId))
  )
};

declare
%rest:path("blackjack/{$gameId=[0-9]+}/insurance")
%rest:GET
%updating
function api:insurance($gameId as xs:integer){
  let $game := $api:db/games/game[@id=$gameId]
  return (
    player:insurance($game),
    update:output(helper:showGame($gameId))
  )
};

declare
%rest:path("blackjack/{$gameId=[0-9]+}/double")
%rest:GET
%updating
function api:double ($gameId as xs:integer){
  let $game := $api:db/games/game[@id=$gameId]
  return(
    player:double($game),
    update:output(helper:showGame($gameId))
  )
};

declare
%rest:path("blackjack/{$gameId=[0-9]+}/evaluate")
%rest:GET
%updating
function api:evaluateGame($gameId as xs:integer) {
  let $game := $api:db/games/game[@id=$gameId]
  return (
    game:evaluateGame($game),
    update:output(helper:showGame($gameId))
  )
};

declare
%rest:path("blackjack/{$gameId=[0-9]+}/delete")
%rest:GET
%updating
function api:delete($gameId as xs:integer){
    let $game := $api:db/games/game[@id=$gameId]
    let $redir := "/blackjack"
    return(
        delete node $game,
        update:output(helper:showMainMenu())
    )
};

declare
%rest:path("/blackjack/test")
%rest:GET
function api:test() {
    <result>{xslt:processor()}</result>
};