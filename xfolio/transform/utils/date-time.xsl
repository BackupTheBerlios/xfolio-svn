<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:doc="http://xsltsl.org/xsl/documentation/1.0" xmlns:dt="http://xsltsl.org/date-time" exclude-result-prefixes="dt doc xsl">

	<xsl:param name="lang" select="'fr'"/>
	<xsl:variable name="calendars" select="document('calendars.xml')"/>
	<xsl:variable name="messages">
		<xsl:choose>
			<xsl:when test="$calendars/*/calendar[@xml:lang=$lang]">
				<xsl:copy-of select="$calendars/*/calendar[@xml:lang=$lang]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$calendars/*/calendar[1]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<doc:reference xmlns="">
		<referenceinfo>
			<releaseinfo role="meta">
        $Id: date-time.xsl,v 1.1 2004/06/10 10:11:44 frederic Exp $
      </releaseinfo>
			<author>
				<surname>Diamond</surname>
				<firstname>Jason</firstname>
			</author>
			<copyright>
				<year>2001</year>
				<holder>Jason Diamond</holder>
			</copyright>
		</referenceinfo>
		<title>Date/Time Processing</title>
		<partintro>
			<section>
				<title>Introduction</title>
				<para>This module provides templates for formatting and parsing date/time strings.</para>
				<para>See <ulink url="http://www.tondering.dk/claus/calendar.html">http://www.tondering.dk/claus/calendar.html</ulink> for more information on calendars and the calculations this library performs.</para>
			</section>
		</partintro>
	</doc:reference>
	<doc:template name="dt:format-date-time" xmlns="">
		<refpurpose>Returns a string with a formatted date/time.</refpurpose>
		<refdescription>
			<para>The formatted date/time is determined by the format parameter. The default format is %Y-%m-%dT%H:%M:%S%z, the W3C format.</para>
		</refdescription>
		<refparameter>
			<variablelist>
				<varlistentry>
					<term>year</term>
					<listitem>
						<para>Year</para>
					</listitem>
				</varlistentry>
				<varlistentry>
					<term>month</term>
					<listitem>
						<para>Month (1 - 12; January = 1)</para>
					</listitem>
				</varlistentry>
				<varlistentry>
					<term>day</term>
					<listitem>
						<para>Day of month (1 - 31)</para>
					</listitem>
				</varlistentry>
				<varlistentry>
					<term>hour</term>
					<listitem>
						<para>Hours since midnight (0 - 23)</para>
					</listitem>
				</varlistentry>
				<varlistentry>
					<term>minute</term>
					<listitem>
						<para>Minutes after hour (0 - 59)</para>
					</listitem>
				</varlistentry>
				<varlistentry>
					<term>second</term>
					<listitem>
						<para>Seconds after minute (0 - 59)</para>
					</listitem>
				</varlistentry>
				<varlistentry>
					<term>time-zone</term>
					<listitem>
						<para>Time zone string (e.g., 'Z' or '-08:00')</para>
					</listitem>
				</varlistentry>
				<varlistentry>
					<term>format</term>
					<listitem>
						<para>The format specification.</para>
						<variablelist>
							<varlistentry>
								<term>%a</term>
								<listitem>
									<para>Abbreviated weekday name</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%A</term>
								<listitem>
									<para>Full weekday name</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%b</term>
								<listitem>
									<para>Abbreviated month name</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%B</term>
								<listitem>
									<para>Full month name</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%c</term>
								<listitem>
									<para>Date and time representation appropriate for locale</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%d</term>
								<listitem>
									<para>Day of month as decimal number (01 - 31)</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%H</term>
								<listitem>
									<para>Hour in 24-hour format (00 - 23)</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%I</term>
								<listitem>
									<para>Hour in 12-hour format (01 - 12)</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%j</term>
								<listitem>
									<para>Day of year as decimal number (001 - 366)</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%m</term>
								<listitem>
									<para>Month as decimal number (01 - 12)</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%M</term>
								<listitem>
									<para>Minute as decimal number (00 - 59)</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%p</term>
								<listitem>
									<para>Current locale's A.M./P.M. indicator for 12-hour clock</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%S</term>
								<listitem>
									<para>Second as decimal number (00 - 59)</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%U</term>
								<listitem>
									<para>Week of year as decimal number, with Sunday as first day of week (00 - 53)</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%w</term>
								<listitem>
									<para>Weekday as decimal number (0 - 6; Sunday is 0)</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%W</term>
								<listitem>
									<para>Week of year as decimal number, with Monday as first day of week (00 - 53)</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%x</term>
								<listitem>
									<para>Date representation for current locale </para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%X</term>
								<listitem>
									<para>Time representation for current locale</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%y</term>
								<listitem>
									<para>Year without century, as decimal number (00 - 99)</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%Y</term>
								<listitem>
									<para>Year with century, as decimal number</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%z</term>
								<listitem>
									<para>Time-zone name or abbreviation; no characters if time zone is unknown</para>
								</listitem>
							</varlistentry>
							<varlistentry>
								<term>%%</term>
								<listitem>
									<para>Percent sign</para>
								</listitem>
							</varlistentry>
						</variablelist>
					</listitem>
				</varlistentry>
			</variablelist>
		</refparameter>
		<refreturn>
			<para>Returns a formatted date/time string.</para>
		</refreturn>
	</doc:template>

	<xsl:template name="dt:format-date-time">
		<!-- default, parse date in W3C format -->
		<xsl:param name="date"/>
		<!-- YYYY-mm-ddTHH:MM:SS -->
		<xsl:param name="year" select="substring($date, 1, 4)"/>
		<xsl:param name="month" select="substring($date, 6, 2)"/>
		<xsl:param name="day" select="substring($date, 9, 2)"/>
		<xsl:param name="hour" select="substring($date, 12, 2)"/>
		<xsl:param name="minute" select="substring($date, 15, 2)"/>
		<xsl:param name="second" select="substring($date, 18, 2)"/>
		<xsl:param name="time-zone" select="substring($date, 20)"/>
		<xsl:param name="format" select="'%A, %d %B %Y'"/>
		<!--
		<xsl:param name="format" select="'%Y-%m-%dT%H:%M:%S%z'"/>
		-->
		<xsl:value-of select="substring-before($format, '%')"/>
		<xsl:variable name="code" select="substring(substring-after($format, '%'), 1, 1)"/>
		<xsl:choose>
			<!-- Abbreviated weekday name -->
			<xsl:when test="$code='a'">
				<xsl:variable name="day-of-the-week">
					<xsl:call-template name="dt:calculate-day-of-the-week">
						<xsl:with-param name="year" select="number($year)"/>
						<xsl:with-param name="month" select="number($month)"/>
						<xsl:with-param name="day" select="number($day)"/>
					</xsl:call-template>
				</xsl:variable>
						<xsl:value-of select="$messages/*/a[position()=($day-of-the-week+1)]"/>
			</xsl:when>
			<!-- Full weekday name -->
			<xsl:when test="$code='A'">
				<xsl:variable name="day-of-the-week">
					<xsl:call-template name="dt:calculate-day-of-the-week">
						<xsl:with-param name="year" select="number($year)"/>
						<xsl:with-param name="month" select="number($month)"/>
						<xsl:with-param name="day" select="number($day)"/>
					</xsl:call-template>
				</xsl:variable>
						<xsl:value-of select="$messages/*/A[position()=($day-of-the-week+1)]"/>
			</xsl:when>
			<!-- Abbreviated month name -->
			<xsl:when test="$code='b'">
						<xsl:value-of select="$messages/*/b[position()=(number($month)+1)]"/>

			</xsl:when>
			<!-- Full month name -->
			<xsl:when test="$code='B'">
						<xsl:value-of select="$messages/*/B[position()=(number($month)+1)]"/>

			</xsl:when>
			<!-- Date and time representation appropriate for locale -->
			<xsl:when test="$code='c'">
				<xsl:text>[not implemented]</xsl:text>
			</xsl:when>
			<!-- Day of month as decimal number (01 - 31) -->
			<xsl:when test="$code='d'">
				<xsl:if test="$day &lt; 10">0</xsl:if>
				<xsl:value-of select="number($day)"/>
			</xsl:when>
			<!-- Hour in 24-hour format (00 - 23) -->
			<xsl:when test="$code='H'">
				<xsl:if test="$hour &lt; 10">0</xsl:if>
				<xsl:value-of select="number($hour)"/>
			</xsl:when>
			<!-- Hour in 12-hour format (01 - 12) -->
			<xsl:when test="$code='I'">
				<xsl:choose>
					<xsl:when test="$hour = 0">12</xsl:when>
					<xsl:when test="$hour &lt; 10">0<xsl:value-of select="$hour - 0"/>
					</xsl:when>
					<xsl:when test="$hour &lt; 13">
						<xsl:value-of select="$hour - 0"/>
					</xsl:when>
					<xsl:when test="$hour &lt; 22">0<xsl:value-of select="$hour - 12"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$hour - 12"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- Day of year as decimal number (001 - 366) -->
			<xsl:when test="$code='j'">
				<xsl:text>[not implemented]</xsl:text>
			</xsl:when>
			<!-- Month as decimal number (01 - 12) -->
			<xsl:when test="$code='m'">
				<xsl:if test="number($month) &lt; 10">0</xsl:if>
				<xsl:value-of select="number($month)"/>
			</xsl:when>
			<!-- Minute as decimal number (00 - 59) -->
			<xsl:when test="$code='M'">
				<xsl:if test="$minute &lt; 10">0</xsl:if>
				<xsl:value-of select="number($minute)"/>
			</xsl:when>
			<!-- Current locale's A.M./P.M. indicator for 12-hour clock -->
			<xsl:when test="$code='p'">
				<xsl:choose>
					<xsl:when test="$hour &lt; 12">AM</xsl:when>
					<xsl:otherwise>PM</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- Second as decimal number (00 - 59) -->
			<xsl:when test="$code='S'">
				<xsl:if test="$second &lt; 10">0</xsl:if>
				<xsl:value-of select="number($second)"/>
			</xsl:when>
			<!-- Week of year as decimal number, with Sunday as first day of week (00 - 53) -->
			<xsl:when test="$code='U'">
				<!-- add 1 to day -->
				<xsl:call-template name="dt:calculate-week-number">
					<xsl:with-param name="year" select="number($year)"/>
					<xsl:with-param name="month" select="number($month)"/>
					<xsl:with-param name="day" select="number($day) + 1"/>
				</xsl:call-template>
			</xsl:when>
			<!-- Weekday as decimal number (0 - 6; Sunday is 0) -->
			<xsl:when test="$code='w'">
				<xsl:call-template name="dt:calculate-day-of-the-week">
					<xsl:with-param name="year" select="number($year)"/>
					<xsl:with-param name="month" select="number($month)"/>
					<xsl:with-param name="day" select="number($day)"/>
				</xsl:call-template>
			</xsl:when>
			<!-- Week of year as decimal number, with Monday as first day of week (00 - 53) -->
			<xsl:when test="$code='W'">
				<xsl:call-template name="dt:calculate-week-number">
					<xsl:with-param name="year" select="number($year)"/>
					<xsl:with-param name="month" select="number($month)"/>
					<xsl:with-param name="day" select="number($day)"/>
				</xsl:call-template>
			</xsl:when>
			<!-- Date representation for current locale -->
			<xsl:when test="$code='x'">
				<xsl:text>[not implemented]</xsl:text>
			</xsl:when>
			<!-- Time representation for current locale -->
			<xsl:when test="$code='X'">
				<xsl:text>[not implemented]</xsl:text>
			</xsl:when>
			<!-- Year without century, as decimal number (00 - 99) -->
			<xsl:when test="$code='y'">
				<xsl:text>[not implemented]</xsl:text>
			</xsl:when>
			<!-- Year with century, as decimal number -->
			<xsl:when test="$code='Y'">
				<xsl:value-of select="concat(substring('000', string-length(string(number($year)))  ), string($year) )"/>
			</xsl:when>
			<!-- Time-zone name or abbreviation; no characters if time zone is unknown -->
			<xsl:when test="$code='z'">
				<xsl:value-of select="$time-zone"/>
			</xsl:when>
			<!-- Percent sign -->
			<xsl:when test="$code='%'">
				<xsl:text>%</xsl:text>
			</xsl:when>
		</xsl:choose>
		<xsl:variable name="remainder" select="substring(substring-after($format, '%'), 2)"/>
		<xsl:if test="$remainder">
			<xsl:call-template name="dt:format-date-time">
				<xsl:with-param name="year" select="number($year)"/>
				<xsl:with-param name="month" select="number($month)"/>
				<xsl:with-param name="day" select="number($day)"/>
				<xsl:with-param name="hour" select="$hour"/>
				<xsl:with-param name="minute" select="$minute"/>
				<xsl:with-param name="second" select="$second"/>
				<xsl:with-param name="time-zone" select="$time-zone"/>
				<xsl:with-param name="format" select="$remainder"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<doc:template name="dt:calculate-day-of-the-week" xmlns="">
		<refpurpose>Calculates the day of the week.</refpurpose>
		<refdescription>
			<para>Given any Gregorian date, this calculates the day of the week.</para>
		</refdescription>
		<refparameter>
			<variablelist>
				<varlistentry>
					<term>year</term>
					<listitem>
						<para>Year</para>
					</listitem>
				</varlistentry>
				<varlistentry>
					<term>month</term>
					<listitem>
						<para>Month (1 - 12; January = 1)</para>
					</listitem>
				</varlistentry>
				<varlistentry>
					<term>day</term>
					<listitem>
						<para>Day of month (1 - 31)</para>
					</listitem>
				</varlistentry>
			</variablelist>
		</refparameter>
		<refreturn>
			<para>Returns the day of the week (0 - 6; Sunday = 0).</para>
		</refreturn>
	</doc:template>
	<xsl:template name="dt:calculate-day-of-the-week">
		<xsl:param name="year"/>
		<xsl:param name="month"/>
		<xsl:param name="day"/>
		<xsl:variable name="a" select="floor((14 - number($month)) div 12)"/>
		<xsl:variable name="y" select="number($year) - $a"/>
		<xsl:variable name="m" select="number($month) + 12 * $a - 2"/>
		<xsl:value-of select="(number($day) + $y + floor($y div 4) - floor($y div 100) + floor($y div 400) + floor((31 * $m) div 12)) mod 7"/>
	</xsl:template>



	<doc:template name="dt:calculate-julian-day" xmlns="">
		<refpurpose>Calculates the Julian Day for a specified date.</refpurpose>
		<refdescription>
			<para>Given any Gregorian date, this calculates the Julian Day.</para>
		</refdescription>
		<refparameter>
			<variablelist>
				<varlistentry>
					<term>year</term>
					<listitem>
						<para>Year</para>
					</listitem>
				</varlistentry>
				<varlistentry>
					<term>month</term>
					<listitem>
						<para>Month (1 - 12; January = 1)</para>
					</listitem>
				</varlistentry>
				<varlistentry>
					<term>day</term>
					<listitem>
						<para>Day of month (1 - 31)</para>
					</listitem>
				</varlistentry>
			</variablelist>
		</refparameter>
		<refreturn>
			<para>Returns the Julian Day as a decimal number.</para>
		</refreturn>
	</doc:template>
	<xsl:template name="dt:calculate-julian-day">
		<xsl:param name="year"/>
		<xsl:param name="month"/>
		<xsl:param name="day"/>
		<xsl:variable name="a" select="floor((14 - number($month)) div 12)"/>
		<xsl:variable name="y" select="number($year) + 4800 - $a"/>
		<xsl:variable name="m" select="number($month) + 12 * $a - 3"/>
		<xsl:value-of select="number($day) + floor((153 * $m + 2) div 5) + $y * 365 + floor($y div 4) - floor($y div 100) + floor($y div 400) - 32045"/>
	</xsl:template>

	<doc:template name="dt:format-julian-day" xmlns="">
		<refpurpose>Returns a string with a formatted date for a specified Julian Day.</refpurpose>
		<refdescription>
			<para>Given any Julian Day, this returns a string according to the format specification.</para>
		</refdescription>
		<refparameter>
			<variablelist>
				<varlistentry>
					<term>julian-day</term>
					<listitem>
						<para>A Julian Day</para>
					</listitem>
				</varlistentry>
				<varlistentry>
					<term>format</term>
					<listitem>
						<para>The format specification. See dt:format-date-time for more details.</para>
					</listitem>
				</varlistentry>
			</variablelist>
		</refparameter>
		<refreturn>
			<para>A string.</para>
		</refreturn>
	</doc:template>

	<xsl:template name="dt:format-julian-day">
		<xsl:param name="julian-day"/>
		<xsl:param name="format" select="'%Y-%m-%d'"/>
		<xsl:variable name="a" select="$julian-day + 32044"/>
		<xsl:variable name="b" select="floor((4 * $a + 3) div 146097)"/>
		<xsl:variable name="c" select="$a - floor(($b * 146097) div 4)"/>
		<xsl:variable name="d" select="floor((4 * $c + 3) div 1461)"/>
		<xsl:variable name="e" select="$c - floor((1461 * $d) div 4)"/>
		<xsl:variable name="m" select="floor((5 * $e + 2) div 153)"/>
		<xsl:variable name="day" select="$e - floor((153 * $m + 2) div 5) + 1"/>
		<xsl:variable name="month" select="$m + 3 - 12 * floor($m div 10)"/>
		<xsl:variable name="year" select="$b * 100 + $d - 4800 + floor($m div 10)"/>
		<xsl:call-template name="dt:format-date-time">
			<xsl:with-param name="year" select="number($year)"/>
			<xsl:with-param name="month" select="number($month)"/>
			<xsl:with-param name="day" select="number($day)"/>
			<xsl:with-param name="format" select="$format"/>
		</xsl:call-template>
	</xsl:template>

	<doc:template name="dt:calculate-week-number" xmlns="">
		<refpurpose>Calculates the week number for a specified date.</refpurpose>
		<refdescription>
			<para>Assumes Monday is the first day of the week.</para>
		</refdescription>
		<refparameter>
			<variablelist>
				<varlistentry>
					<term>year</term>
					<listitem>
						<para>Year</para>
					</listitem>
				</varlistentry>
				<varlistentry>
					<term>month</term>
					<listitem>
						<para>Month (1 - 12; January = 1)</para>
					</listitem>
				</varlistentry>
				<varlistentry>
					<term>day</term>
					<listitem>
						<para>Day of month (1 - 31)</para>
					</listitem>
				</varlistentry>
			</variablelist>
		</refparameter>
		<refreturn>
			<para>Returns the week number as a decimal number.</para>
		</refreturn>
	</doc:template>

	<xsl:template name="dt:calculate-week-number">
		<xsl:param name="year"/>
		<xsl:param name="month"/>
		<xsl:param name="day"/>
		<xsl:variable name="J">
			<xsl:call-template name="dt:calculate-julian-day">
				<xsl:with-param name="year" select="number($year)"/>
				<xsl:with-param name="month" select="number($month)"/>
				<xsl:with-param name="day" select="number($day)"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="d4" select="($J + 31741 - ($J mod 7)) mod 146097 mod 36524 mod 1461"/>
		<xsl:variable name="L" select="floor($d4 div 1460)"/>
		<xsl:variable name="d1" select="(($d4 - $L) mod 365) + $L"/>
		<xsl:value-of select="floor($d1 div 7) + 1"/>
	</xsl:template>

</xsl:stylesheet>
