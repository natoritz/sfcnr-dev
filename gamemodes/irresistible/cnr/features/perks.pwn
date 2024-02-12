/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\features\perks.pwn
 * Purpose: perks system
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Variables ** */
static stock
	bool: p_OffRadar 				[ MAX_PLAYERS char ],
	p_OffRadarTimestamp 			[ MAX_PLAYERS ],
	p_OffRadarVisible 				[ MAX_PLAYERS ]
;

/* ** Hooks ** */
hook OnPlayerDisconnect( playerid, reason )
{
	p_OffRadar{ playerid } = false;
	return 1;
}

hook OnPlayerSpawn( playerid )
{
	p_OffRadar{ playerid } = false;
	return 1;
}

hook OnPlayerUpdateEx( playerid )
{
	if ( IsPlayerHiddenFromRadar( playerid ) )
	{
		new
			current_time = GetServerTime( );

		// Expire stealth mode after 30 seconds
		if ( p_OffRadarTimestamp[ playerid ] != 0 && current_time > p_OffRadarTimestamp[ playerid ] ) {
			p_OffRadar{ playerid } = false;
			SetPlayerColorToTeam( playerid );
			SendServerMessage( playerid, "Your hide from radar perk has now expired." );
		}

		// Stealth mode after getting shot
		else if ( p_OffRadarVisible[ playerid ] != 0 && current_time > p_OffRadarVisible[ playerid ] ) {
			SetPlayerColorToTeam( playerid ), p_OffRadarVisible[ playerid ] = 0;
		}
	}
	return 1;
}

hook OnPlayerWeaponShot( playerid, weaponid, hittype, hitid, Float: fX, Float: fY, Float: fZ )
{
	if ( hittype == BULLET_HIT_TYPE_PLAYER ) {
		// Exposing stealth mode player
		if ( IsPlayerHiddenFromRadar( playerid ) ) {
			SetPlayerColor( playerid, setAlpha( GetPlayerColor( playerid ), 0xFF ) ), p_OffRadarVisible[ playerid ] = g_iTime + 2;
		}
	}
	return 1;
}

