<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="1.0">

    <!-- Without (incorrect) output declaration, basex complains because some tags (including link and input) are not closed by the xslt processor -->
    <xsl:output method="xml" omit-xml-declaration="yes"/>

    <xsl:template match="/">
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="/static/blackjack/CSS/style.css"/>
            </head>
            <div class="navbar">
                <a href="/blackjack"><button class="menu">&lt; Menu</button></a>
            </div>
            <body>
                <xsl:choose>
                    <xsl:when test="data/screen/text() = 'games'">
                        <table id="games-table" >
                            <thead >
                                <tr>
                                    <th scope="col">Game ID</th>
                                    <th scope="col">Player 1 (Balance)</th>
                                    <th scope="col">Player 2 (Balance)</th>
                                    <th scope="col">Player 3 (Balance)</th>
                                    <th scope="col">Player 4 (Balance)</th>
                                    <th scope="col">Player 5 (Balance)</th>
									<th scope="col"></th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each select="data/games/game">
                                    <tr>
                                        <td>
                                            <a href="/blackjack/{@id}"><xsl:value-of select="@id"/></a>
                                        </td>

                                        <td>
                                            <a href="/blackjack/{@id}">
                                                <xsl:if test="player[1]">
                                                    <xsl:value-of select="player[1]/@name"/>(<xsl:value-of select="player[1]/balance"/>)
                                                </xsl:if>
                                                <xsl:if test="not(player[1])">
                                                    -
                                                </xsl:if>  
                                            </a>
                                        </td>
                                        <td>
                                            <a href="/blackjack/{@id}">
                                                <xsl:if test="player[2]">
                                                    <xsl:value-of select="player[2]/@name"/>(<xsl:value-of select="player[2]/balance"/>)
                                                </xsl:if>
                                                <xsl:if test="not(player[2])">
                                                    -
                                                </xsl:if>  
                                            </a>
                                        </td>
                                        <td>
                                            <a href="/blackjack/{@id}">
                                                <xsl:if test="player[3]">
                                                    <xsl:value-of select="player[3]/@name"/>(<xsl:value-of select="player[3]/balance"/>)
                                                </xsl:if>
                                                <xsl:if test="not(player[3])">
                                                    -
                                                </xsl:if>  
                                            </a>
                                        </td>
                                        <td>
                                            <a href="/blackjack/{@id}">
                                                <xsl:if test="player[4]">
                                                    <xsl:value-of select="player[4]/@name"/>(<xsl:value-of select="player[4]/balance"/>)
                                                </xsl:if>
                                                <xsl:if test="not(player[4])">
                                                    -
                                                </xsl:if>  
                                            </a>
                                        </td>
                                        <td>
                                            <a href="/blackjack/{@id}">
                                                <xsl:if test="player[5]">
                                                    <xsl:value-of select="player[5]/@name"/>(<xsl:value-of select="player[5]/balance"/>)
                                                </xsl:if>
                                                <xsl:if test="not(player[5])">
                                                    -
                                                </xsl:if>  
                                            </a>
                                        </td>
										<td>
										<div>
											<a href="/blackjack/{@id}/delete">
											<button class="delete">Delete</button></a>
										</div>
										</td>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table>
                    </xsl:when>
                    <xsl:when test="data/screen/text() = 'highscores'">
                        <table id="highscore-table">
                            <thead>
                                <tr>
                                    <th scope="col">Name</th>
                                    <th scope="col">Balance</th>
                                    <th scope="col">#</th>
                                </tr>
                            </thead>
                            <tbody>
                                <xsl:for-each select="data/games/game/player">
                                    <xsl:sort select="balance" data-type="number" order="descending"/>
                                    <tr>
                                        <td>
                                            <xsl:value-of select="@name"/>
                                        </td>
                                        <td>
                                            <xsl:value-of select="balance"/>
                                        </td>
                                        <td><xsl:value-of select="../@id"/>-<xsl:value-of
                                                select="@id"/>
                                        </td>
                                    </tr>
                                </xsl:for-each>
                            </tbody>
                        </table>
                    </xsl:when>
                </xsl:choose> 
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
