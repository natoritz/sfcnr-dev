/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr/commands/admin/admin_three.pwn
 * Purpose: level three administrator commands (cnr)
 */

/* ** Commands ** */
CMD:resetwep( playerid, params[ ] )
{
	new
		pID
	;
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, """u""", pID ) ) return SendUsage( playerid, "/resetwep [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else
	{
		ResetPlayerWeapons( pID );
        AddAdminLogLineFormatted( "%s(%d) has reset %s(%d)'s weapons", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have reset %s(%d)'s weapons.", ReturnPlayerName( pID ), pID );
		SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]"COL_WHITE" Your weapons have been reset by %s(%d).", ReturnPlayerName( playerid ), playerid );
	}
	return 1;
}

CMD:getip( playerid, params[ ] )
{
	new
		pID
	;
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, """u""", pID ) ) return SendUsage( playerid, "/getip [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( p_AdminLevel[ pID ] >= 5 || IsPlayerServerMaintainer( pID ) ) return SendError( playerid, "I love this person so much that I wont give you his IP :)");
	else
	{
		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d): "COL_GREY"%s", ReturnPlayerName( pID ), pID, ReturnPlayerIP( pID ) );
	}
	return 1;
}

CMD:geolocate( playerid, params[ ] )
{
	new pID;
 	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
 	else if ( sscanf( params, """u""", pID ) ) return SendUsage( playerid, "/geolocate [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( !IsProxyEnabledForPlayer( pID ) ) return SendError( playerid, "The server has failed to fetch geographical data. Please use a 3rd party." );
	else if ( p_AdminLevel[ pID ] >= 5 || IsPlayerServerMaintainer( pID ) ) return SendError( playerid, "I love this person so much that I wont give you his geographical data! :)");
 	else
 	{
		SendClientMessageFormatted( playerid, COLOR_PINK, "[ADMIN]"COL_WHITE" %s(%d) is from %s (%s) [%s]", ReturnPlayerName( pID ), pID, GetPlayerCountryName( pID ), GetPlayerCountryCode( pID ), ReturnPlayerIP( pID ) );
	}
	return 1;
}

CMD:copwarn( playerid, params [ ] )
{
    new
	    pID,
	    reason[ 32 ]
	;
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, """u""S(No Reason)[32]", pID, reason ) ) return SendUsage( playerid, "/copwarn [PLAYER_ID] [REASON]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( p_CopBanned{ pID } >= MAX_CLASS_BAN_WARNS ) return SendError( playerid, "This player is cop-banned." );
    else if ( p_AdminLevel[ playerid ] < p_AdminLevel[ pID ] ) return SendError( playerid, "This player has a higher administration level than you." );
	else
	{
		if ( p_AdminCommandPause[ pID ] > g_iTime )
			return SendError( playerid, "You must wait %d seconds before using this admin command on the player.", p_AdminCommandPause[ pID ] - g_iTime );

		p_AdminCommandPause[ pID ] = g_iTime + ADMIN_COMMAND_TIME;

		new
			iWarns = WarnPlayerClass( pID, .bArmy = false );

		if ( iWarns >= MAX_CLASS_BAN_WARNS )
		{
	        AddAdminLogLineFormatted( "%s(%d) has cop-banned %s(%d) [%d/%d]", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, iWarns, MAX_CLASS_BAN_WARNS );
		    SendGlobalMessage( -1, ""COL_PINK"[ADMIN]{FFFFFF} %s has cop-banned %s(%d) due to excessive cop-warnings "COL_GREEN"[REASON: %s]", ReturnPlayerName( playerid ), ReturnPlayerName( pID ), pID, reason );
		}
		else
		{
	        AddAdminLogLineFormatted( "%s(%d) has cop-warned %s(%d) [%d/%d]", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, iWarns, MAX_CLASS_BAN_WARNS );
		    SendGlobalMessage( -1, ""COL_PINK"[ADMIN]{FFFFFF} %s has cop-warned %s(%d) "COL_GREEN"[REASON: %s]", ReturnPlayerName( playerid ), ReturnPlayerName( pID ), pID, reason );
		}
	}
	return 1;
}

CMD:armywarn( playerid, params [ ] )
{
    new
	    pID,
	    reason[ 32 ]
	;
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, """u""S(No Reason)[32]", pID, reason ) ) return SendUsage( playerid, "/armywarn [PLAYER_ID] [REASON]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( p_ArmyBanned{ pID } >= MAX_CLASS_BAN_WARNS ) return SendError( playerid, "This player is army-banned." );
    else if ( p_AdminLevel[ playerid ] < p_AdminLevel[ pID ] ) return SendError( playerid, "This player has a higher administration level than you." );
	else
	{
		if ( p_AdminCommandPause[ pID ] > g_iTime )
			return SendError( playerid, "You must wait %d seconds before using this admin command on the player.", p_AdminCommandPause[ pID ] - g_iTime );

		p_AdminCommandPause[ pID ] = g_iTime + ADMIN_COMMAND_TIME;

		new
			iWarns = WarnPlayerClass( pID, .bArmy = true );

		if ( iWarns >= MAX_CLASS_BAN_WARNS )
		{
	        AddAdminLogLineFormatted( "%s(%d) has army-banned %s(%d) [%d/%d]", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, iWarns, MAX_CLASS_BAN_WARNS );
		    SendGlobalMessage( -1, ""COL_PINK"[ADMIN]{FFFFFF} %s has army-banned %s(%d) due to excessive army-warnings "COL_GREEN"[REASON: %s]", ReturnPlayerName( playerid ), ReturnPlayerName( pID ), pID, reason );
		}
		else
		{
	        AddAdminLogLineFormatted( "%s(%d) has army-warned %s(%d) [%d/%d]", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, iWarns, MAX_CLASS_BAN_WARNS );
		    SendGlobalMessage( -1, ""COL_PINK"[ADMIN]{FFFFFF} %s has army-warned %s(%d) "COL_GREEN"[REASON: %s]", ReturnPlayerName( playerid ), ReturnPlayerName( pID ), pID, reason );
		}
	}
	return 1;
}

CMD:rcopwarn( playerid, params [ ] )
{
    new
	    pID;

	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/rcopwarn [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( !p_CopBanned{ pID } ) return SendError( playerid, "This player does not have any cop warns." );
    else if ( p_AdminLevel[ playerid ] < p_AdminLevel[ pID ] ) return SendError( playerid, "This player has a higher administration level than you." );
	else
	{
		new
			iWarns = WarnPlayerClass( pID, .bArmy = false, .iPoints = -1 );

        AddAdminLogLineFormatted( "%s(%d) has removed a cop-warn from %s(%d) [%d/%d]", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, iWarns, MAX_CLASS_BAN_WARNS );
	    SendGlobalMessage( -1, ""COL_PINK"[ADMIN]{FFFFFF} %s has removed a cop-warn from %s(%d)!", ReturnPlayerName( playerid ), ReturnPlayerName( pID ), pID );
	}
	return 1;
}

CMD:rarmywarn( playerid, params [ ] )
{
    new
	    pID;

	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/rarmywarn [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( !p_ArmyBanned{ pID } ) return SendError( playerid, "This player does not have any army warns." );
    else if ( p_AdminLevel[ playerid ] < p_AdminLevel[ pID ] ) return SendError( playerid, "This player has a higher administration level than you." );
	else
	{
		new
			iWarns = WarnPlayerClass( pID, .bArmy = true, .iPoints = -1 );

        AddAdminLogLineFormatted( "%s(%d) has removed an army-warn from %s(%d) [%d/%d]", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, iWarns, MAX_CLASS_BAN_WARNS );
	    SendGlobalMessage( -1, ""COL_PINK"[ADMIN]{FFFFFF} %s has removed an army-warn from %s(%d)!", ReturnPlayerName( playerid ), ReturnPlayerName( pID ), pID );
	}
	return 1;
}

/*CMD:forcecoptutorial( playerid, params[ ] )
{
	new pID;
	if ( p_AdminLevel[ playerid ] < 2 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, """u""", pID ) ) SendUsage( playerid, "/forcecoptutorial [PLAYER_ID]" );
    else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
    else if ( p_AdminLevel[ pID ] > p_AdminLevel[ playerid ] ) return SendError( playerid, "You cannot use this command on admins higher than your level." );
    else
	{
	    SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) has forced you to view the law enforcement officer tutorial.", ReturnPlayerName( playerid ), playerid );
		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have forced the law enforcement officer tutorial on %s(%d).", ReturnPlayerName( pID ), pID );
		p_CopTutorial{ pID } = 0;
		if ( p_Class[ pID ] == CLASS_POLICE ) SpawnPlayer( pID );
	}
	return 1;
}*/

CMD:ann( playerid, params[ ] ) return cmd_announce( playerid, params );
CMD:announce( playerid, params[ ] )
{
    new Message[60];
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, "s[60]", Message ) ) SendUsage(playerid, "/announce [MESSAGE]");
    else if ( !IsSafeGameText( Message ) ) return SendError( playerid, "Your message is not safe for players to view." );
    else
	{
        GameTextForAll( sprintf( "~w~%s", Message ), 6000, 3 );
        printf( "[ANNOUNCEMENT]: %s(%d) has announced \"%s\"", ReturnPlayerName( playerid ), playerid, Message );

		strreplacechar	( Message, '~', ']' );
        AddAdminLogLineFormatted( "%s(%d) has announced \"%s\"", ReturnPlayerName( playerid ), playerid, Message );
    }
    return 1;
}

CMD:aheal( playerid, params[ ] )
{
	new pID;
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, "u", pID ) ) SendUsage( playerid, "/aheal [PLAYER_ID]" );
    else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
    else if ( IsPlayerJailed( pID ) ) return SendError( playerid, "This player is jailed, you cannot do this." );
    else if ( IsPlayerAdminOnDuty( pID ) ) return SendError( playerid, "This player is an admin on duty, you cannot do this." );
    else
	{
	    SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) healed you.", ReturnPlayerName( playerid ), playerid );
		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have healed %s(%d).", ReturnPlayerName( pID ), pID );
        AddAdminLogLineFormatted( "%s(%d) has healed %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
		SetPlayerHealth( pID, 100.0 );
	}
	return 1;
}

