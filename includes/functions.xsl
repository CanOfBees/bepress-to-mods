<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.og/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:etd="http://www.ndltd.org/standards/metadata/etdms/1.1"
	xmlns:cob="http://cob.net/fn"
	xmlns:file="http://expath.org/ns/file"
	xmlns="http://www.loc.gov/mods/v3"
	exclude-result-prefixes="#all" version="2.0">
	
	<xsl:output encoding="UTF-8" indent="yes" method="xml"/>
		
	<!-- functions -->
	<xsl:function name="cob:escape">
		<xsl:param name="text-in"/>
		<xsl:sequence select="if (contains($text-in, '&lt;'))
                          then (if (contains($text-in, '&lt;a'))
                                then (normalize-space(replace($text-in, '&lt;/?\p{L}+&gt;|&lt;a href=&quot;([A-Za-z0-9:/.]+)&quot;&gt;[A-Za-z0-9:/.]+&lt;/?\p{L}+&gt;', '$1')))
                                else (normalize-space(replace($text-in, '&lt;/?\p{L}+&gt;', ''))))
                          else (normalize-space($text-in))"/>
	</xsl:function>
	
</xsl:stylesheet>