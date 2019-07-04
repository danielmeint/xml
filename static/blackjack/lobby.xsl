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
            <a href="/blackjack">
            <div class="navbar">
                <xsl:choose>
                    <xsl:when test="data/screen/text() = 'games'">
                        <button class="menu">&lt; Load Game</button>
                    </xsl:when>
                <xsl:otherwise>
                        <button class="menu">&lt; Highscore</button>
                </xsl:otherwise>
                </xsl:choose>
                    
            </div>
            </a>
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
											<button class="delete" style="color: white">Delete</button></a>
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
