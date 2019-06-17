import module namespace player="gruppe_xforms/blackjack/player" at 'Player.xq';
import module namespace hand="gruppe_xforms/blackjack/hand" at 'Hand.xq';
import module namespace card="gruppe_xforms/blackjack/card" at 'Card.xq';
import module namespace deck="gruppe_xforms/blackjack/deck" at 'Deck.xq';
import module namespace game="gruppe_xforms/blackjack/game" at 'Game.xq';


let $myCards := (card:newCard("A", "clubs"), card:newCard("K", "spades"))
let $myHand := hand:newHand($myCards)
let $updatedHand := hand:removeCard($myHand, card:newCard("2", "hearts"))
return deck:getSize(deck:drawCard(deck:shuffle(deck:newDeck()))/deck)
(: return player:newPlayer(1, "Daniel", 100, 0, hand:newHand((deck:drawCard(deck:newDeck())/card))) :)