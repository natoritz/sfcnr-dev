/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\features\vehicles\vehicles.pwn
 * Purpose: personal vehicle system
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
#define MAX_BUYABLE_VEHICLES        ( 20 + VIP_MAX_EXTRA_SLOTS )
#define MAX_CAR_MODS                15

/* ** Variables ** */
enum E_CAR_DATA
{
	E_VEHICLE_ID,       bool: E_CREATED,        	bool: E_LOCKED,
	Float: E_X,         Float: E_Y,             	Float: E_Z,
	Float: E_ANGLE,     E_OWNER_ID,            		E_PRICE,
	E_COLOR[ 2 ],       E_MODEL,                    E_PLATE[ 32 ],
	E_PAINTJOB,			E_SQL_ID,					E_GARAGE
};

new
	g_vehicleData                	[ MAX_PLAYERS ] [ MAX_BUYABLE_VEHICLES ] [ E_CAR_DATA ],
	bool: g_buyableVehicle        	[ MAX_VEHICLES char ],
	g_vehicleModifications          [ MAX_PLAYERS ] [ MAX_BUYABLE_VEHICLES ] [ MAX_CAR_MODS ],
	g_vehicleColors 				[ ] =
	{
		0x000000AA, 0xF5F5F5AA, 0x2A77A1AA, 0x840410AA, 0x263739AA, 0x86446EAA, 0xD78E10AA, 0x4C75B7AA, 0xBDBEC6AA, 0x5E7072AA,
		0x46597AAA, 0x656A79AA, 0x5D7E8DAA, 0x58595AAA, 0xD6DAD6AA, 0x9CA1A3AA, 0x335F3FAA, 0x730E1AAA, 0x7B0A2AAA, 0x9F9D94AA,
		0x3B4E78AA, 0x732E3EAA, 0x691E3BAA, 0x96918CAA, 0x515459AA, 0x3F3E45AA, 0xA5A9A7AA, 0x635C5AAA, 0x3D4A68AA, 0x979592AA,
		0x421F21AA, 0x5F272BAA, 0x8494ABAA, 0x767B7CAA, 0x646464AA, 0x5A5752AA, 0x252527AA, 0x2D3A35AA, 0x93A396AA, 0x6D7A88AA,
		0x221918AA, 0x6F675FAA, 0x7C1C2AAA, 0x5F0A15AA, 0x193826AA, 0x5D1B20AA, 0x9D9872AA, 0x7A7560AA, 0x989586AA, 0xADB0B0AA,
		0x848988AA, 0x304F45AA, 0x4D6268AA, 0x162248AA, 0x272F4BAA, 0x7D6256AA, 0x9EA4ABAA, 0x9C8D71AA, 0x6D1822AA, 0x4E6881AA,
		0x9C9C98AA, 0x917347AA, 0x661C26AA, 0x949D9FAA, 0xA4A7A5AA, 0x8E8C46AA, 0x341A1EAA, 0x6A7A8CAA, 0xAAAD8EAA, 0xAB988FAA,
		0x851F2EAA, 0x6F8297AA, 0x585853AA, 0x9AA790AA, 0x601A23AA, 0x20202CAA, 0xA4A096AA, 0xAA9D84AA, 0x78222BAA, 0x0E316DAA,
		0x722A3FAA, 0x7B715EAA, 0x741D28AA, 0x1E2E32AA, 0x4D322FAA, 0x7C1B44AA, 0x2E5B20AA, 0x395A83AA, 0x6D2837AA, 0xA7A28FAA,
		0xAFB1B1AA, 0x364155AA, 0x6D6C6EAA, 0x0F6A89AA, 0x204B6BAA, 0x2B3E57AA, 0x9B9F9DAA, 0x6C8495AA, 0x4D8495AA, 0xAE9B7FAA,
		0x406C8FAA, 0x1F253BAA, 0xAB9276AA, 0x134573AA, 0x96816CAA, 0x64686AAA, 0x105082AA, 0xA19983AA, 0x385694AA, 0x525661AA,
		0x7F6956AA, 0x8C929AAA, 0x596E87AA, 0x473532AA, 0x44624FAA, 0x730A27AA, 0x223457AA, 0x640D1BAA, 0xA3ADC6AA, 0x695853AA,
		0x9B8B80AA, 0x620B1CAA, 0x5B5D5EAA, 0x624428AA, 0x731827AA, 0x1B376DAA, 0xEC6AAEAA, 0x000000AA, 0x177517AA, 0x210606AA,
		0x125478AA, 0x452A0DAA, 0x571E1EAA, 0x010701AA, 0x25225AAA, 0x2C89AAAA, 0x8A4DBDAA, 0x35963AAA, 0xB7B7B7AA, 0x464C8DAA,
		0x84888CAA, 0x817867AA, 0x817A26AA, 0x6A506FAA, 0x583E6FAA, 0x8CB972AA, 0x824F78AA, 0x6D276AAA, 0x1E1D13AA, 0x1E1306AA,
		0x1F2518AA, 0x2C4531AA, 0x1E4C99AA, 0x2E5F43AA, 0x1E9948AA, 0x1E9999AA, 0x999976AA, 0x7C8499AA, 0x992E1EAA, 0x2C1E08AA,
		0x142407AA, 0x993E4DAA, 0x1E4C99AA, 0x198181AA, 0x1A292AAA, 0x16616FAA, 0x1B6687AA, 0x6C3F99AA, 0x481A0EAA, 0x7A7399AA,
		0x746D99AA, 0x53387EAA, 0x222407AA, 0x3E190CAA, 0x46210EAA, 0x991E1EAA, 0x8D4C8DAA, 0x805B80AA, 0x7B3E7EAA, 0x3C1737AA,
		0x733517AA, 0x781818AA, 0x83341AAA, 0x8E2F1CAA, 0x7E3E53AA, 0x7C6D7CAA, 0x020C02AA, 0x072407AA, 0x163012AA, 0x16301BAA,
		0x642B4FAA, 0x368452AA, 0x999590AA, 0x818D96AA, 0x99991EAA, 0x7F994CAA, 0x839292AA, 0x788222AA, 0x2B3C99AA, 0x3A3A0BAA,
		0x8A794EAA, 0x0E1F49AA, 0x15371CAA, 0x15273AAA, 0x375775AA, 0x060820AA, 0x071326AA, 0x20394BAA, 0x2C5089AA, 0x15426CAA,
		0x103250AA, 0x241663AA, 0x692015AA, 0x8C8D94AA, 0x516013AA, 0x090F02AA, 0x8C573AAA, 0x52888EAA, 0x995C52AA, 0x99581EAA,
		0x993A63AA, 0x998F4EAA, 0x99311EAA, 0x0D1842AA, 0x521E1EAA, 0x42420DAA, 0x4C991EAA, 0x082A1DAA, 0x96821DAA, 0x197F19AA,
		0x3B141FAA, 0x745217AA, 0x893F8DAA, 0x7E1A6CAA, 0x0B370BAA, 0x27450DAA, 0x071F24AA, 0x784573AA, 0x8A653AAA, 0x732617AA,
		0x319490AA, 0x56941DAA, 0x59163DAA, 0x1B8A2FAA, 0x38160BAA, 0x041804AA, 0x355D8EAA, 0x2E3F5BAA, 0x561A28AA, 0x4E0E27AA,
		0x706C67AA, 0x3B3E42AA, 0x2E2D33AA, 0x7B7E7DAA, 0x4A4442AA, 0x28344EAA
	}
;

/* ** Hooks ** */
hook OnPlayerLogin( playerid )
{
	format( szNormalString, sizeof( szNormalString ), "SELECT * FROM `VEHICLES` WHERE `OWNER`=%d", GetPlayerAccountID( playerid ) );
	mysql_tquery( dbHandle, szNormalString, "OnVehicleLoad", "d", playerid );
	return 1;
}

