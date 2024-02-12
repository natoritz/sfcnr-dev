/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc and Night
 * Module: cnr\discord\discord_commands.pwn
 * Purpose: commands that can be used on the discord channel
 */

/* ** Error Checking ** */
#if defined DISCORD_DISABLED
	#endinput
#endif

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Commands ** */
DISCORD:commands( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordCmdsChan) {
		DCC_SendChannelMessageFormatted(channel, "**[ERROR]** You can only use this command in <#%s> channel!", DISCORD_COMMANDS_CHAN);
		return 1;
	}

	new
		bool: hasMember;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleMember, hasMember );

	if ( hasMember )
	{
		DCC_SendChannelMessage(channel, "**Commands:**\n**!stats** - Displays the statistics of a user.\n**!say** - Sends a message to in-game chat.\n**!players** - Displays the current online players.\
										\n**!admins** - Displays the current online administrators.\n**!weeklytime** - Shows the weekly time of a player.\n**!lastlogged** - Shows the last played time of a user." );
	}
	else DCC_SendChannelMessage(channel, "**[ERROR]** You don't have an appropriate role to use this command." );
	return 1;
}

DISCORD:say( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordChatChan) {
		DCC_SendChannelMessageFormatted(channel, "**[ERROR]** You can only use this command in <#%s> channel!", DISCORD_CHAT_CHAN);
		return 1;
	}

	new
		bool: hasMember;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleMember, hasMember );

	if ( hasMember )
	{
		new
			szAntispam[ 64 ];

		if ( !isnull( params ) && !textContainsIP( params ) )
		{
			format( szAntispam, 64, "!say_%s", ReturnDiscordName( author ) );
			if ( GetGVarInt( szAntispam ) < g_iTime )
			{
				if ( hasMember )
					SetGVarInt( szAntispam, g_iTime + 10 );

				// send message
				SendClientMessageToAllFormatted( -1, "{7289DA}(Discord %s) {FFFFFF}%s:{99AAB5} %s", discordLevelToString( author ), ReturnDiscordName( author ), params );
				DCC_SendChannelMessageFormatted( discordChatChan, "**(Discord %s) %s:** %s", discordLevelToString( author ), ReturnDiscordName( author ), params );
			}
			else DCC_SendChannelMessage( channel, "You must wait 10 seconds before speaking again." );
		}
	}
	else DCC_SendChannelMessage(channel, "**[ERROR]** You don't have an appropriate role to use this command." );
	return 1;
}

DISCORD:players( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordCmdsChan) {
		DCC_SendChannelMessageFormatted(channel, "**[ERROR]** You can only use this command in <#%s> channel!", DISCORD_COMMANDS_CHAN);
		return 1;
	}

	new
		bool: hasMember;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleMember, hasMember );

	if ( hasMember )
	{
		new
			iPlayers = Iter_Count(Player);

		szLargeString[ 0 ] = '\0';
		if ( iPlayers <= 25 )
		{
			foreach(new i : Player) {
				if ( IsPlayerConnected( i ) ) {
					format( szLargeString, sizeof( szLargeString ), "There are **%d** player(s) online.", iPlayers );
				}
			}
		}
		format( szLargeString, sizeof( szLargeString ), "There are **%d** player(s) online.", iPlayers );
		DCC_SendChannelMessage( discordCmdsChan, szLargeString );
	}
	else DCC_SendChannelMessage( discordCmdsChan, "**[ERROR]** You don't have an appropriate role to use this command." );
	return 1;
}

DISCORD:admins( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordCmdsChan) {
		DCC_SendChannelMessageFormatted(channel, "**[ERROR]** You can only use this command in <#%s> channel!", DISCORD_COMMANDS_CHAN);
		return 1;
	}

	new
		bool: hasMember;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleMember, hasMember );

	if ( hasMember )
	{
		new count = 0;
		szBigString[ 0 ] = '\0';

		foreach(new i : Player) {
			if ( IsPlayerConnected( i ) && p_AdminLevel[ i ] > 0 ) {
				format( szBigString, sizeof( szBigString ), "%s**%s** (**ID: %d**)\n", szBigString, ReturnPlayerName( i ), i );
				count++;
			}
		}

		format( szBigString, sizeof( szBigString ), "%sThere are **%d** admin(s) online.", szBigString, count );
		DCC_SendChannelMessage( discordCmdsChan, szBigString );
	}
	else DCC_SendChannelMessage( discordCmdsChan, "**[ERROR]** You don't have an appropriate role to use this command." );
	return 1;
}

