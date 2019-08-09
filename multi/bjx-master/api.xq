module namespace api = "xforms/api";

import module namespace card="xforms/card" at 'card.xq';
import module namespace dealer="xforms/dealer" at 'dealer.xq';
import module namespace deck="xforms/deck" at 'deck.xq';
import module namespace game="xforms/game" at 'game.xq';
import module namespace hand="xforms/hand" at 'hand.xq';
import module namespace html="xforms/html" at 'html.xq';
import module namespace player="xforms/player" at 'player.xq';
import module namespace usr="xforms/usr" at 'usr.xq';


import module namespace ws = "http://basex.org/modules/ws";
import module namespace request = "http://exquery.org/ns/request";

import module namespace session = 'http://basex.org/modules/session';

declare variable $api:db := db:open("bjx");
declare variable $api:users := db:open("bjx-users");

declare
%rest:path("/bjx")
%rest:GET
%output:method("html")
function api:entry() {
  if (session:get('name'))
  then (
    api:menu() 
  ) else (
    api:login()
  )
};

declare function api:menu() {
  let $stylesheet := doc("../static/bjx/xslt/lobby.xsl")
  let $games := $api:db/games
  let $map := map{ "screen": "menu", "name": session:get('name') }
  return xslt:transform($games, $stylesheet, $map)
};

declare function api:login() {
  html:login()
};

declare
%rest:GET
%rest:path('bjx/signup')
%output:method("html")
%rest:query-param("error", "{$error}")
function api:sign-up($error) {
    html:signup($error)
};

declare
%rest:POST
%rest:path("/bjx/signup")
%rest:query-param("name", "{$name}")
%rest:query-param("pass", "{$pass}")
%updating
function api:user-create(
  $name as xs:string,
  $pass as xs:string
) as empty-sequence() {
  try {
    if(user:exists($name)) then (
      error((), 'User already exists.')
    ) else (
      user:create($name, $pass, 'none'),
      usr:create($name)
    ),
    update:output(web:redirect("/bjx"))
  } catch * {
    update:output(web:redirect("/bjx/signup", map { 'error': $err:description }))
  }
};

declare
%rest:POST
%rest:path('/bjx/signup-check')
%rest:query-param('name', '{$name}')
%rest:query-param('pass', '{$pass}')
function api:signup-check(
  $name as xs:string,
  $pass as xs:string
) as element(rest:response) {
  
};

declare
%rest:POST
%rest:path('/bjx/login')
%rest:query-param('name', '{$name}')
%rest:query-param('pass', '{$pass}')
%updating
function api:login-check(
  $name  as xs:string,
  $pass  as xs:string

) {
  try {
    let $u := user:check($name, $pass)
    let $s := session:set('name', $name)
    return (
      if (not(usr:exists($name)))
      then (
        usr:create($name)
      )
    )
  } catch user:* {
    (: login fails: no session info is set :)
  },
  update:output(web:redirect('/bjx'))
};

declare
%rest:path('/bjx/logout')
function api:logout() as element(rest:response) {
  session:get('name') ! api:close(.),
  session:delete('name'),
  web:redirect('/bjx')
};

declare function api:close($name  as  xs:string) as empty-sequence() {
  for $wsId in ws:ids()
  where ws:get($wsId, 'name') = $name
  return ws:close($wsId)
};

declare
%rest:path("/bjx/setup")
%rest:GET
%output:method("html")
%updating
function api:setup() {
  db:create("bjx", doc('model.xml')),
  db:create("bjx-users", doc('users.xml')),
  update:output(web:redirect('/bjx'))
};

declare
%rest:path("/bjx/games")
%rest:GET
%output:method("html")
function api:accessGames() {
  if (session:get('name'))
  then (
    api:games() 
  ) else (
    api:login()
  )
};

declare function api:games() {
  let $stylesheet := doc("../static/bjx/xslt/lobby.xsl")
  let $games := $api:db/games
  let $map := map{ "screen": "games", "name": session:get('name') }
  return xslt:transform($games, $stylesheet, $map)
};

declare
%rest:path("/bjx/highscores")
%rest:GET
%output:method("html")
function api:accessHighscores() {
  if (session:get('name'))
  then (
    api:highscores() 
  ) else (
    api:login()
  )
};


declare function api:highscores() {
  let $stylesheet := doc("../static/bjx/xslt/lobby.xsl")
  let $games := $api:db/games
  let $map := map{ "screen": "highscores", "name": session:get('name') }
  return xslt:transform($games, $stylesheet, $map)
};

declare
%rest:path("/bjx/games")
%rest:POST
%updating
function api:createGame() {
  game:updateCreate(),
  update:output(web:redirect(concat("/bjx/games/", game:latestId() + 1)))
};

declare
%rest:path("/bjx/games/{$gameId}/delete")
%rest:POST
%updating
function api:deleteGame($gameId as xs:integer) {
    let $game := $api:db/games/game[@id = $gameId]
    return (
      game:delete($game),
      update:output(web:redirect("/bjx/games"))
    )
};

