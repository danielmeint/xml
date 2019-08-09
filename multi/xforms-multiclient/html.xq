module namespace html = "xforms/html";

declare function html:wrap($content) {
<html>
    <head>
      <link rel="stylesheet" type="text/css" href="/static/xforms-static/css/style.css"/>
    </head>
    <div class="navbar" id="centered">
    <h1>XForms' Blackjack</h1>
    </div>
    <body scroll="no">
    <div class="flex-container flex-center">
        {$content}
    </div>
    </body>
  </html>
};
declare function html:login() {
  html:wrap(
    <div class="dialog" id="login">
      <div class="dialog--header">
        Login
      </div>
      <form action='/xforms-multiclient/login' method='post'>
        <div class="input--advanced" id="menu">
          <label id="name">
            Name
          </label>
          <input type="text" name='name' id='user' autofocus='' />
        </div>
        <div class="input--advanced" id="menu">
          <label id="name">
            Password
          </label>
          <input type='password' name='pass' />
        </div>
        <button type="submit">Login</button>
      </form>
        <a href='/xforms-multiclient/signup'><button class="circular"><text>+</text></button></a>
      </div>
  )
};
declare function html:signup($error) {
  html:wrap(
  <div class="dialog" id="register">
      <div class="dialog--header">
        Register
      </div>
      <form action='/xforms-multiclient/signup' method='post'>
        <div class="input--advanced" id="menu">
          <label id="name">
            Name
          </label>
          <input type="text" name='name' id='user' autofocus='' />
        </div>
        <div class="input--advanced" id="menu">
          <label id="name">
            Password
          </label>
          <input type='password' name='pass' />
        </div>
        <button type="submit" class="menu">Create</button>
      </form>
        <a href='/xforms-multiclient'><button class="circular" id="animated"><text>+</text></button></a>
      </div>
  )
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