DISCORD:stats( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordCmdsChan) {
		DCC_SendChannelMessageFormatted(channel, "**[ERROR]** You can only use this command in <#%s> channel!", DISCORD_COMMANDS_CHAN);
		return 1;
	}

	new
		bool: hasMember;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleMember, hasMember );

	if ( isnull( params ) || strlen( params ) > 24 ) return DCC_SendChannelMessage( discordCmdsChan, "**[USAGE]** !stats [PLAYER_NAME]" );

	if ( hasMember )
	{
		format( szNormalString, sizeof( szNormalString ), "SELECT * FROM `USERS` WHERE `NAME`='%s' LIMIT 0,1", mysql_escape( params ) );
		mysql_tquery( dbHandle, szNormalString, "OnPlayerDiscordStats", "ds", INVALID_PLAYER_ID, params );
	}
	else DCC_SendChannelMessage( discordCmdsChan, "**[ERROR]** You don't have an appropriate role to use this command." );
	return 1;
}

thread OnPlayerDiscordStats( playerid, params[ ] )
{
	new
		iScore, iDeaths, iKills, iVIP,
		rows, fields;

	cache_get_data( rows, fields );

	if ( rows )
	{
		iScore		= cache_get_field_content_int( 0, "SCORE", dbHandle );
		iKills		= cache_get_field_content_int( 0, "KILLS", dbHandle );
		iDeaths		= cache_get_field_content_int( 0, "DEATHS", dbHandle );
		iVIP		= cache_get_field_content_int( 0, "VIP_PACKAGE", dbHandle );

		DCC_SendChannelMessageFormatted( discordCmdsChan, "__**%s**__ - **Score:** %d, **Kills:** %d, **Deaths:** %d, **Ratio:** %0.2f, **VIP:** %s", params, iScore, iKills, iDeaths, floatdiv( iKills, iDeaths ), VIPToString( iVIP ) );
	}
	else DCC_SendChannelMessage( discordCmdsChan, "**[ERROR]** This player doesn't exist." );
	return 1;
}

DISCORD:weeklytime( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordCmdsChan) {
		DCC_SendChannelMessageFormatted(channel, "**[ERROR]** You can only use this command in <#%s> channel!", DISCORD_COMMANDS_CHAN);
		return 1;
	}

	new
		bool: hasMember;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleMember, hasMember );

	if ( isnull( params ) || strlen( params ) > 24 ) return DCC_SendChannelMessage( discordCmdsChan, "**[USAGE]** !weeklytime [PLAYER_NAME]" );

	if ( hasMember )
	{
		format( szNormalString, sizeof( szNormalString ), "SELECT `UPTIME`,`WEEKEND_UPTIME` FROM `USERS` WHERE `NAME` = '%s' LIMIT 0,1", mysql_escape( params ) );
		mysql_tquery( dbHandle, szNormalString, "OnPlayerDiscordWeekly", "is", INVALID_PLAYER_ID, params );
	}
	else DCC_SendChannelMessage( discordCmdsChan, "**[ERROR]** You don't have an appropriate role to use this command." );
	return 1;
}

thread OnPlayerDiscordWeekly( playerid, params[ ] )
{
	new
		rows, fields,
		iCurrentUptime, iLastUptime
	;
	cache_get_data( rows, fields );

	if ( rows )
	{
		iCurrentUptime		= cache_get_field_content_int( 0, "UPTIME", dbHandle );
		iLastUptime 		= cache_get_field_content_int( 0, "WEEKEND_UPTIME", dbHandle );

		DCC_SendChannelMessageFormatted( discordCmdsChan, "**%s's** weekly time is **%s**.", params, secondstotime( iCurrentUptime - iLastUptime ) );
	}
	else DCC_SendChannelMessage( discordCmdsChan, "**[ERROR]** This player doesn't exist." );
	return 1;
}