hook OnDialogResponse( playerid, dialogid, response, listitem, inputtext[ ] )
{
	if ( dialogid == DIALOG_VEHICLE_SPAWN && response )
	{
		if ( !listitem )
		{
			for( new id; id < MAX_BUYABLE_VEHICLES; id ++ )
				if ( g_vehicleData[ playerid ] [ id ] [ E_CREATED ] && g_vehicleData[ playerid ] [ id ] [ E_OWNER_ID ] == p_AccountID[ playerid ] && IsValidVehicle( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] ) )
			 		RespawnBuyableVehicle( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] );

			SendServerMessage( playerid, "You have respawned all your vehicles." );
		}
		else
		{
			for( new id, x = 1; id < MAX_BUYABLE_VEHICLES; id ++ )
			{
				if ( g_vehicleData[ playerid ] [ id ] [ E_CREATED ] && g_vehicleData[ playerid ] [ id ] [ E_OWNER_ID ] == p_AccountID[ playerid ] && IsValidVehicle( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] ) )
				{
			       	if ( x == listitem )
			      	{
						RespawnBuyableVehicle( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] );
						SendServerMessage( playerid, "You have respawned your "COL_GREY"%s"COL_WHITE".", GetVehicleName( GetVehicleModel( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] ) ) );
					 	break;
			   		}
			      	x ++;
				}
			}
		}
	}
	else if ( dialogid == DIALOG_VEHICLE_LOCATE && response )
	{
		if ( GetPlayerInterior( playerid ) || GetPlayerVirtualWorld( playerid ) )
			return SendError( playerid, "You cannot use this feature inside of an interior." );

		for( new id, x = 0; id < MAX_BUYABLE_VEHICLES; id ++ )
		{
			if ( g_vehicleData[ playerid ] [ id ] [ E_CREATED ] == true && g_vehicleData[ playerid ] [ id ] [ E_OWNER_ID ] == p_AccountID[ playerid ] && IsValidVehicle( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] ) )
			{
		       	if ( x == listitem )
		      	{
		      		if ( GetPlayerCash( playerid ) < 10000 )
		      			return SendError( playerid, "You need $10,000 to bring your vehicle to you." );

				    new
					    Float: X, Float: Y, Float: Z;

		      		foreach( new i : Player )
		      		{
		      			if( GetPlayerVehicleID( i ) == g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] )
		      			{
		      				GetPlayerPos( i, X, Y, Z );
		      				SetPlayerPos( i, X, Y, ( Z + 0.5 ) );
		      				SendServerMessage( i, "You have been thrown out of the vehicle as the owner has teleported it away!" );
		      			}
		      		}

					// get the player's position again
					GetPlayerPos( playerid, X, Y, Z );

					// get nearest node
					new Float: nodeX, Float: nodeY, Float: nodeZ, Float: nextX, Float: nextY;
					new nodeid = NearestNodeFromPoint( X, Y, Z );
					new nextNodeid = NearestNodeFromPoint( X, Y, Z, 9999.9, nodeid );

					GetNodePos( nextNodeid, nextX, nextY, nodeZ );
					GetNodePos( nodeid, nodeX, nodeY, nodeZ );

					new
						Float: rotation = atan2( nextY - nodeY, nextX - nodeX ) - 90.0;

					SetVehiclePos( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], nodeX, nodeY, nodeZ + 1.0 );
					SetVehicleZAngle( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], rotation );
					LinkVehicleToInterior( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], 0 );
					SetVehicleVirtualWorld( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], 0 );

					// alert
					Beep( playerid );
					GivePlayerCash( playerid, -10000 );
					p_VehicleBringCooldown[ playerid ] = g_iTime + 120;
					SendServerMessage( playerid, "You have brought your "COL_GREY"%s"COL_WHITE". Check the nearest road for it.", GetVehicleName( GetVehicleModel( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] ) ) );
					break;
		   		}
		      	x ++;
			}
		}
	}
	return 1;
}

hook OnPlayerDriveVehicle( playerid, vehicleid )
{
	if ( g_buyableVehicle{ vehicleid } == true )
	{
		new ownerid, slotid;
		new v = getVehicleSlotFromID( vehicleid, ownerid, slotid );

		if ( v == -1 ) {
			return 1; // ignore if unowned/erroneous
		}

		if ( ownerid == playerid )
		{
			SendClientMessage(playerid, -1, ""COL_GREY"[VEHICLE]"COL_WHITE" Welcome back to your vehicle.");
			Beep( playerid );
			GetVehicleParamsEx( vehicleid, engine, lights, alarm, doors, bonnet, boot, objective );
			SetVehicleParamsEx( vehicleid, VEHICLE_PARAMS_ON, lights, VEHICLE_PARAMS_OFF, doors, bonnet, boot, objective );
			return 1;
		}
        else
	    {
			if ( g_vehicleData[ ownerid ] [ slotid ] [ E_LOCKED ] == true )
			{
				if ( p_AdminLevel[ playerid ] < 3 || !p_AdminOnDuty{ playerid } )
				{
					new
						model_id = GetVehicleModel( vehicleid );

					GetVehicleParamsEx( vehicleid, engine, lights, alarm, doors, bonnet, boot, objective );
					SetVehicleParamsEx( vehicleid, VEHICLE_PARAMS_ON, lights, VEHICLE_PARAMS_ON, doors, bonnet, boot, objective );

					// Remove helicopter bottoms
					if ( GetGVarInt( "heli_gunner", vehicleid ) && ( model_id == 487 || model_id == 497 ) ) {
						DestroyDynamicObject( GetGVarInt( "heli_gunner", vehicleid ) );
						DeleteGVar( "heli_gunner", vehicleid );
					}

					SyncObject( playerid, 1 ); // Just sets the players position where the vehicle is.
					SendError( playerid, "You cannot drive this car, it has been locked by the owner." );
				}
				else SendClientMessage( playerid, -1, ""COL_PINK"[ADMIN]"COL_GREY" This is a locked vehicle." );
			}
			else SendClientMessageFormatted( playerid, -1, ""COL_GREY"[VEHICLE]"COL_WHITE" This vehicle is owned by %s.", ReturnPlayerName( ownerid ) );
		}
	}
	return 1;
}

hook OnEnterExitModShop( playerid, enterexit, interiorid )
{
	if ( enterexit == 0 )
	{
		new
		    vehicleid = GetPlayerVehicleID( playerid );

	    if ( IsValidVehicle( vehicleid ) )
	    {
			if ( g_buyableVehicle{ vehicleid } == true )
			{
		        new
		        	ownerid = INVALID_PLAYER_ID,
		        	v = getVehicleSlotFromID( vehicleid, ownerid )
		        ;
			    if ( ownerid == playerid && v != -1 )
			    {
			        if ( UpdateBuyableVehicleMods( playerid, v ) )
			        {
			        	new
				        	szMods[ MAX_CAR_MODS * 10 ];

						for( new i; i < MAX_CAR_MODS; i++ ) {
							format( szMods, sizeof( szMods ), "%s%d.", szMods, g_vehicleModifications[ playerid ] [ v ] [ i ] );
						}

						format( szBigString, sizeof( szBigString ), "UPDATE `VEHICLES` SET `MODS`='%s' WHERE `ID`=%d", szMods, g_vehicleData[ playerid ] [ v ] [ E_SQL_ID ] );
						mysql_single_query( szBigString );
			        }
			        else SendError( playerid, "Couldn't update your vehicle mods due to an unexpected error (0x82FF)." );
			    }
			}
		}
	}
	return 1;
}

