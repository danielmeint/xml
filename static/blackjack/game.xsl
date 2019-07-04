<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="1.0">

  <!-- Without (incorrect) output declaration, basex complains because some tags (including link and input) are not closed by the xslt processor -->
  <xsl:output method="xml" omit-xml-declaration="yes"/>

  <xsl:variable name="activePlayerHandValue" select="/game/player[@state = 'active']/hand/@value"/>
  <xsl:variable name="activePlayerHandCardCount" select="count(/game/player[@state = 'active']/hand/card)"/>
  <xsl:variable name="activePlayerBet" select="/game/player[@state = 'active']/bet"/>
  <xsl:variable name="activePlayerBalance" select="/game/player[@state = 'active']/balance"/>
  <xsl:variable name="dealerCard" select="/game/dealer/hand/card[1]/@value"/>
  <xsl:variable name="isInsurance" select="/game/player[@state = 'active']/@insurance"/>

  <xsl:template match="/">
    <html>
      <head>
        <link rel="stylesheet" type="text/css" href="/static/blackjack/CSS/style.css"/>
      </head>
      <body id="game">
        <a href="/blackjack"><button class="menu" id="game">&lt; Menu</button></a>
        <div class="container flex-container">
          <svg viewBox="-100 0 1000 620">
            <!-- table dimensions: 800 x 450 -->
            <use href="/static/blackjack/table.svg#table" x="0" y="0"/>
            <g class="card_group" id="dealer">
              <xsl:choose>
                <xsl:when test="game/@state = 'playing' and count(game/dealer/hand/card) = '2'">
                  <use
                    href="/static/blackjack/cards.svg#{game/dealer/hand/card[1]/@value}_{game/dealer/hand/card[1]/@suit}"/>
                  <use href="/static/blackjack/cards.svg#back"
                    style="transform: translate(20px, 4px)"/>
                </xsl:when>

                <xsl:otherwise>
                  <xsl:for-each select="game/dealer/hand/card">
                    <use href="/static/blackjack/cards.svg#{@value}_{@suit}"
                      style="transform: translate({(position() - 1) * 20}px, {(position() - 1) * 4}px)"
                    />
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
            </g>
            <g id="player_cards">
              <xsl:for-each select="game/player">
                <g id="player_{position()}_of_{count(/game/player)}">
                  <xsl:if test="bet > 0">
                    <g viewBox="0 0 100 100">
                      <xsl:choose>
                        <xsl:when test="@state = 'won' or @state='tied'">
                          <xsl:attribute name="style">animation: chip-won 1s ease-in forwards</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="@state = 'lost'">
                          <xsl:attribute name="style">animation: chip-lost 1s ease-in forwards</xsl:attribute>
                        </xsl:when>
                      </xsl:choose>
                      <xsl:choose>
                        <xsl:when test="bet >= 100">
                          <xsl:attribute name="class">bet chip chip-100</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="bet >= 25">
                          <xsl:attribute name="class">bet chip chip-25</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="bet >= 10">
                          <xsl:attribute name="class">bet chip chip-10</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="bet >= 5">
                          <xsl:attribute name="class">bet chip chip-5</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="bet >= 1">
                          <xsl:attribute name="class">bet chip chip-1</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:attribute name="class">bet chip</xsl:attribute>
                        </xsl:otherwise>
                      </xsl:choose>
                      <use href="/static/blackjack/chips.svg#chip" width="50" height="50"/>
                      <text x="25" y="25" alignment-baseline="central">
                        <xsl:value-of select="bet"/>
                      </text>
                    </g>
                    <xsl:if test="@insurance = 'true'">
                    <g>
                      <xsl:attribute name="class">bet chip chip-insurance</xsl:attribute>
                      <xsl:if test="@state = 'won' or @state = 'tied' or @state = 'lost'">
                        <xsl:attribute name="style">visibility: hidden</xsl:attribute>
                      </xsl:if>
                      <use href="/static/blackjack/chips.svg#chip" width="40" height="40" transform="translate(40, -30)"/>
                      <text x="20" y="20" alignment-baseline="central" transform="translate(40, -30)">
                        I
                      </text>
                    </g>
                    </xsl:if>
                  </xsl:if>
                  <g class="card_group">
                    <xsl:for-each select="hand/card">
                      <use href="/static/blackjack/cards.svg#{@value}_{@suit}"
                        style="transform: translate({(position() - 1) * 20}px, {(position() - 1) * 4}px)"
                      />
                    </xsl:for-each>
                  </g>
                  <xsl:if test="/game/@state = 'playing'">
                    <g>
                      <xsl:choose>
                        <xsl:when test="@state='active'">
                          <xsl:attribute name="class">label label-hand label-active</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:attribute name="class">label label-hand</xsl:attribute>
                        </xsl:otherwise>
                      </xsl:choose>
					            <rect x="10px" y="110px" rx="15" ry="15" width="{string-length(@name)*5 + 60}px"  height="65"/>
                      <!-- <rect x="10px" y="110px" rx="15" ry="15" width="75" height="65"/> -->
                      <text class="name" x="27px" y="125px">
                        &#x1F60E;<xsl:value-of select="@name"/>
                      </text>
                      <text class="hand_value" x="27px" y="170px" xmlns="http://www.w3.org/2000/svg">
                        <xsl:value-of select="hand/@value"/>
                      </text>
					  <text class="balance" x="27px" y="142px" xmlns="http://www.w3.org/2000/svg">
						&#x1F4B0;<xsl:value-of select="balance - bet"/>
                      </text>
                    </g>
                  </xsl:if>
                </g>
              </xsl:for-each>
            </g>
          </svg>

            <xsl:choose>
              <xsl:when test="game/@state = 'playing'">
                <div class="dialog" id="buttongroup">
                <div class="dialog--header">
                  <xsl:value-of select="game/player[@state = 'active']/@name"/>
                </div>
                <div class="buttongroup">
                  <div>
                  <a href="/blackjack/{game/@id}/stand">
                    <button class="stand">Stand</button></a>
                  </div>
                  <xsl:choose>
                    <xsl:when test="$activePlayerHandValue &gt; 21">
                      <div>
                    <button class="hit" id="disabled">Busted</button>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                      <div>
                      <a href="/blackjack/{game/@id}/hit"><button class="hit">Hit</button></a>
                        </div>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:choose>
                    
                    <xsl:when test="$activePlayerHandCardCount &gt; 2 or $activePlayerBet * 2 &gt; $activePlayerBalance">
                      <div>
                      <button class="double" id="disabled">Double</button>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                      <div>
                      <a href="/blackjack/{game/@id}/double"
                        ><button class="double">Double</button></a>
                        </div>
                    </xsl:otherwise>
                      
                  </xsl:choose>
                  <xsl:choose>
                    <xsl:when test="$activePlayerBet * 2 &gt; $activePlayerBalance or $dealerCard!='A' or $isInsurance='true'">
                      <div>
                      <button class="insurance" id="disabled">Insurance</button>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                      <div>
                      <a href="/blackjack/{game/@id}/insurance">
                        <button id="insurance">Insurance</button>
                      </a>
                        </div>
                    </xsl:otherwise>
                  </xsl:choose>
                </div>
                </div>
              </xsl:when>
              </xsl:choose>
          
              <xsl:choose>
              <xsl:when test="game/@state = 'toEvaluate'">
                <a href="/blackjack/{game/@id}/evaluate"><button>Show Results</button></a>
              </xsl:when>

              <xsl:when test="game/@state = 'evaluated'">
                <div class="dialog">
                <div class="dialog--result">
                  <div class="dialog--header">Results &#x1F4B0;</div>
                <div class="dialog--content">
                <xsl:for-each select="game/player">
                  <xsl:choose>
                    <xsl:when test="@state = 'won'">
                      <p id="win">
                        &#x1F60A; &#xA0;
                        <span>
                          <xsl:value-of select="@name"/>
                        </span>
                        <span>
                          &#x2B;
                        </span>
                        <span>
                          <xsl:value-of select="bet"/>
                        </span>
                      </p>
                    </xsl:when>
                    <xsl:when test="@state = 'lost'">
                      <p id="lose">
                        <span>
                        &#x1F612; &#xA0;
                        </span>
                        <span>
                          <xsl:value-of select="@name"/>
                        </span>
                        <span>
                          &#8722;
                        </span>
                        <span>
                          <xsl:value-of select="bet"/>
                        </span>
                      </p>
                    </xsl:when>
                    <xsl:when test="@state='tied'">
                      <p id="tie">
                        &#x1F60A; &#xA0;
                        <span>
                          <xsl:value-of select="@name"/>
                        </span>
                        <span>
                          &#xB1;
                        </span>
                        <span>
                          0
                        </span>
                      </p>
                    </xsl:when>
                  </xsl:choose>
                </xsl:for-each>
                </div>
                  <a href="/blackjack/{game/@id}/reset"><button>New Round</button></a>
                </div>
                </div>
              </xsl:when>
              <xsl:when test="count(game/player) = 0">
                <!-- Game has to be removed here! -->
                <div class="dialog">
                  <div class="dialog--header">
                    No Players left!
                  </div>
                  <div class="dialog--content">
                    <a href="/blackjack/{game/@id}/delete"><button>Main Menu</button></a>
                  </div>
                </div>
              </xsl:when>
              <xsl:when test="game/@state = 'betting'">
                <div class="dialog">
                <div class="dialog--header">
                  Place your bets!
                </div>
                <div class="dialog--content">
                <form action="/blackjack/{game/@id}/play" method="POST">
                  <div class="dialog--betting">
                  <xsl:for-each select="game/player">
                    <div class="input--advanced">
                      <label for="">
                        <xsl:value-of select="@name"/>
                      </label>
                      <input class="betting" type="number" id="player_{@id}_bet" name="player_{@id}_bet" min="5" step="5"
                        max="{balance}" required=""/>
                    </div>
                  </xsl:for-each>
                  </div>
                  <button type="submit">Deal</button>
                </form>
                </div>
                </div>
              </xsl:when>
              </xsl:choose>
        </div>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
