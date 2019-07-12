module namespace html = "xforms/bjx/html";

declare function html:wrap($content) {
  <html>
    <head>
      <link rel="stylesheet" type="text/css" href="/static/bjx/css/style.css"/>
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
      <form action='/bjx/login' method='post'>
        <div class="input--advanced">
          <label id="name">
            Name
          </label>
          <input type="text" name='name' id='user' autofocus='' />
        </div>
        <div class="input--advanced">
          <label id="name">
            Password
          </label>
          <input type='password' name='pass' />
        </div>
        <button type="submit">Login</button>
      </form>
        <a href='/bjx/signup'><button class="circular"><text>+</text></button></a>
      </div>
  )
};

declare function html:signup($error) {
  html:wrap(
  <div class="dialog" id="register">
      <div class="dialog--header">
        Register
      </div>
      <form action='/bjx/signup' method='post'>
        <div class="input--advanced">
          <label id="name">
            Name
          </label>
          <input type="text" name='name' id='user' autofocus='' />
        </div>
        <div class="input--advanced">
          <label id="name">
            Password
          </label>
          <input type='password' name='pass' />
        </div>
        <button type="submit" class="menu">Create</button>
      </form>
        <a href='/bjx'><button class="circular" id="animated"><text>+</text></button></a>
      </div>

  )
};

declare function html:gameNotFound() {
  html:wrap(
    <form action="/bjx/games" method="post">
    <a href="/bjx">
        <button class="menu top left">&lt; Menu</button>
    </a>
      <p style="text-align: center">Game not found.</p>
      <button class="btn" type="submit">New Game</button>
    </form>
  )
};