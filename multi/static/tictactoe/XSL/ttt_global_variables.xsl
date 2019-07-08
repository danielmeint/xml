<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:variable name="screenTotalWidth" select="100"/>
    <xsl:variable name="screenTotalHeight" select="100"/>

    <xsl:variable name="gameLeftMargin" select="5"/>
    <xsl:variable name="gameTopMargin" select="5"/>

    <xsl:variable name="gridLineTotalLength" select="60"/>
    <xsl:variable name="oSize" select="0.7"/>
    <xsl:variable name="xSize" select="0.85"/>

    <xsl:variable name="gridTotalWidth" select="$screenTotalWidth - $gameLeftMargin"/>
    <xsl:variable name="gridTotalHeight" select="$screenTotalHeight - $gameTopMargin"/>

    <xsl:variable name="gridLineTotalLengthScaled" select="$gridTotalWidth * ($gridLineTotalLength * 0.01)"/>
    <xsl:variable name="gridLineBoxLength" select="$gridLineTotalLengthScaled div 3"/>
    <xsl:variable name="gridSideMargin" select="($gridTotalWidth - $gridLineTotalLengthScaled) div 2"/>

    <xsl:variable name="x1HorizontalLine" select="$gameLeftMargin + $gridSideMargin"/>
    <xsl:variable name="x2HorizontalLine" select="$gameLeftMargin + $gridSideMargin + $gridLineTotalLengthScaled"/>

    <xsl:variable name="y1VerticalLine" select="$gameTopMargin + $gridSideMargin"/>
    <xsl:variable name="y2VerticalLine" select="$gameTopMargin + $gridSideMargin + $gridLineTotalLengthScaled"/>
</xsl:stylesheet>