CMD:healall( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 3 )
		return SendError( playerid, ADMIN_COMMAND_REJECT );

	new admin_world = GetPlayerVirtualWorld( playerid );

	AddAdminLogLineFormatted( "%s(%d) has healed everybody", ReturnPlayerName( playerid ), playerid );
	foreach(new i : Player) {
		new loop_world = GetPlayerVirtualWorld( i );
	    if ( !p_Jailed{ i } && loop_world == admin_world ) SetPlayerHealth( i, p_AdminOnDuty{ i } == true ? float( INVALID_PLAYER_ID ) : 100.0 );
	}
	SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" All players have been healed in %s's(%d) world!", ReturnPlayerName( playerid ), playerid );
	return 1;
}

CMD:vadminstats( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 3 )
		return SendError( playerid, ADMIN_COMMAND_REJECT );

	if ( !IsPlayerInAnyVehicle( playerid ) )
	    return SendError( playerid, "You are not in any vehicle." );

	if ( g_buyableVehicle{ GetPlayerVehicleID( playerid ) } == false )
		return SendError( playerid, "This vehicle isn't a buyable vehicle." );

	new
		ownerid, slotid,
		v = getVehicleSlotFromID( GetPlayerVehicleID( playerid ), ownerid, slotid )
	;

	if ( v == -1 ) return SendError( playerid, "This vehicle doesn't look like it can be examined. (0xAA)" );
	if ( g_vehicleData[ ownerid ] [ slotid ] [ E_CREATED ] == false ) return SendError( playerid, "This vehicle doesn't look like it can be examined. (0xAF)" );

	format( szBigString, sizeof( szBigString ), 	""COL_GREY"Vehicle Owner:"COL_WHITE" %s\n"\
	                            ""COL_GREY"Vehicle Type:"COL_WHITE" %s\n"\
	                            ""COL_GREY"Vehicle ID:"COL_WHITE" %d\n"\
	                            ""COL_GREY"Vehicle Price:"COL_WHITE" %s",
	                            ReturnPlayerName( ownerid ), GetVehicleName( GetVehicleModel( GetPlayerVehicleID( playerid ) ) ),
	                            g_vehicleData[ ownerid ] [ slotid ] [ E_SQL_ID ], cash_format( g_vehicleData[ ownerid ] [ slotid ] [ E_PRICE ] ) );

	ShowPlayerDialog( playerid, DIALOG_NULL, DIALOG_STYLE_MSGBOX, "{FFFFFF}Vehicle Data", szBigString, "Okay", "" );
	return 1;
}