DISCORD:lastlogged( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordCmdsChan) {
		DCC_SendChannelMessageFormatted(channel, "**[ERROR]** You can only use this command in <#%s> channel!", DISCORD_COMMANDS_CHAN);
		return 1;
	}

	new
		bool: hasMember;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleMember, hasMember );

	if ( isnull( params ) || strlen( params ) > 24 ) return DCC_SendChannelMessage( discordCmdsChan, "**[USAGE]** !lastlogged [PLAYER_NAME]" );

	if ( hasMember )
	{
		format( szNormalString, sizeof( szNormalString ), "SELECT `LASTLOGGED` FROM `USERS` WHERE `NAME` = '%s' LIMIT 0,1", mysql_escape( params ) );
		mysql_tquery( dbHandle, szNormalString, "OnPlayerDiscordLastLogged", "is", INVALID_PLAYER_ID, params );
	}
	else DCC_SendChannelMessage( discordCmdsChan, "**[ERROR]** You don't have an appropriate role to use this command." );
	return 1;
}

thread OnPlayerDiscordLastLogged( playerid, params[ ] )
{
	new
		rows, fields,
		time, Field[ 50 ]
	;
	cache_get_data( rows, fields );

	if ( rows )
	{
		cache_get_field_content( 0, "LASTLOGGED", Field );

		time = g_iTime - strval( Field );
		if ( time > 86400 )
		{
			time /= 86400;
			format( Field, sizeof( Field ), "%d day(s) ago.", time );
		}
		else if ( time > 3600 )
		{
			time /= 3600;
			format( Field, sizeof( Field ), "%d hour(s) ago.", time );
		}
		else
		{
			time /= 60;
			format( Field, sizeof( Field ), "%d minute(s) ago.", time );
		}

		DCC_SendChannelMessageFormatted( discordCmdsChan, "**%s** last logged **%s**", params, Field );
	}
	else DCC_SendChannelMessage( discordCmdsChan, "**[ERROR]** This player doesn't exist." );
	return 1;
}

/* Level 1+ */
DISCORD:acmds( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordAdminChan) {
		DCC_SendChannelMessage(channel, "**[ERROR]** You can only use this command in admin channel!");
		return 1;
	}

	new
		bool: hasExec, bool: hasDev, bool: hasCouncil,
		bool: hasLead, bool: hasSenior, bool: hasGeneral, bool: hasTrial;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleExec, hasExec );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleDev, hasDev );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleCouncil, hasCouncil );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleLead, hasLead );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleSenior, hasSenior );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleGeneral, hasGeneral );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleTrial, hasTrial );

	if ( hasExec || hasDev || hasCouncil || hasLead || hasSenior || hasGeneral || hasTrial )
	{
 		DCC_SendChannelMessage( discordAdminChan, "**Commands:**\n**!kick** - Kicking a player from the server.\n**!mute** - Muting a player.\n**!unmute** - Un-muting a player.\n**!suspend** - Suspending a player.\
		 											\n**!ban** - Banning a player.\n**!unban** - Unban a player from the server.\n**!jail** - Jailing a player.\n**!unjail** - Un-jailing a player\
													\n**!getip** - Getting IP of a player.\n**!warn** - Warning a player.\n**!ans** - Answering a question.");
	}
	else DCC_SendChannelMessage(channel, "**[ERROR]** You don't have an appropriate administration role to use this command." );
	return 1;
}

