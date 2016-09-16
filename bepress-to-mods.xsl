<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.og/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="http://www.loc.gov/mods/v3"
	exclude-result-prefixes="#all"
	version="2.0">

	<xsl:output encoding="UTF-8" indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>

	<xsl:template name="main">
		<!-- input-collection: recurse through a directory for all metadata.xml files -->
		<xsl:variable name="input-collection" select="collection('sample-data/?select=metadata.xml;recurse=yes')"/>
		
		<!-- for each file in input-collection, do... -->
		<xsl:for-each select="$input-collection">
			<!-- 
				set up the following variables for each file: 
				* input-file-tokens
				* input-file-parent-directory
			-->
			<xsl:variable name="input-file-tokens" select="tokenize(document-uri(.), '/')"/>
			<xsl:variable name="input-file-parent-directory" select="replace(replace(document-uri(.), 'metadata.xml$', ''), '^file:', '')"/>
			
			<!-- serialize a document for each match in $input-collection -->
			<xsl:result-document href="{concat($input-file-parent-directory, 'MODS.xml')}">
				<mods>
					<title>test</title>
					<identifier><xsl:value-of select="/documents/document/authors/author/email"/></identifier>
				</mods>
			</xsl:result-document>
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