hook OnVehiclePaintjob( playerid, vehicleid, paintjobid )
{
	if ( g_buyableVehicle{ vehicleid } == true )
	{
	    new
	    	ownerid = INVALID_PLAYER_ID,
	    	v = getVehicleSlotFromID( vehicleid, ownerid )
	    ;
	    if ( ownerid == playerid && v != -1 )
	    {
	        g_vehicleData[ playerid ] [ v ] [ E_PAINTJOB ] = paintjobid;
	        SaveVehicleData( playerid, v );
	    }
	}
	return 1;
}

hook OnVehicleRespray( playerid, vehicleid, color1, color2 )
{
    if ( g_buyableVehicle{ vehicleid } == true )
    {
	    new
	    	ownerid = INVALID_PLAYER_ID,
	    	v = getVehicleSlotFromID( vehicleid, ownerid )
	    ;
	    if ( ownerid == playerid && v != -1 )
		{
			g_vehicleData[ playerid ] [ v ] [ E_COLOR ] [ 0 ] = color1;
	        g_vehicleData[ playerid ] [ v ] [ E_COLOR ] [ 1 ] = color2;
	        SaveVehicleData( playerid, v );
		}
    }
	return 1;
}

/* ** Commands ** */
CMD:vehicle( playerid, params[ ] ) return cmd_v( playerid, params );
CMD:v( playerid, params[ ] )
{
	if ( p_accountSecurityData[ playerid ] [ E_ID ] && ! p_accountSecurityData[ playerid ] [ E_VERIFIED ] && p_accountSecurityData[ playerid ] [ E_MODE ] != SECURITY_MODE_DISABLED )
		return SendError( playerid, "You must be verified in order to use this feature. "COL_YELLOW"(use /verify)" );

#if VIP_ALLOW_OVER_LIMIT == false
	// force hoarders to sell
	if ( ! p_VIPLevel[ playerid ] && p_OwnedVehicles[ playerid ] > GetPlayerVehicleSlots( playerid ) && ! strmatch( params, "sell" ) && ! strmatch( params, "bring" ) ) {
		for( new i = 0; i < p_OwnedVehicles[ playerid ]; i++ ) if ( g_vehicleData[ playerid ] [ i ] [ E_OWNER_ID ] == p_AccountID[ playerid ] ) {
			g_vehicleData[ playerid ] [ i ] [ E_LOCKED ] = false;
		}
		return SendError( playerid, "Please renew your V.I.P or sell this vehicle to match your vehicle allocated limit. (/v sell/bring only)" );
	}
#endif

	new
		vehicleid = GetPlayerVehicleID( playerid ),
		ownerid = INVALID_PLAYER_ID
	;

	if ( isnull( params ) ) return SendUsage( playerid, "/v [SELL/COLOR/LOCK/PARK/RESPAWN/BRING/DATA/PLATE/PAINTJOB/RESET]" );
	else if ( strmatch( params, "sell" ) )
	{
		new v = getVehicleSlotFromID( vehicleid, ownerid );
	    if ( !IsPlayerInAnyVehicle( playerid ) ) return SendError( playerid, "You need to be in a vehicle to use this command." );
		else if ( v == -1 ) return SendError( playerid, "This vehicle isn't a buyable vehicle." );
		else if ( g_buyableVehicle{ vehicleid } == false ) return SendError( playerid, "This vehicle isn't a buyable vehicle." );
		else if ( playerid != ownerid ) return SendError( playerid, "You cannot sell this vehicle." );
		else
		{
			format( szBigString, sizeof( szBigString ), "[SELL] [%s] %s | %d | %s\r\n", getCurrentDate( ), ReturnPlayerName( playerid ), v, GetVehicleName( GetVehicleModel( g_vehicleData[ playerid ] [ v ] [ E_VEHICLE_ID ] ) ) );
		    AddFileLogLine( "log_destroycar.txt", szBigString );
            GivePlayerCash( playerid, ( g_vehicleData[ playerid ] [ v ] [ E_PRICE ] / 2 ) );
			SendClientMessageFormatted( playerid, -1, ""COL_GREY"[VEHICLE]"COL_WHITE" You have sold this vehicle for half the price it was (%s).", cash_format( ( g_vehicleData[ playerid ] [ v ] [ E_PRICE ] / 2 ) ) );
            DestroyBuyableVehicle( playerid, v );
		}
	}
	else if ( strmatch( params, "lock" ) )
	{
		new v = getVehicleSlotFromID( vehicleid, ownerid  );
	    if ( GetPlayerState( playerid ) != PLAYER_STATE_DRIVER ) return SendError( playerid, "You need to be in a vehicle to use this command." );
		else if ( v == -1 ) return SendError( playerid, "This vehicle isn't a buyable vehicle." );
		else if ( g_buyableVehicle{ vehicleid } == false ) return SendError( playerid, "This vehicle isn't a buyable vehicle." );
		else if ( playerid != ownerid ) return SendError( playerid, "You cannot lock this vehicle." );
		else
		{
		    g_vehicleData[ playerid ] [ v ] [ E_LOCKED ] = !g_vehicleData[ playerid ] [ v ] [ E_LOCKED ];
			SendClientMessageFormatted( playerid, -1, ""COL_GREY"[VEHICLE]"COL_WHITE" You have %s this vehicle.", g_vehicleData[ playerid ] [ v ] [ E_LOCKED ] == true ? ( "locked" ) : ( "un-locked" ) );
            SaveVehicleData( playerid, v );
		}
	}
	else if ( strmatch( params, "park" ) )
	{
		new v = getVehicleSlotFromID( vehicleid, ownerid  ), Float: X, Float: Y, Float: Z, Float: Angle;
	    if ( !IsPlayerInAnyVehicle( playerid ) ) return SendError( playerid, "You need to be in a vehicle to use this command." );
	    else if ( GetPlayerState( playerid ) != PLAYER_STATE_DRIVER ) return SendError( playerid, "You need to be a driver to use this command." );
		else if ( v == -1 ) return SendError( playerid, "This vehicle isn't a buyable vehicle." );
		else if ( playerid != ownerid ) return SendError( playerid, "You cannot park this vehicle." );
		else if ( IsPlayerBelowSeaLevel( playerid ) ) return SendError( playerid, "You cannot use this command while below sea level." );
		else
		{
	        if ( IsVehicleUpsideDown( GetPlayerVehicleID( playerid ) ) ) return SendError( playerid, "Sorry, you're just going to have to ditch your car as soon as possible." );

	        new
	        	iBreach = PlayerBreachedGarageLimit( playerid, v );

	        if ( iBreach == -1 ) return SendError( playerid, "You cannot park vehicles that are not owned by the owner of this garage." );
	        if ( iBreach == -2 ) return SendError( playerid, "This garage has already reached its capacity of %d vehicles.", GetGarageVehicleCapacity( p_InGarage[ playerid ] ) );

			GetVehiclePos( vehicleid, X, Y, Z );
			GetVehicleZAngle( vehicleid, Angle );
			g_vehicleData[ playerid ] [ v ] [ E_X ] = X, g_vehicleData[ playerid ] [ v ] [ E_Y ] = Y, g_vehicleData[ playerid ] [ v ] [ E_Z ] = Z, g_vehicleData[ playerid ] [ v ] [ E_ANGLE ] = Angle;
			PutPlayerInVehicle( playerid, RespawnBuyableVehicle( vehicleid, playerid ), 0 );
 			SetTimerEx( "timedUpdates_RBV", 25, false, "ddf", playerid, INVALID_VEHICLE_ID, -1000.0 );
            SaveVehicleData( playerid, v );
        	SendClientMessage( playerid, -1, ""COL_GREY"[VEHICLE]"COL_WHITE" You have parked this vehicle." );
		}
	}
	else if ( strmatch( params, "respawn" ) )
	{
		if ( p_OwnedVehicles[ playerid ] > 0 )
		{
		    szLargeString = ""COL_GREY"Respawn All Vehicles\n";
			for( new i; i < p_OwnedVehicles[ playerid ]; i++ )
		    {
				if ( g_vehicleData[ playerid ] [ i ] [ E_OWNER_ID ] == p_AccountID[ playerid ] && IsValidVehicle( g_vehicleData[ playerid ] [ i ] [ E_VEHICLE_ID ] ) ) {
				    format( szLargeString, sizeof( szLargeString ), "%s%s\n", szLargeString, GetVehicleName( GetVehicleModel( g_vehicleData[ playerid ] [ i ] [ E_VEHICLE_ID ] ) ) );
				}
		    }
		    ShowPlayerDialog( playerid, DIALOG_VEHICLE_SPAWN, DIALOG_STYLE_LIST, "{FFFFFF}Spawn your vehicle", szLargeString, "Select", "Cancel" );
		}
		else SendError( playerid, "You don't own any vehicles." );
	}
	else if ( strmatch( params, "locate" ) ) return SendServerMessage( playerid, "This feature has been replaced with "COL_GREY"/v bring"COL_WHITE"." );
	else if ( strmatch( params, "bring" ) )
	{
		if ( p_VehicleBringCooldown[ playerid ] > g_iTime )
			return SendError( playerid, "You must wait %s before using this feature again.", secondstotime( p_VehicleBringCooldown[ playerid ] - g_iTime ) );
		else if ( IsPlayerBelowSeaLevel( playerid ) ) return SendError( playerid, "You cannot use this command while below sea level." );
		else if ( p_OwnedVehicles[ playerid ] > 0 )
		{
		    szLargeString = ""COL_WHITE"Bringing your vehicle to you will cost $10,000!\n";
			for( new i; i < p_OwnedVehicles[ playerid ]; i++ )
		    {
				if ( g_vehicleData[ playerid ] [ i ] [ E_OWNER_ID ] == p_AccountID[ playerid ] && IsValidVehicle( g_vehicleData[ playerid ] [ i ] [ E_VEHICLE_ID ] ) ) {
				    format( szLargeString, sizeof( szLargeString ), "%s%s\n", szLargeString, GetVehicleName( GetVehicleModel( g_vehicleData[ playerid ] [ i ] [ E_VEHICLE_ID ] ) ) );
				}
			}
		    ShowPlayerDialog( playerid, DIALOG_VEHICLE_LOCATE, DIALOG_STYLE_TABLIST_HEADERS, "{FFFFFF}Bring Vehicle", szLargeString, "Select", "Cancel" );
		}
		else SendError( playerid, "You don't own any vehicles." );
	}
	else if ( strmatch( params, "data" ) )
	{
		if ( !IsPlayerInAnyVehicle( playerid ) ) return SendError( playerid, "You are not in any vehicle." );
		else if ( g_buyableVehicle{ GetPlayerVehicleID( playerid ) } == false ) return SendError( playerid, "This vehicle isn't a buyable vehicle." );
		else
		{
			new v = getVehicleSlotFromID( vehicleid, ownerid );
	        if ( playerid != ownerid ) return SendError( playerid, "You don't own this vehicle." );

			format( szBigString, sizeof( szBigString ),	""COL_GREY"Vehicle Owner:"COL_WHITE" %s\n"\
			                            ""COL_GREY"Vehicle Type:"COL_WHITE" %s\n"\
			                            ""COL_GREY"Vehicle ID:"COL_WHITE" %d\n"\
			                            ""COL_GREY"Vehicle Price:"COL_WHITE" %s",
			                            ReturnPlayerName( ownerid ), GetVehicleName( GetVehicleModel( GetPlayerVehicleID( playerid ) ) ),
			                            g_vehicleData[ playerid ] [ v ] [ E_SQL_ID ], cash_format( g_vehicleData[ playerid ] [ v ] [ E_PRICE ] ) );
			ShowPlayerDialog( playerid, DIALOG_NULL, DIALOG_STYLE_MSGBOX, "{FFFFFF}Vehicle Data", szBigString, "Okay", "" );
		}
	}
	else if ( !strcmp( params, "color", false, 4 ) )
	{
		new
		    color1, color2
		;
		if ( !IsPlayerInAnyVehicle( playerid ) ) return SendError( playerid, "You must be inside a vehicle to use this command." );
	    else if ( GetPlayerState( playerid ) != PLAYER_STATE_DRIVER ) return SendError( playerid, "You need to be a driver to use this command." );
		else if ( IsPlayerBelowSeaLevel( playerid ) ) return SendError( playerid, "You cannot use this command while below sea level." );
		else if ( sscanf( params[ 6 ], "dd", color1, color2 ) ) return SendUsage( playerid, "/v color [COLOR_1] [COLOR_2]" );
		else if ( g_buyableVehicle{ GetPlayerVehicleID( playerid ) } == false ) return SendError( playerid, "This isn't a buyable vehicle." );
		else if ( GetPlayerCash( playerid ) < 100 ) return SendError( playerid, "You don't have enough cash for this." );
		else if ( color1 > 255 || color1 < 0 || color2 > 255 || color2 < 0 ) return SendError( playerid, "Invalid vehicle color ID." );
		else
		{
	        new vID = getVehicleSlotFromID( GetPlayerVehicleID( playerid ), ownerid );
	        if ( playerid != ownerid ) return SendError( playerid, "You don't own this vehicle." );
	        if ( IsVehicleUpsideDown( GetPlayerVehicleID( playerid ) ) ) return SendError( playerid, "Sorry, you're just going to have to ditch your car as soon as possible." );
	        g_vehicleData[ playerid ] [ vID ] [ E_COLOR ] [ 0 ] = color1;
	        g_vehicleData[ playerid ] [ vID ] [ E_COLOR ] [ 1 ] = color2;
	    	GivePlayerCash( playerid, -100 );
			PutPlayerInVehicle( playerid, RespawnBuyableVehicle( vehicleid, playerid ), 0 );
	        SaveVehicleData( playerid, vID );
			SendServerMessage( playerid, "You have successfully changed your vehicle colors." );
		}
	}
	else if ( !strcmp( params, "plate", false, 4 ) )
	{
		new
		    szPlate[ 32 ]
		;
		if ( !IsPlayerInAnyVehicle( playerid ) ) return SendError( playerid, "You must be inside a vehicle to use this command." );
	    else if ( GetPlayerState( playerid ) != PLAYER_STATE_DRIVER ) return SendError( playerid, "You need to be a driver to use this command." );
		else if ( IsPlayerBelowSeaLevel( playerid ) ) return SendError( playerid, "You cannot use this command while below sea level." );
		else if ( sscanf( params[ 6 ], "s[32]", szPlate ) ) return SendUsage( playerid, "/v plate [TEXT]" );
		else if ( g_buyableVehicle{ GetPlayerVehicleID( playerid ) } == false ) return SendError( playerid, "This isn't a buyable vehicle." );
		else
		{
	        new vID = getVehicleSlotFromID( GetPlayerVehicleID( playerid ), ownerid );
	        if ( playerid != ownerid ) return SendError( playerid, "You don't own this vehicle." );
			if ( IsBoatVehicle( GetVehicleModel( g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ] ) ) || IsAirVehicle( GetVehicleModel( g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ] ) ) ) return SendError( playerid, "Sorry, this feature is not available on planes and boats." );
	        if ( IsVehicleUpsideDown( GetPlayerVehicleID( playerid ) ) ) return SendError( playerid, "Sorry, you're just going to have to ditch your car as soon as possible." );
			format( g_vehicleData[ playerid ] [ vID ] [ E_PLATE ], 32, "%s", szPlate );
			PutPlayerInVehicle( playerid, RespawnBuyableVehicle( vehicleid, playerid ), 0 );
	        SaveVehicleData( playerid, vID );
			SendServerMessage( playerid, "Your have changed your vehicle's number plate to "COL_GREY"%s"COL_WHITE".", szPlate );
		}
	}
	else if ( !strcmp( params, "paintjob", false, 7 ) )
	{
		new
		    paintjobid
		;
		if ( !IsPlayerInAnyVehicle( playerid ) ) return SendError( playerid, "You must be inside a vehicle to use this command." );
	    else if ( GetPlayerState( playerid ) != PLAYER_STATE_DRIVER ) return SendError( playerid, "You need to be a driver to use this command." );
		else if ( IsPlayerBelowSeaLevel( playerid ) ) return SendError( playerid, "You cannot use this command while below sea level." );
		else if ( sscanf( params[ 9 ], "d", paintjobid ) ) return SendUsage( playerid, "/v paintjob [PAINT_JOB_ID]" );
		else if ( g_buyableVehicle{ GetPlayerVehicleID( playerid ) } == false ) return SendError( playerid, "This isn't a buyable vehicle." );
		else if ( GetPlayerCash( playerid ) < 500 ) return SendError( playerid, "You don't have enough cash for this." );
		else if ( paintjobid < 0 || paintjobid > 3 ) return SendError( playerid, "Please specify a paintjob between 0 to 3." );
		else
		{
	        new vID = getVehicleSlotFromID( GetPlayerVehicleID( playerid ), ownerid );
	        if ( playerid != ownerid ) return SendError( playerid, "You don't own this vehicle." );
			if ( !IsPaintJobVehicle( GetVehicleModel( GetPlayerVehicleID( playerid ) ) ) ) return SendError( playerid, "This vehicle cannot have a paintjob installed." );
			if ( IsVehicleUpsideDown( GetPlayerVehicleID( playerid ) ) ) return SendError( playerid, "Sorry, you're just going to have to ditch your car as soon as possible." );
	        g_vehicleData[ playerid ] [ vID ] [ E_PAINTJOB ] = paintjobid;
		    ChangeVehiclePaintjob( GetPlayerVehicleID( playerid ), paintjobid );
		    GivePlayerCash( playerid, -500 );
			PutPlayerInVehicle( playerid, RespawnBuyableVehicle( vehicleid, playerid ), 0 );
	        SaveVehicleData( playerid, vID );
		}
	}
	else if ( !strcmp( params, "toggle", false, 5 ) )
	{
		new v = getVehicleSlotFromID( vehicleid, ownerid );
	    if ( !IsPlayerInAnyVehicle( playerid ) ) return SendError( playerid, "You need to be in a vehicle to use this command." );
	    else if ( GetPlayerState( playerid ) != PLAYER_STATE_DRIVER ) return SendError( playerid, "You need to be a driver to use this command." );
		else if ( IsPlayerBelowSeaLevel( playerid ) ) return SendError( playerid, "You cannot use this command while below sea level." );
		else if ( v == -1 ) return SendError( playerid, "This vehicle isn't a buyable vehicle." );
		else if ( playerid != ownerid ) return SendError( playerid, "This vehicle does not belong to you." );
		else
		{
			if ( !strlen( params[ 7 ] ) )
				return SendUsage( playerid, "/v toggle [DOORS/BONNET/BOOT/LIGHTS/WINDOWS]" );

			GetVehicleParamsEx( vehicleid, engine, lights, alarm, doors, bonnet, boot, objective );

			if ( !strcmp( params[ 7 ], "doors", true, 5 ) ) {
				if ( !strlen( params[ 13 ] ) ) return SendUsage( playerid, "/v toggle doors [OPEN/CLOSE]" );
				else if ( strmatch( params[ 13 ], "open" ) ) {
					SetVehicleParamsCarDoors( vehicleid, 1, 1, 1, 1 );
					return SendServerMessage( playerid, "You have opened the doors of this vehicle." );
				}
				else if ( strmatch( params[ 13 ], "close" ) ) {
					SetVehicleParamsCarDoors( vehicleid, 0, 0, 0, 0 );
					return SendServerMessage( playerid, "You have closed the doors of this vehicle." );
				}
				else {
					return SendUsage( playerid, "/v toggle doors [OPEN/CLOSE]" );
				}
			}

			else if ( !strcmp( params[ 7 ], "windows", true, 7 ) ) {
				if ( !strlen( params[ 15 ] ) ) return SendUsage( playerid, "/v toggle windows [OPEN/CLOSE]" );
				else if ( strmatch( params[ 15 ], "open" ) ) {
					SetVehicleParamsCarWindows( vehicleid, 0, 0, 0, 0 );
					return SendServerMessage( playerid, "You have opened the windows of this vehicle." );
				}
				else if ( strmatch( params[ 15 ], "close" ) ) {
					SetVehicleParamsCarWindows( vehicleid, 1, 1, 1, 1 );
					return SendServerMessage( playerid, "You have closed the windows of this vehicle." );
				}
				else {
					return SendUsage( playerid, "/v toggle windows [OPEN/CLOSE]" );
				}
			}

			else if ( strmatch( params[ 7 ], "bonnet" ) ){
				SendServerMessage( playerid, "You have %s the bonnet of this vehicle.", ( bonnet = !bonnet ) ? ( "opened" ) : ( "closed" ) );
			}

			else if ( strmatch( params[ 7 ], "boot" ) ) {
				SendServerMessage( playerid, "You have %s the boot of this vehicle.", ( boot = !boot ) ? ( "opened" ) : ( "closed" ) );
			}

			else if ( strmatch( params[ 7 ], "lights" ) ) {
				SendServerMessage( playerid, "You have %s the lights of this vehicle.", ( lights = !lights ) ? ( "switched on" ) : ( "switched off" ) );
			}

			else {
				return SendUsage( playerid, "/v toggle [DOORS/BONNET/BOOT/LIGHTS/WINDOWS]" );
			}

			return SetVehicleParamsEx( vehicleid, engine, lights, alarm, doors, bonnet, boot, objective );
		}
	}
	else if ( strmatch( params, "reset" ) )
	{
		new v = getVehicleSlotFromID( vehicleid, ownerid );
	    if ( !IsPlayerInAnyVehicle( playerid ) ) return SendError( playerid, "You need to be in a vehicle to use this command." );
	    else if ( GetPlayerState( playerid ) != PLAYER_STATE_DRIVER ) return SendError( playerid, "You need to be a driver to use this command." );
		else if ( v == -1 ) return SendError( playerid, "This vehicle isn't a buyable vehicle." );
		else if ( playerid != ownerid ) return SendError( playerid, "This vehicle does not belong to you." );
		else
		{
			if ( IsVehicleUpsideDown( vehicleid ) ) return SendError( playerid, "Sorry, you're just going to have to ditch your car as soon as possible." );
			ResetBuyableVehicleMods( playerid, v, 0 );
		    ChangeVehiclePaintjob( vehicleid, 3 );
		    g_vehicleData[ playerid ] [ v ] [ E_PAINTJOB ] = 3;
	        g_vehicleData[ playerid ] [ v ] [ E_COLOR ] [ 0 ] = 0;
	        g_vehicleData[ playerid ] [ v ] [ E_COLOR ] [ 1 ] = 0;
			PutPlayerInVehicle( playerid, RespawnBuyableVehicle( vehicleid, playerid ), 0 );
	        SaveVehicleData( playerid, v );
			SendClientMessage( playerid, -1, ""COL_GREY"[SERVER]"COL_WHITE" You have reset your vehicle's appearance." );
		}
	}
	else SendUsage( playerid, "/v [SELL/COLOR/LOCK/PARK/RESPAWN/BRING/DATA/PLATE/PAINTJOB/TOGGLE/RESET]" );
	return 1;
}

