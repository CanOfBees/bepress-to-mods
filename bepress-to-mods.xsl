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
				* proc-path: this simplifies the XPath statements when we're structuring our MODS result documents
			-->
			<xsl:variable name="input-file-tokens" select="tokenize(document-uri(.), '/')"/>
			<xsl:variable name="input-file-parent-directory" select="replace(replace(document-uri(.), 'metadata.xml$', ''), '^file:', '')"/>
			<xsl:variable name="proc-path" select="/documents/document"/>
			
			<!-- serialize a document for each match in $input-collection -->
			<xsl:result-document href="{concat($input-file-parent-directory, 'MODS.xml')}">
				<mods xmlns="http://www.loc.gov/mods/v3" version="3.5" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
					<xsl:apply-templates select="$proc-path/title"/>
					<xsl:apply-templates select="$proc-path/submission-path"/>
				</mods>
			</xsl:result-document>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="title">
		<title>
			<titleInfo><xsl:apply-templates/></titleInfo>
		</title>
	</xsl:template>

	<xsl:template match="submission-path">
		<identifier type="local">
			<xsl:apply-templates/>
		</identifier>
	</xsl:template>

</xsl:stylesheet>