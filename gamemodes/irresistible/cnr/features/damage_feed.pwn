/*
 * Irresistible Gaming (c) 2018
 * Developed by Stev, Slice
 * Module: cnr/features/damage_feed.pwn
 * Purpose: damage feed for dmers
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Macros ** */
#define IsDamageFeedActive(%0) 		( IsPlayerSettingToggled( %0, SETTING_HITMARKER ) )

/* ** Definitions ** */
#define MAX_FEED_HEIGHT 			( 5 )
#define HIDE_FEED_DELAY 			( 3000 )
#define MAX_UPDATE_RATE 			( 250 )

#define TEXTDRAW_ADDON 				( 100.0 )

/* ** Forwards ** */
forward OnPlayerFeedUpdate 			( playerid );
forward OnPlayerTakenDamage 		( playerid, issuerid, Float: amount, weaponid, bodypart );

/* ** Variables ** */
enum E_SYNC_DATA
{
	Float: E_X,				Float: E_Y,					Float: E_Z,
	Float: E_A, 			Float: E_HEALTH, 			Float: E_ARMOUR,

	E_SKIN, 				E_WORLD, 					E_INTERIOR,
	E_CURRENT_WEAPON, 		E_WEAPON_ID[ 13 ], 			E_WEAPON_AMMO[ 13 ],
	E_WANTED_LEVEL
};

enum E_DAMAGE_FEED
{
	E_ISSUER, 				E_NAME[ MAX_PLAYER_NAME ], 			Float: E_AMOUNT,
	E_WEAPON, 				E_TICK
};

enum E_HITMARKER_SOUND
{
	E_NAME[ 10 ], 			E_SOUND_ID
};

static stock
	p_HitmarkerSound 				[ MAX_PLAYERS char ]
;

static stock
	g_damageGiven 					[ MAX_PLAYERS ] [ MAX_FEED_HEIGHT ] [ E_DAMAGE_FEED ],
	g_damageTaken 					[ MAX_PLAYERS ] [ MAX_FEED_HEIGHT ] [ E_DAMAGE_FEED ],
	g_syncData 						[ MAX_PLAYERS ] [ E_SYNC_DATA ],
	//Text3D: g_BulletLabel			[ MAX_PLAYERS ],
	//g_BulletTimer 				[ MAX_PLAYERS ],

	bool: p_GotHit 					[ MAX_PLAYERS char ],
	bool: p_SyncingPlayer 			[ MAX_PLAYERS char ],
	p_DamageObject 					[ MAX_PLAYERS ] = { -1, ... },

	PlayerText: g_damageFeedTakenTD	[ MAX_PLAYERS ] = { PlayerText: INVALID_TEXT_DRAW, ... },
	PlayerText: g_damageFeedGivenTD [ MAX_PLAYERS ] = { PlayerText: INVALID_TEXT_DRAW, ... },
	//PlayerText: p_DamageTD          [ MAX_PLAYERS ] = { PlayerText: INVALID_TEXT_DRAW, ... },

	g_HitmarkerSounds 				[ ] [ E_HITMARKER_SOUND ] =
	{
		{ "Bell Ding", 17802 }, 	{ "Soft Beep", 5205 }, 		{ "Low Blip", 1138 }, 	{ "Med Blip", 1137 },
		{ "High Blip", 1139 }, 		{ "Bling", 5201 }
	},

	p_damageFeedTimer 				[ MAX_PLAYERS ] = { -1, ... },
	p_lastFeedUpdate 				[ MAX_PLAYERS ]
;

