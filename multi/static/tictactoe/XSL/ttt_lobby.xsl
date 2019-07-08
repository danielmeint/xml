<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:template match="/">
    	<svg width="85%" height="90%" version="1.1" viewBox="0 0 1200 1200" preserveAspectRatio="xMinYMin"  xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
            <!-- Defines variables for screen sizes, margins and grid size and calculate parameters to draw the grid and background -->
            <xsl:include href="ttt_global_variables.xsl" />

            <!-- Define variables from the model -->
    		<xsl:variable name="playerX" select="TicTacToe/Players/Player[@id = 'X']"/>
    		<xsl:variable name="playerO" select="TicTacToe/Players/Player[@id = 'O']"/>
            <xsl:variable name="playerCount" select="TicTacToe/playerCount"/>
    		<xsl:variable name="playerTurn" select="TicTacToe/playerTurn"/>
            <xsl:variable name="winner" select="TicTacToe/winner"/>

    		<!-- Draw the background for the lobby screen -->     		
    		<rect id = "background" class = "backgroundStyle" x="{$gameLeftMargin}%" y="{$gameTopMargin}%" width="{$gridTotalWidth}%" height="{$gridTotalHeight}%"/>

            <!-- Draw game information like score and players ingame -->
            <text class = "textVeryLargeStyle" x="{$gameLeftMargin + $gridTotalWidth div 2}%" y="{$gameTopMargin + $gridSideMargin}%"  
                        dominant-baseline="middle" text-anchor="middle">Tic-Tac-Toe</text>
            <text class = "textLargeStyle" x="{$gameLeftMargin + $gridTotalWidth div 2}%" y="{$gameTopMargin + $gridSideMargin + 10}%"  
                    dominant-baseline="middle" text-anchor="middle">Players&#160;<xsl:value-of select="$playerCount"/>/2</text>
            <text class = "textLargeStyle" x="{$gameLeftMargin + $gridTotalWidth div 2}%" y="{$gameTopMargin + $gridSideMargin + 20}%"  
                    dominant-baseline="middle" text-anchor="middle">Score&#160;<xsl:value-of select="$playerX/score"/>&#160;:&#160;<xsl:value-of select="$playerO/score"/></text>

            <!-- Draw join buttons -->
            <foreignObject width="100%" height="100%" x="{$gameLeftMargin + $gridTotalWidth div 2 - 15}%" y="{$gameTopMargin + $gridSideMargin + 30}%">
                <form xmlns="http://www.w3.org/1999/xhtml" action="/ttt/join/X" method="POST" id="form1" >
                    <button class = "textMediumStyle lobbyButton" type="submit" form="form1" value="Submit">Play as X</button>
                </form>
            </foreignObject>
            <foreignObject width="100%" height="100%" x="{$gameLeftMargin + $gridTotalWidth div 2 - 15}%" y="{$gameTopMargin + $gridSideMargin + 42}%">
                <form xmlns="http://www.w3.org/1999/xhtml" action="/ttt/join/O" method="POST" id="form2" >
                    <button class = "textMediumStyle lobbyButton" type="submit" form="form2" value="Submit">Play as O</button>
                </form>
            </foreignObject>          
        </svg>
    </xsl:template>
</xsl:stylesheet>