/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\player_settings.pwn
 * Purpose: player settings that can be easily configured via /controlpanel (/cp)
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
#define MAX_SETTINGS 				( 13 )

#define SETTING_BAILOFFERS 			( 0 )
#define SETTING_EVENT_TP			( 1 )
#define SETTING_GANG_INVITES		( 2 )
#define SETTING_CHAT_PREFIXES		( 3 )
#define SETTING_RANSOMS				( 4 )
#define SETTING_CHAT_ID 			( 5 )
#define SETTING_CONNECTION_LOG 		( 6 )
#define SETTING_HITMARKER 			( 7 )
#define SETTING_VIPSKIN 			( 8 )
#define SETTING_COINS_BAR	 		( 9 )
#define SETTING_TOP_DONOR 			( 10 )
#define SETTING_WEAPON_PICKUP 		( 11 )
#define SETTING_HIDE_GAMB_MSG		( 12 )

/* ** Variables ** */
static stock
	g_PlayerSettings 				[ MAX_SETTINGS ] [ 24 ] = {
		{ "Prevent Bail Offers" }, { "Prevent Event Teleports" }, { "Prevent Gang Invites" }, { "Prevent Chat Prefixes" }, { "Prevent Ransom Offers" },
		{ "Display User ID In Chat" }, { "Display Connection Log" }, { "Display Hitmarker" }, { "Set V.I.P Skin" }, { "Hide Total Coin Bar" }, { "Hide Last Donor Text" },
		{ "Manual Pickup Weapon" }, { "Hide Gambling Win Msgs" }
	},
	bool: p_PlayerSettings 			[ MAX_PLAYERS ] [ MAX_SETTINGS char ]
;

/* ** Hooks ** */
hook OnPlayerRegister( playerid )
{
	return 1;
}

hook OnDialogResponse( playerid, dialogid, response, listitem, inputtext[ ] )
{
	if ( dialogid == DIALOG_CP_MENU && response )
	{
		if ( IsPlayerInEvent( playerid ) ) {
			return SendError( playerid, "You cannot modify your player settings within an event." );
		}

		if ( listitem == 0 ) {
			return ShowPlayerAccountGuard( playerid );
		}

		new
			settingid = listitem - 1;

		if ( settingid == SETTING_VIPSKIN && p_VIPLevel[ playerid ] < VIP_REGULAR ) {
			return SendError( playerid, "You are not a V.I.P, to become one visit "COL_GREY"donate.sfcnr.com" );
		}

		// setting is being toggled ... then
		if ( ! p_PlayerSettings[ playerid ] { settingid } == true )
		{
			if ( settingid == SETTING_VIPSKIN ) {
				SyncObject( playerid );
				ClearAnimations( playerid );
				SetPlayerSkin( playerid, p_LastSkin[ playerid ] );
			}

			else if ( settingid == SETTING_COINS_BAR || settingid == SETTING_TOP_DONOR ) {
			 	HidePlayerTogglableTextdraws( playerid, .force = false );
 				ShowPlayerTogglableTextdraws( playerid, .force = false );
			}
		}
		else // setting is not being toggled
		{
			if ( settingid == SETTING_COINS_BAR || settingid == SETTING_TOP_DONOR ) {
			 	HidePlayerTogglableTextdraws( playerid, .force = false );
 				ShowPlayerTogglableTextdraws( playerid, .force = false );
			}
		}

		TogglePlayerSetting( playerid, settingid, ! p_PlayerSettings[ playerid ] { settingid } );
		SendServerMessage( playerid, ""COL_ORANGE"%s"COL_WHITE" is now %s. Changes may take effect after spawning/relogging.", g_PlayerSettings[ settingid ], p_PlayerSettings[ playerid ] { settingid } ? ( "enabled" ) : ( "disabled" ) );

	    if ( ! strmatch( inputtext, "ignore" )) {
	   		cmd_cp( playerid, "" ); // Redirect to control panel again...
	    }
	}
	return 1;
}

hook OnPlayerConnect( playerid ) {
	for ( new i = 0; i < MAX_SETTINGS; i ++ ) {
		p_PlayerSettings[ playerid ] { i } = false;
	}
	return 1;
}

