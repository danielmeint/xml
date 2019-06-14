module namespace card="gruppe_xforms/blackjack/card";

declare variable $card:values := array {
    "A", 2 to 10, "J", "Q", "K"
};
declare variable $card:suits := array {
    "clubs", "hearts", "spades", "diamonds"
};


declare function card:newCard($value, $suit) {
  <card value="{$value}" suit="{$suit}"/>
};

declare function card:setValue($self, $value) {
  let $suit := $self/@suit
  return card:newCard($value, $suit)
};

declare function card:setSuit($self, $suit) {
  let $value := $self/@value
  return card:newCard($value, $suit)
};

declare function card:equals($card1, $card2) {
  $card1/@value eq $card2/@value and $card1/@suit eq $card2/@suit
};

declare function card:randomElement($input) {
  $input(random:integer(array:size($input) - 1) + 1)
};


declare function card:randomCard() {
  <card value="{card:randomElement($card:values)}" suit="{ card:randomElement($card:suits)}"/>
};