/* ** Hooks ** */
hook OnPlayerConnect( playerid )
{
	for( new x = 0; x < sizeof( g_damageGiven[ ] ); x ++) {
		g_damageGiven[ playerid ] [ x ] [ E_TICK ] = 0;
		g_damageTaken[ playerid ] [ x ] [ E_TICK ] = 0;
	}

	p_lastFeedUpdate[ playerid ] = GetTickCount( );

	/* ** Textdraws ** */
	/*p_DamageTD[ playerid ] = CreatePlayerTextDraw(playerid, 357.000000, 208.000000, "~r~~h~300.24 DAMAGE");
	PlayerTextDrawBackgroundColor(playerid, p_DamageTD[ playerid ], 255);
	PlayerTextDrawFont(playerid, p_DamageTD[ playerid ], 3);
	PlayerTextDrawLetterSize(playerid, p_DamageTD[ playerid ], 0.400000, 1.000000);
	PlayerTextDrawColor(playerid, p_DamageTD[ playerid ], -1);
	PlayerTextDrawSetOutline(playerid, p_DamageTD[ playerid ], 1);
	PlayerTextDrawSetProportional(playerid, p_DamageTD[ playerid ], 1);*/

	/* ** Textdraws ** */
	g_damageFeedGivenTD[ playerid ] = CreatePlayerTextDraw( playerid, ( 320.0 - TEXTDRAW_ADDON ), 340.0, "_");
	PlayerTextDrawBackgroundColor(playerid, g_damageFeedGivenTD[ playerid ], 117 );
	PlayerTextDrawAlignment( playerid, g_damageFeedGivenTD[ playerid ], 2 );
	PlayerTextDrawFont( playerid, g_damageFeedGivenTD[ playerid ], 1 );
	PlayerTextDrawLetterSize( playerid, g_damageFeedGivenTD[ playerid ], 0.200000, 0.899999 );
	PlayerTextDrawColor( playerid, g_damageFeedGivenTD[ playerid ], 0xDD2020FF );
	PlayerTextDrawSetOutline( playerid, g_damageFeedGivenTD[ playerid ], 1 );
	PlayerTextDrawSetProportional( playerid, g_damageFeedGivenTD[ playerid ], 1 );
	PlayerTextDrawSetSelectable( playerid, g_damageFeedGivenTD[ playerid ], 0 );

	g_damageFeedTakenTD[ playerid ] = CreatePlayerTextDraw( playerid, ( TEXTDRAW_ADDON + 320.0 ), 340.0, "_");
	PlayerTextDrawBackgroundColor(playerid, g_damageFeedTakenTD[ playerid ], 117 );
	PlayerTextDrawAlignment( playerid, g_damageFeedTakenTD[ playerid ], 2 );
	PlayerTextDrawFont( playerid, g_damageFeedTakenTD[ playerid ], 1 );
	PlayerTextDrawLetterSize( playerid, g_damageFeedTakenTD[ playerid ], 0.200000, 0.899999 );
	PlayerTextDrawColor( playerid, g_damageFeedTakenTD[ playerid ], 1069804543 );
	PlayerTextDrawSetOutline( playerid, g_damageFeedTakenTD[ playerid ], 1 );
	PlayerTextDrawSetProportional( playerid, g_damageFeedTakenTD[ playerid ], 1 );
	PlayerTextDrawSetSelectable( playerid, g_damageFeedTakenTD[ playerid ], 0 );

	return 1;
}

hook OnPlayerDisconnect( playerid, reason )
{
	p_HitmarkerSound{ playerid } = 0;
	p_SyncingPlayer{ playerid } = false;
	return 1;
}

hook OnDialogResponse( playerid, dialogid, response, listitem, inputtext[ ] )
{
	if ( dialogid == DIALOG_MODIFY_HITSOUND && response )
	{
		p_HitmarkerSound{ playerid } = listitem;
		mysql_single_query( sprintf( "UPDATE `USERS` SET `HIT_SOUND`=%d WHERE `ID`=%d", listitem, GetPlayerAccountID( playerid ) ) );
		SendClientMessageFormatted( playerid, -1, ""COL_GREY"[SERVER]"COL_WHITE" You have changed your hitmarker sound to "COL_GREY"%s"COL_WHITE".", g_HitmarkerSounds[ listitem ] [ E_NAME ] );

		PlayerPlaySound( playerid, g_HitmarkerSounds[ listitem ] [ E_SOUND_ID ], 0.0, 0.0, 0.0 );
		ShowSoundsMenu( playerid );
	}
	return 1;
}