CMD:vadminpark( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 3 )
		return SendError( playerid, ADMIN_COMMAND_REJECT );

	if ( !IsPlayerInAnyVehicle( playerid ) )
	    return SendError( playerid, "You are not in any vehicle." );

	if ( g_buyableVehicle{ GetPlayerVehicleID( playerid ) } == false )
		return SendError( playerid, "This vehicle isn't a buyable vehicle." );

	new
		ownerid, slotid, vehicleid = GetPlayerVehicleID( playerid ),
		v = getVehicleSlotFromID( vehicleid, ownerid, slotid ),
		Float: X, Float: Y, Float: Z, Float: Angle
	;

	if ( v == -1 ) return SendError( playerid, "This vehicle doesn't look like it can be parked. (0xAA)" );
	if ( g_vehicleData[ ownerid ] [ slotid ] [ E_CREATED ] == false ) return SendError( playerid, "This vehicle doesn't look like it can be parked. (0xAF)" );

    new
    	iBreach = PlayerBreachedGarageLimit( playerid, v, .admin_place = true );

	if ( iBreach == -1 ) return SendError( playerid, "You cannot park vehicles that are not owned by the owner of this garage." );
	if ( iBreach == -2 ) return SendError( playerid, "This garage has already reached its capacity of %d vehicles.", g_garageInteriorData[ g_garageData[ p_InGarage[ playerid ] ] [ E_INTERIOR_ID ] ] [ E_VEHICLE_CAPACITY ] );

	GetVehiclePos( vehicleid, X, Y, Z );
	GetVehicleZAngle( vehicleid, Angle );

	g_vehicleData[ ownerid ] [ slotid ] [ E_X ] = X, g_vehicleData[ ownerid ] [ slotid ] [ E_Y ] = Y, g_vehicleData[ ownerid ] [ slotid ] [ E_Z ] = Z, g_vehicleData[ ownerid ] [ slotid ] [ E_ANGLE ] = Angle;

	PutPlayerInVehicle( playerid, RespawnBuyableVehicle( vehicleid, playerid ), 0 );
	SaveVehicleData( ownerid, slotid );

	SendClientMessage( playerid, -1, ""COL_GREY"[VEHICLE]"COL_WHITE" You have parked this vehicle via administration." );
	return 1;
}

