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
  let $oldPlayers := $game/player
  return (
    replace value of node $game/@state with 'playing',
    helper:replaceAll($oldPlayers/bet/text(), $bets),
    replace value of node $game/player[@id='1']/@state with 'active',
    api:deal($gameId),
    update:output(helper:showGame($gameId)) 
  )
};

declare
%rest:path("/blackjack/{$gameId=[0-9]+}/deal")
%updating
function api:deal($gameId) {
  let $game := $api:db/games/game[@id=$gameId]
  for $player at $index in ($game/player, $game/dealer)
  let $oldHand := $player/hand
  let $deck := $game/dealer/deck
  let $newHand := hand:addCard(hand:addCard($oldHand, $deck/card[$index * 2 - 1]), $deck/card[$index * 2])
  return (
    replace node $oldHand with $newHand,
    delete node $deck/card[$index * 2 - 1],
    delete node $deck/card[$index * 2]
  )
};

declare
%rest:path("/blackjack/{$gameId=[0-9]+}/deal/{$playerId=[0-5]}")
%rest:GET
%updating
function api:dealPlayer($gameId as xs:integer, $playerId as xs:integer) {
  let $game := $api:db/games/game[@id=$gameId]
  let $player := $game/player[$playerId]
  let $oldHand := $player/hand
  let $deck := $game/dealer/deck
  let $newHand := hand:addCard(hand:addCard($oldHand, $deck/card[1]), $deck/card[2])
  
  return (
    replace node $oldHand with $newHand,
    delete node $deck/card[1],
    delete node $deck/card[2],
    update:output(helper:showGame($gameId)) 
  )
};

declare
%rest:path("blackjack/{$gameId=[0-9]+}/hit/{$playerId=[0-5]}")
%rest:GET
%updating
function api:hit($gameId as xs:integer, $playerId as xs:integer) {
  let $game := $api:db/games/game[@id=$gameId]
  let $player := $game/player[$playerId]
  let $oldHand := $player/hand
  let $oldDeck := $game/dealer/deck
  let $resultTuple := deck:drawCard($oldDeck)
  let $newCard := $resultTuple/card
  let $newDeck := $resultTuple/deck
  let $newHand := hand:addCard($oldHand, $newCard)
  
  return (
    replace node $oldHand with $newHand,
    replace node $oldDeck with $newDeck,
    update:output(helper:showGame($gameId))
  )
};

declare
%rest:path("blackjack/{$gameId=[0-9]+}/hit/dealer")
%rest:GET
%updating
function api:hitDealer($gameId as xs:integer) {
  let $game := $api:db/games/game[@id=$gameId]
  let $dealer := $game/dealer
  let $oldHand := $dealer/hand
  let $oldDeck := $dealer/deck
  let $resultTuple := deck:drawCard($oldDeck)
  let $newCard := $resultTuple/card
  let $newDeck := $resultTuple/deck
  let $newHand := hand:addCard($oldHand, $newCard)
  
  return (
    replace node $oldHand with $newHand,
    replace node $oldDeck with $newDeck,
    update:output(helper:showGame($gameId))
  )
};

declare
%rest:path("blackjack/{$gameId=[0-9]+}/stand/{$playerId=[0-5]}")
%rest:GET
%updating
function api:stand($gameId as xs:integer, $playerId as xs:integer) {
  let $game := $api:db/games/game[@id=$gameId]
  let $currPlayer := $game/player[$playerId]
  let $nextPlayer := $game/player[$playerId + 1]
  
  
  return (
    replace value of node $currPlayer/@state with 'inactive',
    
    if (exists($nextPlayer))
    then (
      replace value of node $nextPlayer/@state with 'active',
      update:output(helper:showGame($gameId))
    ) else (
      (: everybody played :)
      api:playDealer($gameId),
      replace value of node $game/@state with 'toEvaluate',
      update:output(helper:showGame($gameId))
    )
  )
};

declare
%rest:path("blackjack/{$gameId=[0-9]+}/insurance/{$playerId=[0-5]}")
%rest:GET
%updating
function api:insurance($gameId as xs:integer, $playerId as xs:integer){
  let $game := $api:db/games/game[@id=$gameId]
  let $currPlayer := $game/player[$playerId]
  let $oldBet := $currPlayer/bet
  let $newBet := $oldBet * 2
  return (
    replace value of node $oldBet with $newBet,
    replace value of node $currPlayer/@insurance with 'true',
    update:output(helper:showGame($gameId))
  )
};

