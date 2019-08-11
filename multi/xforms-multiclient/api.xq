module namespace api = "xforms/api";

import module namespace card="xforms/card" at "card.xq";
import module namespace dealer="xforms/dealer" at "dealer.xq";
import module namespace deck="xforms/deck" at "deck.xq";
import module namespace game="xforms/game" at "game.xq";
import module namespace hand="xforms/hand" at "hand.xq";
import module namespace html="xforms/html" at "html.xq";
import module namespace player="xforms/player" at "player.xq";
import module namespace usr="xforms/usr" at "usr.xq";


import module namespace ws = "http://basex.org/modules/ws";
import module namespace request = "http://exquery.org/ns/request";

import module namespace session = "http://basex.org/modules/session";

declare variable $api:games := db:open("xforms-games")/games;
declare variable $api:users := db:open("xforms-users")/users;

declare
%rest:path("/xforms-multiclient")
%rest:GET
%output:method("html")
function api:entry() {
  if (session:get("name"))
  then (
    html:menu() 
  ) else (
    web:redirect("/xforms-multiclient/login", map { "error": "" })
  )
};

declare
%rest:GET
%rest:path("/xforms-multiclient/signup")
%output:method("html")
%rest:query-param("error", "{$error}")
function api:sign-up($error) {
    html:signup($error)
};

declare
%rest:GET
%rest:path("xforms-multiclient/login")
%output:method("html")
%rest:query-param("error", "{$error}")
function api:login($error) {
    html:login($error)
};

declare
%rest:POST
%rest:path("/xforms-multiclient/signup")
%rest:query-param("name", "{$name}")
%rest:query-param("pass", "{$pass}")
%updating
function api:user-create(
  $name as xs:string,
  $pass as xs:string
) as empty-sequence() {
  if (usr:exists($name))
  then (
    update:output(web:redirect("/xforms-multiclient/signup", map { "error": "User already exists." }))
  ) else (
    usr:create($name, $pass),
    update:output(web:redirect("/xforms-multiclient"))
  )
};

declare
%rest:POST
%rest:path("/xforms-multiclient/login")
%rest:query-param("name", "{$name}")
%rest:query-param("pass", "{$pass}")
function api:login-check(
  $name  as xs:string,
  $pass  as xs:string
) {
  if (usr:check($name, $pass))
  then (
    session:set("name", $name),
    web:redirect("/xforms-multiclient")
  ) else (
    web:redirect("/xforms-multiclient/login", map { "error": "Incorrect name or password. Click the '+' to register." })
  )
};

declare
%rest:path("/xforms-multiclient/logout")
function api:logout() as element(rest:response) {
  session:get("name") ! api:close(.),
  session:delete("name"),
  web:redirect("/xforms-multiclient")
};

declare
%rest:path("/xforms-multiclient/balance")
%rest:POST
%output:method("html")
%updating
function api:deposit() {
  let $name := session:get("name")
  let $user := $api:users/user[@name=$name]
  
  return (
    usr:deposit($user, 10),
    update:output(web:redirect("/xforms-multiclient"))
  )
};

declare function api:close($name as xs:string) as empty-sequence() {
  for $wsId in ws:ids()
  where ws:get($wsId, "name") = $name
  return ws:close($wsId)
};

declare
%rest:path("/xforms-multiclient/setup")
%rest:GET
%output:method("html")
%updating
function api:setup() {
  db:create("xforms-games", doc("model.xml")),
  db:create("xforms-users", doc("users.xml")),
  update:output(web:redirect("/xforms-multiclient"))
};

declare
%rest:path("/xforms-multiclient/games")
%rest:GET
%output:method("html")
function api:accessGames() {
  if (session:get("name"))
  then (
    html:games() 
  ) else (
    web:redirect("/xforms-multiclient/login", map { "error": "" })
  )
};

declare
%rest:path("/xforms-multiclient/highscores")
%rest:GET
%output:method("html")
function api:accessHighscores() {
  if (session:get("name"))
  then (
    html:highscores() 
  ) else (
    web:redirect("/xforms-multiclient/login", map { "error": "" })
  )
};

declare
%rest:path("/xforms-multiclient/games")
%rest:POST
%updating
function api:createGame() {
  game:updateCreate(),
  update:output(web:redirect(concat("/xforms-multiclient/games/", game:latestId() + 1)))
};

declare
%rest:path("/xforms-multiclient/games/{$gameId}/delete")
%rest:POST
%updating
function api:deleteGame($gameId as xs:integer) {
    let $game := $api:games/game[@id = $gameId]
    return (
      game:delete($game),
      update:output(web:redirect("/xforms-multiclient/games"))
    )
};