CMD:givewep( playerid, params[ ] ) return cmd_giveweapon( playerid, params );
CMD:giveweapon( playerid, params[ ] )
{
    new
		pID,
		wep,
		ammo,
		gunname[ 32 ]
	;

	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, """u""dd", pID, wep, ammo ) ) return SendUsage(playerid, "/giveweapon [PLAYER_ID] [WEAPON_ID] [AMMO]");
    else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
    else if ( !( 0 <= wep < MAX_WEAPONS ) || wep == 47 ) return SendError(playerid, "Invalid weapon id");
    else if ( IsWeaponBanned( wep ) && p_AdminLevel[ pID ] < 5 ) return SendError( playerid, "This weapon is a banned weapon, you cannot spawn this." );
    else
	{
		//printf("%s banned wep %d - admin level %d", ReturnPlayerName( pID ), wep, p_AdminLevel[ playerid ]);
        GetWeaponName( wep, gunname, sizeof( gunname ) );
        AddAdminLogLineFormatted( "%s(%d) has given %s(%d) a %s", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, gunname );
		SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have given %s(%d) a %s(%d)", ReturnPlayerName( pID ), pID, gunname, wep );
        SendClientMessageFormatted( pID, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have been given a %s from %s(%d)", gunname, ReturnPlayerName( playerid ), playerid );
        GivePlayerWeapon( pID, wep, ammo );
    }
    return 1;
}

CMD:cc( playerid, params[ ] ) return cmd_clearchat( playerid, params );
CMD:clearchat( playerid, params[ ] )
{
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	for( new i = 0; i < 50; i++ ) {
	    SendClientMessageToAll( -1, " " );
	}
    SendGlobalMessage( -1, ""COL_PINK"[ADMIN]{FFFFFF} %s cleared the chat.", ReturnPlayerName( playerid ) );
	AddAdminLogLineFormatted( "%s(%d) has cleared the chat", ReturnPlayerName( playerid ), playerid );
	return 1;
}

CMD:vbring( playerid, params[ ] )
{
	new vID;
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", vID ) ) return SendUsage( playerid, "/vbring [VEHICLE_ID]" );
	else if ( !IsValidVehicle( vID ) ) return SendError( playerid, "Invalid Vehicle ID." );
	else
	{
	    new Float: X, Float: Y, Float: Z;
	    GetPlayerPos( playerid, X, Y, Z );
	    LinkVehicleToInterior( vID, GetPlayerInterior( playerid ) );
	    SetVehicleVirtualWorld( vID, GetPlayerVirtualWorld( playerid ) );
	    SetVehiclePos( vID, X + 1, Y + 1, Z );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have brought vehicle id %d to you.", vID );
	  	AddAdminLogLineFormatted( "%s(%d) has brought vehicle id %d to them", ReturnPlayerName( playerid ), playerid, vID );
    }
	return 1;
}

CMD:vgoto( playerid, params[ ] )
{
	new vID;
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", vID ) ) return SendUsage( playerid, "/vgoto [VEHICLE_ID]" );
	else if ( !IsValidVehicle( vID ) ) return SendError( playerid, "Invalid Vehicle ID." );
	else
	{
	    new Float: X, Float: Y, Float: Z;
	    GetVehiclePos( vID, X, Y, Z );
	    SetPlayerPos( playerid, X + 1, Y + 1, Z );
	    SetPlayerInterior( playerid, 0 );
	    SetPlayerVirtualWorld( playerid, 0 );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have gone to vehicle id %d.", vID );
	  	AddAdminLogLineFormatted( "%s(%d) has gone to vehicle id %d", ReturnPlayerName( playerid ), playerid, vID );
    }
	return 1;
}

CMD:venter( playerid, params[ ] )
{
	new vID;
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", vID ) ) return SendUsage( playerid, "/venter [VEHICLE_ID]" );
	else if ( !IsValidVehicle( vID ) ) return SendError( playerid, "Invalid Vehicle ID." );
	else
	{
		// Maybe virtual world support
	    SetPlayerVirtualWorld( playerid, GetVehicleVirtualWorld( vID ) );
	    PutPlayerInVehicle( playerid, vID, 0 );

	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have entered the vehicle id %d.", vID );
	  	AddAdminLogLineFormatted( "%s(%d) has entered the vehicle id %d", ReturnPlayerName( playerid ), playerid, vID );
    }
	return 1;
}

CMD:vforce( playerid, params[ ] )
{
	new pID, vID;
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, """u""d", pID, vID ) ) return SendUsage( playerid, "/vforce [PLAYER_ID] [VEHICLE_ID]" );
    else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( !IsValidVehicle( vID ) ) return SendError( playerid, "Invalid Vehicle ID." );
	else
	{
		// Maybe virtual world support
	    SetPlayerVirtualWorld( pID, GetVehicleVirtualWorld( vID ) );
	    PutPlayerInVehicle( pID, vID, 0 );

	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have forced %s(%d) to enter the vehicle id %d.", ReturnPlayerName( pID ), pID, vID );
	  	AddAdminLogLineFormatted( "%s(%d) has forced %s to enter the vehicle id %d.", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), vID );
    }
	return 1;
}