DISCORD:warn( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordAdminChan) {
		DCC_SendChannelMessage(channel, "**[ERROR]** You can only use this command in admin channel!");
		return 1;
	}

	new
		bool: hasExec, bool: hasDev, bool: hasCouncil,
		bool: hasLead, bool: hasSenior, bool: hasGeneral, bool: hasTrial;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleExec, hasExec );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleDev, hasDev );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleCouncil, hasCouncil );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleLead, hasLead );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleSenior, hasSenior );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleGeneral, hasGeneral );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleTrial, hasTrial );

	if ( hasExec || hasDev || hasCouncil || hasLead || hasSenior || hasGeneral || hasTrial )
	{
		new pID, reason[50];
		if ( sscanf( params, "uS(No Reason)[32]", pID, reason ) ) DCC_SendChannelMessage( discordAdminChan, "**[USAGE]** !warn [PLAYER_ID] [REASON]" );
		if ( IsPlayerConnected( pID ) )
		{
			p_Warns[ pID ] ++;
			DCC_SendChannelMessageFormatted( discordLogChan, "**[DISCORD LOG]** **%s** has warned **%s(%d) [%d/3]** **[REASON: %s]**.", ReturnDiscordName( author ), ReturnPlayerName( pID ), pID,p_Warns[ pID ], reason );
			SendGlobalMessage( -1, "{7289DA}[DISCORD]{FFFFFF} %s {99AAB5}has warned {FFFFFF}%s(%d) [%d/3] "COL_GREEN"[REASON: %s]", ReturnDiscordName( author ), ReturnPlayerName( pID ), pID,p_Warns[ pID ], reason );

			if ( p_Warns[ pID ] >= 3 )
			{
				p_Warns[ pID ] = 0;
				SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) has been kicked from the server. "COL_GREEN"[REASON: Excessive Warns]", ReturnPlayerName( pID ), pID );
				KickPlayerTimed( pID );
				return 1;
			}
		}
		else DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Player is not connected!" );
	}
	else DCC_SendChannelMessage(channel, "**[ERROR]** You don't have an appropriate administration role to use this command." );
	return 1;
}

DISCORD:jail( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordAdminChan) {
		DCC_SendChannelMessage(channel, "**[ERROR]** You can only use this command in admin channel!");
		return 1;
	}

	new
		bool: hasExec, bool: hasDev, bool: hasCouncil,
		bool: hasLead, bool: hasSenior, bool: hasGeneral, bool: hasTrial;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleExec, hasExec );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleDev, hasDev );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleCouncil, hasCouncil );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleLead, hasLead );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleSenior, hasSenior );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleGeneral, hasGeneral );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleTrial, hasTrial );

	if ( hasExec || hasDev || hasCouncil || hasLead || hasSenior || hasGeneral || hasTrial )
	{
		new pID, reason[50], Seconds;
		if ( sscanf( params, "udS(No Reason)[32]", pID, Seconds, reason ) ) return DCC_SendChannelMessage( discordAdminChan, "**[USAGE]** !jail [PLAYER_ID] [SECONDS] [REASON]" );
		if ( Seconds > 20000 || Seconds < 1 ) return DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** You're misleading the seconds limit! ( 0 - 20000 )" );
		if ( IsPlayerConnected( pID ) )
		{
			DCC_SendChannelMessageFormatted( discordLogChan, "**[DISCORD LOG]** **%s** has sent **%s(%d)** to jail for **%d** seconds. **[REASON: %s]**", ReturnDiscordName( author ), ReturnPlayerName( pID ), pID, Seconds, reason );
			SendGlobalMessage( -1, "{7289DA}[DISCORD]{FFFFFF} %s {99AAB5}has sent {FFFFFF}%s(%d) {99AAB5}to jail for {FFFFFF}%d seconds. "COL_GREEN"[REASON: %s]", ReturnDiscordName( author ), ReturnPlayerName( pID ), pID, Seconds, reason );
			JailPlayer( pID, Seconds, 1 );
		}
		else DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Player is not connected!" );
	}
	else DCC_SendChannelMessage(channel, "**[ERROR]** You don't have an appropriate administration role to use this command." );
	return 1;
}

