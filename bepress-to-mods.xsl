<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.og/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="http://www.loc.gov/mods/v3"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<!-- character map for processing abstract nodes -->
	<xsl:character-map name="cmap">
		<xsl:output-character character="&lt;" string="''"/>
		<xsl:output-character character="p" string="''"/>
		<xsl:output-character character="&gt;" string="''"/>
	</xsl:character-map>
	
	<xsl:output encoding="UTF-8" indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>

	<xsl:template name="main">
		<!-- input-collection: recurse through a directory for all metadata.xml files -->
		<xsl:variable name="input-collection" select="collection('sample-data/?select=metadata.xml;recurse=yes')"/>
		
		<!-- for each file in input-collection, do... -->
		<xsl:for-each select="$input-collection">
			<!-- 
				set up the following variables for each file: 
				* input-file-tokens: tokenized document uri, using '/'
				* input-file-parent-directory: the parent directory of the context 'metadata.xml'
				* xp: abbreviated xpath @TODO maybe not?
			-->
			<xsl:variable name="input-file-tokens" select="tokenize(document-uri(.), '/')"/>
			<xsl:variable name="input-file-parent-directory" select="replace(replace(document-uri(.), 'metadata.xml$', ''), '^file:', '')"/>
			
			<!-- serialize a document for each match in $input-collection -->
			<xsl:result-document href="{concat($input-file-parent-directory, 'MODS.xml')}">
				<mods xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3" version="3.5" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
					<xsl:apply-templates/>
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
	
	<xsl:template match="publication-date">
		<originInfo>
			<dateIssued keyDate="yes">
				<xsl:value-of select="substring-before(.,'T')"/>
			</dateIssued>
		</originInfo>
	</xsl:template>
	
	<xsl:template match="publication-title">
		<relatedItem type="series">
			<titleInfo lang="en">
				<title>
					<xsl:apply-templates/>
				</title>
			</titleInfo>
		</relatedItem>
	</xsl:template>
	
	<xsl:template match="submission-date">
		<recordInfo>
			<recordCreationDate encoding="w3cdtf">
				<xsl:apply-templates/>
			</recordCreationDate>
		</recordInfo>
	</xsl:template>
	
	<xsl:template match="submission-path">
		<identifier type="local">
			<xsl:apply-templates/>
		</identifier>
	</xsl:template>
	
	<xsl:template match="authors">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- do we need a positional? if authors > 1 then maybe...-->
	<xsl:template match="author">
		<name>
			<namePart type="family"><xsl:value-of select="lname"/></namePart>
			<namePart type="given"><xsl:value-of select="fname"/></namePart>
			<role>
				<roleTerm type="text" authority="marcrelator" valueURI="http://id.loc.gov/vocabulary/relators/aut">Author</roleTerm>
			</role>
		</name>
	</xsl:template>
	
	<!-- this needs some work -->
	<xsl:template match="abstract">
		<abstract1>
			<xsl:apply-templates/>
		</abstract1>
		<abstract2>
			
		</abstract2>
	</xsl:template>
	
	<!-- ignore the following elements -->
	<xsl:template match="articleid"/>
	<xsl:template match="context-key"/>
	<xsl:template match="coverpage-url"/>
	<xsl:template match="document-type"/>
	<xsl:template match="label"/>
	<xsl:template match="type"/>
	<xsl:template match="fulltext-url"/>
</xsl:stylesheet>