CMD:hgoto( playerid, params[ ] )
{
	new hID;
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", hID ) ) return SendUsage( playerid, "/hgoto [HOUSE_ID]" );
	else if ( hID < 0 || hID >= MAX_HOUSES ) return SendError( playerid, "Invalid House ID." );
	else if ( ! Iter_Contains( houses, hID ) ) return SendError( playerid, "Invalid House ID." );
	else
	{
	    SetPlayerPos( playerid, g_houseData[ hID ] [ E_EX ], g_houseData[ hID ] [ E_EY ], g_houseData[ hID ] [ E_EZ ] );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have went to house id %d.", hID );
	  	AddAdminLogLineFormatted( "%s(%d) has went to house id %d", ReturnPlayerName( playerid ), playerid, hID );
    }
	return 1;
}

CMD:bgoto( playerid, params[ ] )
{
	new bID;
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", bID ) ) return SendUsage( playerid, "/bgoto [BUSINESS_ID]" );
	else if ( bID < 0 || bID >= MAX_BUSINESSES ) return SendError( playerid, "Invalid Business ID." );
	else if ( ! Iter_Contains( business, bID ) ) return SendError( playerid, "Invalid Business ID." );
	else
	{
	    SetPlayerPos( playerid, g_businessData[ bID ] [ E_X ], g_businessData[ bID ] [ E_Y ], g_businessData[ bID ] [ E_Z ] );
	    SendClientMessageFormatted( playerid, -1, ""COL_PINK"[ADMIN]"COL_WHITE" You have went to business id %d.", bID );
	  	AddAdminLogLineFormatted( "%s(%d) has went to business id %d", ReturnPlayerName( playerid ), playerid, bID );
    }
	return 1;
}

