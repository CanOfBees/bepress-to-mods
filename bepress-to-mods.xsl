<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.og/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:etd="http://www.ndltd.org/standards/metadata/etdms/1.1"
	xmlns:cob="http://cob.net/fn"
	xmlns:file="http://expath.org/ns/file"
	xmlns="http://www.loc.gov/mods/v3"
	exclude-result-prefixes="#all" version="2.0">

	<xsl:output encoding="UTF-8" indent="yes" method="xml"/>
	<xsl:strip-space elements="*"/>
	
	<!-- includes -->
	<xsl:include href="includes/functions.xsl"/>

	<!-- input-collection: recurse through a directory for all metadata.xml files -->
	<xsl:variable name="input-collection"
								select="collection('sample-data/?select=metadata.xml;recurse=yes')"/>

	<xsl:template name="main">
		<!-- for each file in input-collection, do... -->
		<xsl:for-each select="$input-collection">
			<!-- 
				set up the following variables/parameters for each file: 
				* doc-path: the path to the context 'metadata.xml' file's parent directory
			-->
			<xsl:variable name="doc-path"
										select="replace(replace(document-uri(.), 'metadata.xml$', ''), '^file:', '')"/>

			<!-- serialize a document for each match in $input-collection -->
			<xsl:result-document href="{concat($doc-path, 'MODS.xml')}">
				<mods xmlns:xlink="http://www.w3.org/1999/xlink"
					xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3"
					version="3.5"
					xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
					<xsl:apply-templates select="/documents/document">
						<xsl:with-param name="p-doc-path" select="$doc-path" tunnel="yes"/>
					</xsl:apply-templates>
					<xsl:call-template name="genre-authority"/>
					<xsl:call-template name="record-info"/>
				</mods>
			</xsl:result-document>
		</xsl:for-each>
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
					<xsl:value-of select="cob:escape(.)"/>
				</title>
			</titleInfo>
		</relatedItem>
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
			<xsl:value-of select="cob:escape(.)"/>
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
			<xsl:value-of select="cob:escape(.)"/>
		</note>
	</xsl:template>

	<xsl:template match="keywords">
		<xsl:apply-templates/>
	  <note displayLabel="Keywords Submitted by Author::B">
	    <xsl:value-of select="for $k in (keyword) return string-join($k, ' ')" separator=", "/>
	  </note>
	</xsl:template>

	<xsl:template match="keyword">
		<note displayLabel="Keywords Submitted by Author::A">
			<xsl:apply-templates/>
		</note>
	</xsl:template>

	<xsl:template match="supplemental-files">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="file">
		<xsl:param name="p-doc-path" tunnel="yes"/>
		<xsl:variable name="supplemental-file-list" select="file:list($p-doc-path)"/>
		<xsl:variable name="supplemental-file-name" select="archive-name"/>
		<relatedItem type="constituent">
			<titleInfo>
				<title><xsl:apply-templates select="archive-name"/></title>
			</titleInfo>
			<physicalDescription>
				<internetMediaType><xsl:apply-templates select="mime-type"/></internetMediaType>
			</physicalDescription>
			<xsl:for-each select="$supplemental-file-list">
				<xsl:analyze-string select="." regex="(^\d{{1,}}-)(.*$)">
					<xsl:matching-substring>
						<xsl:if test="matches($supplemental-file-name, regex-group(2))">
							<note displayLabel="supplemental_file">
								<xsl:value-of select="concat('SUPPLE_', substring-before(regex-group(1), '-'))"/>
							</note>
						</xsl:if>
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:for-each>
			<xsl:if test="description">
				<abstract><xsl:value-of select="cob:escape(description)"/></abstract>
			</xsl:if>
		</relatedItem>
	</xsl:template>
	
	<xsl:template name="record-info">
		<recordInfo>
			<recordCreationDate encoding="w3cdtf">
				<xsl:value-of select="submission-date"/>
			</recordCreationDate>
			<recordChangeDate><xsl:value-of select="current-date()"/></recordChangeDate>
			<xsl:if test="/documents/document/withdrawn">
				<recordChangeDate keyDate="yes">
					<xsl:value-of select="/documents/document/withdrawn"/>
				</recordChangeDate>
			<!--
				commenting this for now; throws a validity error
				<recordInfoNote displayLabel="withdrawn">
					<xsl:value-of select="concat('Record withdrawn ', /documents/document/withdrawn)"/>
				</recordInfoNote>
			-->
			</xsl:if>
		</recordInfo>
	</xsl:template>

	<xsl:template name="genre-authority">
		<xsl:if test="/documents/document/submission-path[(starts-with(., 'utk_gradthes')) or (starts-with(., 'utk_graddiss'))]">
			<genre authority="lcgft" valueURI="http://id.loc.gov/authorities/genreForms/gf2014026039">Academic theses</genre>
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
	<xsl:template match="field[@name = 'source_fulltext_url']/value"/>
	<xsl:template match="submission-date"/>
	<xsl:template match="withdrawn"/>
	<xsl:template match="native-url"/>

	<!-- temporarily ignore these -->
	<xsl:template match="field[@name = 'instruct']/value"/>
	<xsl:template match="field[@name = 'publication_date']/value"/>
	<xsl:template match="field[@name = 'embargo_date']/value"/>
</xsl:stylesheet>
