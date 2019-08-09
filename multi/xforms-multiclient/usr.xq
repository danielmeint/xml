module namespace usr = "xforms/usr";

import module namespace api="xforms/api" at 'api.xq';

declare variable $usr:defaultBalance := 100;
declare variable $usr:defaultHighscore := $usr:defaultBalance;

declare 
%updating 
function usr:create($name) {
  insert node usr:newUser($name) into $api:users
};

declare function usr:newUser($name) {
  usr:newUser($name, $usr:defaultBalance, $usr:defaultHighscore)
};

declare function usr:newUser($name, $balance, $highscore) {
  <user name="{$name}">
    <balance>{$balance}</balance>
    <highscore>{$highscore}</highscore>
  </user>
};

declare function usr:exists($name) {
  if ($api:users/user[@name=$name])
  then (
    true()
  ) else (
    false()
  )
};

declare
%updating
function usr:win($self, $amount) {
  let $newBalance := $self/balance/text() + $amount
  return (
    replace value of node $self/balance with $newBalance,
    if ($newBalance > $self/highscore)
    then (
      replace value of node $self/highscore with $newBalance
    )
  )
};

declare
%updating
function usr:lose($self, $amount) {
  replace value of node $self/balance with $self/balance/text() - $amount
};

declare
%updating
function usr:deposit($self, $amount) {
  usr:win($self, $amount)
};