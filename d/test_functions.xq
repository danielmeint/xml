declare variable $gameState := db:open("example_database", "game_state_example.xml");

declare variable $values := array { "A", 2 to 10, "J", "Q", "K" };
declare variable $suits := array { "clubs", "hearts", "spades", "diamonds" };

let $randomElement := function($input) { $input(random:integer(array:size($input)-1)+1) }
let $randomCard := function() {<card value="{$randomElement($values)}" suit="{$randomElement($suits)}"/>}
let $sameCard := function($card1, $card2) { $card1/@value eq $card2/@value and $card1/@suit eq $card2/@suit }

let $drawnCards := $gameState//card
let $newCard := $randomCard()
let $A_hearts := <card value="A" suit="hearts"/>
let $anotherCard := <card value="Q" suit="hearts"/>

for $card in $drawnCards
where $sameCard($newCard, $card)
return
<duplicateCard>
  {$newCard}
</duplicateCard>