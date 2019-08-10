module namespace html = "xforms/html";

import module namespace api="xforms/api" at "api.xq";

import module namespace session = 'http://basex.org/modules/session';

declare function html:wrap($content) {
<html>
    <head>
      <link rel="stylesheet" type="text/css" href="/static/xforms-static/css/style.css"/>
    </head>
    <div class="navbar" id="centered">
    <h1>XForms Blackjack</h1>
    </div>
    <body scroll="no">
    <div class="flex-container flex-center">
        {$content}
    </div>
    </body>
  </html>
};

declare function html:menu() {
  let $name := session:get("name")
  let $user := $api:users/user[@name=$name]
  
  let $stylesheet := doc("../static/xforms-static/xslt/lobby.xsl")
  let $data := $api:games
  let $map := map{ "screen": "menu", "name": $name, "balance": $user/balance }
  
  return xslt:transform($data, $stylesheet, $map)
};

declare function html:login($error) {
  html:wrap(
    <div class="dialog" id="login">
      <div class="dialog--header">
        Login
      </div>
      <form action="/xforms-multiclient/login" method="post">
        <div class="input--advanced" id="menu">
          <span>{$error}</span>
          <label id="name">
            Name
          </label>
          <input type="text" name="name" id="user" autofocus="" />
        </div>
        <div class="input--advanced" id="menu">
          <label id="name">
            Password
          </label>
          <input type="password" name="pass" />
        </div>
        <button type="submit">Login</button>
      </form>
        <a href="/xforms-multiclient/signup"><button class="circular"><text>+</text></button></a>
      </div>
  )
};
declare function html:signup($error) {
  html:wrap(
  <div class="dialog" id="register">
      <div class="dialog--header">
        Register
      </div>
      <form action="/xforms-multiclient/signup" method="post">
        <div class="input--advanced" id="menu">
          <label id="name">
            Name
          </label>
          <input type="text" name="name" id="user" autofocus="" />
        </div>
        <div class="input--advanced" id="menu">
          <label id="name">
            Password
          </label>
          <input type="password" name="pass" />
        </div>
        <button type="submit" class="menu">Create</button>
      </form>
        <a href="/xforms-multiclient"><button class="circular" id="animated"><text>+</text></button></a>
      </div>
  )
};

declare function html:games() {
  let $name := session:get("name")
  let $user := $api:users/user[@name=$name]
  
  let $stylesheet := doc("../static/xforms-static/xslt/lobby.xsl")
  let $data := $api:games
  let $map := map{ "screen": "games", "name": $name, "balance": $user/balance }
  let $content := xslt:transform($data, $stylesheet, $map)
  return xslt:transform($data, $stylesheet, $map)
};

declare function html:highscores() {
  let $name := session:get('name')
  let $user := $api:users/user[@name=$name]
  
  let $stylesheet := doc("../static/xforms-static/xslt/lobby.xsl")
  let $data := $api:users
  let $map := map{ "screen": "highscores", "name": $name, "balance": $user/balance }
  let $content := xslt:transform($data, $stylesheet, $map)
  return xslt:transform($data, $stylesheet, $map)
};

declare function html:gameNotFound() {
  html:wrap(
    <form action="/xforms-multiclient/games" method="post">
    <a href="/xforms-multiclient">
        <button class="menu top left">&lt; Menu</button>
    </a>
      <p style="text-align: center">Game not found.</p>
      <button class="btn" type="submit">New Game</button>
    </form>
  )
};