module namespace api = "gruppe_xforms/blackjack/API";

import module namespace player="gruppe_xforms/blackjack/player" at 'Player.xq';
import module namespace hand="gruppe_xforms/blackjack/hand" at 'Hand.xq';
import module namespace card="gruppe_xforms/blackjack/card" at 'Card.xq';
import module namespace deck="gruppe_xforms/blackjack/deck" at 'Deck.xq';
import module namespace game="gruppe_xforms/blackjack/game" at 'Game.xq';
import module namespace dealer="gruppe_xforms/blackjack/dealer" at 'Dealer.xq';


declare variable $api:startingBudget := 100;
declare variable $api:db := db:open("blackjack");

(: Setup the database and load the model :)
declare
%rest:path("blackjack/setup")
%output:method("xhtml")
%updating
%rest:GET
function api:setup(){
    let $model := doc('model.xml')
    let $html  := <div>
      <p>Database successfully setup!</p>
      <a href="/blackjack/start">Start!</a>
    </div>
    return(
      db:create("blackjack", $model),
      update:output($html)
  )
};

declare
%rest:path("/blackjack/start")
%rest:GET
%output:method("xhtml")
function api:entry() {
    doc("start.html")
};

declare
%rest:path("/blackjack/play")
%rest:POST
%rest:form-param("player1", "{$player1}")
%rest:form-param("player2", "{$player2}")
%rest:form-param("player3", "{$player3}")
%rest:form-param("player4", "{$player4}")
%rest:form-param("player5", "{$player5}")
%updating

function api:play($player1, $player2, $player3, $player4, $player5) {
  let $players := (
    for $name at $pos in ($player1, $player2, $player3, $player4, $player5)
    where not($name eq "")
    return player:setName(player:newPlayer($pos), $name)
  )
  let $id := count($api:db/games/game) +1
  
  let $game := game:setPlayers(game:newGame($id), $players)
  return (
    insert node $game into $api:db/games,
    update:output(web:redirect("/blackjack/show"))
  )
};

declare
%rest:path("/blackjack/show")
%rest:GET
function api:show() {
    $api:db
};

declare
%rest:path("/blackjack/{$game}/show")
%rest:GET
function api:show($game as xs:integer) {
   $api:db/games/game[$game] 
};

declare
%rest:path("blackjack/{$game}/hit/{$player}")
%rest:GET
%updating
function api:hit($game as xs:integer, $player as xs:integer) {
  let $gameNode := $api:db/games/game[$game]
  let $playerNode := $gameNode/player[$player]
  let $playerHand := $playerNode/hand
  let $deck := $gameNode/dealer/deck
  let $resultTuple := deck:drawCard($deck)
  let $newCard := $resultTuple/card
  let $newDeck := $resultTuple/deck
  return (
    insert node $newCard into $playerHand,
    replace node $deck with $newDeck,
    update:output(web:redirect("/blackjack/show"))
  )
};

declare
%rest:path("blackjack/{$game}/update_bet/{$player}/{$bet_amount}")
%rest:GET
%updating
function api:update_bet($game as xs:integer, $player as xs:integer, $bet_amount as xs:int){
  let $gameNode := $api:db/games/game[$game]
  let $playerNode := $gameNode/player[$player]
  let $old_balance := $playerNode/balance
  let $new_balance := $old_balance - $bet_amount
  let $new_playerNode := player:setBet($playerNode,$bet_amount)
  let $new_playerNode := player:setBalance($new_playerNode,$new_balance)
  return (
    if ($new_balance >= 0) then
    (   replace node $playerNode with $new_playerNode, 
	    update:output(web:redirect("/blackjack/show"))
    )else 
        (: show error message and ask for new input :)
        update:output(web:redirect("/blackjack/show"))
  )
};

(:declare
%rest:path("blackjack/{$game}/draw_cards")
%rest:GET
%updating
function api:draw_cards($game as xs:integer){
    let $gameNode := $api:db/games/game[$game]
    let $deck := $gameNode/dealer/deck
    return (
        let $newDeck:=api:draw_cards_helper($game,1,$deck)
        return(
            replace node $deck with $newDeck,
            update:output(web:redirect("/blackjack/show"))
    ))
};

declare function api:draw_cards_helper($game as xs:integer,$count as xs:integer,$deck ){
    let $gameNode := $api:db/games/game[$game]
    let $playerNode := $gameNode/player[$count]
    let $playerHand := $playerNode/hand
    return( 
        if ( $count < count ($gameNode/player)) 
        then(
            let $resultTuple := deck:drawCard($deck)
            let $newCard := $resultTuple/card
            let $newDeck := $resultTuple/deck
            let $x := api:draw_cards_helper($game,$count + 1, $newDeck)
            return(
                $newDeck
            )
        )else(
        
            return ($deck)
        )
    
      )
      
};:)

declare 
%rest:path("blackjack/{$game}/draw_cards_rng")
%rest:GET
%updating
function api:draw_cards_rng($game as xs:integer){
     let $gameNode := $api:db/games/game[$game]
     for $player in $gameNode/player
     let $result1 := card:randomCard()
     let $result2 := card:randomCard()
     let $playerHand := $player/hand
     return (
        insert node $result1 into $playerHand,
        insert node $result2 into $playerHand,
        update:output(web:redirect("/blackjack/show"))
     )
};
