<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.og/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="http://www.loc.gov/mods/v3"
	exclude-result-prefixes="#all"
	version="2.0">

	<xsl:output encoding="UTF-8" indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>

	<xsl:variable name="input-collection" select="collection('./sample-data/?select=metadata.xml;recurse=yes')"/>
	
	<xsl:template match="$input-collection/">
		<xsl:variable name="input-file" select="tokenize(document-uri(.), '/')"/>
		<xsl:variable name="input-file-name" select="$input-file[position() = last()]"/>
		<xsl:variable name="input-file-parent-directory" select="replace(replace(document-uri(.), 'metadata.xml$', ''), '^file:', '')"/>
		<xsl:result-document href=""></xsl:result-document>
	</xsl:template>
	
	<xsl:template name="main">
		<xsl:for-each select="for $f in $input-collection return $f">
			<xsl:variable name="input-file" select="tokenize(document-uri(.), '/')"/>
			<xsl:variable name="input-file-name" select="$input-file[position() = last()]"/>
			<xsl:variable name="input-file-parent-directory" select="replace(replace(document-uri(.), 'metadata.xml$', ''), '^file:', '')"/>
			
			<result-document href="{concat($input-file-parent-directory, 'MODS.xml')}">
				<mods xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3" version="3.5" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
					<xsl:apply-templates/>
				</mods>	
			</result-document>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="/documents">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="document">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="title">
		<title>
			<titleInfo><xsl:apply-templates/></titleInfo>
		</title>
	</xsl:template>
	
</xsl:stylesheet>