declare
%rest:path("/bjx/games/{$gameId}/join")
%rest:POST
%updating
function api:joinGame($gameId as xs:integer) {
  let $name := session:get('name')
  return (
    player:joinGame($gameId, $name),
    update:output(web:redirect(concat("/bjx/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/bjx/games/{$gameId}/leave")
%rest:POST
%updating
function api:leaveGame($gameId as xs:integer) {
  let $game := $api:db/games/game[@id = $gameId]
  let $name := session:get('name')
  let $player := $game/player[@name = $name]
  return (
    player:leave($player),
    update:output(web:redirect(concat("/bjx/games/", $gameId, "/draw")))
  ) 
};

declare
%rest:path("/bjx/games/{$gameId}")
%rest:GET
%output:method("html")
function api:accessGame($gameId) {
  if (session:get('name'))
  then (
    api:getGame($gameId)
  ) else (
    api:login()
  )
};

declare function api:getGame($gameId) {
  if (exists($api:db/games/game[@id = $gameId]))
  then (
    api:returnGame($gameId)
  ) else (
    api:gameNotFound()
  )
};

declare function api:returnGame($gameId) {
  let $name := session:get('name')
  let $hostname := request:hostname()
  let $port := request:port()
  let $address := concat($hostname,":",$port)
  let $websocketURL := concat("ws://", $address, "/ws/bjx")
  let $getURL := concat("http://", $address, "/bjx/games/", $gameId, "/draw")
  let $subscription := concat("/bjx/games/", $gameId, "/", $name)
  let $html :=
      <html>
          <head>
              <title>BJX</title>
              <script src="/static/bjx/js/jquery-3.2.1.min.js"></script>
              <script src="/static/bjx/js/stomp.js"></script>
              <script src="/static/bjx/js/ws-element.js"></script>
              <link rel="stylesheet" type="text/css" href="/static/bjx/css/style.css"/>
          </head>
          <body>
              <ws-stream id="bjx" url="{$websocketURL}" subscription="{$subscription}" geturl="{$getURL}"/>
          </body>
      </html>
  return $html
};

declare function api:gameNotFound() {
  html:gameNotFound()
};

declare
%rest:path("/bjx/games/{$gameId}/draw")
%rest:GET
function api:drawGame($gameId) {
  let $game := $api:db/games/game[@id = $gameId]
  let $wsIds := ws:ids()
  return (
    for $wsId in $wsIds
    where ws:get($wsId, "app") = "bjx" and ws:get($wsId, "gameId") = $gameId
    (: might need another check for gameId:)
    let $path := ws:get($wsId, "path")
    let $name := ws:get($wsId, "name")
    let $destinationPath := concat("/bjx/", $path, "/", $gameId, "/", $name)
    let $data := game:drawFull($game, $name)
    return (
      trace(concat("BJX: drawing game to destination path: ", $destinationPath)),
      ws:sendchannel(fn:serialize($data), $destinationPath)
    )
  )
};

declare
%rest:path("/bjx/games/{$gameId}/draw")
%rest:POST
function api:redraw($gameId) {
  api:drawGame($gameId)
};

declare
%rest:path("/bjx/games/{$gameId}/bet")
%rest:POST
%rest:form-param("bet", "{$bet}", 0) 
%updating
function api:betPlayer($gameId, $bet) {
  let $game := $api:db/games/game[@id = $gameId]
  let $player := $game/player[@state='active']
  return (
    player:bet($player, $bet),
    update:output(web:redirect(concat("/bjx/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/bjx/games/{$gameId}/hit")
%rest:POST
%updating
function api:hitPlayer($gameId) {
  let $game := $api:db/games/game[@id = $gameId]
  let $player := $game/player[@state='active']
  return (
    player:hit($player),
    update:output(web:redirect(concat("/bjx/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/bjx/games/{$gameId}/stand") 
%rest:POST
%updating
function api:standPlayer($gameId) {
  let $game := $api:db/games/game[@id = $gameId]
  let $player := $game/player[@state='active']
  return (
    player:stand($player),
    update:output(web:redirect(concat("/bjx/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/bjx/games/{$gameId}/double")
%rest:POST
%updating
function api:doublePlayer($gameId) {
  let $game := $api:db/games/game[@id = $gameId]
  let $player := $game/player[@state='active']
  return (
    player:double($player),
    update:output(web:redirect(concat("/bjx/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/bjx/games/{$gameId}/insurance")
%rest:POST
%updating
function api:insurancePlayer($gameId) {
  let $game := $api:db/games/game[@id = $gameId]
  let $player := $game/player[@state='active']
  return (
    player:insurance($player),
    update:output(web:redirect(concat("/bjx/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/bjx/games/{$gameId}/newRound")
%rest:POST
%updating
function api:newRound($gameId) {
  let $game := $api:db/games/game[@id = $gameId]
  return (
    game:newRound($game),
    update:output(web:redirect(concat("/bjx/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/bjx/games/{$gameId}/chat")
%rest:POST
%rest:form-param("msg", "{$msg}")
%updating
function api:chat($gameId, $msg) {
  let $game := $api:db/games/game[@id = $gameId]
  let $name := session:get('name')
  let $trace := trace("new message in chat")
  let $chat := $game/chat
  
  return (
    insert node <message author="{$name}">{$msg}</message> into $chat,
    update:output(web:redirect(concat("/bjx/games/", $gameId, "/draw")))
  )
};

declare
%rest:path("/bjx/test/game")
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
        <title>BJX</title>
        <script src="/static/bjx/JS/jquery-3.2.1.min.js"></script>
        <script src="/static/bjx/JS/stomp.js"></script>
        <script src="/static/bjx/JS/ws-element.js"></script>
        <link rel="stylesheet" type="text/css" href="/static/bjx/css/style.css"/>
    </head>
    <body>
      {game:drawFull($self, "1")}
    </body>
  </html>
};

declare
%rest:path("/bjx/test/lobby")
%rest:GET
%output:method("html")
function api:testLobby() {
  let $stylesheet := doc("../static/bjx/xslt/lobby.xsl")
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