<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:template match="/">
        <html>
            <head>
                <title>XForms' BlackJack</title>
                <link rel="stylesheet" type="text/css" href="assets/style.css"/>
            </head>
            <body>
                <div class="container">
                    <svg viewBox="0 0 800 520">
                        <!-- table dimensions: 800 x 450 -->
                        <use href="assets/table.svg#table" x="0" y="0"/>
                        <g id="player_cards">
                            <xsl:for-each select="game/player">
                                <g class="card_group"
                                    id="player_{position()}_of_{count(/game/player)}">
                                    <xsl:for-each select="cards/card">
                                        <use
                                            href="assets/cards.svg#{attribute::value}_{attribute::suit}"
                                        />
                                    </xsl:for-each>
                                </g>
                            </xsl:for-each>
                        </g>
                    </svg>
                    <p><xsl:value-of select="count(game/player)"/> Players</p>
                    <div class="button_group">
                        <button class="btn btn-stand">Stand</button>
                        <button class="btn btn-hit">Hit</button>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