DISCORD:unjail( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordAdminChan) {
		DCC_SendChannelMessage(channel, "**[ERROR]** You can only use this command in admin channel!");
		return 1;
	}

	new
		bool: hasExec, bool: hasDev, bool: hasCouncil,
		bool: hasLead, bool: hasSenior, bool: hasGeneral, bool: hasTrial;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleExec, hasExec );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleDev, hasDev );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleCouncil, hasCouncil );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleLead, hasLead );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleSenior, hasSenior );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleGeneral, hasGeneral );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleTrial, hasTrial );

	if ( hasExec || hasDev || hasCouncil || hasLead || hasSenior || hasGeneral || hasTrial )
	{
		new
			pID
		;
		if ( sscanf( params, "u", pID ) ) return DCC_SendChannelMessage( discordAdminChan, "**[USAGE]** !unjail [PLAYER_ID]" );
		if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Invalid Player ID." );
		if ( !IsPlayerJailed( pID ) ) return DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** The player is not jailed." );
		if ( IsPlayerConnected( pID ) )
		{
			DCC_SendChannelMessageFormatted( discordLogChan, "**[DISCORD LOG]** **%s** has unjailed **%s(%d)**.", ReturnDiscordName( author ), ReturnPlayerName( pID ), pID );
			SendGlobalMessage( -1, "{7289DA}[DISCORD]{FFFFFF} %s {99AAB5}has unjailed{FFFFFF} %s(%d).", ReturnDiscordName( author ), ReturnPlayerName( pID ), pID );
			CallLocalFunction( "OnPlayerUnjailed", "dd", pID, 3 );
		}
		else DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Player is not connected!" );
	}
	else DCC_SendChannelMessage(channel, "**[ERROR]** You don't have an appropriate administration role to use this command." );
	return 1;
}
DISCORD:ans( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordAdminChan) {
		DCC_SendChannelMessage(channel, "**[ERROR]** You can only use this command in admin channel!");
		return 1;
	}

	new
		bool: hasExec, bool: hasDev, bool: hasCouncil,
		bool: hasLead, bool: hasSenior, bool: hasGeneral, bool: hasTrial;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleExec, hasExec );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleDev, hasDev );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleCouncil, hasCouncil );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleLead, hasLead );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleSenior, hasSenior );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleGeneral, hasGeneral );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleTrial, hasTrial );

	if ( hasExec || hasDev || hasCouncil || hasLead || hasSenior || hasGeneral || hasTrial )
	{
		new
			pID, msg[ 90 ]
		;
		if ( sscanf( params, "us[90]", pID, msg ) ) return DCC_SendChannelMessage( discordAdminChan, "**[USAGE]** !ans [PLAYER_ID] [ANSWER]" );
		if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Invalid Player ID." );
		if ( IsPlayerConnected( pID ) )
		{
		SendClientMessageToAdmins( -1, "{7289DA}[DISCORD]{99AAB5} ({FFFFFF}%s{99AAB5} >> {FFFFFF}%s{99AAB5}):{FFFFFF} %s", ReturnDiscordName( author ), ReturnPlayerName( pID ), msg );
		SendClientMessageFormatted( pID, -1, "{7289DA}[DISCORD ANSWER] {FFFFFF}%s:{99AAB5} %s", ReturnDiscordName( author ), msg );
		DCC_SendChannelMessageFormatted( discordLogChan, "**[DISCORD LOG]** **%s** has answered **%s(%d)'s** question.", ReturnDiscordName( author ), ReturnPlayerName(pID), pID );
		Beep( pID );
		}
		else DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Player is not connected!" );
	}
	else DCC_SendChannelMessage(channel, "**[ERROR]** You don't have an appropriate administration role to use this command." );
	return 1;
}

