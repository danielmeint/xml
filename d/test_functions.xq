declare variable $gameState := db:open(
"example_database", "game_state_example.xml"
);

declare variable $values := array {
    "A", 2 to 10, "J", "Q", "K"
};
declare variable $suits := array {
    "clubs", "hearts", "spades", "diamonds"
};

declare function local:randomElement($input) {
  $input(random:integer(array:size($input) - 1) + 1)
};

declare function local:randomCard() {
  <card value="{local:randomElement($values)}" suit="{ local:randomElement($suits)}"/>
};

declare function local:sameCard($card1, $card2) {
  $card1/@value eq $card2/@value and $card1/@suit eq $card2/@suit
};

declare function local:seqContains($sequence, $item) {
  some $x in $sequence satisfies $x eq $item
};

declare function local:getAbsoluteValue($card) {
  if (local:seqContains(("J", "Q", "K"), $card/@value))
  then ( 10 )
  else if ($card/@value eq "A")
  then ( 11 )
  else ( data($card/@value) )
};

declare function local:getValues($cards) {
    $cards ! local:getAbsoluteValue(.)
};

(: Calculates the best possible value from a player's perspective, 
i.e. counts Aces as 11s as long as sum <= 21 :)
declare function local:getOptimalSum($values) {
  if (sum($values) le 21 or not(local:seqContains($values, 11)))
  then (
    sum($values)
  )
  else (
    (: remove the first 11, append a 1, and recursively recalculate :)
    let $firstIndex := index-of($values, 11)[1]
    let $newValues := ($values[not(position() eq $firstIndex)], 1)
    return local:getOptimalSum($newValues)
  )
};

let $drawnCards := $gameState//card
let $newCard := local:randomCard()
let $A := <card value="A" suit="hearts"/>
let $Q := <card value="Q" suit="hearts"/>

return local:getOptimalSum(local:getValues(($A, $Q, $Q, $Q)))