declare
%rest:path("/xforms-multiclient/games/{$gameId}/join")
%rest:POST
%updating
function api:joinGame($gameId as xs:integer) {
  let $name := session:get("name")
  return (
    player:joinGame($gameId, $name),
    update:output(web:redirect(concat("/xforms-multiclient/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/xforms-multiclient/games/{$gameId}/leave")
%rest:POST
%updating
function api:leaveGame($gameId as xs:integer) {
  let $game := $api:games/game[@id = $gameId]
  let $name := session:get("name")
  let $player := $game/player[@name = $name]
  return (
    player:leave($player),
    update:output(web:redirect(concat("/xforms-multiclient/games/", $gameId, "/draw")))
  ) 
};

declare
%rest:path("/xforms-multiclient/games/{$gameId}")
%rest:GET
%output:method("html")
function api:accessGame($gameId) {
  if (session:get("name"))
  then (
    api:getGame($gameId)
  ) else (
    web:redirect("/xforms-multiclient/login", map { "error": "" })
  )
};

declare function api:getGame($gameId) {
  if (exists($api:games/game[@id = $gameId]))
  then (
    api:returnGame($gameId)
  ) else (
    api:gameNotFound()
  )
};

declare function api:returnGame($gameId) {
  let $name := session:get("name")
  let $hostname := request:hostname()
  let $port := request:port()
  let $address := concat($hostname,":",$port)
  let $websocketURL := concat("ws://", $address, "/ws/xforms-multiclient")
  let $getURL := concat("http://", $address, "/xforms-multiclient/games/", $gameId, "/draw")
  let $subscription := concat("/xforms-multiclient/games/", $gameId, "/", $name)
  let $html :=
      <html>
          <head>
              <title>XForms Multiclient Blackjack</title>
              <script src="/static/xforms-static/js/jquery-3.2.1.min.js"></script>
              <script src="/static/xforms-static/js/stomp.js"></script>
              <script src="/static/xforms-static/js/ws-element.js"></script>
              <link rel="stylesheet" type="text/css" href="/static/xforms-static/css/style.css"/>
          </head>
          <body>
              <ws-stream id="xforms-multiclient" url="{$websocketURL}" subscription="{$subscription}" geturl="{$getURL}"/>
          </body>
      </html>
  return $html
};

declare function api:gameNotFound() {
  html:gameNotFound()
};

declare
%rest:path("/xforms-multiclient/games/{$gameId}/draw")
%rest:GET
function api:drawGame($gameId) {
  let $game := $api:games/game[@id = $gameId]
  let $wsIds := ws:ids()
  let $trace := trace("started draw function")
  return (
    for $wsId in $wsIds
    let $trace := trace(concat($wsId, " exists"))
    where ws:get($wsId, "gameId") = $gameId
    (: might need another check for gameId:)
    let $trace := trace(concat($wsId, " is subbed to game", $gameId))
    let $path := ws:get($wsId, "path")
    let $name := ws:get($wsId, "name")
    let $destinationPath := concat("/xforms-multiclient/", $path, "/", $gameId, "/", $name)
    let $trace := trace(concat("destinationPath: ", $destinationPath))
    let $data := game:draw($game, $name)
    let $trace := trace("succesfully generated game")
    return (
      trace(concat("xforms-multiclient: drawing game to destination path: ", $destinationPath)),
      ws:sendchannel(fn:serialize($data), $destinationPath)
    )
  )
};

declare
%rest:path("/xforms-multiclient/games/{$gameId}/draw")
%rest:POST
function api:redraw($gameId) {
  api:drawGame($gameId)
};

declare
%rest:path("/xforms-multiclient/games/{$gameId}/bet")
%rest:POST
%rest:form-param("bet", "{$bet}", 0) 
%updating
function api:betPlayer($gameId, $bet) {
  let $game := $api:games/game[@id = $gameId]
  let $player := $game/player[@state="active"]
  return (
    player:bet($player, $bet),
    update:output(web:redirect(concat("/xforms-multiclient/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/xforms-multiclient/games/{$gameId}/hit")
%rest:POST
%updating
function api:hitPlayer($gameId) {
  let $game := $api:games/game[@id = $gameId]
  let $player := $game/player[@state="active"]
  return (
    player:hit($player),
    update:output(web:redirect(concat("/xforms-multiclient/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/xforms-multiclient/games/{$gameId}/stand") 
%rest:POST
%updating
function api:standPlayer($gameId) {
  let $game := $api:games/game[@id = $gameId]
  let $player := $game/player[@state="active"]
  return (
    player:stand($player),
    update:output(web:redirect(concat("/xforms-multiclient/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/xforms-multiclient/games/{$gameId}/double")
%rest:POST
%updating
function api:doublePlayer($gameId) {
  let $game := $api:games/game[@id = $gameId]
  let $player := $game/player[@state="active"]
  return (
    player:double($player),
    update:output(web:redirect(concat("/xforms-multiclient/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/xforms-multiclient/games/{$gameId}/insurance")
%rest:POST
%updating
function api:insurancePlayer($gameId) {
  let $game := $api:games/game[@id = $gameId]
  let $player := $game/player[@state="active"]
  return (
    player:insurance($player),
    update:output(web:redirect(concat("/xforms-multiclient/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/xforms-multiclient/games/{$gameId}/newRound")
%rest:POST
%updating
function api:newRound($gameId) {
  let $game := $api:games/game[@id = $gameId]
  return (
    game:newRound($game),
    update:output(web:redirect(concat("/xforms-multiclient/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/xforms-multiclient/games/{$gameId}/chat")
%rest:POST
%rest:form-param("msg", "{$msg}")
%updating
function api:chat($gameId, $msg) {
  let $game := $api:games/game[@id = $gameId]
  let $name := session:get("name")
  let $trace := trace("new message in chat")
  let $chat := $game/chat
  
  return (
    insert node <message author="{$name}">{$msg}</message> into $chat,
    update:output(web:redirect(concat("/xforms-multiclient/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/xforms-multiclient/test/game")
%rest:GET
%output:method("html")
function api:testGame() {
  let $self := 
  <game id="1" state="playing">
    <dealer>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
      <deck>
      </deck>
    </dealer>
    <player name="1" state="active">
      <balance>100</balance>
      <bet>20</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="2" state="active">
      <balance>100</balance>
      <bet>50</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="3" state="active">
      <balance>100</balance>
      <bet>70</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="4" state="active">
      <balance>100</balance>
      <bet>200</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="5" state="active">
      <balance>100</balance>
      <bet>500</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <chat>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
      <message author="test">Hello</message>
    </chat>
  </game>
  return 
  <html>
    <head>
        <title>Test</title>
        <script src="/static/xforms-static/JS/jquery-3.2.1.min.js"></script>
        <script src="/static/xforms-static/JS/stomp.js"></script>
        <script src="/static/xforms-static/JS/ws-element.js"></script>
        <link rel="stylesheet" type="text/css" href="/static/xforms-static/css/style.css"/>
    </head>
    <body>
      {game:draw($self, "1")}
    </body>
  </html>
};

declare
%rest:path("/xforms-multiclient/test/lobby")
%rest:GET
%output:method("html")
function api:testLobby() {
  let $stylesheet := doc("../static/xforms-static/xslt/lobby.xsl")
  let $games := <games>
  <game id="1" state="evaluated">
    <dealer>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
      <deck>
      </deck>
    </dealer>
    <player name="1" state="lost">
      <balance>100</balance>
      <bet>20</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="2" state="lost">
      <balance>100</balance>
      <bet>50</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="3" state="won">
      <balance>100</balance>
      <bet>70</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="4" state="lost">
      <balance>100</balance>
      <bet>200</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="5" state="won">
      <balance>100</balance>
      <bet>500</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
  </game>
  <game id="1" state="evaluated">
    <dealer>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
      <deck>
      </deck>
    </dealer>
    <player name="1" state="lost">
      <balance>100</balance>
      <bet>20</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="2" state="lost">
      <balance>100</balance>
      <bet>50</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="3" state="won">
      <balance>100</balance>
      <bet>70</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="4" state="lost">
      <balance>100</balance>
      <bet>200</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="5" state="won">
      <balance>100</balance>
      <bet>500</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
  </game>
  <game id="1" state="evaluated">
    <dealer>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
      <deck>
      </deck>
    </dealer>
    <player name="1" state="lost">
      <balance>100</balance>
      <bet>20</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="2" state="lost">
      <balance>100</balance>
      <bet>50</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="3" state="won">
      <balance>100</balance>
      <bet>70</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="4" state="lost">
      <balance>100</balance>
      <bet>200</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="5" state="won">
      <balance>100</balance>
      <bet>500</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
  </game>
  <game id="1" state="evaluated">
    <dealer>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
      <deck>
      </deck>
    </dealer>
    <player name="1" state="lost">
      <balance>100</balance>
      <bet>20</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="2" state="lost">
      <balance>100</balance>
      <bet>50</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="3" state="won">
      <balance>100</balance>
      <bet>70</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="4" state="lost">
      <balance>100</balance>
      <bet>200</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
    <player name="5" state="won">
      <balance>100</balance>
      <bet>500</bet>
      <hand value="14">
        <card value="7" suit="hearts"/>
        <card value="7" suit="hearts"/>
      </hand>
    </player>
  </game>
</games>
  let $map := map{ "screen": "games", "name": "test" }
  return xslt:transform($games, $stylesheet, $map)
};