<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="1.0">

  <!-- Without (incorrect) output declaration, basex complains because some tags (including link and input) are not closed by the xslt processor -->
  <xsl:output method="xml" omit-xml-declaration="yes"/>

  <xsl:variable name="activePlayerHandValue" select="/game/player[@state = 'active']/hand/@value"/>
  <xsl:variable name="activePlayerHandCardCount" select="count(/game/player[@state = 'active']/hand/card)"/>
  <xsl:variable name="activePlayerBet" select="/game/player[@state = 'active']/bet"/>
  <xsl:variable name="activePlayerBalance" select="/game/player[@state = 'active']/balance"/>

  <xsl:template match="/">
    <html>
      <head>
        <link rel="stylesheet" type="text/css" href="/static/blackjack/style.css"/>
      </head>
      <body>
        <a id="exit-button" class="btn" href="/blackjack">&lt; Menu</a>
        <div class="container flex-container">
          <svg viewBox="0 0 800 520">
            <!-- table dimensions: 800 x 450 -->
            <use href="/static/blackjack/table.svg#table" x="0" y="0"/>
            <g class="card_group" id="dealer">

              <xsl:choose>

                <xsl:when test="game/@state = 'playing' and count(game/dealer/hand/card) = '2'">
                  <use
                    href="/static/blackjack/cards.svg#{game/dealer/hand/card[1]/@value}_{game/dealer/hand/card[1]/@suit}"/>
                  <use href="/static/blackjack/cards.svg#back"
                    style="transform: translate(40px, 4px)"/>
                </xsl:when>

                <xsl:otherwise>
                  <xsl:for-each select="game/dealer/hand/card">
                    <use href="/static/blackjack/cards.svg#{@value}_{@suit}"
                      style="transform: translate({(position() - 1) * 40}px, {(position() - 1) * 4}px)"
                    />
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
            </g>
            <g id="player_cards">
              <xsl:for-each select="game/player">
                <g id="player_{position()}_of_{count(/game/player)}">
                  <xsl:if test="@state = 'active'">
                    <use viewBox="0 0 450 450" height="20px" width="20px"
                      href="/static/blackjack/gui.svg#arrow_down"/>
                  </xsl:if>
                  <g class="card_group">
                    <xsl:for-each select="hand/card">
                      <use href="/static/blackjack/cards.svg#{@value}_{@suit}"
                        style="transform: translate({(position() - 1) * 40}px, {(position() - 1) * 4}px)"
                      />
                    </xsl:for-each>
                  </g>
                </g>
              </xsl:for-each>
            </g>
          </svg>

          <div id="info">
            <xsl:choose>

              <xsl:when test="game/@state = 'playing'">
                <p><xsl:value-of select="game/player[@state = 'active']/@name"/>'s turn</p>
                <p id="hand_value">
                  <xsl:value-of select="game/player[@state = 'active']/hand/@value"/>
                </p>
                <div class="button_group">
                  <a href="/blackjack/{game/@id}/stand/{game/player[@state='active']/@id}"
                    class="btn btn-small btn-stand">Stand</a>
                  <xsl:choose>
                    <xsl:when test="$activePlayerHandValue &gt; 21">
                      <a class="btn btn-disabled btn-busted">Busted</a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a href="/blackjack/{game/@id}/hit/{game/player[@state='active']/@id}"
                        class="btn btn-small btn-hit">Hit</a>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:choose>
                    <xsl:when test="$activePlayerHandCardCount &gt; 2 or $activePlayerBet * 2 &gt; $activePlayerBalance">
                      <a class="btn btn-disabled btn-busted">Double</a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a href="/blackjack/{game/@id}/double/{game/player[@state='active']/@id}"
                        class="btn btn-double">Double</a>
                    </xsl:otherwise>
                  </xsl:choose>
                </div>
              </xsl:when>

              <xsl:when test="game/@state = 'toEvaluate'">
                <a href="/blackjack/{game/@id}/evaluate" class="btn btn-large">Show Results</a>
              </xsl:when>

              <xsl:when test="game/@state = 'evaluated'">
                <xsl:for-each select="game/player">
                  <p>
                    <span>
                      <xsl:value-of select="@name"/>
                    </span>
                    <span>
                      <xsl:value-of select="@state"/>
                    </span>
                    <span>
                      <xsl:value-of select="bet"/>
                    </span>
                  </p>
                </xsl:for-each>

                <a href="/blackjack/{game/@id}/reset" class="btn btn-large">New Round</a>
              </xsl:when>


              <xsl:when test="game/@state = 'betting'">
                <form action="/blackjack/{game/@id}/play" method="POST">
                  <p>Place your bets!</p>
                  <xsl:for-each select="game/player">
                    <div>
                      <label for="">
                        <xsl:value-of select="@name"/>
                      </label>
                      <input type="number" id="player_{@id}_bet" name="player_{@id}_bet" min="0"
                        max="{balance}"/>
                    </div>
                  </xsl:for-each>
                  <input type="submit" value="Deal" class="btn"/>
                </form>
              </xsl:when>
            </xsl:choose>

          </div>
        </div>
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