/* Level 2+ */
DISCORD:kick( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordAdminChan) {
		DCC_SendChannelMessage(channel, "**[ERROR]** You can only use this command in admin channel!");
		return 1;
	}

	new
		bool: hasExec, bool: hasDev, bool: hasCouncil,
		bool: hasLead, bool: hasSenior, bool: hasGeneral;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleExec, hasExec );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleDev, hasDev );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleCouncil, hasCouncil );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleLead, hasLead );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleSenior, hasSenior );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleGeneral, hasGeneral );

	if ( hasExec || hasDev || hasCouncil || hasLead || hasSenior || hasGeneral )
	{
		new pID, reason[64];

		if (sscanf( params, "uS(No reason)[64]", pID, reason)) return DCC_SendChannelMessage( discordAdminChan, "**[USAGE]** !kick [PLAYER_ID] [REASON]" );
		if (IsPlayerConnected(pID))
		{
			DCC_SendChannelMessageFormatted( discordLogChan, "**[DISCORD LOG]** **%s** has kicked **%s(%d)**. **[REASON: %s]**", ReturnDiscordName( author ), ReturnPlayerName(pID), pID, reason );
			SendGlobalMessage( -1, "{7289DA}[DISCORD]{FFFFFF} %s {99AAB5}has kicked {FFFFFF}%s(%d) "COL_GREEN"[REASON: %s]", ReturnDiscordName( author ), ReturnPlayerName(pID), pID, reason );
			KickPlayerTimed( pID );
		}
		else DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Player is not connected!" );
	}
	else DCC_SendChannelMessage(channel, "**[ERROR]** You don't have an appropriate administration role to use this command." );
	return 1;
}

DISCORD:mute( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordAdminChan) {
		DCC_SendChannelMessage(channel, "**[ERROR]** You can only use this command in admin channel!");
		return 1;
	}

	new
		bool: hasExec, bool: hasDev, bool: hasCouncil,
		bool: hasLead, bool: hasSenior, bool: hasGeneral;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleExec, hasExec );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleDev, hasDev );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleCouncil, hasCouncil );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleLead, hasLead );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleSenior, hasSenior );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleGeneral, hasGeneral );

	if ( hasExec || hasDev || hasCouncil || hasLead || hasSenior || hasGeneral )
	{
		new pID, seconds, reason[ 32 ];

		if ( sscanf( params, "udS(No Reason)[32]", pID, seconds, reason ) ) return DCC_SendChannelMessage( discordAdminChan, "**[USAGE]** !mute [PLAYER_ID] [SECONDS] [REASON]" );
		else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Invalid Player ID." );
		else if ( p_AdminLevel[ pID ] > 4 ) return DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** You cannot use this command on admins higher than level 4.");
		else if ( seconds < 0 || seconds > 10000000 ) return DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Specify the amount of seconds from 1 - 10000000." );
		else
		{
			DCC_SendChannelMessageFormatted( discordLogChan, "**[DISCORD LOG]** **%s** has muted **%s(%d)** for **%d** seconds. **[REASON: %s]**", ReturnDiscordName( author ), ReturnPlayerName( pID ), pID, seconds, reason );
			SendGlobalMessage( -1, "{7289DA}[DISCORD]{FFFFFF} %s {99AAB5}has muted{FFFFFF} %s(%d) {99AAB5}for {FFFFFF}%d {99AAB5}seconds "COL_GREEN"[REASON: %s]", ReturnDiscordName( author ), ReturnPlayerName( pID ), pID, seconds, reason );
			GameTextForPlayer( pID, "~r~Muted!", 4000, 4 );
			p_Muted{ pID } = true;
			p_MutedTime[ pID ] = g_iTime + seconds;
		}
	}
	else DCC_SendChannelMessage(channel, "**[ERROR]** You don't have an appropriate administration role to use this command." );
	return 1;
}