CMD:colors( playerid, params[ ] ) return cmd_colours( playerid, params );
CMD:colours( playerid, params[ ] )
{
	const
		COLORS_PER_ROW = 20;

	static
		list[ 4072 ];

	list[ 0 ] = '\0';

	for ( new J; J != sizeof( g_vehicleColors ); J ++ )
	{
		format( list, sizeof( list ), "%s{%06x}%03d%s", list, g_vehicleColors[ J ] >>> 8, J, ! ( ( J + 1 ) % COLORS_PER_ROW ) ? ( "\n" ) : ( " " ) );
	}

	ShowPlayerDialog( playerid, DIALOG_VEH_COLORS, DIALOG_STYLE_MSGBOX, ""COL_WHITE"Vehicle Colors", list, "Okay", "");
	return 1;
}

/* ** SQL Threads ** */
thread OnVehicleLoad( playerid )
{
	if ( !IsPlayerConnected( playerid ) )
		return 0;

	new
		rows, fields, i = -1, vID,
		Query[ 76 ]
	;

	cache_get_data( rows, fields );
	if ( rows )
	{
		while( ++i < rows )
		{
			for( vID = 0; vID < MAX_BUYABLE_VEHICLES; vID++ )
				if ( !g_vehicleData[ playerid ] [ vID ] [ E_CREATED ] ) break;

			if ( vID >= MAX_BUYABLE_VEHICLES )
				continue;

			if ( g_vehicleData[ playerid ] [ vID ] [ E_CREATED ] )
			    continue;

			cache_get_field_content( i, "PLATE", g_vehicleData[ playerid ] [ vID ] [ E_PLATE ], dbHandle, 32 );
			cache_get_field_content( i, "MODS", Query ), sscanf( Query, "p<.>e<ddddddddddddddd>", g_vehicleModifications[ playerid ] [ vID ] );

			g_vehicleData[ playerid ] [ vID ] [ E_SQL_ID ] 		= cache_get_field_content_int( i, "ID", dbHandle );
			g_vehicleData[ playerid ] [ vID ] [ E_OWNER_ID ] 	= cache_get_field_content_int( i, "OWNER", dbHandle );
			g_vehicleData[ playerid ] [ vID ] [ E_MODEL ] 		= cache_get_field_content_int( i, "MODEL", dbHandle );
			g_vehicleData[ playerid ] [ vID ] [ E_LOCKED ] 		= !!cache_get_field_content_int( i, "LOCKED", dbHandle );
			g_vehicleData[ playerid ] [ vID ] [ E_X ] 			= cache_get_field_content_float( i, "X", dbHandle );
			g_vehicleData[ playerid ] [ vID ] [ E_Y ] 			= cache_get_field_content_float( i, "Y", dbHandle );
			g_vehicleData[ playerid ] [ vID ] [ E_Z ] 			= cache_get_field_content_float( i, "Z", dbHandle );
			g_vehicleData[ playerid ] [ vID ] [ E_ANGLE ] 		= cache_get_field_content_float( i, "ANGLE", dbHandle );
			g_vehicleData[ playerid ] [ vID ] [ E_COLOR ] [ 0 ] = cache_get_field_content_int( i, "COLOR1", dbHandle );
			g_vehicleData[ playerid ] [ vID ] [ E_COLOR ] [ 1 ] = cache_get_field_content_int( i, "COLOR2", dbHandle );
			g_vehicleData[ playerid ] [ vID ] [ E_PRICE ] 		= cache_get_field_content_int( i, "PRICE", dbHandle );
			g_vehicleData[ playerid ] [ vID ] [ E_PAINTJOB ] 	= cache_get_field_content_int( i, "PAINTJOB", dbHandle );
			g_vehicleData[ playerid ] [ vID ] [ E_GARAGE ] 		= cache_get_field_content_int( i, "GARAGE", dbHandle );

			new iVehicle = CreateVehicle( g_vehicleData[ playerid ] [ vID ] [ E_MODEL ], g_vehicleData[ playerid ] [ vID ] [ E_X ], g_vehicleData[ playerid ] [ vID ] [ E_Y ], g_vehicleData[ playerid ] [ vID ] [ E_Z ], g_vehicleData[ playerid ] [ vID ] [ E_ANGLE ], g_vehicleData[ playerid ] [ vID ] [ E_COLOR ] [ 0 ], g_vehicleData[ playerid ] [ vID ] [ E_COLOR ] [ 1 ], 999 );
		    g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ] = iVehicle;

			if ( iVehicle != INVALID_VEHICLE_ID ) {
				if ( g_vehicleData[ playerid ] [ vID ] [ E_GARAGE ] != -1 ) {
					LinkVehicleToInterior( g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ], GetGarageInteriorID( g_vehicleData[ playerid ] [ vID ] [ E_GARAGE ] ) );
					SetVehicleVirtualWorld( g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ], GetGarageVirtualWorld( g_vehicleData[ playerid ] [ vID ] [ E_GARAGE ] ) );
				}

				SetVehicleNumberPlate( g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ], g_vehicleData[ playerid ] [ vID ] [ E_PLATE ] );
				ChangeVehiclePaintjob( g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ], g_vehicleData[ playerid ] [ vID ] [ E_PAINTJOB ] );
				for( new x = 0; x < MAX_CAR_MODS; x++ )
				{
					if ( g_vehicleModifications[ playerid ] [ vID ] [ x ] >= 1000 && g_vehicleModifications[ playerid ] [ vID ] [ x ] < 1193 )
					{
					    if ( CarMod_IsLegalCarMod( GetVehicleModel( g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ] ), g_vehicleModifications[ playerid ] [ vID ] [ x ] ) )
					        AddVehicleComponent( g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ], g_vehicleModifications[ playerid ] [ vID ] [ x ] );
						else
						    g_vehicleModifications[ playerid ] [ vID ] [ x ] = 0;
					}
				}
				g_adminSpawnedCar{ g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ] } = false;
				g_buyableVehicle{ g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ] } = true;
			}

		    g_vehicleData[ playerid ] [ vID ] [ E_CREATED ] = true;

			// Load vehicle components
			format( szNormalString, sizeof( szNormalString ), "SELECT * FROM `COMPONENTS` WHERE `VEHICLE_ID`=%d", g_vehicleData[ playerid ] [ vID ] [ E_SQL_ID ] );
			mysql_function_query( dbHandle, szNormalString, true, "OnVehicleComponentsLoad", "dd", playerid, vID );
		}

		p_OwnedVehicles[ playerid ] = rows;
	}
	return 1;
}