hook SetPlayerRandomSpawn( playerid )
{
	if ( p_SyncingPlayer{ playerid } == true )
	{
		ResetPlayerWeapons( playerid );
		DisablePlayerSpawnProtection( playerid );
		SetPlayerWantedLevel( playerid, g_syncData[ playerid ] [ E_WANTED_LEVEL ] );

		SetPlayerHealth( playerid, g_syncData[ playerid ] [ E_HEALTH ] );
		SetPlayerArmour( playerid, g_syncData[ playerid ] [ E_ARMOUR ] );
		SetPlayerVirtualWorld( playerid, g_syncData[ playerid ] [ E_WORLD ] );
		SetPlayerInterior( playerid, g_syncData[ playerid ] [ E_INTERIOR ] );
		SetPlayerSkin( playerid, g_syncData[ playerid ] [ E_SKIN ] );
		SetPlayerPos( playerid, g_syncData[ playerid ] [ E_X ], g_syncData[ playerid ] [ E_Y ], g_syncData[ playerid ] [ E_Z ] );
		SetPlayerFacingAngle( playerid, g_syncData[ playerid ] [ E_A ] );

		for( new slotid = 0; slotid < 13; slotid ++ ) {
			GivePlayerWeapon( playerid, g_syncData[ playerid ] [ E_WEAPON_ID ] [ slotid ], g_syncData[ playerid ] [ E_WEAPON_AMMO ] [ slotid ] );
		}

		SetPlayerArmedWeapon( playerid, g_syncData[ playerid ] [ E_CURRENT_WEAPON ] );
		SetCameraBehindPlayer( playerid );

		p_SyncingPlayer{ playerid } = false;
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return 1;
}

/*hook OnPlayerKeyStateChange( playerid, newkeys, oldkeys )
{
	if ( newkeys & KEY_SPRINT && newkeys & KEY_AIM ) {
		SyncPlayer( playerid, .message = false );
	}
	return 1;
}*/

/* ** Functions ** */
function DamageFeed_HideBulletLabel( labelid )
{
	DestroyDynamic3DTextLabel( Text3D: labelid );
	return 1;
}

public OnPlayerTakenDamage( playerid, issuerid, Float: amount, weaponid, bodypart )
{
	/* ** Label Damage Indicator ** */
	if ( issuerid != INVALID_PLAYER_ID )
	{
		static Float: fromX, Float: fromY, Float: fromZ;
		static Float: toX, Float: toY, Float: toZ;

		GetPlayerLastShotVectors( issuerid, fromX, fromY, fromZ, toX, toY, toZ );

		new
			Text3D: bullet_label = CreateDynamic3DTextLabel( sprintf( "%.0f", amount ), 0xFFFFFF80, toX, toY, toZ, 100.0, .interiorid = GetPlayerInterior( playerid ), .worldid = GetPlayerVirtualWorld( playerid ), .testlos = 1 );

		if ( IsValidDynamic3DTextLabel( bullet_label ) )
		{
			Streamer_Update( issuerid, STREAMER_TYPE_3D_TEXT_LABEL );
			Streamer_Update( playerid, STREAMER_TYPE_3D_TEXT_LABEL );
			SetTimerEx( "DamageFeed_HideBulletLabel", 1250, false, "d", _: bullet_label );
		}

		/* ** Armour and Health Object Damage ** */

		if ( ! p_GotHit{ playerid } )
		{
			static
				Float: armour;

			if ( GetPlayerArmour( playerid, armour ) )
			{
				// reset damage object for player
				DestroyObject( p_DamageObject[ playerid ] );
				p_DamageObject[ playerid ] = -1;

				// show damage object if the player is not in a vehicle (otherwise their heli explodes)
				if ( ! IsPlayerInAnyVehicle( playerid ) ) {
					p_DamageObject[ playerid ] = CreateObject( armour - amount <= 0.0 ? ( 1240 ) : ( 1242 ), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 100.0 );
					AttachObjectToPlayer( p_DamageObject[ playerid ], playerid, 0.0, 0.0, 1.5, 0.0, 0.0, 0.0 );
					SetTimerEx( "HideDamageObject", 1000, false, "d", playerid );
				}

			}
			
			// mark player as hit
			p_GotHit{ playerid } = true;
		}

		/* ** Hitmarker ** */
		DamageFeedAddHitGiven( issuerid, playerid, amount, weaponid );

		// play noise
		if ( IsDamageFeedActive( issuerid ) )
		{
			new
				soundid = p_VIPLevel[ issuerid ] ? p_HitmarkerSound{ issuerid } : 0;

	    	PlayerPlaySound( issuerid, g_HitmarkerSounds[ soundid ] [ E_SOUND_ID ], 0.0, 0.0, 0.0 );
	    }

	    // play noise for admins
	    foreach ( new i : Player )
	    {
			if ( IsPlayerSpectatingPlayer( i, issuerid ) )
			{
				new soundid = p_VIPLevel[ i ] ? p_HitmarkerSound{ i } : 0;
	    		PlayerPlaySound( i, g_HitmarkerSounds[ soundid ] [ E_SOUND_ID ], 0.0, 0.0, 0.0 );
			}
	    }
	}

	DamageFeedAddHitTaken( playerid, issuerid, amount, weaponid );
	return 1;
}

function HideDamageObject( playerid )
{
	if( IsValidObject( p_DamageObject[ playerid ] ) ) {
		DestroyObject( p_DamageObject[ playerid ] );
		p_DamageObject[ playerid ] = -1;
	}

	p_GotHit{ playerid } = false;
	return 1;
}

public OnPlayerFeedUpdate( playerid )
{
	p_damageFeedTimer[ playerid ] = -1;

	if ( IsPlayerConnected( playerid ) && IsDamageFeedActive( playerid ) ) {
		UpdateDamageFeed( playerid, true );
	}

	return 1;
}

stock DamageFeedAddHitGiven( playerid, issuerid, Float: amount, weaponid )
{
	foreach( new i : Player ) if ( p_Spectating{ i } && p_whomSpectating[ i ] == playerid && i != playerid ) {
		AddDamageHit( g_damageGiven[ i ], i, issuerid, amount, weaponid );
	}

	AddDamageHit( g_damageGiven[ playerid ], playerid, issuerid, amount, weaponid );
}

stock DamageFeedAddHitTaken( playerid, issuerid, Float: amount, weaponid )
{
	foreach( new i : Player ) if ( p_Spectating{ i } && p_whomSpectating[ i ] == playerid && i != playerid ) {
		AddDamageHit( g_damageTaken[ i ], i, issuerid, amount, weaponid );
	}

	AddDamageHit( g_damageTaken[ playerid ], playerid, issuerid, amount, weaponid );
}

stock IsPlayerSpectatingPlayer( playerid, targetid )
{
	return ( p_Spectating{ playerid } && p_whomSpectating[ playerid ] == targetid && playerid != targetid );
}

stock UpdateDamageFeed( playerid, bool: modified = false )
{
	/* ** Core ** */
	new szTick = GetTickCount( );
	if ( szTick == 0 ) szTick = 1;
	new lowest_tick = szTick + 1;

	for( new givenid = 0; givenid < sizeof( g_damageGiven[ ] ) - 1; givenid ++)
	{
		if ( !g_damageGiven[ playerid ] [ givenid ] [ E_TICK ] ) {
			break;
		}

		if ( szTick - g_damageGiven[ playerid ] [ givenid ] [ E_TICK ] >= HIDE_FEED_DELAY )
		{
			modified = true;

			for( new j = givenid; j < sizeof( g_damageGiven[ ] ) - 1; j++ ) {
				g_damageGiven[ playerid ] [ j ] [ E_TICK ] = 0;
			}

			break;
		}

		if ( g_damageGiven[ playerid ] [ givenid ] [ E_TICK ] < lowest_tick ) {
			lowest_tick = g_damageGiven[ playerid ] [ givenid ] [ E_TICK ];
		}
	}

	for( new takenid = 0; takenid < sizeof( g_damageTaken[ ] ) - 1; takenid ++)
	{
		if ( !g_damageTaken[ playerid ] [ takenid ] [ E_TICK ] ) {
			break;
		}

		if ( szTick - g_damageTaken[ playerid ] [ takenid ] [ E_TICK ] >= HIDE_FEED_DELAY )
		{
			modified = true;

			for( new j = takenid; j < sizeof( g_damageTaken[ ] ) - 1; j++ ) {
				g_damageTaken[ playerid ] [ j ] [ E_TICK ] = 0;
			}

			break;
		}

		if ( g_damageTaken[ playerid ] [ takenid ] [ E_TICK ] < lowest_tick ) {
			lowest_tick = g_damageTaken[ playerid ] [ takenid ] [ E_TICK ];
		}
	}

	if ( p_damageFeedTimer[ playerid ] != -1 ) {
		KillTimer( p_damageFeedTimer[ playerid ] );
	}

	if ( ( szTick - p_lastFeedUpdate[ playerid ] ) < MAX_UPDATE_RATE && modified )
	{
		p_damageFeedTimer[ playerid ] = SetTimerEx( "OnPlayerFeedUpdate", MAX_UPDATE_RATE - ( szTick - p_lastFeedUpdate[ playerid ] ) + 10, false, "d", playerid );
	}
	else
	{
		if ( lowest_tick == ( szTick + 1 ) )
		{
			p_damageFeedTimer[playerid] = -1;
			modified = true;
		}
		else
		{
			p_damageFeedTimer[playerid] = SetTimerEx( "OnPlayerFeedUpdate", HIDE_FEED_DELAY - ( szTick - lowest_tick ) + 10, false, "i", playerid );
		}

		if (modified)
		{
			UpdateDamageFeedLabel( playerid );

			p_lastFeedUpdate[ playerid ] = szTick;
		}
	}

	return 1;
}

stock UpdateDamageFeedLabel( playerid )
{
	new
		szLabel[ 64 * MAX_FEED_HEIGHT ] = "";

	for( new givenid = 0; givenid < sizeof( g_damageGiven[ ] ) - 1; givenid ++)
	{
		if ( !g_damageGiven[ playerid ] [ givenid ] [ E_TICK ] )
			break;

		new szWeapon[ 32 ];

		if ( g_damageGiven[ playerid ] [ givenid ] [ E_WEAPON ] == -1 ) {
			szWeapon = "Multiple";
		}
		else {
			GetWeaponName( g_damageGiven[ playerid ] [ givenid ] [ E_WEAPON ], szWeapon, sizeof( szWeapon ) );
		}

		if ( g_damageGiven[ playerid ] [ givenid ] [ E_ISSUER ] == INVALID_PLAYER_ID )
		{
			format( szLabel, sizeof( szLabel ), "%s%s +%.2f~n~", szLabel, szWeapon, g_damageGiven[ playerid ] [ givenid ] [ E_AMOUNT ] );
		}
		else
		{
			format( szLabel, sizeof( szLabel ), "%s%s - %s +%.2f~n~", szLabel, szWeapon, g_damageGiven[ playerid ] [ givenid ] [ E_NAME ], g_damageGiven[ playerid ] [ givenid ] [ E_AMOUNT ] );
		}
	}

	if ( g_damageFeedGivenTD[ playerid ] == PlayerText: INVALID_TEXT_DRAW ) {
		print( "[DAMAGE FEED ERROR] Doesn't have feed textdraw when needed ( g_damageFeedGivenTD )" );
	}
	else
	{
		if ( szLabel[ 0 ] )
		{
			PlayerTextDrawSetString( playerid, g_damageFeedGivenTD[ playerid ], szLabel );
			PlayerTextDrawShow( playerid, g_damageFeedGivenTD[ playerid ] );
		}
		else
		{
			PlayerTextDrawHide( playerid, g_damageFeedGivenTD[ playerid ] );
		}
	}

	szLabel = "";

	for( new takenid = 0; takenid < sizeof( g_damageTaken[ ] ) - 1; takenid ++)
	{
		if ( !g_damageTaken[ playerid ] [ takenid ] [ E_TICK ] )
			break;

		new szWeapon[ 32 ];

		if ( g_damageTaken[ playerid ] [ takenid ] [ E_WEAPON ] == -1 ) {
			szWeapon = "Multiple";
		}
		else {
			GetWeaponName( g_damageTaken[ playerid ] [ takenid ] [ E_WEAPON ], szWeapon, sizeof( szWeapon ) );
		}

		if ( g_damageTaken[ playerid ] [ takenid ] [ E_ISSUER ] == INVALID_PLAYER_ID )
		{
			format( szLabel, sizeof( szLabel ), "%s%s -%.2f~n~", szLabel, szWeapon, g_damageTaken[ playerid ] [ takenid ] [ E_AMOUNT ] );
		}
		else
		{
			format( szLabel, sizeof( szLabel ), "%s%s - %s -%.2f~n~", szLabel, szWeapon, g_damageTaken[ playerid ] [ takenid ] [ E_NAME ], g_damageTaken[ playerid ] [ takenid ] [ E_AMOUNT ] );
		}
	}

	if ( g_damageFeedTakenTD[ playerid ] == PlayerText: INVALID_TEXT_DRAW ) {
		print( "[DAMAGE FEED ERROR] Doesn't have feed textdraw when needed ( g_damageFeedTakenTD )" );
	}
	else
	{
		if ( szLabel[ 0 ] )
		{
			PlayerTextDrawSetString( playerid, g_damageFeedTakenTD[ playerid ], szLabel );
			PlayerTextDrawShow( playerid, g_damageFeedTakenTD[ playerid ] );
		}
		else
		{
			PlayerTextDrawHide( playerid, g_damageFeedTakenTD[ playerid ] );
		}
	}
}

stock RemoveDamageHit( array[ MAX_FEED_HEIGHT ] [ E_DAMAGE_FEED ], index )
{
	for( new i = 0; i < MAX_FEED_HEIGHT; i ++ )
	{
		if ( i >= index ) {
			array[ i ] [ E_TICK ] = 0;
		}
	}
}

stock AddDamageHit( array[ MAX_FEED_HEIGHT ] [ E_DAMAGE_FEED ], playerid, issuerid, Float: amount, weapon )
{
	if ( ! IsDamageFeedActive( playerid ) ) {
		return;
	}

	new szTick = GetTickCount( );
	if ( szTick == 0 ) szTick = 1;
	new wID = -1;

	for( new i = 0; i < sizeof( array ); i ++ )
	{
		if ( ! array[ i ] [ E_TICK ] ) {
			break;
		}

		if ( szTick - array[ i ] [ E_TICK ] >= HIDE_FEED_DELAY ) {
			RemoveDamageHit( array, i );
			break;
		}

		if ( array[ i ] [ E_ISSUER ] == issuerid )
		{
			amount += array[ i ] [ E_AMOUNT ];
			wID = i;
			break;
		}
	}

	if ( wID == -1 )
	{
		wID = 0;

		for( new i = sizeof( array ) - 1; i >= 1; i -- )
		{
			array[ i ] = array[ i - 1 ];
		}
	}

	array[ wID ] [ E_TICK ] = szTick;
	array[ wID ] [ E_AMOUNT ] = amount;
	array[ wID ] [ E_ISSUER ] = issuerid;
	array[ wID ] [ E_WEAPON ] = weapon;

	GetPlayerName( issuerid, array[ wID ] [ E_NAME ] , MAX_PLAYER_NAME );

	UpdateDamageFeed( playerid, true );
}

stock ShowSoundsMenu( playerid )
{
	static
		szSounds[ 11 * sizeof( g_HitmarkerSounds ) ];

	if ( szSounds[ 0 ] == '\0' )
	{
		for( new i = 0; i < sizeof( g_HitmarkerSounds ); i++ )
			format( szSounds, sizeof( szSounds ), "%s%s\n", szSounds, g_HitmarkerSounds[ i ] [ E_NAME ] );
	}
	ShowPlayerDialog( playerid, DIALOG_MODIFY_HITSOUND, DIALOG_STYLE_LIST, ""COL_WHITE"Hitmarker Sound", szSounds, "Select", "Close" );
}

/* ** Commands ** */
CMD:hitmarker( playerid, params[ ] )
{
	ShowSoundsMenu( playerid );
	return 1;
}

CMD:s( playerid, params[ ] ) return cmd_sync( playerid, params );
CMD:sync( playerid, params[ ] )
{
	if ( ! IsPlayerConnected( playerid ) || ! IsPlayerSpawned( playerid ) || p_SyncingPlayer{ playerid } == true || IsPlayerAFK( playerid ) )
		return SendError( playerid, "You cannot use this feature at the moment." );

	if ( IsPlayerJailed( playerid ) )
		return SendError( playerid, "You cannot use this feature while you are jailed." );

	if ( IsPlayerDetained( playerid ) )
		return SendError( playerid, "You cannot use this feature while you are detained." );

	if ( IsPlayerInAnyVehicle( playerid ) )
		return SendError( playerid, "You cannot synchronize yourself in a vehicle." );

	if ( IsPlayerTazed( playerid ) || IsPlayerCuffed( playerid ) || IsPlayerKidnapped( playerid ) || IsPlayerTied( playerid ) || IsPlayerLoadingObjects( playerid ) || IsPlayerSpawnProtected( playerid ) )
		return SendError( playerid, "You cannot synchronize yourself at the moment." );

	if ( GetPlayerWeapon( playerid ) == WEAPON_SNIPER )
		return SendError( playerid, "You cannot synchronize yourself holding a sniper." );

	if ( IsPlayerInBattleRoyale( playerid ) )
		return SendError( playerid, "You cannot use this command while in Battle Royale." );
	
	new
		curr_server_time = GetServerTime( );

	if ( GetPVarInt( playerid, "sync_cooldown" ) > curr_server_time )
		return SendServerMessage( playerid, "Please wait %d seconds seconds before using this feature again.", GetPVarInt( playerid, "sync_cooldown" ) - curr_server_time );

	SetPVarInt( playerid, "sync_cooldown", curr_server_time + 30 );

	p_SyncingPlayer{ playerid } = true;

	// ** Obtaining Information **
	GetPlayerHealth( playerid, g_syncData[ playerid ] [ E_HEALTH ] );
	GetPlayerArmour( playerid, g_syncData[ playerid ] [ E_ARMOUR ] );
	g_syncData[ playerid ] [ E_CURRENT_WEAPON ] = GetPlayerWeapon( playerid );
	g_syncData[ playerid ] [ E_WORLD ] = GetPlayerVirtualWorld( playerid );
	g_syncData[ playerid ] [ E_INTERIOR ] = GetPlayerInterior( playerid );
	g_syncData[ playerid ] [ E_SKIN ] = GetPlayerSkin( playerid );
	g_syncData[ playerid ] [ E_WANTED_LEVEL ] = GetPlayerWantedLevel( playerid );

	GetPlayerPos( playerid, g_syncData[ playerid ] [ E_X ], g_syncData[ playerid ] [ E_Y ], g_syncData[ playerid ] [ E_Z ] );
	GetPlayerFacingAngle( playerid, g_syncData[ playerid ] [ E_A ] );

	for( new slotid = 0; slotid < 13; slotid ++ ) {
		GetPlayerWeaponData( playerid, slotid, g_syncData[ playerid ] [ E_WEAPON_ID ] [ slotid ], g_syncData[ playerid ] [ E_WEAPON_AMMO ] [ slotid ] );
	}

	//ResetPlayerWeapons( playerid );
	ClearAnimations( playerid );

	// Reinstating Information
	SpawnPlayer( playerid );
	SendServerMessage( playerid, "You are now synchronized." );
	return 1;
}