hook OnDialogResponse( playerid, dialogid, response, listitem, inputtext[ ] )
{
	#if defined __cloudy_event_system
	if ( IsPlayerInEvent( playerid ) && ! EventSettingAllow( EVENT_SETTING_PERKS ) ) {
		return 1;
	}
	#endif

	if ( dialogid == DIALOG_PERKS && response )
	{
		switch( listitem )
		{
			case 0: ShowPlayerDialog( playerid, DIALOG_PERKS_P, DIALOG_STYLE_TABLIST_HEADERS, "{FFFFFF}Deathmatch Perks", ""COL_WHITE"Item Name\t"COL_WHITE"Cost (XP)\nHide From Radar\t"COL_GREEN"250 XP\nUnlimited Ammunition\t"COL_GREEN"100 XP", "Select", "Back" );
			case 1: ShowPlayerDialog( playerid, DIALOG_PERKS_V, DIALOG_STYLE_TABLIST_HEADERS, "{FFFFFF}Robbery Perks", ""COL_WHITE"Item Name\t"COL_WHITE"Cost (XP)\nFix & Flip vehicle\t"COL_GREEN"180 XP\nRepair Vehicle\t"COL_GREEN"120 XP\nAdd NOS\t"COL_GREEN"80 XP\nFlip vehicle\t"COL_GREEN"50 XP", "Select", "Back" );
		}
	}
	else if ( dialogid == DIALOG_PERKS_P )
	{
	    if ( !response )
	        return ShowPlayerDialog( playerid, DIALOG_PERKS, DIALOG_STYLE_LIST, "{FFFFFF}Game Perks", "Deathmatch Perks\nRobbery Perks", "Select", "Cancel" );

	    new
			Float: total_dm_xp = GetPlayerExperience( playerid, E_DEATHMATCH );

	    switch( listitem )
	    {
	        case 0:
	        {
	        	if ( total_dm_xp < 250 ) {
	        		return SendError( playerid, "You need at least 250 Deathmatch XP for this item." );
	        	}

	        	if ( GetPlayerClass( playerid ) != CLASS_CIVILIAN ) {
	        		return SendError( playerid, "You need to be a civilian to use this perk." );
	        	}

	        	p_OffRadar{ playerid } = true;
				p_OffRadarTimestamp[ playerid ] = GetServerTime( ) + 180;

	        	GivePlayerExperience( playerid, E_DEATHMATCH, -250, .with_dilation = false );

	        	SendServerMessage( playerid, "You have hidden yourself from the radar (3 minutes) for 250 Deathmatch XP." );
	        	ShowPlayerHelpDialog( playerid, 3000, "~g~~h~Hide from radar ~w~will be deactivate in 3 minutes." );

	        	SetPlayerColor( playerid, setAlpha( GetPlayerColor( playerid ), 0x00 ) );
	        	Beep( playerid );
	        }

	        case 1:
	        {
	        	if ( total_dm_xp < 100 ) {
	        		return SendError( playerid, "You need at least 100 Deathmatch XP for this item." );
	        	}

                for ( new i = 0; i < MAX_WEAPONS; i++ )
				{
				    if ( IsWeaponInAnySlot( playerid, i ) && i != 0 && !( 16 <= i <= 18 ) && i != 35 && i != 47 && i != WEAPON_BOMB )
				    {
				        GivePlayerWeapon( playerid, i, 15000 );
				    }
				}

	        	GivePlayerExperience( playerid, E_DEATHMATCH, -100, .with_dilation = false );

				SendServerMessage( playerid, "You have bought unlimited ammunition for 100 Deathmatch XP." );
				SetPlayerArmedWeapon( playerid, 0 );
				Beep( playerid );
	        }
	    }
	}
	else if ( dialogid == DIALOG_PERKS_V )
	{
	    if ( !response )
	        return ShowPlayerDialog( playerid, DIALOG_PERKS, DIALOG_STYLE_LIST, "{FFFFFF}Game Perks", "Deathmatch Perks\nRobbery Perks", "Select", "Cancel" );

		if ( !IsPlayerInAnyVehicle( playerid ) || GetPlayerState( playerid ) != PLAYER_STATE_DRIVER )
		    return SendError( playerid, "You are not in any vehicle as a driver." );

		new
			Float: total_robbery_xp = GetPlayerExperience( playerid, E_ROBBERY );

	    switch( listitem )
	    {
	    	case 0:
	        {
	        	if ( total_robbery_xp < 180 ) {
	        		return SendError( playerid, "You need at least 180 Robbery XP for this item." );
	        	}

	            new Float: vZ, vehicleid = GetPlayerVehicleID( playerid );
				GetVehicleZAngle( vehicleid, vZ ), SetVehicleZAngle( vehicleid, vZ );
                RepairVehicle( vehicleid );
				GivePlayerExperience( playerid, E_ROBBERY, -180, .with_dilation = false );
				SendServerMessage( playerid, "You have fixed and flipped your vehicle for 180 Robbery XP." );
				PlayerPlaySound( playerid, 1133, 0.0, 0.0, 5.0 );
	        }
	        case 1:
	        {
	        	if ( total_robbery_xp < 120 ) {
	        		return SendError( playerid, "You need at least 120 Robbery XP for this item." );
	        	}

            	new vehicleid = GetPlayerVehicleID( playerid );
				PlayerPlaySound( playerid, 1133, 0.0, 0.0, 5.0 );
                RepairVehicle( vehicleid );
				GivePlayerExperience( playerid, E_ROBBERY, -120, .with_dilation = false );
				SendServerMessage( playerid, "You have repaired your car for 120 Robbery XP." );
	        }
	        case 2:
	        {
	        	if ( total_robbery_xp < 80 ) {
	        		return SendError( playerid, "You need at least 80 Robbery XP for this item." );
	        	}

                AddVehicleComponent( GetPlayerVehicleID( playerid ), 1010 );
				GivePlayerExperience( playerid, E_ROBBERY, -80, .with_dilation = false );
				SendServerMessage( playerid, "You have repaired your car for 80 Robbery XP." );
				PlayerPlaySound( playerid, 1133, 0.0, 0.0, 5.0 );
	        }
	        case 3:
	        {
	        	if ( total_robbery_xp < 50 ) {
	        		return SendError( playerid, "You need at least 50 Robbery XP for this item." );
	        	}

	            new Float: vZ, vehicleid = GetPlayerVehicleID( playerid );
				GetVehicleZAngle( vehicleid, vZ ), SetVehicleZAngle( vehicleid, vZ );
				GivePlayerExperience( playerid, E_ROBBERY, -50, .with_dilation = false );
				SendServerMessage( playerid, "You have repaired your car for 50 Robbery XP." );
				PlayerPlaySound( playerid, 1133, 0.0, 0.0, 5.0 );
	        }
	    }
	}
	return 1;
}

/* ** Commands ** */
CMD:perks( playerid, params[ ] )
{
	#if defined __cloudy_event_system
	if ( IsPlayerInEvent( playerid ) && ! EventSettingAllow( EVENT_SETTING_PERKS ) ) {
		return SendError( playerid, "You cannot use this command since you're in an event." );
	}
	#else
	if ( IsPlayerInEvent( playerid ) || IsPlayerInBattleRoyale( playerid ) ) {
		return SendError( playerid, "You cannot use this command since you're in an event." );
	}
	#endif

	if ( IsPlayerInArmyVehicle( playerid ) )
		return SendError( playerid, "You cannot use this command while in an army vehicle." );

	return ShowPlayerDialog( playerid, DIALOG_PERKS, DIALOG_STYLE_LIST, "{FFFFFF}Game Perks", "Deathmatch Perks\nRobbery Perks", "Select", "Cancel" );
}

/* ** Functions ** */
stock IsPlayerHiddenFromRadar( playerid ) {
	return p_OffRadar{ playerid };
}