thread OnPlayerCreateBuyableVehicle( playerid, slot )
{
	g_vehicleData[ playerid ] [ slot ] [ E_SQL_ID ] = cache_insert_id( );
	return 1;
}

/* ** Functions ** */
stock CreateBuyableVehicle( playerid, Model, Color1, Color2, Float: X, Float: Y, Float: Z, Float: Angle, Cost )
{
	new
		vID,
	    szString[ 300 ],
	    iCar = INVALID_VEHICLE_ID
	;

	if ( playerid != INVALID_PLAYER_ID && !IsPlayerConnected( playerid ) )
	    return INVALID_PLAYER_ID;

	for( vID = 0; vID < MAX_BUYABLE_VEHICLES; vID++ )
		if ( !g_vehicleData[ playerid ] [ vID ] [ E_CREATED ] ) break;

	if ( vID >= MAX_BUYABLE_VEHICLES )
		return -1;

	if ( g_vehicleData[ playerid ] [ vID ] [ E_CREATED ] )
	    return -1;

	if ( vID != -1 )
	{
		strcpy( g_vehicleData[ playerid ] [ vID ] [ E_PLATE ], "SF-CNR" );
		g_vehicleData[ playerid ] [ vID ] [ E_LOCKED ] = false;
		g_vehicleData[ playerid ] [ vID ] [ E_X ] = X;
		g_vehicleData[ playerid ] [ vID ] [ E_Y ] = Y;
		g_vehicleData[ playerid ] [ vID ] [ E_Z ] = Z;
		g_vehicleData[ playerid ] [ vID ] [ E_ANGLE ] = Angle;
		g_vehicleData[ playerid ] [ vID ] [ E_PRICE ] = Cost;
		g_vehicleData[ playerid ] [ vID ] [ E_COLOR ] [ 0 ] = Color1;
		g_vehicleData[ playerid ] [ vID ] [ E_COLOR ] [ 1 ] = Color2;
		g_vehicleData[ playerid ] [ vID ] [ E_CREATED ] = true;
		g_vehicleData[ playerid ] [ vID ] [ E_PRICE ] = Cost;
		g_vehicleData[ playerid ] [ vID ] [ E_MODEL ] = Model;
		g_vehicleData[ playerid ] [ vID ] [ E_PAINTJOB ] = 3;
		g_vehicleData[ playerid ] [ vID ] [ E_GARAGE ] = -1;
		g_vehicleData[ playerid ] [ vID ] [ E_OWNER_ID ] = p_AccountID[ playerid ];
		ResetBuyableVehicleMods( playerid, vID );
		iCar = CreateVehicle( Model, X, Y, Z, Angle, Color1, Color2, 999999999 );
		g_adminSpawnedCar{ iCar } = false;
		//GetVehicleParamsEx( iCar, engine, lights, alarm, doors, bonnet, boot, objective );
		//SetVehicleParamsEx( iCar, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective );
		SetVehicleNumberPlate( iCar, "SF-CNR" );
		g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ] = iCar;
		g_buyableVehicle{ iCar } = true;
		format( szString, sizeof( szString ), "INSERT INTO `VEHICLES` (`MODEL`,`LOCKED`,`X`,`Y`,`Z`,`ANGLE`,`COLOR1`,`COLOR2`,`PRICE`,`OWNER`,`PLATE`,`PAINTJOB`,`MODS`) VALUES (%d,0,%f,%f,%f,%f,%d,%d,%d,%d,'SF-CNR',3,'0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.')", Model, X, Y, Z, Angle, Color1, Color2, Cost, g_vehicleData[ playerid ] [ vID ] [ E_OWNER_ID ] );
		mysql_function_query( dbHandle, szString, true, "OnPlayerCreateBuyableVehicle", "dd", playerid, vID );

		p_OwnedVehicles[ playerid ] ++; // Append value
	}
	return vID;
}