declare
%rest:path("blackjack/{$gameId=[0-9]+}/double/{$playerId=[0-5]}")
%rest:GET
%updating
function api:double ($gameId as xs:integer, $playerId as xs:integer){
  let $game := $api:db/games/game[@id=$gameId]
  let $currPlayer := $game/player[$playerId]
  let $nextPlayer := $game/player[$playerId + 1]
  let $oldBet := $currPlayer/bet
  let $newBet := $oldBet * 2
  return (
    if (exists($nextPlayer)) then(
        replace value of node $oldBet with $newBet,
        api:hit($gameId,$playerId),
        api:stand($gameId,$playerId),
        update:output(helper:showGame($gameId))
        )
     else(
        api:playDealerDouble($gameId,$currPlayer/@id),
        replace value of node $currPlayer/@state with 'inactive',
        replace value of node $oldBet with $newBet,
        replace value of node $game/@state with 'toEvaluate',
        update:output(helper:showGame($gameId))
     )
  )
};

declare
%updating
function api:playDealerDouble($gameId as xs:integer,$playerId as xs:integer){
  let $game := $api:db/games/game[@id=$gameId]
  let $dealer := $game/dealer
  let $oldDealerHand := $dealer/hand
  let $oldDeck := $dealer/deck
  
  let $player := $game/player[$playerId]
  let $oldPlayerHand := $player/hand
  let $resultTuple := deck:drawCard($oldDeck)
  let $newCard := $resultTuple/card
  let $newDeck := $resultTuple/deck
  let $newPlayerHand := hand:addCard($oldPlayerHand, $newCard)
  
  let $result := helper:drawTo17($oldDealerHand, $newDeck)
  let $newDealerHand := $result/hand
  let $newDealerDeck := $result/deck
  
  return(
    replace node $oldPlayerHand with $newPlayerHand,
    replace node $oldDeck with $newDealerDeck,
    replace node $oldDealerHand with $newPlayerHand
  )
};


declare 
%updating
function api:playDealer($gameId as xs:integer) {
  let $game := $api:db/games/game[@id=$gameId]
  let $dealer := $game/dealer
  let $oldHand := $dealer/hand
  let $oldDeck := $dealer/deck
  let $result := helper:drawTo17($oldHand, $oldDeck)
  let $newHand := $result/hand
  let $newDeck := $result/deck
  
  return (
    replace node $oldHand with $newHand,
    replace node $oldDeck with $newDeck
  )
};

declare
%rest:path("blackjack/{$gameId=[0-9]+}/evaluate")
%rest:GET
%updating
function api:evaluateGame($gameId as xs:integer) {
  let $game := $api:db/games/game[@id=$gameId]
  let $players := $game/player
  let $toBeat := $game/dealer/hand/@value
  return (
    api:evaluatePlayers($players, $toBeat),
    replace value of node $game/@state with 'evaluated',
    update:output(helper:showGame($gameId))
  )
};

declare
%updating
function api:evaluatePlayers($players, $toBeat) {
  for $player in $players
  return api:evaluatePlayer($player, $toBeat)
};

declare
function api:isDealersCardAce($gameId as xs:integer) {
  let $game := $api:db/games/game[@id=$gameId]
  return (
    if($game/dealer/hand/card[1]/@value = 'A')
    then "true"
    else "false"
  )
};

declare
%updating
function api:evaluatePlayer($player, $toBeat as xs:integer) {
   if ($player/hand/@value <= 21 and ($player/hand/@value > $toBeat or $toBeat > 21))
    then (
      (:insurance + win -> 2 * Einsatz:)
      if(($player/@insurance = "true") and ($toBeat = 21) )
      then (
        replace value of node $player/@state with "won",
        replace value of node $player/balance with $player/balance/text() + $player/bet/text() + $player/bet/text()
      )
      else (
        replace value of node $player/@state with "won",
        replace value of node $player/balance with $player/balance/text() + $player/bet/text()
    )
    )
    else if ($player/hand/@value <= 21 and $player/hand/@value = $toBeat)
    then (
      (:insurance + tie -> 1 * Einsatz:)
      if(($player/@insurance = "true") and ($toBeat = 21) ) then (
        replace value of node $player/@state with "won",
        replace value of node $player/balance with $player/balance/text() + $player/bet/text()
      )
      else (
      replace value of node $player/@state with "tied"
    )  
  )
    else (
       (:insurance + Lose -> 0 * Einsatz:)
      if(($player/@insurance = "true") and ($toBeat = 21) ) then (
        replace value of node $player/@state with "won"
      )
      else (
      replace value of node $player/@state with "lost",
      replace value of node $player/balance with $player/balance/text() - $player/bet/text()
    )  
)
};

declare
%rest:path("/blackjack/test")
%rest:GET
function api:test() {
    <result>{xslt:processor()}</result>
};