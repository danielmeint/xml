<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:param name="name"/>
    
    <xsl:variable name="self" select="/game/player[@name = $name]"/>
    <xsl:variable name="selfBalance" select="/game/player[@name = $name]/balance"/>
    <xsl:variable name="activePlayer" select="/game/player[@state = 'active']"/>
	<xsl:variable name="activePlayerHandValue" select="/game/player[@state = 'active']/hand/@value"/>
    
    <xsl:variable name="activePlayerBet" select="/game/player[@state = 'active']/bet"/>
    <xsl:variable name="activePlayerBalance" select="/game/player[@state = 'active']/balance"/>
    <xsl:variable name="dealerCard" select="/game/dealer/hand/card[1]/@value"/>
    <xsl:variable name="isInsurance" select="/game/player[@state = 'active']/@insurance"/>


    <xsl:template match="/">

        <div id="game">
            <div class="container flex-container">
                <svg viewBox="-100 0 1000 620">
                    <!-- table dimensions: 800 x 450 -->
                    <use href="/static/xforms-static/svg/table.svg#table" x="0" y="0"/>
                    <g id="dealer">
                        <g class="card_group">
                            <xsl:choose>
                                <xsl:when test="game/@state = 'playing'">
                                    <!-- only show the dealer's first card -->
                                    <use
                                        href="/static/xforms-static/svg/cards.svg#{game/dealer/hand/card[1]/@value}_{game/dealer/hand/card[1]/@suit}"/>
                                    <use href="/static/xforms-static/svg/cards.svg#back"
                                        style="transform: translate(20px, 4px)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="game/dealer/hand/card">
                                        <use href="/static/xforms-static/svg/cards.svg#{@value}_{@suit}"
                                            style="transform: translate({(position() - 1) * 20}px, {(position() - 1) * 4}px)"
                                        />
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </g>
			<xsl:if test="/game/dealer/hand/card[1]/@value > 0">
                        <g class="label label-hand">
                            <rect x="10px" y="70px" rx="15" ry="15" width="80" height="50"/>
                            <text class="name" x="30px" y="85px">
                                Dealer
                            </text>
                            <text class="hand_value" x="30px" y="115px" xmlns="http://www.w3.org/2000/svg">
                                <xsl:choose>
                                    <xsl:when test="/game/@state = 'playing'">
                                        <!-- only show value of the visible card -->
                                        <xsl:value-of select="/game/dealer/hand/card[1]/@value"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="/game/dealer/hand/@value"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                            </text>
                        </g>
                        </xsl:if>
                    </g>
                    <g id="player_cards">
                        <xsl:for-each select="/game/player">
                            <g id="player_{position()}_of_{count(/game/player)}">
                                <xsl:if test="@state = 'active'">
                                    <xsl:attribute name="class">active</xsl:attribute>
                                </xsl:if>
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
                                        <use href="/static/xforms-static/svg/chips.svg#chip" width="50" height="50"/>
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
                                            <use href="/static/xforms-static/svg/chips.svg#chip" width="40" height="40" transform="translate(40, -30)"/>
                                            <text x="20" y="20" alignment-baseline="central" transform="translate(40, -30)">
                                                <xsl:value-of select="ceiling(bet div 2)"/>
                                            </text>
                                        </g>
                                    </xsl:if>
                                </xsl:if>
                                <g class="card_group">
                                    <xsl:for-each select="hand/card">
                                        <use href="/static/xforms-static/svg/cards.svg#{@value}_{@suit}"
                                            style="transform: translate({(position() - 1) * 20}px, {(position() - 1) * 4}px)"
                                        />
                                    </xsl:for-each>
                                </g>
                                <xsl:if test="hand/@value > 0">
                                <g>
                                  <xsl:attribute name="class">label label-hand</xsl:attribute>
                                  
								 <rect x="10px" y="110px" rx="15" ry="15" width="{string-length(@name)*5 + 60}px"  height="65"/>
								<text class="name" x="27px" y="125px">
									<xsl:value-of select="@name"/>
								</text>
								<text class="hand_value" x="27px" y="170px" xmlns="http://www.w3.org/2000/svg">
									<xsl:value-of select="hand/@value"/>
								</text>
								<text class="balance" x="27px" y="142px" xmlns="http://www.w3.org/2000/svg">
									$<xsl:choose>
									    <xsl:when test="/game/@state = 'evaluated'">
									        <xsl:value-of select="balance"/>
									    </xsl:when>
									    <xsl:otherwise>
									        <xsl:value-of select="balance - bet"/>
									    </xsl:otherwise>
									</xsl:choose>
								</text> 
                                </g>
                                </xsl:if>
                            </g>
                        </xsl:for-each>
                    </g>
                </svg>
                <div class="functions">
                    <xsl:choose>
                        <xsl:when test="$self">
                            <!-- client is participating in the game -->
                            <form class="top left" action="/xforms-multiclient/games/{/game/@id}/leave" method="post" target="hiddenFrame">
                                <button class="btn btn-secondary" type="submit">
                                    Leave
                                </button>
                            </form>
                            <xsl:choose>
                                <xsl:when test="(/game/@state = 'betting' or /game/@state = 'playing') and $self/@state = 'inactive'">
                                    <!-- Player is inactive -->
                            <div class="lds-ellipsis"><div></div><div></div><div></div><div></div></div>
                                </xsl:when>
                                
                                <xsl:when test="/game/@state = 'betting' and $self/@state = 'active'">
                                    <!-- Betting stage -->
                                    <div class="dialog animation" id="shadow">
                                    <div class="dialog--header">
                                        Place your bets!
                                    </div>
                                    <div class="dialog--betting">
                                    <form class="join" action="/xforms-multiclient/games/{/game/@id}/bet" method="POST" target="hiddenFrame">
                                        <div class="input--advanced">
                                        <input class="betting" type="number" name="bet" min="1" max="{$self/balance}" required=""/>
                                        <label id="balance">
											&#x1F4B0;
										<xsl:value-of select="$self/balance"/>
										</label>
                                        </div>
										<button type="submit">
                                            Bet
                                        </button>
                                    </form>
                                    </div>
                                    </div>
                                </xsl:when>

                                <xsl:when test="/game/@state = 'playing' and $self/@state = 'active'">
                                    <!-- Playing stage -->
									<div class="dialog" id="buttongroup">
									<div class="dialog--header">
									<xsl:value-of select="game/player[@state = 'active']/@name"/>
									</div>
									<div class="buttongroup">
									    <div>
									    <form action="/xforms-multiclient/games/{/game/@id}/stand" method="POST" target="hiddenFrame">
									        <button class="stand" type="submit">Stand</button>
									    </form>
									    </div>
									    <div>
									    <xsl:if test="$self/hand/@value &lt; 21">
									        <form action="/xforms-multiclient/games/{/game/@id}/hit" method="POST" target="hiddenFrame">
									            <button class="hit" type="submit">Hit</button>
									        </form>
									    </xsl:if>
									    </div>
									   <div>						
                                            <xsl:if test="count($self/hand/card) &lt; 3 and $self/@insurance='false' and $self/hand/@value &lt; 21 and $self/balance &gt;= $self/bet * 2">
                                                <form action="/xforms-multiclient/games/{/game/@id}/double" method="POST" target="hiddenFrame">
                                                    <button class="double" type="submit">Double</button>
                                                </form>
                                            </xsl:if>
									   </div>
							           <div>									       
   									     <xsl:choose>
                                                <xsl:when test="$activePlayerBet * 1.5 &gt; $activePlayerBalance or $dealerCard!='A' or $isInsurance='true'">
                                                </xsl:when>
                                                <xsl:otherwise>
                                                   <form action="/xforms-multiclient/games/{/game/@id}/insurance" method="POST" target="hiddenFrame">
                                                       <button class="insurance" type="submit">Insurance</button>
                                                   </form>
                                                </xsl:otherwise>
                                            </xsl:choose>									                                                    
									   </div>
									</div>
								</div>
                                </xsl:when>
                                <xsl:when test="/game/@state = 'evaluated'">
                                    <div class="dialog" id="shadow">
                                        <div class="dialog--header">
                                            <xsl:choose>
                                                <xsl:when test="$self/@state = 'won'">
                                                    <a id="win">
                                                        You won +<xsl:value-of select="$self/profit"/>!
                                                    </a>
                                                </xsl:when>
                                                <xsl:when test="$self/@state = 'lost'">
                                                    <a id="lose">
                                                        You lost -<xsl:value-of select="$self/profit *-1"/>!
                                                    </a>
                                                </xsl:when>
                                                <xsl:when test="$self/@state = 'tied'">
                                                    <a id="tie">
                                                        You tied!
                                                    </a>
                                                </xsl:when>
                                            </xsl:choose>
                                        </div>
                                        <form action="/xforms-multiclient/games/{/game/@id}/newRound" method="POST" target="hiddenFrame">
                                            <button class="btn" type="submit">New Round</button>
                                        </form>
                                    </div>                             
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- client is not participating, spectator mode -->
                            <div class="dialog" id="shadow">
                            <div class="dialog--header">
                            Spectating mode
                            </div>
                            <a href="/xforms-multiclient"><button>◀ Leave</button></a>
                                <xsl:choose>
                                    <xsl:when test="false">
                                        <!--test="game/player[@state = 'active']/balance = 0"> -->
                                        <button id="disabled" type='submit'>no balance/></button>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <form class="join" action='/xforms-multiclient/games/{/game/@id}/join' method='POST' target="hiddenFrame">
                                            <button type='submit'>join</button>
                                        </form>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                    <div class="dialog chat">
                        <input type="checkbox" id="chatToggle"/>
                        <label id="hideChat" for="chatToggle">
                            <svg>
                                <use href="/static/xforms-static/svg/solid.svg#times"/>
                            </svg>
                        </label>
                        <label class="bottom left" id="showChat" for="chatToggle">
                            <svg>
                                <use href="/static/xforms-static/svg/solid.svg#comments"/>
                            </svg>
                        </label>
                        <table>
                            <xsl:for-each select="/game/chat/message">
                                <tr>
                                    <xsl:choose>
                                        <xsl:when test="@author = 'INFO'">
                                            <td colspan="2" class="msg msg-info">
                                                <xsl:value-of select="text()"/>
                                            </td>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <td class="author">
                                                <xsl:value-of select="@author"/>
                                            </td>
                                            <td class="msg">
                                                <xsl:value-of select="text()"/>
                                            </td>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </tr>
                            </xsl:for-each>
                        </table>
                        <form class ="join" action="/xforms-multiclient/games/{/game/@id}/chat" method="POST" target="hiddenFrame">
                            <input type="text" name="msg" placeholder="Chatting as {$name}" required=""/>
                            <button class="btn" type="submit">►</button>
                        </form>
                    </div>
                </div>
                <iframe class="hidden" name="hiddenFrame"/>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>