stock ResetBuyableVehicleMods( playerid, id, fordestroy=1 )
{
	if ( id < 0 || id > MAX_BUYABLE_VEHICLES )
	    return;

	if ( !g_vehicleData[ playerid ] [ id ] [ E_CREATED ] )
	    return;

	for( new i = 0; i < MAX_CAR_MODS; i++ )
	{
		if ( !fordestroy && IsValidVehicle( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] ) ) {
	        if ( CarMod_IsLegalCarMod( GetVehicleModel( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] ), g_vehicleModifications[ playerid ] [ id ] [ i ] ) )
	            RemoveVehicleComponent( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], g_vehicleModifications[ playerid ] [ id ] [ i ] );
		}
		g_vehicleModifications[ playerid ] [ id ] [ i ] = 0;
	}

	format( szNormalString, sizeof( szNormalString ), "UPDATE `VEHICLES` SET `MODS`='0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.' WHERE `ID`=%d", g_vehicleData[ playerid ] [ id ] [ E_SQL_ID ] );
	mysql_single_query( szNormalString );
}

stock DestroyBuyableVehicle( playerid, vID, bool: db_remove = true )
{
	if ( vID < 0 || vID > MAX_BUYABLE_VEHICLES )
	    return 0;

	if ( playerid == INVALID_PLAYER_ID )
		return INVALID_PLAYER_ID;

	if ( !g_vehicleData[ playerid ] [ vID ] [ E_CREATED ] )
	    return 0;

	new
	    query[ 40 ]
	;

	if ( db_remove )
	{
	    SendClientMessage( playerid, -1, ""COL_PINK"[VEHICLE]"COL_WHITE" One of your vehicles has been destroyed.");
		p_OwnedVehicles[ playerid ] --;

		format( query, sizeof( query ), "DELETE FROM `VEHICLES` WHERE `ID`=%d", g_vehicleData[ playerid ] [ vID ] [ E_SQL_ID ] );
		mysql_single_query( query );

    	ResetBuyableVehicleMods( playerid, vID );
	}

	CallLocalFunction( "OnPlayerVehicleDestroyed", "dd", playerid, vID );

	// Reset vehicle component data (hook into module)
	DestroyVehicleCustomComponents( playerid, vID, db_remove );

	// Reset vehicle data
	g_vehicleData[ playerid ] [ vID ] [ E_OWNER_ID ] = 0;
	g_vehicleData[ playerid ] [ vID ] [ E_LOCKED ] = false;
	g_vehicleData[ playerid ] [ vID ] [ E_CREATED ] = false;
	g_buyableVehicle{ g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ] } = false;
	DestroyVehicle( g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ] );
    g_vehicleData[ playerid ] [ vID ] [ E_VEHICLE_ID ] = INVALID_VEHICLE_ID;
	return 1;
}

