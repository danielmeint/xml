module namespace card="gruppe_xforms/blackjack/card";

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