CMD:cd( playerid, params[ ] ) return cmd_countdown( playerid, params );
CMD:countdown( playerid, params[ ] )
{
	new seconds;
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "d", seconds ) ) return SendUsage( playerid, "/countdown [SECONDS]" );
	else if ( seconds < 0 || seconds > 30 ) return SendError( playerid, "Please specify a time between 0 and 30 seconds." );
	else if ( g_circleall_CD ) return SendError( playerid, "Countdown is already in progress." );
	else
	{
        g_circleall_CD = true;
	    SetTimerEx( "circleall_Countdown", 960, false, "dd", seconds, 1 );
	    SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) has initiated a countdown starting from %d.", ReturnPlayerName( playerid ), playerid, seconds );
		AddAdminLogLineFormatted( "%s(%d) has initiated a countdown from %d", ReturnPlayerName( playerid ), playerid, seconds );
    }
	return 1;
}

CMD:pingimmune( playerid, params[ ] )
{
    new pID;
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, """u""", pID ) ) return SendUsage( playerid, "/pingimmune [PLAYER_ID]" );
    else if ( !IsPlayerConnected(pID) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
    else if ( p_AdminLevel[ pID ] > 0 ) return SendError( playerid, "Admins already have immunity." );
    else
	{
 		p_PingImmunity{ pID } = ( p_PingImmunity{ pID } == 0 ? 1 : 0 );
		SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_WHITE" %s(%d) has made %s(%d) %s to the ping kicker.", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, p_PingImmunity{ pID } == 0 ? ("prone") : ("immune") );
        AddAdminLogLineFormatted( "%s(%d) has made %s(%d) %s to the ping kicker", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID, p_PingImmunity{ pID } == 0 ? ("prone") : ("immune") );
    }
    return 1;
}