stock RespawnBuyableVehicle( samp_veh_id, occupantid = INVALID_PLAYER_ID )
{
	new playerid, id;
	new gravy = getVehicleSlotFromID( samp_veh_id, playerid, id );

	if ( gravy == -1 )
		return INVALID_VEHICLE_ID;

	if ( id == -1 && !g_vehicleData[ playerid ] [ id ] [ E_CREATED ] )
	    return INVALID_VEHICLE_ID;

	if ( !IsValidVehicle( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] ) )
	    return INVALID_VEHICLE_ID; // If it aint working.

	new
		Float: beforeAngle,
		Float: Health,
		newVeh = INVALID_VEHICLE_ID
	;

	GetVehicleZAngle( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], beforeAngle );
	GetVehicleDamageStatus( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], panels, doors, lights, tires ); // Can't do this to restore health.
	GetVehicleHealth( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], Health );

	if ( ( newVeh = CreateVehicle( g_vehicleData[ playerid ] [ id ] [ E_MODEL ], g_vehicleData[ playerid ] [ id ] [ E_X ], g_vehicleData[ playerid ] [ id ] [ E_Y ], g_vehicleData[ playerid ] [ id ] [ E_Z ], g_vehicleData[ playerid ] [ id ] [ E_ANGLE ], g_vehicleData[ playerid ] [ id ] [ E_COLOR ] [ 0 ], g_vehicleData[ playerid ] [ id ] [ E_COLOR ] [ 1 ], 999999999 ) ) == INVALID_VEHICLE_ID ) {
	    printf( "[ERROR] CreateVehicle(%d, %f, %f, %f, %f, %d, %d, %d);", g_vehicleData[ playerid ] [ id ] [ E_MODEL ], g_vehicleData[ playerid ] [ id ] [ E_X ], g_vehicleData[ playerid ] [ id ] [ E_Y ], g_vehicleData[ playerid ] [ id ] [ E_Z ], g_vehicleData[ playerid ] [ id ] [ E_ANGLE ], g_vehicleData[ playerid ] [ id ] [ E_COLOR ] [ 0 ], g_vehicleData[ playerid ] [ id ] [ E_COLOR ] [ 1 ], 999999999 );
		return SendError( playerid, "Couldn't update vehicle due to a unknown error." );
	}

	// Reset special data
    ResetVehicleMethlabData( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], true );

    // Destroy vehicle
	DestroyVehicle( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] );
	g_buyableVehicle{ g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] } = false;
	g_buyableVehicle{ newVeh } = true;
 	g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] = newVeh;

	// Restore old data
	SetVehicleNumberPlate( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], g_vehicleData[ playerid ] [ id ] [ E_PLATE ] );
	ChangeVehiclePaintjob( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], g_vehicleData[ playerid ] [ id ] [ E_PAINTJOB ] );
	for( new i = 0; i < MAX_CAR_MODS; i++ ) {
	    if ( g_vehicleModifications[ playerid ] [ id ] [ i ] >= 1000 && g_vehicleModifications[ playerid ] [ id ] [ i ] < 1193 )
	    {
	        if ( CarMod_IsLegalCarMod( GetVehicleModel( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ] ), g_vehicleModifications[ playerid ] [ id ] [ i ] ) )
	            AddVehicleComponent( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], g_vehicleModifications[ playerid ] [ id ] [ i ] );
			else
			    g_vehicleModifications[ playerid ] [ id ] [ i ] = 0;
	    }
	}

	UpdateVehicleDamageStatus( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], panels, doors, lights, tires );
	SetVehicleHealth( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], Health );

	if ( g_vehicleData[ playerid ] [ id ] [ E_GARAGE ] != -1 ) {
		LinkVehicleToInterior( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], GetGarageInteriorID( g_vehicleData[ playerid ] [ id ] [ E_GARAGE ] ) );
		SetVehicleVirtualWorld( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], GetGarageVirtualWorld( g_vehicleData[ playerid ] [ id ] [ E_GARAGE ] ) );
	}

	if ( occupantid != INVALID_PLAYER_ID ) // So nothing bugs with /v color
	{
	    new Float: X, Float: Y, Float: Z;
	    SyncSpectation( playerid ); // Bug?
	    GetPlayerPos( occupantid, X, Y, Z );
	    SetVehiclePos( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], X, Y, Z + 1 );
	    LinkVehicleToInterior( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], GetPlayerInterior( playerid ) );
	    SetVehicleVirtualWorld( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], GetPlayerVirtualWorld( playerid ) );
	    SetTimerEx( "timedUpdates_RBV", 50, false, "ddf", occupantid, g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], beforeAngle );
	}

	// Replace components (hook into module)
	ReplaceVehicleCustomComponents( playerid, id );

	if ( !g_vehicleData[ playerid ] [ id ] [ E_OWNER_ID ] ) {
		GetVehicleParamsEx( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], engine, lights, alarm, doors, bonnet, boot, objective );
		SetVehicleParamsEx( g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ], VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective );
	}
	return g_vehicleData[ playerid ] [ id ] [ E_VEHICLE_ID ];
}

