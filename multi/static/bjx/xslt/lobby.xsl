<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="1.0">
    <xsl:output indent="no" method="xml" omit-xml-declaration="yes" />
    <xsl:param name="screen" />
    <xsl:param name="name" />
    <xsl:param name="balance" />
    <xsl:template match="/">
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="/static/bjx/css/style.css" />
            </head>
                <div class="navbar" id="centered">
                    <h1>Hello&#xA0;<xsl:value-of select="$name"/>!</h1> 
                </div>
                <a href="/bjx">
                <xsl:if test="$screen = 'games'">
                    <button class="menu top left">◀ Games</button>
                </xsl:if>
                <xsl:if test="$screen = 'highscores'">
                    <button class="menu top left">◀ Highscore</button>
                </xsl:if>
                </a>
                <a href="/bjx/logout">
                    <button class = "menu top right">
                        Logout
                    </button>
                </a>
            <body>
                <div class="flex-container flex-center">
                        <xsl:choose>
                            <xsl:when test="$screen = 'menu'">
                                <form action="/bjx/games" method="post">
                                    <button type="submit">New Game</button>
                                </form>
                                <a href="/bjx/games"><button>Join Game</button></a>
                                <a href="/bjx/highscores"><button>Highscores</button></a>
                                <form class="join" action="/bjx/games" method="post">
                                    <a>&#x1F4B0; 100</a>
                                    <button type="submit">Reset</button> 
                                </form>
                            </xsl:when>
                            <xsl:when test="$screen = 'games'">
                                <xsl:choose>
                                    <xsl:when test="count(games/game) = 0">
                                        <p>No active games.</p>
                                        <form action="/bjx/games" method="post">
                                            <button type="submit">New Game</button> 
                                        </form>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <div class="menutable">
                                            <table id="games-table" >
                                                <thead >
                                                    <tr>
                                                        <th scope="col">Game ID</th>
                                                        <th scope="col">State</th>
                                                        <th scope="col">1</th>
                                                        <th scope="col">2</th>
                                                        <th scope="col">3</th>
                                                        <th scope="col">4</th>
                                                        <th scope="col">5</th>
                                                        <th scope="col">
                                                            <form action="/bjx/games" method="post">
                                                            <button class="circular" id="table" type="submit">+</button>
                                                            </form>
                                                        </th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <xsl:for-each select="games/game">
                                                        <tr>
                                                            <td>
                                                                <a href="/bjx/games/{@id}"><xsl:value-of select="@id"/></a>
                                                            </td>
                                                            <td>
                                                                <a href="/bjx/games/{@id}">
                                                                    <xsl:value-of select="player[@state = 'active']/@name" /><xsl:value-of select="@state" />
                                                                </a>
                                                            </td>
                                                            <td>
                                                                <a href="/bjx/games/{@id}">
                                                                    <xsl:if test="player[1]">
                                                                        <xsl:value-of select="player[1]/@name"/>(<xsl:value-of select="player[1]/balance"/>)
                                                                    </xsl:if>
                                                                    <xsl:if test="not(player[1])">
                                                                        <text id="free">Free</text>
                                                                    </xsl:if>  
                                                                </a>
                                                            </td>
                                                            <td>
                                                                <a href="/bjx/games/{@id}">
                                                                    <xsl:if test="player[2]">
                                                                        <xsl:value-of select="player[2]/@name"/>(<xsl:value-of select="player[2]/balance"/>)
                                                                    </xsl:if>
                                                                    <xsl:if test="not(player[2])">
                                                                        <text id="free">Free</text>
                                                                    </xsl:if>  
                                                                </a>
                                                            </td>
                                                            <td>
                                                                <a href="/bjx/games/{@id}">
                                                                    <xsl:if test="player[3]">
                                                                        <xsl:value-of select="player[3]/@name"/>(<xsl:value-of select="player[3]/balance"/>)
                                                                    </xsl:if>
                                                                    <xsl:if test="not(player[3])">
                                                                        <text id="free">Free</text>
                                                                    </xsl:if>  
                                                                </a>
                                                            </td>
                                                            <td>
                                                                <a href="/bjx/games/{@id}">
                                                                    <xsl:if test="player[4]">
                                                                        <xsl:value-of select="player[4]/@name"/>(<xsl:value-of select="player[4]/balance"/>)
                                                                    </xsl:if>
                                                                    <xsl:if test="not(player[4])">
                                                                        <text id="free">Free</text>
                                                                    </xsl:if>  
                                                                </a>
                                                            </td>
                                                            <td>
                                                                <a href="/bjx/games/{@id}">
                                                                    <xsl:if test="player[5]">
                                                                        <xsl:value-of select="player[5]/@name"/>(<xsl:value-of select="player[5]/balance"/>)
                                                                    </xsl:if>
                                                                    <xsl:if test="not(player[5])">
                                                                        <text id="free">Free</text>
                                                                    </xsl:if>  
                                                                </a>
                                                            </td>
                                                            <td>
                                                                <a href="/bjx/games/{@id}">
                                                                </a>
                                                            </td>
                                                        </tr>
                                                    </xsl:for-each>
                                                </tbody>
                                            </table>
                                        </div>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            
                            <xsl:when test="$screen = 'highscores'">
                                <div class="menutable">
                                    <table id="highscore-table">
                                        <thead class="thead-light">
                                            <tr>
                                                <th scope="col">Name</th>
                                                <th scope="col">Balance</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <xsl:for-each select="games/game/player">
                                                <xsl:sort select="balance" data-type="number" order="descending" />
                                                <tr>
                                                    <td>
                                                        <xsl:choose>
                                                            <xsl:when test="position() = 1">
                                                                &#x1F947; &#xa0;
                                                            </xsl:when>
                                                            <xsl:when test="position() = 2">
                                                                &#x1f948; &#xa0;
                                                            </xsl:when>
                                                            <xsl:when test="position() = 3">
                                                                &#x1f949; &#xa0;
                                                            </xsl:when>
                                                            <xsl:otherwise><xsl:value-of select="concat(position(), '. &#xa0;')" /></xsl:otherwise>
                                                        </xsl:choose>
                                                        <xsl:value-of select="@name" /> (Game <xsl:value-of select="../@id" />) </td>
                                                    <td>
                                                        <xsl:value-of select="balance" />
                                                    </td>
                                                </tr>
                                            </xsl:for-each>
                                        </tbody>
                                    </table>
                                </div>
                            </xsl:when>
                        </xsl:choose>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>