CMD:ban( playerid, params [ ] )
{
    new
	    pID,
		reason[ 50 ]
	;
	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, """u""S(No Reason)[50]", pID, reason ) ) return SendUsage( playerid, "/ban [PLAYER_ID] [REASON]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	// else if ( pID == playerid ) return SendError( playerid, "You cannot ban yourself." );
  	else if ( p_AdminLevel[ playerid ] < p_AdminLevel[ pID ] ) return SendError( playerid, "This player has a higher administration level than you." );
	else
	{
		adhereBanCodes( reason );
        AddAdminLogLineFormatted( "%s(%d) has banned %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
	    SendGlobalMessage( -1, ""COL_PINK"[ADMIN]{FFFFFF} %s has banned %s(%d) "COL_GREEN"[REASON: %s]", ReturnPlayerName( playerid ), ReturnPlayerName( pID ), pID, reason );
		AdvancedBan( pID, ReturnPlayerName( playerid ), reason, ReturnPlayerIP( pID ) );
	}
	return 1;
}

CMD:banlog( playerid, params[ ] )
{
	new
		iName[ MAX_PLAYER_NAME ];

	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "s[24]", iName ) ) return SendUsage( playerid, "/banlog [PLAYER_NAME]" );
	else
	{
		format( szNormalString, sizeof( szNormalString ) , "SELECT * FROM `BANS` WHERE `NAME`='%s' LIMIT 1", iName );
		mysql_function_query( dbHandle, szNormalString, true, "OnPlayerBanLog", "ds", playerid, iName );
	}
	return 1;
}

thread OnPlayerBanLog( playerid, const Name[ ] )
{
	new
		rows = cache_get_row_count( );

	if ( ! rows ) {
		return SendError( playerid, "This player isn't banned." );
	}

	static
		ban_ip[ 16 ],
		ban_reason[ 80 ],
		ban_by[ 24 ],
		// ban_date,
		ban_expire
	;

	for ( new row = 0; row < rows; row ++ )
	{
		// ban_date = cache_get_field_content_int( row, "DATE" );
		ban_expire = cache_get_field_content_int( row, "EXPIRE" );
		cache_get_field_content( row, "IP", ban_ip );
		cache_get_field_content( row, "REASON", ban_reason );
		cache_get_field_content( row, "BANBY", ban_by );

		if ( ! ban_expire )
			format( szHugeString, sizeof( szHugeString ), ""COL_ORANGE"Ban Information:\n\n"COL_GREY"Username: "COL_WHITE"%s\n"COL_GREY"IP Address: "COL_WHITE"%s\n"COL_GREY"Reason: "COL_WHITE"%s\n"COL_GREY"Banned by: "COL_WHITE"%s\n"COL_GREY"Expires: "COL_WHITE"Never\n", Name, ban_ip, ban_reason, ban_by );
		else
			format( szHugeString, sizeof( szHugeString ), ""COL_ORANGE"Ban Information:\n\n"COL_GREY"Username: "COL_WHITE"%s\n"COL_GREY"IP Address: "COL_WHITE"%s\n"COL_GREY"Reason: "COL_WHITE"%s\n"COL_GREY"Banned by: "COL_WHITE"%s\n"COL_GREY"Expires: "COL_WHITE"%s\n", Name, ban_ip, ban_reason, ban_by, secondstotime( ban_expire - g_iTime ) );
	}

	return ShowPlayerDialog( playerid, DIALOG_NULL, DIALOG_STYLE_MSGBOX, ""COL_WHITE"Ban Search", szHugeString, "Close", "" ), 1;
}

CMD:bring( playerid, params[ ] )
{
    new
		pID,
		Float: X,
		Float: Y,
		Float: Z
	;

	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, """u""", pID ) ) return SendUsage( playerid, "/bring [PLAYER_ID]" );
    else if ( !IsPlayerConnected(pID) ) return SendError(playerid, "Invalid Player ID.");
    else if ( pID == playerid ) return SendError(playerid, "You cannot bring your self.");
    else
	{
    	/*if ( IsPlayerInAnyVehicle( playerid ) ) {
			if ( PutPlayerInEmptyVehicleSeat( GetPlayerVehicleID( playerid ), pID ) )
				return 1;
    	}*/
        GetPlayerPos( playerid, X, Y, Z );
        SetPlayerPos( pID, X, Y + 2, Z );
        SetPlayerInterior( pID, GetPlayerInterior( playerid ) );
        SetPlayerVirtualWorld( pID, GetPlayerVirtualWorld( playerid ) );
        AddAdminLogLineFormatted( "%s(%d) has brought %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
        if ( p_InHouse[ pID ] != -1 ) p_InHouse[ pID ] = -1;
        if ( p_InGarage[ pID ] != -1 ) p_InGarage[ pID ] = -1;
        if ( p_inPaintBall{ pID } ) LeavePlayerPaintball( pID );
    }
    return 1;
}

CMD:forceac( playerid, params[ ] )
{
    new
        pID;

	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
    else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/forceac [PLAYER_ID]" );
    else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
    else if ( pID == playerid ) return SendError( playerid, "You can't use this command on yourself." );
    else if ( p_AdminLevel[ pID ] > p_AdminLevel[ playerid ] ) return SendError( playerid, "You cannot use this command on admins higher than your level." );
    //else if ( GetPlayerScore( pID ) < 100 ) return SendError( playerid, "This player's score is under 100, please spectate instead." );
    else
	{
		if ( p_forcedAnticheat[ pID ] <= 0 )
		{
			p_forcedAnticheat[ pID ] = p_AccountID[ playerid ];
			mysql_single_query( sprintf( "UPDATE `USERS` SET `FORCE_AC`=%d WHERE `ID`=%d", p_AccountID[ playerid ], p_AccountID[ pID ] ) );
			AddAdminLogLineFormatted( "%s(%d) has forced ac on %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
	        SendGlobalMessage( -1, ""COL_PINK"[ADMIN]"COL_GREY" %s is required to use an anticheat to play by %s. "COL_YELLOW"("AC_WEBSITE")", ReturnPlayerName( pID ), ReturnPlayerName( playerid ) );
	        if ( ! IsPlayerUsingSampAC( pID ) ) KickPlayerTimed( pID );
		}
		else
		{
			return SendError( playerid, "This user is already forced to use the Anti-Cheat." );
		}
    }
    return 1;
}

CMD:chatban( playerid, params[ ] )
{

	new pID, reason[ 25 ];

	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "us[50]", pID, reason ) ) return SendUsage( playerid, "/chatban [PLAYER_ID] [REASON]" );
	else if ( strlen( reason ) < 3 || strlen( reason ) > 25 ) return SendError( playerid, "Please keep your chat ban reason between 3 - 25 characters." );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( pID == playerid ) return SendError( playerid, "You can't use this command on yourself." );
	else if ( p_AdminLevel[ pID ] > p_AdminLevel[ playerid ] ) return SendError( playerid, "You cannot use this command on admins higher than your level." );
	else if ( IsPlayerChatBanned( pID ) ) return SendError( playerid, "This player is already chat banned." );
	else
	{
		p_ChatBanned{ pID } = true;
		p_ChatBannedBy[ pID ] = ReturnPlayerName( playerid );
		p_ChatBanReason[ pID ] = reason;
		mysql_single_query( sprintf( "INSERT INTO `CHAT_BANS` (`ID`, `NAME`, `BANNED_BY_ID`, `BANNED_BY`, `REASON`) VALUES (%d, '%s', %d, '%s', '%s')", p_AccountID[ pID ], mysql_escape( ReturnPlayerName( pID ) ), p_AccountID[ playerid ], mysql_escape( ReturnPlayerName( playerid ) ), mysql_escape( reason ) ) );
		SendGlobalMessage( -1, ""COL_PINK"[ADMIN]{FFFFFF} %s has chat banned %s(%d) "COL_GREEN"[REASON: %s]", ReturnPlayerName( playerid ), ReturnPlayerName( pID ), pID, reason );
		AddAdminLogLineFormatted( "%s(%d) has chat banned %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
		SaveToAdminLog( playerid, p_AccountID[ pID ], "chat ban" );
	}

	return 1;
}

CMD:unchatban( playerid, params[ ] )
{

	new pID;

	if ( p_AdminLevel[ playerid ] < 3 ) return SendError( playerid, ADMIN_COMMAND_REJECT );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/chatban [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( pID == playerid ) return SendError( playerid, "You can't use this command on yourself." );
	else if ( !IsPlayerChatBanned( pID ) ) return SendError( playerid, "This player is not chat banned." );
	else
	{
		p_ChatBanned{ pID } = false;
		mysql_single_query( sprintf( "DELETE FROM `CHAT_BANS` WHERE `ID`=%d", p_AccountID[ pID ] ) );
		SendGlobalMessage( -1, ""COL_PINK"[ADMIN]{FFFFFF} %s(%d) has been chat un-banned by %s", ReturnPlayerName( pID ), pID, ReturnPlayerName( playerid ) );
		AddAdminLogLineFormatted( "%s(%d) has chat unbanned %s(%d)", ReturnPlayerName( playerid ), playerid, ReturnPlayerName( pID ), pID );
		SaveToAdminLog( playerid, p_AccountID[ pID ], "chat unban" );
	}

	return 1;

}

thread ChatBanUponLogin( playerid )
{
	new
	    rows, fields
	;
    cache_get_data( rows, fields );

    if ( rows )
    {
		new banned_by[ MAX_PLAYER_NAME ], reason[ 25 ];

		cache_get_field_content( 0,  "BANNED_BY", banned_by );
		cache_get_field_content( 0,  "REASON", reason );

		p_ChatBanned{ playerid } = true;
		p_ChatBannedBy[ playerid ] = banned_by;
		p_ChatBanReason[ playerid ] = reason;
		print("done with chatbanuponlogin");
	}
	return 1;
}