DISCORD:unmute( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordAdminChan) {
		DCC_SendChannelMessage(channel, "**[ERROR]** You can only use this command in admin channel!");
		return 1;
	}

	new
		bool: hasExec, bool: hasDev, bool: hasCouncil,
		bool: hasLead, bool: hasSenior, bool: hasGeneral;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleExec, hasExec );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleDev, hasDev );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleCouncil, hasCouncil );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleLead, hasLead );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleSenior, hasSenior );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleGeneral, hasGeneral );

	if ( hasExec || hasDev || hasCouncil || hasLead || hasSenior || hasGeneral )
	{
		new pID;
		if ( sscanf( params, "u", pID )) return DCC_SendChannelMessage( discordAdminChan, "**[USAGE]** !unmute [PLAYER_ID]");
		else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Invalid Player ID." );
		else if ( !p_Muted{ pID } ) return DCC_SendChannelMessage( discordAdminChan,  "**[ERROR]** This player isn't muted" );
		else
		{
			DCC_SendChannelMessageFormatted( discordLogChan, "**[DISCORD LOG]** **%s** has un-muted **%s(%d)**.", ReturnDiscordName( author ), ReturnPlayerName( pID ), pID );
			SendGlobalMessage( -1, "{7289DA}[DISCORD]{FFFFFF} %s {99AAB5}has un-muted{FFFFFF} %s(%d).", ReturnDiscordName( author ), ReturnPlayerName( pID ), pID );
			GameTextForPlayer( pID, "~g~Un-Muted!", 4000, 4 );
			p_Muted{ pID } = false;
			p_MutedTime[ pID ] = 0;
		}
	}
	else DCC_SendChannelMessage(channel, "**[ERROR]** You don't have an appropriate administration role to use this command." );
	return 1;
}

DISCORD:suspend( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordAdminChan) {
		DCC_SendChannelMessage(channel, "**[ERROR]** You can only use this command in admin channel!");
		return 1;
	}

	new
		bool: hasExec, bool: hasDev, bool: hasCouncil,
		bool: hasLead, bool: hasSenior, bool: hasGeneral;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleExec, hasExec );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleDev, hasDev );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleCouncil, hasCouncil );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleLead, hasLead );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleSenior, hasSenior );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleGeneral, hasGeneral );

	if ( hasExec || hasDev || hasCouncil || hasLead || hasSenior || hasGeneral )
	{
		new pID, reason[50], hours, days;
		if ( sscanf( params, "uddS(No Reason)[50]", pID, hours, days, reason ) ) return DCC_SendChannelMessage( discordAdminChan, "**[USAGE]** !suspend [PLAYER_ID] [HOURS] [DAYS] [REASON]" );
		if ( hours < 0 || hours > 24 ) return DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Please specify an hour between 0 and 24." );
		if ( days < 0 || days > 60 ) return DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Please specifiy the amount of days between 0 and 60." );
		if ( days == 0 && hours == 0 ) return DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Invalid time specified." );

		if ( IsPlayerConnected( pID ) )
		{
			DCC_SendChannelMessageFormatted( discordLogChan, "**[DISCORD LOG]** **%s** has suspended **%s(%d)** for **%d hour(s)** and **%d day(s)** **[REASON: %s]**", ReturnDiscordName( author ), ReturnPlayerName( pID ), pID, hours, days, reason );
			SendGlobalMessage( -1, "{7289DA}[DISCORD]{FFFFFF} %s {99AAB5}has suspended {FFFFFF}%s(%d) {99AAB5}for {FFFFFF}%d {99AAB5}hour(s) and {FFFFFF}%d {99AAB5}day(s).", ReturnDiscordName( author ), ReturnPlayerName( pID ), pID, hours, days );
			new time = g_iTime + ( hours * 3600 ) + ( days * 86400 );
			AdvancedBan( pID, "DISCORDistrator", reason, ReturnPlayerIP( pID ), time );
		}
		else DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Player is not connected!" );
	}
	else DCC_SendChannelMessage(channel, "**[ERROR]** You don't have an appropriate administration role to use this command." );
	return 1;
}