stock SaveVehicleData( playerid, vID )
{
	if ( vID == -1 )
	    return 0;

	new
		szPlate[ 32 ];

	// Plate System
	if ( isnull( g_vehicleData[ playerid ] [ vID ] [ E_PLATE ] ) )
		szPlate = "SF-CNR";
	else
		strcat( szPlate, g_vehicleData[ playerid ] [ vID ] [ E_PLATE ] );

	// Begin Saving
	format( szLargeString, sizeof( szLargeString ), "UPDATE `VEHICLES` SET `MODEL`=%d,`LOCKED`=%d,`X`=%f,`Y`=%f,`Z`=%f,`ANGLE`=%f,`COLOR1`=%d,`COLOR2`=%d,`PRICE`=%d,`PAINTJOB`=%d,`OWNER`=%d,`PLATE`='%s',`GARAGE`=%d WHERE `ID`=%d",
	    g_vehicleData[ playerid ] [ vID ] [ E_MODEL ], g_vehicleData[ playerid ] [ vID ] [ E_LOCKED ], g_vehicleData[ playerid ] [ vID ] [ E_X ], g_vehicleData[ playerid ] [ vID ] [ E_Y ], g_vehicleData[ playerid ] [ vID ] [ E_Z ],
	    g_vehicleData[ playerid ] [ vID ] [ E_ANGLE ], g_vehicleData[ playerid ] [ vID ] [ E_COLOR ] [ 0 ], g_vehicleData[ playerid ] [ vID ] [ E_COLOR ] [ 1 ], g_vehicleData[ playerid ] [ vID ] [ E_PRICE ], g_vehicleData[ playerid ] [ vID ] [ E_PAINTJOB ],
		g_vehicleData[ playerid ] [ vID ] [ E_OWNER_ID ], mysql_escape( szPlate ), g_vehicleData[ playerid ] [ vID ] [ E_GARAGE ],
		g_vehicleData[ playerid ] [ vID ] [ E_SQL_ID ] );

	mysql_single_query( szLargeString );
	return 1;
}

stock dischargeVehicles( playerid )
{
	if ( p_OwnedVehicles[ playerid ] )
	{
		for( new v; v < MAX_BUYABLE_VEHICLES; v++ )
		{
			if ( g_vehicleData[ playerid ][ v ][ E_MODEL ] == 508 ) RemovePlayersFromJourney( g_vehicleData[ playerid ][ v ][ E_VEHICLE_ID ] );
			DestroyBuyableVehicle( playerid, v, .db_remove = false );
		}

	}
	return 1;
}

function timedUpdates_RBV( playerid, vehicleid, Float: angle ) {
	if ( vehicleid != INVALID_VEHICLE_ID )
		SetVehicleZAngle( vehicleid, angle );
}

stock UpdateBuyableVehicleMods( playerid, v )
{
	if ( v < 0 || v > MAX_BUYABLE_VEHICLES ) return 0;
	if ( !g_vehicleData[ playerid ] [ v ] [ E_CREATED ] ) return 0;
	new vehicleid = g_vehicleData[ playerid ] [ v ] [ E_VEHICLE_ID ];
	if ( !IsValidVehicle( vehicleid ) ) return 0;

	for( new i; i < MAX_CAR_MODS; i++ )
    	if ( ( g_vehicleModifications[ playerid ] [ v ] [ i ] = GetVehicleComponentInSlot( vehicleid, i ) ) < 1000 ) g_vehicleModifications[ playerid ] [ v ] [ i ] = 0;

	return 1;
}

stock getVehicleSlotFromID( vID, &playerid=0, &slot=0 )
{
	foreach(new i : Player)
	{
		for( new x; x < MAX_BUYABLE_VEHICLES; x++ ) if ( g_vehicleData[ i ] [ x ] [ E_CREATED ] )
		{
	    	if ( g_vehicleData[ i ] [ x ] [ E_VEHICLE_ID ] == vID )
	    	{
	    		playerid = i;
	    		slot = x;
	    		return x;
	    	}
		}
	}
	return -1;
}

stock SetPlayerVehicleInteriorData( iOwner, iSlot, iInterior, iWorld, Float: fX, Float: fY, Float: fZ, Float: fAngle, iGarage = -1 )
{
	new
		iVehicle = g_vehicleData[ iOwner ] [ iSlot ] [ E_VEHICLE_ID ];

	SetVehiclePos( iVehicle, fX, fY, fZ );
	SetVehicleZAngle( iVehicle, fAngle );

	LinkVehicleToInterior( iVehicle, iInterior );
	SetVehicleVirtualWorld( iVehicle, iWorld );

	ReplaceVehicleCustomComponents( iOwner, iSlot ); // Change virtual worlds

	// Update for passengers etc
	foreach ( new i : Player )
	{
		if ( GetPlayerVehicleID( i ) == iVehicle || GetPlayerSurfingVehicleID( i ) == iVehicle )
		{
			p_InGarage[ i ] = iGarage;
			SetPlayerInterior( i, iInterior );
			SetPlayerVirtualWorld( i, iWorld );
		}
	}
}
