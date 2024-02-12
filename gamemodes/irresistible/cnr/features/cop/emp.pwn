/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: \cnr\features\cop\emp.pwn
 * Purpose: handle vehicle emp
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Commands ** */
CMD:emp( playerid, params[ ] )
{
	new
		pID
	;
	if ( p_Class[ playerid ] != CLASS_POLICE ) return SendError( playerid, "This is restricted to Police only." );
	else if ( p_inCIA{ playerid } == false || p_inArmy{ playerid } == true ) return SendError( playerid, "This is restricted to CIA only." );
	else if ( sscanf( params, "u", pID ) ) return SendUsage( playerid, "/emp [PLAYER_ID]" );
	else if ( !IsPlayerConnected( pID ) || IsPlayerNPC( pID ) ) return SendError( playerid, "Invalid Player ID." );
	else if ( pID == playerid ) return SendError( playerid, "You cannot do this to yourself." );
	else if ( IsPlayerKidnapped( playerid ) ) return SendError( playerid, "You are kidnapped, you cannot do this." );
	else if ( IsPlayerTied( playerid ) ) return SendError( playerid, "You are tied, you cannot do this." );
	else if ( IsPlayerAdminOnDuty( pID ) ) return SendError( playerid, "This person is an admin on duty!" );
    else if ( IsPlayerAdminOnDuty( playerid ) ) return SendError( playerid, "You cannot use this command while AOD." );
	else if ( p_Class[ pID ] == CLASS_POLICE ) return SendError( playerid, "This person is a apart of the Police Force." );
	else if ( !p_WantedLevel[ pID ] ) return SendError( playerid, "This person is innocent!" );
	else if ( !IsPlayerInAnyVehicle( pID ) ) return SendError( playerid, "This player isn't inside any vehicle." );
	else if ( GetPlayerState( pID ) != PLAYER_STATE_DRIVER ) return SendError( playerid, "This player is not a driver of any vehicle." );
    else if ( GetDistanceBetweenPlayers( playerid, pID ) < 30.0 )
	{
	    /* ** ANTI EMP SPAM ** */
	    if ( p_AntiEmpSpam[ pID ] > g_iTime )
	    	return SendError( playerid, "You cannot EMP this person for %s.", secondstotime( p_AntiEmpSpam[ pID ] - g_iTime ) );
	    /* ** END OF ANTI SPAM ** */

	    new
	    	iVehicle = GetPlayerVehicleID( pID );

		if ( g_buyableVehicle{ iVehicle } )
			return SendError( playerid, "Failed to place a Electromagnetic Pulse on this player's vehicle." );

		p_AntiEmpSpam[ pID ] = g_iTime + 60;

	    if ( p_AntiEMP[ pID ] > 0 )
	    {
		    p_AntiEMP[ pID ] --;

		    new
		    	iRandom = random( 101 );

	    	if ( iRandom < 90 )
	    	{
		        SendClientMessage( playerid, -1, ""COL_RED"[EMP]{FFFFFF} An Electromagnetic Pulse attempt has been repelled by an aluminum foil!" );
				SendClientMessage( pID, -1, ""COL_GREEN"[EMP]{FFFFFF} Electromagnetic Pulse had been repelled by aluminum foil set on vehicle." );
				p_QuitToAvoidTimestamp[ pID ] = g_iTime + 15;
	    		return 1;
	    	}
	    }

 		SendClientMessageFormatted( pID, -1, ""COL_RED"[EMP]{FFFFFF} %s(%d) has sent an electromagnetic pulse on your vehicle causing it to crash for 30 seconds.", ReturnPlayerName( playerid ), playerid );
		SendClientMessageFormatted( playerid, -1, ""COL_GREEN"[EMP]{FFFFFF} You have activated a electromagnetic pulse on %s(%d)'s vehicle!", ReturnPlayerName( pID ), pID );
		p_QuitToAvoidTimestamp[ pID ] = g_iTime + 15;
		SetTimerEx( "emp_deactivate", 30000, false, "d", GetPlayerVehicleID( pID ) );
		GetVehicleParamsEx( iVehicle, engine, lights, alarm, doors, bonnet, boot, objective );
		SetVehicleParamsEx( iVehicle, VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective );
	}
	else SendError( playerid, "This player is not nearby." );
	return 1;
}

CMD:demp( playerid, params[ ] ) return cmd_disableemp(playerid, params);
CMD:disableemp( playerid, params[ ] )
{
    if ( p_Class[ playerid ] != CLASS_POLICE ) return SendError( playerid, "This is restricted to Police only." );
	else if ( p_inCIA{ playerid } == false || p_inArmy{ playerid } == true ) return SendError( playerid, "This is restricted to CIA only." );
	else if ( IsPlayerTied( playerid ) ) return SendError( playerid, "You are tied, you cannot do this." );
	else if ( !IsPlayerInAnyVehicle( playerid ) ) return SendError( playerid, "You are not in any vehicle." );
    
    new
        iVehicle = GetPlayerVehicleID( playerid );

    GetVehicleParamsEx( iVehicle, engine, lights, alarm, doors, bonnet, boot, objective );

    if ( engine != VEHICLE_PARAMS_OFF ) return SendError( playerid, "This has not been affected by any EMP attacks.");

    SetVehicleParamsEx( iVehicle, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective );

    return SendServerMessage( playerid, "You have successfully re-initialized the vehicle." );
}

function emp_deactivate( vehicleid )
{
	if ( !IsValidVehicle( vehicleid ) ) return 0;
	GetVehicleParamsEx( vehicleid, engine, lights, alarm, doors, bonnet, boot, objective );
	SetVehicleParamsEx( vehicleid, VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective );
	return 1;
}