/* Level 3+ */
DISCORD:ban( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordAdminChan) {
		DCC_SendChannelMessage(channel, "**[ERROR]** You can only use this command in admin channel!");
		return 1;
	}

	new
		bool: hasExec, bool: hasDev, bool: hasCouncil,
		bool: hasLead, bool: hasSenior;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleExec, hasExec );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleDev, hasDev );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleCouncil, hasCouncil );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleLead, hasLead );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleSenior, hasSenior );

	if ( hasExec || hasDev || hasCouncil || hasLead || hasSenior )
	{
		new pID, reason[64];
		if (sscanf( params, "uS(No reason)[64]", pID, reason)) return DCC_SendChannelMessage( discordAdminChan, "**[USAGE]** !ban [PLAYER_ID] [REASON]" );
		if (IsPlayerConnected(pID))
		{
			if ( p_AdminLevel[ pID ] >= 3 ) return DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** You can't use this on higher level admins." );
			DCC_SendChannelMessageFormatted( discordLogChan, "**[DISCORD LOG]** **%s** has banned **%s(%d)**. **[REASON: %s]**", ReturnDiscordName( author ), ReturnPlayerName( pID ), pID, reason );
			SendGlobalMessage( -1, "{7289DA}[DISCORD]{FFFFFF} %s {99AAB5}has banned{FFFFFF} %s(%d) "COL_GREEN"[REASON: %s]", ReturnDiscordName( author ), ReturnPlayerName( pID ), pID, reason );
			AdvancedBan( pID, "DISCORDistrator", reason, ReturnPlayerIP( pID ) );
		}
		else DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Player is not connected!" );
	}
	else DCC_SendChannelMessage(channel, "**[ERROR]** You don't have an appropriate administration role to use this command." );
	return 1;
}

DISCORD:getip( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordAdminChan) {
		DCC_SendChannelMessage(channel, "**[ERROR]** You can only use this command in admin channel!");
		return 1;
	}

	new
		bool: hasExec, bool: hasDev, bool: hasCouncil,
		bool: hasLead, bool: hasSenior;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleExec, hasExec );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleDev, hasDev );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleCouncil, hasCouncil );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleLead, hasLead );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleSenior, hasSenior );

	if ( hasExec || hasDev || hasCouncil || hasLead || hasSenior )
	{
		new pID;
		if ( sscanf( params, "u", pID ) ) return DCC_SendChannelMessage( discordAdminChan, "**[USAGE]** !getip [PLAYER_ID]" );
		if ( IsPlayerConnected( pID ) )
		{
			if ( p_AdminLevel[ pID ] >= 5 || IsPlayerServerMaintainer( pID ) ) return DCC_SendChannelMessage( discordAdminChan, "I love this person so much that I wont give you his IP :)");
			DCC_SendChannelMessageFormatted( discordAdminChan, "**[DISCORD LOG]** **%s(%d)'s** IP is **%s**", ReturnPlayerName( pID ), pID, ReturnPlayerIP( pID ) );
		}
		else DCC_SendChannelMessage( discordAdminChan, "**[ERROR]** Player is not connected!" );
	}
	else DCC_SendChannelMessage(channel, "**[ERROR]** You don't have an appropriate administration role to use this command." );
	return 1;
}

/* Level 5+ */
DISCORD:unban( DCC_Channel: channel, DCC_User: author, params[ ] )
{
	if (channel != discordAdminChan) {
		DCC_SendChannelMessage(channel, "**[ERROR]** You can only use this command in admin channel!");
		return 1;
	}

	new
		player[24],
		Query[70],
		bool: hasCouncil, bool: hasExec, bool: hasDev
	;

	DCC_HasGuildMemberRole( discordGuild, author, discordRoleCouncil, hasCouncil );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleExec, hasExec );
	DCC_HasGuildMemberRole( discordGuild, author, discordRoleDev, hasDev );

	if ( hasCouncil || hasExec || hasDev )
	{
		if ( sscanf( params, "s[24]", player ) ) return DCC_SendChannelMessage( discordAdminChan, "**[USAGE]** !unban [PLAYER_ID]" );
		else
		{
			format( Query, sizeof( Query ), "SELECT `NAME` FROM `BANS` WHERE `NAME` = '%s'", mysql_escape( player ) );
			mysql_function_query( dbHandle, Query, true, "OnPlayerUnbanPlayer", "dds", INVALID_PLAYER_ID, 1, player );
		}
	}
	else DCC_SendChannelMessage(channel, "**[ERROR]** You don't have an appropriate administration role to use this command." );
	return 1;
}