<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="1.0">
    <xsl:output indent="no" method="xml" omit-xml-declaration="yes" />
    <xsl:param name="screen" />
    <xsl:param name="name" />
    <xsl:template match="/">
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="/static/bjx/css/style.css" />
            </head>
            <body>
                <span id="login" class="right top">
                    <span><xsl:value-of select="$name"/></span>
                    <a class="btn btn-secondary" href="/bjx/logout">
                        <svg>
                            <use href="/static/bjx/svg/solid.svg#sign-out-alt"/>
                        </svg>
                    </a>
                </span>
                <div class="flex-container flex-center">
                    <div class="content">
                        <xsl:choose>
                            <xsl:when test="$screen = 'menu'">
                                <h1>XForms' Multi-Client Blackjack</h1>
                                <form class="form-menu" action="/bjx/games" method="post">
                                    <input class="btn btn-menu" type="submit" value="New Game" />
                                </form>
                                <form class="form-menu">
                                    <a class="btn btn-menu" href="/bjx/games">Join Game</a>
                                </form>
                                <form class="form-menu">
                                    <a class="btn btn-menu btn-secondary" href="/bjx/highscores">Highscores</a>
                                </form>
                            </xsl:when>
                            
                            
                            <xsl:when test="$screen = 'games'">
                                <a class="btn btn-secondary left top" href="/bjx">◀ Menu</a>
                                <xsl:choose>
                                    <xsl:when test="count(games/game) = 0">
                                        <p>No active games.</p>
                                        <form action="/bjx/games" method="post">
                                            <input class="btn" type="submit" value="Create new Game" />
                                        </form>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <table id="games-table" class="table table-hover information">
                                            <thead class="thead-light">
                                                <tr>
                                                    <th>#</th>
                                                    <th>Players</th>
                                                    <th>State</th>
                                                    <th>
                                                        <form action="/bjx/games" method="post">
                                                            <input class="btn" type="submit" value="+" />
                                                        </form>
                                                    </th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <xsl:for-each select="games/game">
                                                    <tr>
                                                        <td>
                                                            <xsl:value-of select="@id" />
                                                        </td>
                                                        <td>
                                                            <xsl:value-of select="player[1]/@name" />
                                                            <xsl:for-each select="player[position() &gt; 1]">
                                                                ,<xsl:text> </xsl:text><xsl:value-of select="@name" /></xsl:for-each>
                                                        </td>
                                                        <td>
                                                            <xsl:value-of select="player[@state = 'active']/@name" />=<xsl:value-of select="@state" /></td>
                                                        <td>
                                                            <a class="btn btn-secondary" href="/bjx/games/{@id}">Open</a>
                                                            <form action="/bjx/games/{@id}/delete" method="POST">
                                                                <input class="btn btn-danger" type="submit" value="Delete" />
                                                            </form>
                                                        </td>
                                                    </tr>
                                                </xsl:for-each>
                                            </tbody>
                                        </table>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            
                            <xsl:when test="$screen = 'highscores'">
                                <a class="btn btn-secondary left top" href="/bjx">◀ Menu</a>
                                <table id="highscores-table" class="table information">
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
                                                    <xsl:value-of select="@name" /> (Game <xsl:value-of select="../@id" />) </td>
                                                <td>
                                                    <xsl:value-of select="balance" />
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </tbody>
                                </table>
                            </xsl:when>
                        </xsl:choose>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>