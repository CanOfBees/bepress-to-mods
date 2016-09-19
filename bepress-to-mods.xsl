<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.og/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:etd="http://www.ndltd.org/standards/metadata/etdms/1.1"
	xmlns:file="http://expath.org/spec/file"
	xmlns="http://www.loc.gov/mods/v3"
	exclude-result-prefixes="#all" version="2.0">

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
		<xsl:variable name="input-collection"
			select="collection('sample-data/?select=metadata.xml;recurse=yes')"/>

		<!-- for each file in input-collection, do... -->
		<xsl:for-each select="$input-collection">
			<!-- 
				set up the following variables for each file: 
				* input-file-tokens: tokenized document uri, using '/'
				* input-file-parent-directory: the parent directory of the context 'metadata.xml'
				* xp: abbreviated xpath @TODO maybe not?
			-->
			<xsl:variable name="input-file-tokens" select="tokenize(document-uri(.), '/')"/>
			<xsl:variable name="input-file-parent-directory"
				select="replace(replace(document-uri(.), 'metadata.xml$', ''), '^file:', '')"/>


			<!-- serialize a document for each match in $input-collection -->
			<xsl:result-document href="{concat($input-file-parent-directory, 'MODS.xml')}">
				<mods xmlns:xlink="http://www.w3.org/1999/xlink"
					xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3"
					version="3.5"
					xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
					<xsl:apply-templates>
						<xsl:with-param name="i-f-p-d" select="$input-file-parent-directory"/>
					</xsl:apply-templates>
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
		<titleInfo>
			<title>
				<xsl:apply-templates/>
			</title>
		</titleInfo>
	</xsl:template>

	<xsl:template match="publication-date">
		<originInfo>
			<dateIssued keyDate="yes">
				<xsl:value-of select="substring-before(., 'T')"/>
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
			<xsl:if test="../withdrawn">
				<recordChangeDate keyDate="yes">
					<xsl:value-of select="../withdrawn"/>
				</recordChangeDate>
			</xsl:if>
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
			<namePart type="family">
				<xsl:value-of select="lname"/>
			</namePart>
			<namePart type="given">
				<xsl:value-of select="fname"/>
			</namePart>
			<xsl:if test="suffix">
				<namePart type="termsOfAddress">
					<xsl:value-of select="suffix"/>
				</namePart>
			</xsl:if>
			<role>
				<roleTerm type="text" authority="marcrelator"
					valueURI="http://id.loc.gov/vocabulary/relators/aut">Author</roleTerm>
			</role>
		</name>
	</xsl:template>

	<xsl:template match="disciplines">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="discipline">
		<subject>
			<topic>
				<xsl:apply-templates/>
			</topic>
		</subject>
	</xsl:template>

	<xsl:template match="abstract">
		<abstract>
			<xsl:value-of select="normalize-space(replace(., '&lt;p&gt;|&lt;/p&gt;', ''))"/>
		</abstract>
	</xsl:template>

	<xsl:template match="fields">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="field[@name = 'advisor1']">
		<name>
			<displayForm>
				<xsl:value-of select="value"/>
			</displayForm>
			<role>
				<roleTerm type="text" authority="marcrelator"
					valueURI="http://id.loc.gov/vocabulary/relators/ths">Thesis advisor</roleTerm>
			</role>
		</name>
	</xsl:template>

	<xsl:template match="field[@name = 'advisor2']/value">
		<name>
			<displayForm>
				<xsl:apply-templates/>
			</displayForm>
			<role>
				<roleTerm authority="local">Committee Member</roleTerm>
			</role>
		</name>
	</xsl:template>

	<!-- 
		this needs a bit more testing; doesn't accommodate multiple degree_names or departments
  -->
	<xsl:template match="field[@name = 'degree_name']">
		<extension xmlns:etd="http://www.ndltd.org/standards/etdms/1.1">
			<etd:degree>
				<etd:name>
					<xsl:value-of select="value"/>
				</etd:name>
				<etd:discipline>
					<xsl:value-of select="../field[@name = 'department']/value"/>
				</etd:discipline>
				<etd:grantor>University of Tennessee</etd:grantor>
			</etd:degree>
		</extension>
	</xsl:template>

	<!-- 
		ignoring the field[@name='department'] at this level since we're processing it
		in the preceeding template: field[@name='degree_name']; see below
	-->

	<xsl:template match="field[@name = 'comments']/value">
		<note displayLabel="Submitted Comment">
			<xsl:apply-templates/>
		</note>
	</xsl:template>

	<xsl:template match="keywords">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="keyword">
		<note displayLabel="Keywords Submitted by Author">
			<xsl:apply-templates/>
		</note>
	</xsl:template>

	<xsl:template match="supplemental-files">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="file">
		<xsl:param name="i-f-p-d"/>
		<xsl:variable name="supplemental-file-check" select="archive-name"/>

		<xsl:message><xsl:value-of select="$supplemental-file-check"/></xsl:message>
		<xsl:message><xsl:value-of select="$i-f-p-d"/></xsl:message>
		<relatedItem type="constituent">
			<titleInfo>
				<title><xsl:apply-templates select="archive-name"/></title>
			</titleInfo>
			<physicalDescription>
				<internetMediaType><xsl:apply-templates select="mime-type"/></internetMediaType>
			</physicalDescription>
		</relatedItem>
		<xsl:if test="description">
			<abstract><xsl:value-of select="replace(description, '&lt;p&gt;|&lt;/p&gt;', '')"/></abstract>
		</xsl:if>
		
	</xsl:template>

	<!-- ignore the following elements -->
	<xsl:template match="articleid"/>
	<xsl:template match="context-key"/>
	<xsl:template match="coverpage-url"/>
	<xsl:template match="document-type"/>
	<xsl:template match="label"/>
	<xsl:template match="type"/>
	<xsl:template match="fulltext-url"/>
	<xsl:template match="field[@name = 'degree_name']/value"/>
	<xsl:template match="field[@name = 'department']/value"/>

	<!-- temporarily ignore these -->
	<xsl:template match="field[@name = 'instruct']/value"/>
	<xsl:template match="field[@name = 'publication_date']/value"/>
	<xsl:template match="field[@name = 'embargo_date']/value"/>
</xsl:stylesheet>