hook OnPlayerLogin( playerid )
{
	format( szNormalString, sizeof( szNormalString ), "SELECT * FROM `SETTINGS` WHERE `USER_ID`=%d", GetPlayerAccountID( playerid ) );
	mysql_function_query( dbHandle, szNormalString, true, "OnSettingsLoad", "d", playerid );
	return 1;
}

hook OnPlayerLoadTextdraws( playerid ) {
	ShowPlayerTogglableTextdraws( playerid );
	return 1;
}

hook OnPlayerUnloadTextdraws( playerid ) {
	HidePlayerTogglableTextdraws( playerid );
	return 1;
}

/* ** SQL Threads ** */
thread OnSettingsLoad( playerid )
{
	if ( !IsPlayerConnected( playerid ) )
		return 0;

	new
		rows = cache_get_row_count( );

	if ( rows )
	{
		new
			i = -1;

		while( ++ i < rows )
		{
			new
				settingid = cache_get_field_content_int( i, "SETTING_ID", dbHandle );

			if ( settingid < MAX_SETTINGS ) // Must be something wrong otherwise...
				p_PlayerSettings[ playerid ] { settingid } = true;
		}
	}
	return 1;
}

/* ** Commands ** */
CMD:cp( playerid, params[ ] ) return cmd_controlpanel( playerid, params );
CMD:settings( playerid, params[ ] ) return cmd_controlpanel( playerid, params );
CMD:controlpanel( playerid, params[ ] )
{
	szLargeString = ""COL_WHITE"Setting\t"COL_WHITE"Status\n"COL_GREY"Irresistible Guard\t"COL_ORANGE">>>\n";

	for( new i = 0; i < MAX_SETTINGS; i++ ) {
		format( szLargeString, sizeof( szLargeString ), "%s%s\t%s\n", szLargeString, g_PlayerSettings[ i ], p_PlayerSettings[ playerid ] { i } ? ( ""#COL_GREEN"YES" ) : ( ""#COL_RED"NO" ) );
	}

	ShowPlayerDialog( playerid, DIALOG_CP_MENU, DIALOG_STYLE_TABLIST_HEADERS, "{FFFFFF}Control Panel", szLargeString, "Select", "Cancel" );
	return 1;
}

/* ** Functions ** */
static stock ShowPlayerTogglableTextdraws( playerid, bool: force = false )
{
	// Current Coins
	if ( ! IsPlayerSettingToggled( playerid, SETTING_COINS_BAR ) || force ) {
		TextDrawShowForPlayer( playerid, g_CurrentCoinsTD );
		PlayerTextDrawShow( playerid, p_CoinsTD[ playerid ] );
	}

	// Top donor
	if ( ! IsPlayerSettingToggled( playerid, SETTING_TOP_DONOR ) || force ) {
		TextDrawShowForPlayer( playerid, g_TopDonorTD );
	}
}

static stock HidePlayerTogglableTextdraws( playerid, bool: force = true )
{
	// Current Coins
	if ( IsPlayerSettingToggled( playerid, SETTING_COINS_BAR ) || force ) {
		TextDrawHideForPlayer( playerid, g_CurrentCoinsTD );
		PlayerTextDrawHide( playerid, p_CoinsTD[ playerid ] );
	}

	// Top donor
	if ( IsPlayerSettingToggled( playerid, SETTING_TOP_DONOR ) || force ) {
		TextDrawHideForPlayer( playerid, g_TopDonorTD );
	}
}

stock TogglePlayerSetting( playerid, settingid, bool: toggle )
{
	if ( ( p_PlayerSettings[ playerid ] { settingid } = toggle ) == true ) {
		mysql_single_query( sprintf( "INSERT INTO `SETTINGS`(`USER_ID`, `SETTING_ID`) VALUES (%d, %d)", p_AccountID[ playerid ], settingid ) );
	} else {
		mysql_single_query( sprintf( "DELETE FROM `SETTINGS` WHERE `USER_ID`=%d AND `SETTING_ID`=%d", p_AccountID[ playerid ], settingid ) );
	}
	return 1;
}

stock IsPlayerSettingToggled( playerid, settingid ) {
	return p_PlayerSettings[ playerid ] { settingid };
}

stock IsPlayerVIPSkinToggled( playerid ) {
	return p_PlayerSettings[ playerid ] { SETTING_VIPSKIN };
}