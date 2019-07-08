<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">

	<xsl:param name="playerID"/>

    <xsl:template match="/">
    	<svg width="85%" height="90%" version="1.1" viewBox="0 0 1200 1200" preserveAspectRatio="xMinYMin"  xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
            <!-- Defines variables for screen sizes, margins and grid size and calculate parameters to draw the grid and background -->
            <xsl:include href="ttt_global_variables.xsl" />
            
            <!-- Define variables from the model -->
            <xsl:variable name="gameID" select="TicTacToe/gameID"/>
    		<xsl:variable name="activePlayer" select="TicTacToe/Players/Player[@id = $playerID]"/>
    		<xsl:variable name="otherPlayer" select="TicTacToe/Players/Player[@id != $playerID]"/>
    		<xsl:variable name="playerTurn" select="TicTacToe/playerTurn"/>
            <xsl:variable name="winner" select="TicTacToe/winner"/>

    		<!-- Draw the background for the game -->     		
    		<rect id = "background" class = "backgroundStyle" x="{$gameLeftMargin}%" y="{$gameTopMargin}%" width="{$gridTotalWidth}%" height="{$gridTotalHeight}%"/>

            <!-- Draw the grid lines with the calculated values -->
    		<line id = "gridLeftVerticalLine" class = "gridLineStyle" x1="{$gameLeftMargin + $gridSideMargin + $gridLineBoxLength}%" y1="{$y1VerticalLine}%" x2="{$gameLeftMargin + $gridSideMargin + $gridLineBoxLength}%" y2="{$y2VerticalLine}%"/>   	
            <line id = "gridRightVerticalLine" class = "gridLineStyle" x1="{$gameLeftMargin + $gridSideMargin + $gridLineBoxLength * 2}%" y1="{$y1VerticalLine}%" x2="{$gameLeftMargin + $gridSideMargin + $gridLineBoxLength * 2}%" y2="{$y2VerticalLine}%" />   			
    		<line id = "gridTopHorizontalLine" class = "gridLineStyle" x1="{$x1HorizontalLine}%" y1="{$gameTopMargin + $gridSideMargin + $gridLineBoxLength}%" x2="{$x2HorizontalLine}%" y2="{$gameTopMargin + $gridSideMargin + $gridLineBoxLength}%"/>
    		<line id = "gridBottomHorizontalLine" class = "gridLineStyle" x1="{$x1HorizontalLine}%" y1="{$gameTopMargin + $gridSideMargin + $gridLineBoxLength * 2}%" x2="{$x2HorizontalLine}%" y2="{$gameTopMargin + $gridSideMargin + $gridLineBoxLength * 2}%"/>

            <!-- Draw player phase and Won / lost screen -->
            <xsl:choose>    				
                <xsl:when test="$playerID = $playerTurn and $winner = 'none'">            				
                        <text class = "textStyle" x="{$gameLeftMargin + $gridTotalWidth div 2}%" y="{$gameTopMargin + $gridSideMargin div 2}%" 
                        dominant-baseline="middle" text-anchor="middle">Your turn!</text>						
                </xsl:when>      				
                <xsl:when test="$otherPlayer/@id = $playerTurn and $winner = 'none'"> 
                        <text class = "textStyle" x="{$gameLeftMargin + $gridTotalWidth div 2}%" y="{$gameTopMargin + $gridSideMargin div 2}%" 
                        dominant-baseline="middle" text-anchor="middle">Waiting...</text>	
                </xsl:when>
                 <xsl:when test="$activePlayer/@id = $winner"> 
                        <text class = "textStyle" x="{$gameLeftMargin + $gridTotalWidth div 2}%" y="{$gameTopMargin + $gridSideMargin div 3}%" 
                        dominant-baseline="middle" text-anchor="middle">You won!</text>
                        <foreignObject width="100%" height="100%" x="{$gameLeftMargin + $gridTotalWidth div 2 - 12}%" y="{$gameTopMargin + $gridSideMargin div 3 + 4}%">
                            <form xmlns="http://www.w3.org/1999/xhtml" action="/ttt/newRound" method="POST" id="formNewRound" target="hiddenFrame">
                                <button class = "textMediumStyle newRoundButton" type="submit" form="formNewRound" value="Submit">New round</button>
                            </form>
                        </foreignObject>	
                </xsl:when>
                <xsl:when test="$winner = 'tie'"> 
                        <text class = "textStyle" x="{$gameLeftMargin + $gridTotalWidth div 2}%" y="{$gameTopMargin + $gridSideMargin div 3}%" 
                        dominant-baseline="middle" text-anchor="middle">Tie!</text>
                        <foreignObject width="100%" height="100%" x="{$gameLeftMargin + $gridTotalWidth div 2 - 12}%" y="{$gameTopMargin + $gridSideMargin div 3 + 4}%">
                            <form xmlns="http://www.w3.org/1999/xhtml" action="/ttt/newRound" method="POST" id="formNewRound" target="hiddenFrame">
                                <button class = "textMediumStyle newRoundButton" type="submit" form="formNewRound" value="Submit">New round</button>
                            </form>
                        </foreignObject>	
                </xsl:when>
                <xsl:otherwise>
                        <text class = "textStyle" x="{$gameLeftMargin + $gridTotalWidth div 2}%" y="{$gameTopMargin + $gridSideMargin div 3}%" 
                        dominant-baseline="middle" text-anchor="middle">You lost...</text>	
                        <foreignObject width="100%" height="100%" x="{$gameLeftMargin + $gridTotalWidth div 2 - 12}%" y="{$gameTopMargin + $gridSideMargin div 3 + 4}%">
                            <form xmlns="http://www.w3.org/1999/xhtml" action="/ttt/newRound" method="POST" id="formNewRound" target="hiddenFrame">
                                <button class = "textMediumStyle newRoundButton" type="submit" form="formNewRound" value="Submit">New round</button>
                            </form>
                        </foreignObject>	
                </xsl:otherwise>
    		</xsl:choose>	

            <!-- Draw Playing as -->
             <xsl:if test="$winner = 'none'">
                <text class = "textSmallStyle" x="{$gameLeftMargin + $gridTotalWidth div 2}%" y="{$gameTopMargin + $gridSideMargin div 2 + 5}%" 
                    dominant-baseline="middle" text-anchor="middle">Playing as&#160;<xsl:value-of select="$playerID"/></text>	
            </xsl:if>

            <!-- Draw scores -->                        
            <text class = "textLargeStyle" x="{$gameLeftMargin + $gridTotalWidth div 2}%" y="{$gameTopMargin + $gridSideMargin + $gridLineBoxLength * 3 + $gridSideMargin div 2}%"  
                        dominant-baseline="middle" text-anchor="middle"><xsl:value-of select="$activePlayer/score"/>&#160;:&#160;<xsl:value-of select="$otherPlayer/score"/></text>	

            <!-- Draw fields -->
            <xsl:for-each select="TicTacToe/Players/Player[@id ='O']/Fields/Field | TicTacToe/Players/Player[@id ='X']/Fields/Field | TicTacToe/Free/Fields/Field">
    			<xsl:variable name="id" select="@id"/>
                <!-- Calculate x coordinate -->
    			<xsl:variable name="x">  		
                    <xsl:choose>
        				<xsl:when test="$id mod 3 = 0">    
                            <xsl:value-of select="$gameLeftMargin + $gridSideMargin + $gridLineBoxLength div 2 + $gridLineBoxLength * 2" />        					
        				</xsl:when>      
                        <xsl:when test="$id mod 3 = 1">      
                            <xsl:value-of select="$gameLeftMargin + $gridSideMargin + $gridLineBoxLength div 2" />  		
        				</xsl:when> 				
        				<xsl:otherwise> 
                            <xsl:value-of select="$gameLeftMargin + $gridSideMargin + $gridLineBoxLength div 2 + $gridLineBoxLength" />
        				</xsl:otherwise>
        			</xsl:choose>	 
                </xsl:variable>
                <!-- Calculate y coordinate -->
                <xsl:variable name="y">  		
                    <xsl:choose>
        				<xsl:when test="$id &lt;= 3">
                            <xsl:value-of select="$gameTopMargin + $gridSideMargin + $gridLineBoxLength div 2" />        					
        				</xsl:when>      
                        <xsl:when test="$id &gt;=3 and $id &lt; 7">      
                            <xsl:value-of select="$gameTopMargin + $gridSideMargin + $gridLineBoxLength div 2 + $gridLineBoxLength" />  		
        				</xsl:when> 				
        				<xsl:otherwise> 
                            <xsl:value-of select="$gameTopMargin + $gridSideMargin + $gridLineBoxLength div 2 + $gridLineBoxLength * 2" />
        				</xsl:otherwise>
        			</xsl:choose>	 
                </xsl:variable>
                <!-- Draw O, X or a link when the field is free based on the calculated coordinates -->
                <xsl:choose>
        				<xsl:when test="./../../self::*[@id ='O']">    
                            <circle cx = "{$x}%" cy = "{$y}%" r="{($gridLineBoxLength div 2) * $oSize}%" stroke="white" stroke-width="14" fill="none" stroke-opacity = "1"/>    					
        				</xsl:when>      	
                        <xsl:when test="./../../self::*[@id ='X']">  
                            <xsl:variable name="halfDiagonal" select="(($gridLineBoxLength div 1.41421) div 2) * $xSize" /> <!-- 1.41421 is the SQRT of 2 -->
                            <line x1="{$x - $halfDiagonal}%" y1="{$y - $halfDiagonal}%" x2="{$x + $halfDiagonal}%" y2="{$y + $halfDiagonal}%" stroke-opacity = "1" style="stroke:rgb(255,255,255);stroke-width:14" />
                            <line x1="{$x + $halfDiagonal}%" y1="{$y - $halfDiagonal}%" x2="{$x - $halfDiagonal}%" y2="{$y + $halfDiagonal}%" stroke-opacity = "1" style="stroke:rgb(255,255,255);stroke-width:14" />					
        				</xsl:when>   		
        				<xsl:otherwise>
                            <xsl:if test="$playerID = $playerTurn and $winner = 'none'">            				
                                <xsl:variable name="executeTurnLink" select="concat('/ttt/processTurn/', $id)" />        				
                                <foreignObject width="{$gridLineBoxLength}%" height="{$gridLineBoxLength}%" x="{$x - $gridLineBoxLength div 2}%" y="{$y - $gridLineBoxLength div 2}%" >		
                                    <!-- IMPORTANT: Target the hidden iFrame to throw away the http response! -->
                                    <form xmlns="http://www.w3.org/1999/xhtml" action="{$executeTurnLink}" method="POST" target="hiddenFrame">  
                                        <input type="image" name="submit" src="/static/tictactoe/SVG/Invisible_Square.svg" width="100%" height="200%"></input> 
                                    </form> 	
                                </foreignObject>    
                                <xsl:value-of select="$gameLeftMargin + $gridSideMargin + $gridLineBoxLength div 2 + $gridLineBoxLength" />
                            </xsl:if>
        				</xsl:otherwise>
        		</xsl:choose>	 
                		
    		</xsl:for-each>

            <!-- Exit button -->
            <a href = "/ttt/start">
    		    <text class = "textMediumStyle" x="{$gameLeftMargin + $gridTotalWidth - 9}%" y="{$gameTopMargin + 7}%">x</text>
            </a>
    
            <!-- Invisible iframe to throw away results of POST request -->
            <foreignObject width="0" height="0">
                <iframe class = "hiddenFrame" xmlns = "http://www.w3.org/1999/xhtml" name="hiddenFrame"></iframe>
            </foreignObject>
        </svg>
    </xsl:template>
</xsl:stylesheet>