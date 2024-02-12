/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\features\hotel_da_novic.pwn
 * Purpose: hotel da novic with operational apartments (very dated)
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Definitions ** */
#define MAX_AFLOORS                 ( 20 )

/* ** Variables ** */
enum E_FLAT_DATA
{
	E_OWNER[ 24 ],    		E_NAME[ 30 ], 		E_LOCKED,
	bool: E_CREATED,		E_FURNITURE
};

static stock
	g_apartmentData                 [ 19 ] [ E_FLAT_DATA ], // A1 = 19 Floors
	g_apartmentElevator             = INVALID_OBJECT_ID,
	g_apartmentElevatorGate         = INVALID_OBJECT_ID,
    g_apartmentElevatorLevel        = 0,
	g_apartmentElevatorDoor1		[ MAX_AFLOORS ]	= INVALID_OBJECT_ID,
	g_apartmentElevatorDoor2		[ MAX_AFLOORS ] = INVALID_OBJECT_ID,
	p_apartmentEnter                [ MAX_PLAYERS char ]
;

/* ** Hooks ** */
hook OnScriptInit( )
{
	// load objects for apartments
	initializeHotelObjects( );

	// Load apartments
	mysql_function_query( dbHandle, "SELECT * FROM `APARTMENTS`", true, "NovicHotel_Load", "" );

	// Apartments
	CreateDynamicObject( 4587, -1971.51, 1356.26, 65.32, 0.00, 0.00, -180.00, .priority = 1 );
	CreateDynamicObject( 3781, -1971.50, 1356.27, 28.26, 0.00, 0.00, -180.00, .priority = 1 );
	CreateDynamicObject( 3781, -1971.50, 1356.27, 55.54, 0.00, 0.00, -180.00, .priority = 1 );
	CreateDynamicObject( 3781, -1971.50, 1356.27, 82.77, 0.00, 0.00, -180.00, .priority = 1 );
	CreateDynamicObject( 3781, -1971.50, 1356.27, 109.89, 0.00, 0.00, -180.00, .priority = 1 );
	CreateDynamicObject( 4605, -1992.10, 1353.31, 1.11, 0.00, 0.00, -180.00, .priority = 1 );

	g_apartmentElevator = CreateDynamicObject( 18755, -1955.09, 1365.51, 8.36, 0.00, 0.00, 90.00 );

	for( new level, Float: Z; level < MAX_AFLOORS; level++ )
	{
		switch( level )
		{
		    case 0:     Z = 8.36;
		    case 1:     Z = 17.03;
		    default:    Z = 17.03 + ( ( level - 1 ) * 5.447 );
		}
		g_apartmentElevatorDoor1[ level ] = CreateDynamicObject( 18756, -1955.05, 1361.64, Z, 0.00, 0.00, -90.00 );
		g_apartmentElevatorDoor2[ level ] = CreateDynamicObject( 18757, -1955.05, 1361.64, Z, 0.00, 0.00, -90.00 );
	}

	// Bank
	g_bankvaultData[ CITY_SF ] [ E_OBJECT ] = CreateDynamicObject( 18766, -1412.565063, 859.274536, 983.132873, 0.000000, 90.000000, 90.000000 );
	g_bankvaultData[ CITY_LV ] [ E_OBJECT ] = CreateDynamicObject( 2634, 2114.742431, 1233.155273, 1017.616821, 0.000000, 0.000000, -90.000000, g_bankvaultData[ CITY_LV ] [ E_WORLD ] );
	g_bankvaultData[ CITY_LS ] [ E_OBJECT ] = CreateDynamicObject( 2634, 2114.742431, 1233.155273, 1017.616821, 0.000000, 0.000000, -90.000000, g_bankvaultData[ CITY_LS ] [ E_WORLD ] );
	SetDynamicObjectMaterial( g_bankvaultData[ CITY_SF ] [ E_OBJECT ], 0, 18268, "mtbtrackcs_t", "mp_carter_cage", -1 );
	return 1;
}

hook OnPlayerKeyStateChange( playerid, newkeys, oldkeys )
{
	static
		Float: X, Float: Y, Float: Z;

	if ( PRESSED( KEY_SECONDARY_ATTACK ) )
	{
		// Call Elevator Down
		if ( CanPlayerExitEntrance( playerid ) && ! IsPlayerTied( playerid ) && ! IsPlayerInAnyVehicle( playerid ) )
		{
			if ( IsPlayerInArea( playerid, -2005.859375, -1917.968750, 1339.843750, 1396.484375 ) && GetPlayerInterior( playerid ) == 0 )
			{
				GetDynamicObjectPos( g_apartmentElevator, X, Y, Z );
				if ( IsPlayerInRangeOfPoint( playerid, 2.0, X, Y, Z ) )
				{
					ClearAnimations( playerid ); // clear-fix

				    if ( IsDynamicObjectMoving( g_apartmentElevator ) )
				        return SendError( playerid, "You must wait for the elevator to stop operating to select a floor again." );

	                szLargeString = "Ground Floor\n";

	                for ( new i = 0; i < sizeof( g_apartmentData ); i++ ) // First floor
	                {
	                    if ( g_apartmentData[ i ] [ E_CREATED ] ) {
	                    	format( szLargeString, sizeof( szLargeString ), "%s%s - %s\n", szLargeString, g_apartmentData[ i ] [ E_OWNER ], g_apartmentData[ i ] [ E_NAME ] );
	                    } else {
						    strcat( szLargeString, "$5,000,000 - Available For Purchase!\n" );
						}
					}

					ShowPlayerDialog( playerid, DIALOG_APARTMENTS, DIALOG_STYLE_LIST, "{FFFFFF}Apartments", szLargeString, "Select", "Cancel" );
					return 1;
				}

				for ( new floors = 0; floors < MAX_AFLOORS; floors++ )
				{
					GetDynamicObjectPos( g_apartmentElevatorDoor1[ floors ], X, Y, Z );
                	if ( IsPlayerInRangeOfPoint( playerid, 4.0, X, Y, Z ) )
                	{
						ClearAnimations( playerid ); // clear-fix
					    if ( IsDynamicObjectMoving( g_apartmentElevator ) ) {
		       				SendError( playerid, "The elevator is operating, please wait." );
		       				break;
						}

	    				PlayerPlaySound( playerid, 1085, 0.0, 0.0, 0.0 );
						NovicHotel_CallElevator( floors ); // First floor
						break;
                	}
				}

				UpdatePlayerEntranceExitTick( playerid );
				return 1;
			}
		}
	}
	return 1;
}

hook OnDialogResponse( playerid, dialogid, response, listitem, inputtext[ ] )
{
	if ( dialogid == DIALOG_APARTMENTS && response )
	{
		new Float: X, Float: Y, Float: Z;
		GetDynamicObjectPos( g_apartmentElevator, X, Y, Z );
		if ( !IsPlayerInRangeOfPoint( playerid, 2.0, X, Y, Z ) )
			return SendError( playerid, "You must be near the elevator to use this!" );

	    if ( listitem == 0 ) NovicHotel_CallElevator( 0 );
	    else
	    {
			new id = listitem - 1;
			p_apartmentEnter{ playerid } = id;
			if ( strmatch( g_apartmentData[ id ] [ E_OWNER ], "No-one" ) || isnull( g_apartmentData[ id ] [ E_OWNER ] ) || !g_apartmentData[ id ] [ E_CREATED ] )
			{
			 	ShowPlayerDialog( playerid, DIALOG_APARTMENTS_BUY, DIALOG_STYLE_MSGBOX, "{FFFFFF}Are you interested?", "{FFFFFF}This apartment is available for sale. The price is $5,000,000.\nIf you wish to buy it, please click 'Purchase'.", "Purchase", "Deny" );
			}
			else if ( !strmatch( g_apartmentData[ id ] [ E_OWNER ], ReturnPlayerName( playerid ) ) )
			{
			    if ( g_apartmentData[ id ] [ E_LOCKED ] ) {
					return SendError( playerid, "This apartment has been locked by its owner." );
				}
			}
	    	NovicHotel_CallElevator( id + 1 );
		}
	}
	else if ( dialogid == DIALOG_APARTMENTS_BUY && response )
	{
	    if ( NovicHotel_GetPlayerApartments( playerid ) > 0 )
	        return SendError( playerid, "You can only own one apartment." );

	    if ( GetPlayerCash( playerid ) < 5000000 )
	        return SendError( playerid, "You don't have enough money for this ($5,000,000)." );

		GivePlayerCash( playerid, -5000000 );

		new aID = p_apartmentEnter{ playerid };
		g_apartmentData[ aID ] [ E_CREATED ] = true;
		format( g_apartmentData[ aID ] [ E_OWNER ], 24, "%s", ReturnPlayerName( playerid ) );
		format( g_apartmentData[ aID ] [ E_NAME ], 30, "Apartment %d", aID );
		g_apartmentData[ aID ] [ E_LOCKED ] = 0;

		format( szNormalString, 100, "INSERT INTO `APARTMENTS` VALUES (%d,'%s','Apartment %d',0)", aID, mysql_escape( ReturnPlayerName( playerid ) ), aID );
	    mysql_single_query( szNormalString );

		SendServerMessage( playerid, "You have purchased an apartment for "COL_GOLD"$5,000,000"COL_WHITE"." );
	}
	else if ( dialogid == DIALOG_FLAT_CONFIG && response )
	{
		for( new id, x = 0; id < sizeof( g_apartmentData ); id ++ )
		{
			if ( g_apartmentData[ id ] [ E_CREATED ] && strmatch( g_apartmentData[ id ] [ E_OWNER ], ReturnPlayerName( playerid ) ) )
			{
		       	if ( x == listitem )
		      	{
					SetPVarInt( playerid, "flat_editing", id );
		      	    SendServerMessage( playerid, "You are now controlling the settings over "COL_GREY"%s", g_apartmentData[ id ] [ E_NAME ] );
		      		ShowPlayerDialog( playerid, DIALOG_FLAT_CONTROL, DIALOG_STYLE_LIST, "{FFFFFF}Owned Apartments", "Spawn Here\nLock Apartment\nModify Apartment Name\nSell Apartment", "Select", "Back" );
		      		break;
				}
		      	x++;
			}
		}
	}
	else if ( dialogid == DIALOG_FLAT_CONTROL )
	{
	    if ( !response )
	        return cmd_flat( playerid, "config" );

		switch( listitem )
		{
		    case 0:
		    {
		    	SetPlayerSpawnLocation( playerid, "APT", GetPVarInt( playerid, "flat_editing" ) );
				SendServerMessage( playerid, "You have set your spawning location to the specified apartment. To stop this you can use \"/flat stopspawn\"." );
				ShowPlayerDialog( playerid, DIALOG_FLAT_CONTROL, DIALOG_STYLE_LIST, "{FFFFFF}Owned Apartments", "Spawn Here\nLock Apartment\nModify Apartment Name\nSell Apartment", "Select", "Back" );
			}
			case 1:
			{
		        new id = GetPVarInt( playerid, "flat_editing" );
             	g_apartmentData[ id ] [ E_LOCKED ] = ( g_apartmentData[ id ] [ E_LOCKED ] == 1 ? 0 : 1 );
				mysql_single_query( sprintf( "UPDATE `APARTMENTS` SET `LOCKED`=%d WHERE `ID`=%d", g_apartmentData[ id ] [ E_LOCKED ], id  ) );
				SendServerMessage( playerid, "You have %s the specified apartment.", g_apartmentData[ id ] [ E_LOCKED ] == 1 ? ( "locked" ) : ( "unlocked" ) );
				ShowPlayerDialog( playerid, DIALOG_FLAT_CONTROL, DIALOG_STYLE_LIST, "{FFFFFF}Owned Apartments", "Spawn Here\nLock Apartment\nModify Apartment Name\nSell Apartment", "Select", "Back" );
			}
		    case 2:
		    {
		   		ShowPlayerDialog( playerid, DIALOG_FLAT_TITLE, DIALOG_STYLE_INPUT, "{FFFFFF}Owned Apartments", ""COL_WHITE"Input the apartment title you want to change with:", "Submit", "Back" );
			}
		    case 3: ShowPlayerDialog( playerid, DIALOG_YOU_SURE_APART, DIALOG_STYLE_MSGBOX, "{FFFFFF}Owned Apartments", ""COL_WHITE"Are you sure that you want to sell your apartment?", "Yes", "No" );
		}
	}
	else if ( dialogid == DIALOG_YOU_SURE_APART )
	{
		if ( ! response )
   			return ShowPlayerDialog( playerid, DIALOG_FLAT_CONTROL, DIALOG_STYLE_LIST, "{FFFFFF}Owned Apartments", "Spawn Here\nLock Apartment\nModify Apartment Name\nSell Apartment", "Select", "Back" );

		new id = GetPVarInt( playerid, "flat_editing" );

		g_apartmentData[ id ] [ E_CREATED ] = false;
		strcpy( g_apartmentData[ id ] [ E_OWNER ], "No-one" );
		// format( g_apartmentData[ id ] [ E_OWNER ], MAX_PLAYER_NAME, "%s", "No-one" );
		format( g_apartmentData[ id ] [ E_NAME ], 30, "Apartment %d", id );
		g_apartmentData[ id ] [ E_LOCKED ] = 0;

		format( szNormalString, 40, "DELETE FROM `APARTMENTS` WHERE `ID`=%d", id );
	    mysql_single_query( szNormalString );

        GivePlayerCash( playerid, 3000000 );
        printf( "%s(%d) sold their apartment", ReturnPlayerName( playerid ), playerid );

   		return SendClientMessage( playerid, -1, ""COL_GREY"[SERVER]"COL_WHITE" You have successfully sold your apartment for "COL_GOLD"$3,000,000"COL_WHITE".");
	}
	else if ( dialogid == DIALOG_FLAT_TITLE )
	{
	    if ( !response )
	        return ShowPlayerDialog( playerid, DIALOG_FLAT_CONTROL, DIALOG_STYLE_LIST, "{FFFFFF}Owned Apartments", "Spawn Here\nLock Apartment\nModify Apartment Name\nSell Apartment", "Select", "Back" );

		if ( !strlen( inputtext ) )
			return ShowPlayerDialog( playerid, DIALOG_FLAT_TITLE, DIALOG_STYLE_INPUT, "{FFFFFF}Owned Apartments", ""COL_WHITE"Input the apartment title you want to change with:\n\n"COL_RED"Must be more than 0 characters.", "Submit", "Back" );

		new id = GetPVarInt( playerid, "flat_editing" );
		mysql_single_query( sprintf( "UPDATE `APARTMENTS` SET `NAME`='%s' WHERE `ID`=%d", mysql_escape( inputtext ), id ) );
		format( g_apartmentData[ id ] [ E_NAME ], 30, "%s", inputtext );
 		SendServerMessage( playerid, "You have successfully changed the name of your apartment." );
  		ShowPlayerDialog( playerid, DIALOG_FLAT_CONTROL, DIALOG_STYLE_LIST, "{FFFFFF}Owned Apartments", "Spawn Here\nLock Apartment\nModify Apartment Name\nSell Apartment", "Select", "Back" );
	}
	return 1;
}

hook OnDynamicObjectMoved( objectid )
{
	if ( objectid == g_apartmentElevator )
	{
		DestroyDynamicObject( g_apartmentElevatorGate ), g_apartmentElevatorGate = INVALID_OBJECT_ID;

		new Float: Y, Float: Z, i = g_apartmentElevatorLevel;
		GetDynamicObjectPos( g_apartmentElevatorDoor1[ i ], Y, Y, Z );
		MoveDynamicObject( g_apartmentElevatorDoor1[ i ], -1956.8068, Y, Z, 5.0 );

		GetDynamicObjectPos( g_apartmentElevatorDoor2[ i ], Y, Y, Z );
		MoveDynamicObject( g_apartmentElevatorDoor2[ i ], -1953.3468, Y, Z, 5.0 );
		return 1;
	}
	return 1;
}

/* ** SQL Threads ** */
thread NovicHotel_Load( )
{
	new
		rows, fields, i = -1, aID,
		Field[ 5 ],
	    loadingTick = GetTickCount( )
	;

	cache_get_data( rows, fields );
	if ( rows )
	{
		while( ++i < rows )
		{
			cache_get_field_content( i, "ID", Field ),			aID = strval( Field );
			cache_get_field_content( i, "OWNER", g_apartmentData[ aID ] [ E_OWNER ], dbHandle, 24 );
			cache_get_field_content( i, "NAME", g_apartmentData[ aID ] [ E_NAME ], dbHandle, 30 );
			cache_get_field_content( i, "LOCKED", Field ), g_apartmentData[ aID ] [ E_LOCKED ] = strval( Field );
			g_apartmentData[ aID ] [ E_CREATED ] = true;
		}
	}
	printf( "[FLATS]: %d apartments have been loaded. (Tick: %dms)", i, GetTickCount( ) - loadingTick );
	return 1;
}

/* ** Commands ** */
CMD:flat( playerid, params[ ] )
{
	new count = 0;
	szBigString[ 0 ] = '\0';
	for( new i; i < sizeof( g_apartmentData ); i++ ) if ( g_apartmentData[ i ] [ E_CREATED ] )
	{
		if ( strmatch( g_apartmentData[ i ] [ E_OWNER ], ReturnPlayerName( playerid ) ) )
		{
		    count++;
		    format( szBigString, sizeof( szBigString ), "%s%s\n", szBigString, g_apartmentData[ i ] [ E_NAME ] );
		}
	}
	if ( count == 0 ) return SendError( playerid, "You don't own any apartments." );

	ShowPlayerDialog( playerid, DIALOG_FLAT_CONFIG, DIALOG_STYLE_LIST, "{FFFFFF}Owned Apartments", szBigString, "Select", "Cancel" );
	return 1;
}

/* ** Functions ** */
stock NovicHotel_IsOwner( playerid, apartmentid ) {
	return g_apartmentData[ apartmentid ] [ E_CREATED ] && strmatch( g_apartmentData[ apartmentid ] [ E_OWNER ], ReturnPlayerName( playerid ) );
}

stock NovicHotel_SetPlayerToFloor( playerid, floor )
{
	pauseToLoad( playerid );
    SetPlayerInterior( playerid, 0 );
    SetPlayerFacingAngle( playerid, 180.0 );
    SetPlayerPos( playerid, -1955.0114, 1360.8344, 17.03 + ( floor * 5.447 ) );
	return 1;
}

stock NovicHotel_UpdateOwnerName( playerid, const newName[ ] )
{
	mysql_format( dbHandle, szNormalString, sizeof( szNormalString ), "UPDATE `APARTMENTS` SET `OWNER` = '%e' WHERE `OWNER` = '%e'", newName, ReturnPlayerName( playerid ) );
	mysql_single_query( szNormalString );

	for( new i = 0; i < sizeof( g_apartmentData ); i++ ) {
		if ( strmatch( g_apartmentData[ i ] [ E_OWNER ], ReturnPlayerName( playerid ) ) ) {
			format( g_apartmentData[ i ] [ E_OWNER ], 24, "%s", newName );
		}
	}
	return 1;
}

stock NovicHotel_CallElevator( level )
{
	new Float: Z, Float: LastZ;

	if ( level >= MAX_AFLOORS )
	    return -1; // Invalid Floor

	switch( level ) {
	    case 0:     Z = 8.36;
	    case 1:     Z = 17.03;
	    default:    Z = 17.03 + ( ( level - 1 ) * 5.447 );
	}

	GetDynamicObjectPos( g_apartmentElevatorDoor1[ g_apartmentElevatorLevel ], LastZ, LastZ, LastZ );
	MoveDynamicObject( g_apartmentElevatorDoor1[ g_apartmentElevatorLevel ], -1955.05, 1361.64, LastZ, 5.0 );
	MoveDynamicObject( g_apartmentElevatorDoor2[ g_apartmentElevatorLevel ], -1955.05, 1361.64, LastZ, 5.0 );

	DestroyDynamicObject( g_apartmentElevatorGate ), g_apartmentElevatorGate = INVALID_OBJECT_ID;
	g_apartmentElevatorGate = CreateDynamicObject( 19304, -1955.08, 1363.74, LastZ, 0.00, 0.00, 0.00 );
 	SetObjectInvisible( g_apartmentElevatorGate ); // Just looks ugly...
	MoveDynamicObject( g_apartmentElevatorGate, -1955.08, 1363.74, Z, 7.0 );

	MoveDynamicObject( g_apartmentElevator, -1955.09, 1365.51, Z, 7.0 );

	g_apartmentElevatorLevel = level; // For the last level.
	return 1;
}

stock NovicHotel_GetPlayerApartments( playerid )
{
	for( new i; i < sizeof( g_apartmentData ); i++ ) if ( g_apartmentData[ i ] [ E_CREATED ] )
	{
		if ( strmatch( g_apartmentData[ i ][ E_OWNER ], ReturnPlayerName( playerid ) ) )
		    return 1;
	}
	return 0;
}

static stock initializeHotelObjects( )
{
#if !defined DEBUG_MODE
	CreateDynamicObject(2298, -1985.82996, 1338.85999, 15.12000,   0.00000, 0.00000, -149.22000);
	CreateDynamicObject(2841, -1987.06006, 1337.18994, 15.12000,   0.00000, 0.00000, 27.30000);
	CreateDynamicObject(2854, -1984.05005, 1335.71997, 15.64000,   0.00000, 0.00000, -152.39999);
	CreateDynamicObject(322, -1986.59998, 1334.09998, 15.10000,   90.00000, 0.00000, -81.78000);
	CreateDynamicObject(19173, -1985.02002, 1334.90002, 17.59000,   0.00000, 0.00000, 30.24000);
	CreateDynamicObject(2313, -2000.96997, 1334.05005, 15.12000,   0.00000, 0.00000, 129.12000);
	CreateDynamicObject(948, -2000.35999, 1333.39001, 15.12000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(948, -2002.43994, 1335.71997, 15.12000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1996.12000, 1336.56006, 15.12000,   0.00000, 0.00000, -89.94000);
	CreateDynamicObject(1703, -1999.12000, 1339.38000, 15.12000,   0.00000, 0.00000, -28.14000);
	CreateDynamicObject(1433, -1998.10999, 1336.71997, 15.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1791, -2001.67004, 1334.40002, 21.10000,   0.00000, 0.00000, 130.14000);
	CreateDynamicObject(1703, -1980.56995, 1362.45996, 15.12000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1978.67004, 1358.44995, 15.12000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1742, -1986.97998, 1354.63000, 15.12000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1742, -1986.97998, 1356.05005, 15.12000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1742, -1986.97998, 1357.48999, 15.12000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2629, -1944.43994, 1369.47998, 15.12000,   0.00000, 0.00000, -24.18000);
	CreateDynamicObject(2628, -1942.32996, 1360.38000, 15.12000,   0.00000, 0.00000, 200.94000);
	CreateDynamicObject(2632, -1945.13000, 1359.30005, 15.12000,   0.00000, 0.00000, 22.50000);
	CreateDynamicObject(2630, -1944.96997, 1359.29004, 15.17000,   0.00000, 0.00000, -69.72000);
	CreateDynamicObject(2823, -1941.59998, 1361.70996, 15.14000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2823, -1943.38000, 1368.56006, 15.14000,   0.00000, 0.00000, 94.74000);
	CreateDynamicObject(1703, -1967.22998, 1368.43994, 15.12000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1965.34998, 1362.87000, 15.12000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1969.25000, 1364.59998, 15.12000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1963.43994, 1366.64001, 15.12000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1433, -1966.55005, 1365.76001, 15.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1966.77002, 1365.77002, 15.82000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2132, -1977.66003, 1368.47998, 15.12000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2131, -1975.62000, 1368.43994, 15.12000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1979.65002, 1368.46997, 15.12000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1980.65002, 1368.46997, 15.12000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2822, -1979.56995, 1368.39001, 27.10000,   0.00000, 0.00000, -119.10000);
	CreateDynamicObject(2851, -1977.47998, 1366.77002, 32.49000,   0.00000, 0.00000, 55.92000);
	CreateDynamicObject(640, -1989.71997, 1374.45996, 15.81000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(640, -2001.73999, 1377.43994, 15.81000,   0.00000, 0.00000, 150.00000);
	CreateDynamicObject(1594, -2000.27002, 1371.23999, 15.60000,   0.00000, 0.00000, 21.78000);
	CreateDynamicObject(1594, -1996.87000, 1367.43994, 15.60000,   0.00000, 0.00000, -30.00000);
	CreateDynamicObject(1594, -2000.85999, 1363.46997, 15.60000,   0.00000, 0.00000, 38.22000);
	CreateDynamicObject(2823, -2000.17004, 1371.33997, 16.01000,   0.00000, 0.00000, -5.04000);
	CreateDynamicObject(2823, -1996.90002, 1367.47998, 16.01000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2823, -2000.93005, 1363.38000, 16.01000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2823, -1997.03003, 1367.15002, 16.01000,   0.00000, 0.00000, 116.04000);
	CreateDynamicObject(2823, -2000.43994, 1371.00000, 16.01000,   0.00000, 0.00000, 126.24000);
	CreateDynamicObject(1703, -1963.43994, 1366.64001, 20.57000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1703, -1967.22998, 1368.43994, 20.57000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1969.25000, 1364.59998, 20.57000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1965.34998, 1362.87000, 20.57000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1433, -1966.55005, 1365.76001, 20.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1966.77002, 1365.77002, 21.29000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1978.67004, 1358.44995, 20.57000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1980.56995, 1362.45996, 20.57000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1986.97998, 1354.63000, 20.57000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1742, -1986.97998, 1356.05005, 20.57000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1742, -1986.97998, 1357.48999, 20.57000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2632, -1945.13000, 1359.30005, 20.57000,   0.00000, 0.00000, 22.50000);
	CreateDynamicObject(2628, -1942.32996, 1360.38000, 20.57000,   0.00000, 0.00000, 200.94000);
	CreateDynamicObject(2823, -1941.59998, 1361.70996, 20.59000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2630, -1944.96997, 1359.29004, 20.63000,   0.00000, 0.00000, -69.72000);
	CreateDynamicObject(2298, -1985.82996, 1338.85999, 20.57000,   0.00000, 0.00000, -149.22000);
	CreateDynamicObject(2841, -1987.06006, 1337.18994, 20.59000,   0.00000, 0.00000, 27.30000);
	CreateDynamicObject(19173, -1985.02002, 1334.90002, 22.57000,   0.00000, 0.00000, 30.24000);
	CreateDynamicObject(2854, -1984.05005, 1335.71997, 21.10000,   0.00000, 0.00000, -152.39999);
	CreateDynamicObject(322, -1986.59998, 1334.09998, 20.57000,   90.00000, 0.00000, -81.78000);
	CreateDynamicObject(1433, -1998.10999, 1336.71997, 20.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1999.12000, 1339.38000, 20.57000,   0.00000, 0.00000, -28.14000);
	CreateDynamicObject(1703, -1996.12000, 1336.56006, 20.57000,   0.00000, 0.00000, -89.94000);
	CreateDynamicObject(2313, -2000.96997, 1334.05005, 20.57000,   0.00000, 0.00000, 129.12000);
	CreateDynamicObject(948, -2000.35999, 1333.39001, 20.57000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(948, -2002.43994, 1335.71997, 20.57000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1594, -2000.85999, 1363.46997, 21.05000,   0.00000, 0.00000, 38.22000);
	CreateDynamicObject(1594, -1996.87000, 1367.43994, 21.01000,   0.00000, 0.00000, -30.00000);
	CreateDynamicObject(1594, -2000.27002, 1371.23999, 21.01000,   0.00000, 0.00000, 21.78000);
	CreateDynamicObject(640, -2001.73999, 1377.43994, 21.29000,   0.00000, 0.00000, 150.00000);
	CreateDynamicObject(2823, -2000.93005, 1363.38000, 21.45000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2823, -2000.43994, 1371.00000, 21.41000,   0.00000, 0.00000, 126.24000);
	CreateDynamicObject(2823, -2000.17004, 1371.33997, 21.41000,   0.00000, 0.00000, -5.04000);
	CreateDynamicObject(2823, -1997.03003, 1367.15002, 21.41000,   0.00000, 0.00000, 116.04000);
	CreateDynamicObject(2823, -1996.90002, 1367.47998, 21.41000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(640, -1989.71997, 1374.45996, 21.27000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2131, -1975.62000, 1368.43994, 20.57000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2132, -1977.66003, 1368.47998, 20.57000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1979.65002, 1368.46997, 20.57000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1980.65002, 1368.46997, 20.57000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2629, -1944.43994, 1369.47998, 20.57000,   0.00000, 0.00000, -24.18000);
	CreateDynamicObject(2823, -1943.38000, 1368.56006, 20.59000,   0.00000, 0.00000, 94.74000);
	CreateDynamicObject(1703, -1978.67004, 1358.44995, 26.04000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1980.56995, 1362.45996, 26.04000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1969.25000, 1364.59998, 26.04000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1967.22998, 1368.43994, 26.04000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1963.43994, 1366.64001, 26.04000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1703, -1965.34998, 1362.87000, 26.04000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1433, -1966.55005, 1365.76001, 26.22000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1966.77002, 1365.77002, 26.74000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2630, -1944.96997, 1359.29004, 26.10000,   0.00000, 0.00000, -69.72000);
	CreateDynamicObject(2628, -1942.32996, 1360.38000, 26.04000,   0.00000, 0.00000, 200.94000);
	CreateDynamicObject(2632, -1945.13000, 1359.30005, 26.04000,   0.00000, 0.00000, 22.50000);
	CreateDynamicObject(2823, -1941.59998, 1361.70996, 26.08000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2823, -1943.38000, 1368.56006, 26.06000,   0.00000, 0.00000, 94.74000);
	CreateDynamicObject(2629, -1944.43994, 1369.47998, 26.04000,   0.00000, 0.00000, -24.18000);
	CreateDynamicObject(1742, -1986.97998, 1354.63000, 26.04000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1742, -1986.97998, 1356.05005, 26.04000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1742, -1986.97998, 1357.48999, 26.04000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2841, -1987.06006, 1337.18994, 26.04000,   0.00000, 0.00000, 27.30000);
	CreateDynamicObject(2298, -1985.82996, 1338.85999, 26.04000,   0.00000, 0.00000, -149.22000);
	CreateDynamicObject(2854, -1984.05005, 1335.71997, 26.60000,   0.00000, 0.00000, -152.39999);
	CreateDynamicObject(19173, -1985.02002, 1334.90002, 27.78000,   0.00000, 0.00000, 30.24000);
	CreateDynamicObject(1703, -1996.12000, 1336.56006, 26.04000,   0.00000, 0.00000, -89.94000);
	CreateDynamicObject(1703, -1999.12000, 1339.38000, 26.04000,   0.00000, 0.00000, -28.14000);
	CreateDynamicObject(1433, -1998.10999, 1336.71997, 26.22000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2313, -2000.96997, 1334.05005, 26.04000,   0.00000, 0.00000, 129.12000);
	CreateDynamicObject(948, -2002.43994, 1335.71997, 26.04000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(948, -2000.35999, 1333.39001, 26.04000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1791, -2001.67004, 1334.40002, 26.54000,   0.00000, 0.00000, 130.14000);
	CreateDynamicObject(640, -2001.73999, 1377.43994, 26.72000,   0.00000, 0.00000, 150.00000);
	CreateDynamicObject(1594, -2000.27002, 1371.23999, 26.52000,   0.00000, 0.00000, 21.78000);
	CreateDynamicObject(1594, -2000.85999, 1363.46997, 26.52000,   0.00000, 0.00000, 38.22000);
	CreateDynamicObject(1594, -1996.87000, 1367.43994, 26.52000,   0.00000, 0.00000, -30.00000);
	CreateDynamicObject(2823, -2000.93005, 1363.38000, 26.92000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2823, -1997.03003, 1367.15002, 26.92000,   0.00000, 0.00000, 116.04000);
	CreateDynamicObject(2823, -1996.90002, 1367.47998, 26.92000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2823, -2000.17004, 1371.33997, 26.92000,   0.00000, 0.00000, -5.04000);
	CreateDynamicObject(2823, -2000.43994, 1371.00000, 26.92000,   0.00000, 0.00000, 126.24000);
	CreateDynamicObject(640, -1989.71997, 1374.45996, 26.72000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2134, -1980.65002, 1368.46997, 26.04000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1979.65002, 1368.46997, 26.04000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2132, -1977.66003, 1368.47998, 26.04000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2131, -1975.62000, 1368.43994, 26.04000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2822, -1979.56995, 1368.39001, 22.00000,   0.00000, 0.00000, -119.10000);
	CreateDynamicObject(1703, -2000.31995, 1353.22998, 26.03000,   0.00000, 0.00000, 46.14000);
	CreateDynamicObject(1703, -1995.45996, 1351.56006, 26.03000,   0.00000, 0.00000, 226.08000);
	CreateDynamicObject(640, -1989.73999, 1348.68005, 26.72000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1985.12000, 1350.71997, 26.04000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1982.79004, 1354.39001, 26.04000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1982.79004, 1354.39001, 15.12000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1985.12000, 1350.71997, 15.12000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1995.45996, 1351.56006, 15.12000,   0.00000, 0.00000, 226.08000);
	CreateDynamicObject(1703, -2000.31995, 1353.22998, 15.12000,   0.00000, 0.00000, 46.14000);
	CreateDynamicObject(1703, -1995.45996, 1351.56006, 20.57000,   0.00000, 0.00000, 226.08000);
	CreateDynamicObject(1703, -2000.31995, 1353.22998, 20.57000,   0.00000, 0.00000, 46.14000);
	CreateDynamicObject(640, -1989.73999, 1348.68005, 15.81000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(640, -1989.73999, 1348.68005, 21.27000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1985.12000, 1350.71997, 20.57000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1982.79004, 1354.39001, 20.57000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1963.43994, 1366.64001, 31.49000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1703, -1967.22998, 1368.43994, 31.49000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1969.25000, 1364.59998, 31.49000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1965.34998, 1362.87000, 31.49000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1433, -1966.55005, 1365.76001, 31.69000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1966.77002, 1365.77002, 32.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2632, -1945.13000, 1359.30005, 31.49000,   0.00000, 0.00000, 22.50000);
	CreateDynamicObject(2630, -1944.96997, 1359.29004, 31.55000,   0.00000, 0.00000, -69.72000);
	CreateDynamicObject(2628, -1942.32996, 1360.38000, 31.49000,   0.00000, 0.00000, 200.94000);
	CreateDynamicObject(2823, -1941.59998, 1361.70996, 31.51000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2823, -1943.38000, 1368.56006, 31.51000,   0.00000, 0.00000, 94.74000);
	CreateDynamicObject(2629, -1944.43994, 1369.47998, 31.49000,   0.00000, 0.00000, -24.18000);
	CreateDynamicObject(1703, -1982.79004, 1354.39001, 31.49000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1985.12000, 1350.71997, 31.49000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1978.67004, 1358.44995, 31.49000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1980.56995, 1362.45996, 31.49000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1986.97998, 1357.48999, 31.49000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1742, -1986.97998, 1356.06995, 31.49000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1742, -1986.97998, 1354.63000, 31.49000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2131, -1975.62000, 1368.43994, 31.49000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2132, -1977.66003, 1368.47998, 31.49000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1979.65002, 1368.46997, 31.49000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1980.65002, 1368.46997, 31.49000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2822, -1979.56995, 1368.39001, 32.49000,   0.00000, 0.00000, -119.10000);
	CreateDynamicObject(1742, -1981.50000, 1363.72998, 42.38000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1981.50000, 1363.77002, 42.38000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1980.26001, 1363.73999, 47.85000,   0.04000, 0.00000, 0.00000);
	CreateDynamicObject(2000, -1950.63000, 1374.00000, 56.14000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1981.68994, 1363.75000, 53.31000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1980.27002, 1363.76001, 58.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1981.51001, 1363.76001, 64.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2576, -1980.85999, 1337.87000, 42.39000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(1744, -1984.81006, 1334.76001, 49.85000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(2563, -1985.28003, 1337.53003, 42.39000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(1820, -1988.59998, 1333.17004, 42.40000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2196, -1987.98999, 1334.26001, 48.38000,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(321, -1981.87000, 1337.16003, 44.61000,   -87.54000, 61.86000, 0.00000);
	CreateDynamicObject(1825, -2001.13000, 1367.22998, 42.40000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1966.04004, 1368.27002, 42.40000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1968.58997, 1364.70996, 42.40000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1964.07996, 1363.19995, 42.40000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1968.58997, 1364.70996, 47.88000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1966.04004, 1368.27002, 47.82000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1964.07996, 1363.19995, 47.87000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2576, -1980.85999, 1337.87000, 47.85000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(321, -1981.87000, 1337.16003, 50.07000,   -87.54000, 61.86000, 0.00000);
	CreateDynamicObject(2563, -1985.28003, 1337.53003, 47.85000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(1820, -1988.59998, 1333.17004, 47.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1825, -2001.13000, 1367.22998, 47.84000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1744, -1984.81006, 1334.76001, 44.39000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(2196, -1987.98999, 1334.26001, 42.90000,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(1724, -1986.44995, 1350.62000, 42.39000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2629, -1950.42004, 1364.57996, 42.44000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2630, -1950.42004, 1366.39001, 42.44000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2628, -1941.78003, 1369.04004, 42.40000,   0.00000, 0.00000, -30.00000);
	CreateDynamicObject(2627, -1943.22998, 1359.67004, 42.40000,   0.00000, 0.00000, -66.00000);
	CreateDynamicObject(2629, -1950.42004, 1364.57996, 47.90000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2630, -1950.42004, 1366.39001, 47.90000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2628, -1941.78003, 1369.04004, 47.86000,   0.00000, 0.00000, -30.00000);
	CreateDynamicObject(2627, -1943.22998, 1359.67004, 47.86000,   0.00000, 0.00000, -66.00000);
	CreateDynamicObject(1724, -1986.44995, 1350.62000, 47.85000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2628, -1941.78003, 1369.04004, 53.32000,   0.00000, 0.00000, -30.00000);
	CreateDynamicObject(2627, -1943.22998, 1359.67004, 53.32000,   0.00000, 0.00000, -66.00000);
	CreateDynamicObject(2629, -1950.42004, 1364.57996, 53.36000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2630, -1950.42004, 1366.39001, 53.36000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1724, -1986.43005, 1350.59998, 53.32000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1968.57996, 1364.68994, 53.32000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1964.07996, 1363.19995, 53.32000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1966.04004, 1368.27002, 53.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(321, -1981.87000, 1337.16003, 55.52000,   -87.54000, 61.86000, 0.00000);
	CreateDynamicObject(2576, -1980.85999, 1337.87000, 53.30000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(2563, -1985.28003, 1337.53003, 53.32000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(1744, -1984.81006, 1334.76001, 55.32000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(1820, -1988.59998, 1333.17004, 53.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2196, -1987.98999, 1334.26001, 53.82000,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(1825, -2001.13000, 1367.22998, 53.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2010, -2000.56006, 1333.31006, 42.39000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2010, -2002.44995, 1335.54004, 42.39000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2010, -2000.56006, 1333.31006, 47.85000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2010, -2002.44995, 1335.54004, 47.85000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2010, -2000.56006, 1333.31006, 53.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2010, -2002.44995, 1335.54004, 53.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1724, -1982.97998, 1353.77002, 58.77000,   0.00000, 0.00000, 137.64000);
	CreateDynamicObject(1703, -1964.07996, 1363.19995, 58.77000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1966.04004, 1368.27002, 58.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1968.58997, 1364.70996, 58.77000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2627, -1943.22998, 1359.67004, 58.77000,   0.00000, 0.00000, -66.00000);
	CreateDynamicObject(2629, -1950.42004, 1364.57996, 58.89000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2630, -1950.42004, 1366.39001, 58.87000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2628, -1941.78003, 1369.04004, 58.77000,   0.00000, 0.00000, -30.00000);
	CreateDynamicObject(1724, -1986.43005, 1350.59998, 64.23000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(321, -1981.87000, 1337.16003, 60.99000,   -87.54000, 61.86000, 0.00000);
	CreateDynamicObject(2576, -1980.85999, 1337.87000, 58.77000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(2563, -1985.30005, 1337.54004, 58.77000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(1820, -1988.59998, 1333.17004, 58.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1744, -1984.81006, 1334.76001, 66.23000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(2196, -1987.98999, 1334.26001, 59.27000,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(2010, -2000.56006, 1333.31006, 58.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2010, -2002.44995, 1335.54004, 58.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1968.58997, 1364.70996, 64.23000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1966.04004, 1368.27002, 64.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1964.07996, 1363.19995, 64.23000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2628, -1941.78003, 1369.04004, 64.23000,   0.00000, 0.00000, -30.00000);
	CreateDynamicObject(2629, -1950.42004, 1364.57996, 64.31000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2627, -1943.22998, 1359.67004, 64.23000,   0.00000, 0.00000, -66.00000);
	CreateDynamicObject(2630, -1950.42004, 1366.39001, 64.31000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(321, -1982.03003, 1337.34998, 66.45000,   -87.54000, 61.86000, 0.00000);
	CreateDynamicObject(2576, -1980.85999, 1337.87000, 64.23000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(2563, -1985.28003, 1337.53003, 64.23000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(1820, -1988.59998, 1333.17004, 64.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2196, -1987.98999, 1334.26001, 64.73000,   0.00000, 0.00000, 70.00000);
	CreateDynamicObject(1744, -1984.81006, 1334.76001, 60.77000,   0.00000, 0.00000, 210.00000);
	CreateDynamicObject(2010, -2002.44995, 1335.54004, 64.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2010, -2000.56006, 1333.31006, 64.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1825, -2001.13000, 1367.22998, 58.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1825, -2001.13000, 1367.22998, 64.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1516, -1965.03003, 1365.65002, 42.38000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1965.03003, 1365.69995, 48.41000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1516, -1965.03003, 1365.65002, 47.87000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1965.03003, 1365.69995, 42.93000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2762, -1998.67004, 1353.41003, 42.81000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1670, -1998.63000, 1353.90002, 43.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, -1998.68994, 1355.06995, 42.40000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1721, -1997.64001, 1354.06006, 42.40000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, -1997.63000, 1352.81995, 42.40000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, -1999.70996, 1352.81995, 42.40000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1721, -1999.68994, 1354.06006, 42.40000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1721, -1998.68994, 1351.81995, 42.40000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2858, -1998.78003, 1353.02002, 43.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2859, -2001.26001, 1367.21997, 43.27000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1980.07996, 1363.75000, 42.38000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1978.63000, 1363.76001, 42.38000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2204, -1986.81006, 1353.64001, 42.39000,   0.00000, 0.00000, 90.32000);
	CreateDynamicObject(344, -1986.63000, 1354.87000, 43.43000,   -19.38000, -86.82000, 90.00000);
	CreateDynamicObject(2131, -1982.06995, 1368.48999, 42.40000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2132, -1984.35999, 1368.42004, 42.40000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2133, -1986.38000, 1368.48999, 42.40000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1981.01001, 1368.47998, 42.40000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1980.01001, 1368.47998, 42.40000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1979.01001, 1368.47998, 42.40000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2133, -1978.00000, 1368.47998, 42.40000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2823, -1980.46997, 1368.37000, 43.45000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2858, -1979.06006, 1368.35999, 43.45000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2851, -1984.68994, 1368.31995, 43.45000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(638, -2001.79004, 1377.46997, 43.10000,   0.00000, 0.00000, 150.00000);
	CreateDynamicObject(2596, -1959.45996, 1365.79004, 45.26000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2596, -1959.45996, 1365.79004, 50.26000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2596, -1959.45996, 1365.79004, 56.26000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2596, -1959.45996, 1365.79004, 61.26000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2596, -1959.47998, 1365.79004, 67.26000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1516, -1965.03003, 1365.65002, 53.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1965.03003, 1365.69995, 53.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2131, -1982.06995, 1368.48999, 47.88000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2823, -1980.46997, 1368.37000, 48.94000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2858, -1979.06006, 1368.35999, 48.94000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2133, -1986.38000, 1368.48999, 47.88000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2132, -1984.35999, 1368.42004, 47.88000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1981.01001, 1368.47998, 47.88000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1980.01001, 1368.47998, 47.88000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1979.01001, 1368.47998, 47.88000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2133, -1978.00000, 1368.47998, 47.88000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2859, -2001.26001, 1367.21997, 48.72000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(638, -2001.79004, 1377.46997, 48.56000,   0.00000, 0.00000, 150.00000);
	CreateDynamicObject(2762, -1998.67004, 1353.41003, 48.26000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, -1999.70996, 1352.81995, 47.88000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1721, -1999.68994, 1354.06006, 47.88000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1721, -1997.63000, 1352.81995, 47.88000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, -1998.68994, 1351.81995, 47.88000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, -1997.64001, 1354.06006, 47.88000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, -1998.68994, 1355.06995, 47.88000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2858, -1998.78003, 1353.02002, 48.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1998.63000, 1353.90002, 48.70000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(638, -2001.79004, 1377.46997, 54.02000,   0.00000, 0.00000, 150.00000);
	CreateDynamicObject(2859, -2001.26001, 1367.21997, 54.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2762, -1998.67004, 1353.41003, 53.72000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, -1998.68994, 1351.81995, 53.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, -1999.70996, 1352.81995, 53.32000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1721, -1999.68994, 1354.06006, 53.32000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1721, -1997.64001, 1354.06006, 53.32000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, -1997.63000, 1352.81995, 53.32000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, -1998.68994, 1355.06995, 53.32000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1670, -1998.63000, 1353.90002, 54.16000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2858, -1998.78003, 1353.02002, 54.14000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, -1998.68994, 1355.06995, 58.77000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1721, -1999.68994, 1354.06006, 58.77000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1721, -1999.71997, 1352.80005, 58.77000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1721, -1997.63000, 1352.81995, 58.77000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, -1997.64001, 1354.06006, 58.77000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, -1998.68994, 1351.81995, 58.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2762, -1998.67004, 1353.41003, 59.19000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2858, -1998.78003, 1353.02002, 59.61000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1998.63000, 1353.90002, 59.63000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2859, -2001.26001, 1367.21997, 59.65000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, -1998.68994, 1355.06995, 64.23000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1721, -1999.68994, 1354.06006, 64.23000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1721, -1997.64001, 1354.06006, 64.23000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, -1999.71997, 1352.80005, 64.23000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1721, -1998.68994, 1351.81995, 64.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, -1997.63000, 1352.81995, 64.23000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2762, -1998.67004, 1353.41003, 64.63000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2858, -1998.78003, 1353.02002, 65.05000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1998.63000, 1353.90002, 65.07000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2859, -2001.26001, 1367.21997, 65.11000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(638, -2001.79004, 1377.46997, 64.95000,   0.00000, 0.00000, 150.00000);
	CreateDynamicObject(638, -2001.79004, 1377.46997, 59.47000,   0.00000, 0.00000, 150.00000);
	CreateDynamicObject(2842, -1987.07996, 1336.58997, 42.40000,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(2842, -1987.07996, 1336.58997, 47.85000,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(2842, -1987.07996, 1336.58997, 53.32000,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(2842, -1987.07996, 1336.58997, 58.77000,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(2842, -1987.07996, 1336.58997, 64.23000,   0.00000, 0.00000, 30.00000);
	CreateDynamicObject(2131, -1982.06995, 1368.48999, 53.32000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2132, -1984.35999, 1368.42004, 53.32000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2133, -1986.38000, 1368.48999, 53.32000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2133, -1978.00000, 1368.47998, 53.32000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2823, -1980.46997, 1368.37000, 54.38000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2858, -1979.06006, 1368.35999, 54.38000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2134, -1979.01001, 1368.47998, 53.32000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1980.01001, 1368.47998, 53.32000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1981.01001, 1368.47998, 53.32000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2851, -1984.68994, 1368.31995, 54.38000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1516, -1965.03003, 1365.65002, 58.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1965.03003, 1365.69995, 59.31000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1516, -1965.03003, 1365.65002, 64.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1965.03003, 1365.69995, 64.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2851, -1984.68994, 1368.31995, 48.94000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2133, -1978.00000, 1368.47998, 58.77000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2131, -1982.06995, 1368.48999, 58.77000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2133, -1986.38000, 1368.48999, 58.77000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2858, -1979.06006, 1368.31995, 59.83000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2823, -1980.46997, 1368.37000, 59.82000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2851, -1984.68994, 1368.31995, 59.82000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2134, -1979.01001, 1368.47998, 58.77000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1980.01001, 1368.47998, 58.77000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1981.00000, 1368.46997, 58.77000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2132, -1984.35999, 1368.42004, 58.77000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2133, -1978.00000, 1368.47998, 64.23000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2858, -1979.06006, 1368.31995, 65.29000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2134, -1979.01001, 1368.47998, 64.23000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2823, -1980.46997, 1368.37000, 65.28000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2134, -1980.01001, 1368.47998, 64.23000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1981.00000, 1368.46997, 64.23000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2131, -1982.06995, 1368.48999, 64.23000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2851, -1984.68994, 1368.31995, 65.29000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2132, -1984.35999, 1368.42004, 64.23000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2133, -1986.38000, 1368.48999, 64.23000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2204, -1986.81006, 1353.64001, 47.85000,   0.00000, 0.00000, 90.32000);
	CreateDynamicObject(344, -1986.63000, 1354.87000, 48.89000,   -19.38000, -86.82000, 90.00000);
	CreateDynamicObject(1742, -1978.81995, 1363.73999, 47.85000,   0.04000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1981.69995, 1363.73999, 47.85000,   0.04000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1983.13000, 1363.75000, 53.31000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1980.25000, 1363.75000, 53.31000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1978.82996, 1363.73999, 58.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1981.68994, 1363.76001, 58.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1982.95996, 1363.77002, 64.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1742, -1980.06995, 1363.76001, 64.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2204, -1986.79004, 1353.63000, 58.77000,   0.00000, 0.00000, 90.32000);
	CreateDynamicObject(2204, -1986.81006, 1353.64001, 64.23000,   0.00000, 0.00000, 90.32000);
	CreateDynamicObject(2204, -1986.81006, 1353.63000, 53.32000,   0.00000, 0.00000, 90.32000);
	CreateDynamicObject(19086, -1986.68994, 1354.39001, 55.41000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(344, -1986.63000, 1354.87000, 59.53000,   -19.38000, -86.82000, 90.00000);
	CreateDynamicObject(344, -1986.63000, 1354.87000, 65.29000,   -19.38000, -86.82000, 90.00000);
	CreateDynamicObject(2964, -1965.46997, 1365.88000, 69.63000,   0.00000, 0.00000, 3.30000);
	CreateDynamicObject(338, -1965.06995, 1366.44995, 70.56000,   -32.76000, -91.98000, 0.00000);
	CreateDynamicObject(338, -1964.31006, 1365.76001, 70.56000,   -32.76000, -91.98000, 30.42000);
	CreateDynamicObject(338, -1966.46997, 1365.56995, 70.56000,   -32.76000, -91.98000, -209.46001);
	CreateDynamicObject(2995, -1966.00000, 1365.51001, 70.56000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.56995, 1365.93994, 70.56000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.63000, 1365.59998, 70.56000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.04004, 1366.26001, 70.56000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1964.85999, 1365.72998, 70.56000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.08997, 1366.21997, 70.56000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1964.47998, 1365.98999, 70.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1964.39001, 1365.92004, 70.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.43994, 1365.80005, 70.28000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.50000, 1365.95996, 70.28000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2857, -1967.78003, 1367.97998, 70.33000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2857, -1963.64001, 1363.52002, 70.33000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2628, -1941.18994, 1368.20996, 69.63000,   0.00000, 0.00000, -27.36000);
	CreateDynamicObject(2631, -1942.59998, 1360.44995, 69.63000,   0.00000, 0.00000, 23.46000);
	CreateDynamicObject(2629, -1941.93005, 1360.68005, 69.68000,   0.00000, 0.00000, -66.42000);
	CreateDynamicObject(2859, -1941.68994, 1362.58997, 69.63000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2859, -1943.04004, 1367.82996, 69.63000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2859, -1944.80005, 1366.82996, 69.63000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2630, -1946.54004, 1359.20996, 69.63000,   0.00000, 0.00000, 244.98000);
	CreateDynamicObject(2815, -1948.20996, 1365.55005, 69.63000,   0.00000, 0.00000, 90.36000);
	CreateDynamicObject(2229, -1982.53003, 1336.31995, 69.62000,   0.00000, 0.00000, -150.06000);
	CreateDynamicObject(2311, -1985.89001, 1334.82996, 69.63000,   0.00000, 0.00000, 30.90000);
	CreateDynamicObject(2229, -1987.92004, 1333.18994, 69.62000,   0.00000, 0.00000, -150.06000);
	CreateDynamicObject(1786, -1985.07996, 1335.20996, 70.13000,   0.00000, 0.00000, -149.52000);
	CreateDynamicObject(2344, -1985.78003, 1337.63000, 70.33000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2849, -1985.38000, 1335.18994, 69.69000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2566, -1998.98999, 1334.80005, 70.07000,   0.00000, 0.00000, 129.42000);
	CreateDynamicObject(2816, -2000.57996, 1333.43005, 70.12000,   0.00000, 0.00000, 114.84000);
	CreateDynamicObject(2819, -2001.18994, 1336.12000, 70.17000,   0.00000, 0.00000, -82.68000);
	CreateDynamicObject(1703, -1990.51001, 1347.50000, 69.63000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1986.80005, 1339.72998, 69.63000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1989.35999, 1336.55005, 69.63000,   0.00000, 0.00000, 72.90000);
	CreateDynamicObject(2894, -2002.52002, 1335.68005, 70.12000,   0.00000, 0.00000, 83.46000);
	CreateDynamicObject(2816, -1986.22998, 1337.23999, 70.33000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2841, -2000.06006, 1336.45996, 69.63000,   0.00000, 0.00000, -49.56000);
	CreateDynamicObject(948, -1991.62000, 1348.52002, 69.63000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(948, -1987.68994, 1348.56995, 69.63000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1991.77002, 1343.83997, 69.63000,   0.00000, 0.00000, 90.30000);
	CreateDynamicObject(1703, -1988.56995, 1342.31006, 69.63000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1987.40002, 1345.91003, 69.63000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1433, -1989.55005, 1345.18005, 69.81000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1989.68005, 1345.38000, 70.32000,   0.00000, 0.00000, 24.72000);
	CreateDynamicObject(1670, -1989.28003, 1344.93005, 70.32000,   0.00000, 0.00000, 46.26000);
	CreateDynamicObject(638, -1993.29004, 1369.19995, 70.33000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.22998, 1371.93994, 70.33000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.22998, 1362.45996, 70.33000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.29004, 1359.17004, 70.33000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.29004, 1353.50000, 70.33000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.34998, 1350.68994, 70.33000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(2147, -1977.71997, 1368.48999, 69.63000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1978.54004, 1368.45996, 69.63000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1979.19995, 1368.45996, 69.63000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1979.85999, 1368.45996, 69.63000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1980.52002, 1368.45996, 69.63000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2132, -1975.72998, 1368.45996, 69.63000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1981.35999, 1368.41003, 69.63000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1982.35999, 1368.41003, 69.63000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1983.35999, 1368.41003, 69.63000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2851, -1979.16003, 1368.42004, 70.81000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2851, -1976.31995, 1368.58997, 70.81000,   0.00000, 0.00000, -47.76000);
	CreateDynamicObject(2858, -1979.91003, 1368.38000, 70.76000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(322, -2002.56995, 1335.73999, 69.99000,   -35.28000, 95.70000, 0.00000);
	CreateDynamicObject(14455, -1986.79004, 1356.28003, 71.29000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(14455, -1978.01001, 1363.43994, 71.29000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(640, -1986.59998, 1360.65002, 70.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1968.62000, 1370.18005, 69.63000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1965.30005, 1370.18005, 69.63000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1961.70996, 1368.23999, 69.63000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1703, -1961.67004, 1364.85999, 69.63000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1703, -1963.93994, 1361.00000, 69.63000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1967.18005, 1360.95996, 69.63000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1970.79004, 1363.08997, 69.63000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1970.87000, 1366.31995, 69.63000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19172, -1966.08997, 1357.16003, 72.50000,   0.00000, 0.00000, 185.00000);
	CreateDynamicObject(19174, -1984.97998, 1334.93994, 72.47000,   0.00000, 0.00000, 210.53999);
	CreateDynamicObject(1703, -1987.35999, 1345.89001, 75.09000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1703, -1990.51001, 1347.50000, 75.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1991.77002, 1343.83997, 75.09000,   0.00000, 0.00000, 90.30000);
	CreateDynamicObject(1703, -1988.56995, 1342.31006, 75.09000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14455, -1986.79004, 1356.28003, 76.75000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(640, -1986.59998, 1360.65002, 75.79000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14455, -1978.01001, 1363.43994, 76.75000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(948, -1987.68994, 1348.56995, 75.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(948, -1991.62000, 1348.52002, 75.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1989.55005, 1345.18005, 75.27000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1986.80005, 1339.72998, 75.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1989.35999, 1336.55005, 75.09000,   0.00000, 0.00000, 72.90000);
	CreateDynamicObject(1703, -1970.79004, 1363.08997, 75.09000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1970.87000, 1366.31995, 75.09000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1967.18005, 1360.95996, 75.09000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1963.93994, 1361.00000, 75.09000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1961.67004, 1364.85999, 75.09000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1703, -1961.70996, 1368.23999, 75.09000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1703, -1965.30005, 1370.18005, 75.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1968.62000, 1370.18005, 75.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2815, -1948.20996, 1365.55005, 75.09000,   0.00000, 0.00000, 90.36000);
	CreateDynamicObject(2859, -1944.80005, 1366.82996, 75.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2859, -1943.04004, 1367.82996, 75.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2859, -1941.68994, 1362.58997, 75.09000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2630, -1946.54004, 1359.20996, 75.09000,   0.00000, 0.00000, 244.98000);
	CreateDynamicObject(2628, -1941.18994, 1368.20996, 75.09000,   0.00000, 0.00000, -27.36000);
	CreateDynamicObject(2631, -1942.59998, 1360.44995, 75.09000,   0.00000, 0.00000, 23.46000);
	CreateDynamicObject(2629, -1941.93005, 1360.68005, 75.13000,   0.00000, 0.00000, -66.42000);
	CreateDynamicObject(2857, -1963.64001, 1363.52002, 75.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2857, -1967.78003, 1367.97998, 75.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2311, -1985.89001, 1334.82996, 75.09000,   0.00000, 0.00000, 30.90000);
	CreateDynamicObject(2229, -1982.53003, 1336.31995, 75.09000,   0.00000, 0.00000, -150.06000);
	CreateDynamicObject(2229, -1987.92004, 1333.18994, 75.09000,   0.00000, 0.00000, -150.06000);
	CreateDynamicObject(2816, -1986.22998, 1337.23999, 75.79000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2344, -1985.80005, 1337.62000, 75.79000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1786, -1985.07996, 1335.20996, 75.59000,   0.00000, 0.00000, -149.52000);
	CreateDynamicObject(2849, -1985.38000, 1335.18994, 75.15000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2841, -2000.06006, 1336.45996, 75.09000,   0.00000, 0.00000, -49.56000);
	CreateDynamicObject(2566, -1998.98999, 1334.80005, 75.51000,   0.00000, 0.00000, 129.42000);
	CreateDynamicObject(2816, -2000.57996, 1333.43005, 75.59000,   0.00000, 0.00000, 114.84000);
	CreateDynamicObject(2819, -2001.18994, 1336.12000, 75.63000,   0.00000, 0.00000, -82.68000);
	CreateDynamicObject(2894, -2002.53003, 1335.69995, 75.55000,   0.00000, 0.00000, 83.46000);
	CreateDynamicObject(322, -2002.56995, 1335.73999, 75.43000,   -35.28000, 95.70000, 0.00000);
	CreateDynamicObject(638, -1993.34998, 1350.68994, 75.79000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.29004, 1353.50000, 75.79000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.29004, 1359.17004, 75.79000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.20996, 1362.46997, 75.79000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.29004, 1369.19995, 75.79000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.22998, 1371.93994, 75.79000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(1670, -1989.68005, 1345.38000, 75.79000,   0.00000, 0.00000, 24.72000);
	CreateDynamicObject(1670, -1989.28003, 1344.93005, 75.79000,   0.00000, 0.00000, 46.26000);
	CreateDynamicObject(2132, -1975.72998, 1368.45996, 75.09000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2147, -1977.71997, 1368.48999, 75.09000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1978.54004, 1368.45996, 75.09000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1979.19995, 1368.45996, 75.09000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1979.85999, 1368.45996, 75.09000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1980.52002, 1368.45996, 75.09000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1981.35999, 1368.41003, 75.09000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1982.35999, 1368.41003, 75.09000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1983.35999, 1368.41003, 75.09000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2851, -1979.16003, 1368.42004, 76.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2858, -1979.91003, 1368.38000, 76.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2851, -1976.09998, 1368.41003, 76.15000,   0.00000, 0.00000, -47.76000);
	CreateDynamicObject(2964, -1965.46997, 1365.88000, 75.09000,   0.00000, 0.00000, 3.30000);
	CreateDynamicObject(338, -1966.46997, 1365.56995, 76.01000,   -32.76000, -91.98000, -209.46001);
	CreateDynamicObject(338, -1964.31006, 1365.76001, 76.01000,   -32.76000, -91.98000, 30.42000);
	CreateDynamicObject(338, -1965.06995, 1366.44995, 76.01000,   -32.76000, -91.98000, 0.00000);
	CreateDynamicObject(2995, -1964.47998, 1365.98999, 75.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1964.41003, 1365.92004, 75.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.08997, 1366.21997, 76.03000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.00000, 1365.51001, 76.03000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.63000, 1365.59998, 76.03000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.56995, 1365.93994, 76.03000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1964.85999, 1365.72998, 76.03000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.56995, 1365.93994, 81.49000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.04004, 1366.26001, 76.03000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.50000, 1365.95996, 75.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.43994, 1365.80005, 75.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19172, -1966.08997, 1357.16003, 78.09000,   0.00000, 0.00000, 185.00000);
	CreateDynamicObject(19174, -1984.97998, 1334.93994, 78.47000,   0.00000, 0.00000, 210.53999);
	CreateDynamicObject(2628, -1941.18994, 1368.20996, 80.55000,   0.00000, 0.00000, -27.36000);
	CreateDynamicObject(2859, -1943.04004, 1367.82996, 80.55000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2631, -1942.59998, 1360.44995, 80.55000,   0.00000, 0.00000, 23.46000);
	CreateDynamicObject(2859, -1941.68994, 1362.58997, 80.55000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2859, -1944.80005, 1366.82996, 80.55000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2629, -1941.93005, 1360.68005, 80.59000,   0.00000, 0.00000, -66.42000);
	CreateDynamicObject(2630, -1946.54004, 1359.20996, 80.55000,   0.00000, 0.00000, 244.98000);
	CreateDynamicObject(2815, -1948.20996, 1365.55005, 80.55000,   0.00000, 0.00000, 90.36000);
	CreateDynamicObject(1703, -1970.87000, 1366.31995, 80.55000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1965.30005, 1370.18005, 80.55000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1968.62000, 1370.18005, 80.55000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1961.70996, 1368.23999, 80.55000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1703, -1961.67004, 1364.85999, 80.55000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1703, -1963.93994, 1361.00000, 80.55000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1967.18005, 1360.95996, 80.55000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1970.79004, 1363.08997, 80.55000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2857, -1963.64001, 1363.52002, 81.25000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2857, -1967.78003, 1367.97998, 81.25000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(948, -1987.68994, 1348.56995, 80.55000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(948, -1991.62000, 1348.52002, 80.55000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1987.40002, 1345.91003, 80.55000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1703, -1990.51001, 1347.50000, 80.55000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1991.77002, 1343.83997, 80.55000,   0.00000, 0.00000, 90.30000);
	CreateDynamicObject(1703, -1988.56995, 1342.31006, 80.55000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1986.80005, 1339.72998, 80.55000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1989.35999, 1336.55005, 80.55000,   0.00000, 0.00000, 72.90000);
	CreateDynamicObject(2229, -1982.53003, 1336.31995, 80.55000,   0.00000, 0.00000, -150.06000);
	CreateDynamicObject(1433, -1989.55005, 1345.18005, 80.73000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2229, -1987.92004, 1333.18994, 80.55000,   0.00000, 0.00000, -150.06000);
	CreateDynamicObject(2816, -1986.22998, 1337.23999, 81.25000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2344, -1985.80005, 1337.62000, 81.25000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2841, -2000.06006, 1336.45996, 80.55000,   0.00000, 0.00000, -49.56000);
	CreateDynamicObject(1786, -1985.07996, 1335.20996, 81.05000,   0.00000, 0.00000, -149.52000);
	CreateDynamicObject(2311, -1985.89001, 1334.82996, 80.55000,   0.00000, 0.00000, 30.90000);
	CreateDynamicObject(2849, -1985.38000, 1335.18994, 80.61000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2566, -1998.98999, 1334.80005, 80.97000,   0.00000, 0.00000, 129.42000);
	CreateDynamicObject(2816, -2000.57996, 1333.43005, 81.03000,   0.00000, 0.00000, 114.84000);
	CreateDynamicObject(2894, -2002.53003, 1335.69995, 81.03000,   0.00000, 0.00000, 83.46000);
	CreateDynamicObject(2819, -2001.17004, 1336.12000, 81.07000,   0.00000, 0.00000, -82.68000);
	CreateDynamicObject(322, -2002.56995, 1335.73999, 80.89000,   -35.28000, 95.70000, 0.00000);
	CreateDynamicObject(638, -1993.34998, 1350.68994, 81.25000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.29004, 1353.50000, 81.25000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.29004, 1359.17004, 81.25000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.20996, 1362.46997, 81.25000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.29004, 1369.19995, 81.25000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.22998, 1371.93994, 81.25000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(1670, -1989.28003, 1344.93005, 81.25000,   0.00000, 0.00000, 46.26000);
	CreateDynamicObject(1670, -1989.68005, 1345.38000, 81.25000,   0.00000, 0.00000, 24.72000);
	CreateDynamicObject(2964, -1965.46997, 1365.88000, 80.55000,   0.00000, 0.00000, 3.30000);
	CreateDynamicObject(338, -1965.06995, 1366.44995, 81.47000,   -32.76000, -91.98000, 0.00000);
	CreateDynamicObject(338, -1964.31006, 1365.76001, 81.47000,   -32.76000, -91.98000, 30.42000);
	CreateDynamicObject(338, -1966.46997, 1365.56995, 81.47000,   -32.76000, -91.98000, -209.46001);
	CreateDynamicObject(2995, -1964.85999, 1365.72998, 81.49000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.63000, 1365.59998, 81.49000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.00000, 1365.51001, 81.49000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.08997, 1366.21997, 81.49000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.04004, 1366.26001, 81.49000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1964.47998, 1365.98999, 81.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1964.41003, 1365.92004, 81.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.43994, 1365.80005, 81.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.50000, 1365.95996, 81.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2628, -1941.18994, 1368.20996, 86.01000,   0.00000, 0.00000, -27.36000);
	CreateDynamicObject(2815, -1948.20996, 1365.55005, 86.01000,   0.00000, 0.00000, 90.36000);
	CreateDynamicObject(2859, -1944.80005, 1366.82996, 86.01000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2859, -1943.04004, 1367.82996, 86.01000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2859, -1941.68994, 1362.58997, 86.01000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2631, -1942.59998, 1360.44995, 86.01000,   0.00000, 0.00000, 23.46000);
	CreateDynamicObject(2629, -1941.93005, 1360.68005, 86.07000,   0.00000, 0.00000, -66.42000);
	CreateDynamicObject(2630, -1946.54004, 1359.20996, 86.01000,   0.00000, 0.00000, 244.98000);
	CreateDynamicObject(1703, -1968.62000, 1370.18005, 86.01000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1965.30005, 1370.18005, 86.01000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1961.70996, 1368.23999, 86.01000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1703, -1961.67004, 1364.85999, 86.01000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1703, -1963.93994, 1361.00000, 86.01000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1970.87000, 1366.31995, 86.01000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1970.79004, 1363.08997, 86.01000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1967.18005, 1360.95996, 86.01000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2857, -1963.64001, 1363.52002, 86.71000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2857, -1967.78003, 1367.97998, 86.71000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14455, -1986.79004, 1356.28003, 82.21000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(14455, -1978.01001, 1363.43994, 82.21000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(640, -1986.59998, 1360.65002, 81.25000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14455, -1978.01001, 1363.43994, 87.67000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14455, -1986.79004, 1356.28003, 87.67000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(640, -1986.59998, 1360.65002, 86.71000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1987.40002, 1345.91003, 86.01000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1703, -1990.51001, 1347.50000, 86.01000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1991.77002, 1343.83997, 86.01000,   0.00000, 0.00000, 90.30000);
	CreateDynamicObject(1703, -1988.56995, 1342.31006, 86.01000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1433, -1989.55005, 1345.18005, 86.19000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1986.80005, 1339.72998, 86.01000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1989.35999, 1336.55005, 86.01000,   0.00000, 0.00000, 72.90000);
	CreateDynamicObject(2816, -1986.22998, 1337.23999, 86.71000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2344, -1985.78003, 1337.60999, 86.71000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2229, -1982.53003, 1336.31995, 86.01000,   0.00000, 0.00000, -150.06000);
	CreateDynamicObject(2229, -1987.92004, 1333.18994, 86.01000,   0.00000, 0.00000, -150.06000);
	CreateDynamicObject(2311, -1985.89001, 1334.82996, 86.01000,   0.00000, 0.00000, 30.90000);
	CreateDynamicObject(1786, -1985.07996, 1335.20996, 86.51000,   0.00000, 0.00000, -149.52000);
	CreateDynamicObject(2849, -1985.38000, 1335.18994, 86.01000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1989.28003, 1344.93005, 86.71000,   0.00000, 0.00000, 46.26000);
	CreateDynamicObject(1670, -1989.68005, 1345.38000, 86.71000,   0.00000, 0.00000, 24.72000);
	CreateDynamicObject(2566, -1998.97998, 1334.78003, 86.41000,   0.00000, 0.00000, 129.42000);
	CreateDynamicObject(2816, -2000.57996, 1333.43005, 86.47000,   0.00000, 0.00000, 114.84000);
	CreateDynamicObject(2819, -2001.18994, 1336.12000, 86.51000,   0.00000, 0.00000, -82.68000);
	CreateDynamicObject(2894, -2002.53003, 1335.69995, 86.47000,   0.00000, 0.00000, 83.46000);
	CreateDynamicObject(2841, -2000.06006, 1336.45996, 86.01000,   0.00000, 0.00000, -49.56000);
	CreateDynamicObject(322, -2002.56995, 1335.73999, 86.33000,   -35.28000, 95.70000, 0.00000);
	CreateDynamicObject(638, -1993.34998, 1350.68994, 86.69000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.29004, 1353.50000, 86.69000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.29004, 1359.17004, 86.69000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.20996, 1362.46997, 86.69000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.29004, 1369.19995, 86.69000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.22998, 1371.93994, 86.69000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(2134, -1983.35999, 1368.41003, 80.55000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1982.35999, 1368.41003, 80.55000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1981.35999, 1368.41003, 80.55000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1980.52002, 1368.45996, 80.55000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1979.85999, 1368.45996, 80.55000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1979.19995, 1368.45996, 80.55000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1978.54004, 1368.45996, 80.55000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2147, -1977.71997, 1368.48999, 80.55000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2132, -1975.72998, 1368.45996, 80.55000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2851, -1976.09998, 1368.41003, 81.61000,   0.00000, 0.00000, -47.76000);
	CreateDynamicObject(2851, -1979.16003, 1368.42004, 81.67000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2858, -1979.91003, 1368.38000, 81.67000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2964, -1965.46997, 1365.88000, 86.01000,   0.00000, 0.00000, 3.30000);
	CreateDynamicObject(338, -1966.46997, 1365.56995, 86.93000,   -32.76000, -91.98000, -209.46001);
	CreateDynamicObject(338, -1964.31006, 1365.76001, 86.93000,   -32.76000, -91.98000, 30.42000);
	CreateDynamicObject(338, -1965.06995, 1366.44995, 86.93000,   -32.76000, -91.98000, 0.00000);
	CreateDynamicObject(2995, -1964.85999, 1365.72998, 86.95000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.04004, 1366.26001, 86.95000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.56995, 1365.93994, 86.95000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.63000, 1365.59998, 86.95000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.00000, 1365.51001, 86.95000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.08997, 1366.21997, 86.95000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1964.41003, 1365.92004, 86.69000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1964.47998, 1365.98999, 86.69000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.42004, 1365.78003, 86.65000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.50000, 1365.95996, 86.65000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14455, -1986.79004, 1356.28003, 93.13000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(14455, -1978.01001, 1363.43994, 93.13000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(640, -1986.59998, 1360.65002, 92.17000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1970.79004, 1363.08997, 91.47000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1970.87000, 1366.31995, 91.47000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1968.62000, 1370.18005, 91.47000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1965.30005, 1370.18005, 91.47000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1967.19995, 1360.96997, 91.47000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2857, -1967.78003, 1367.97998, 92.13000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1963.93994, 1361.00000, 91.47000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1961.67004, 1364.85999, 91.47000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1703, -1961.70996, 1368.23999, 91.47000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1703, -1965.30005, 1370.18005, 91.47000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2857, -1963.64001, 1363.52002, 92.17000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2964, -1965.46997, 1365.88000, 91.47000,   0.00000, 0.00000, 3.30000);
	CreateDynamicObject(2815, -1948.20996, 1365.55005, 91.47000,   0.00000, 0.00000, 90.36000);
	CreateDynamicObject(2859, -1944.80005, 1366.82996, 91.47000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2630, -1946.54004, 1359.20996, 91.47000,   0.00000, 0.00000, 244.98000);
	CreateDynamicObject(2628, -1941.18994, 1368.20996, 91.47000,   0.00000, 0.00000, -27.36000);
	CreateDynamicObject(2859, -1943.04004, 1367.82996, 91.47000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2859, -1941.68994, 1362.58997, 91.47000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2631, -1942.59998, 1360.44995, 91.47000,   0.00000, 0.00000, 23.46000);
	CreateDynamicObject(2629, -1941.93005, 1360.68005, 91.47000,   0.00000, 0.00000, -66.42000);
	CreateDynamicObject(1703, -1991.77002, 1343.83997, 91.47000,   0.00000, 0.00000, 90.30000);
	CreateDynamicObject(1703, -1990.51001, 1347.50000, 91.47000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1987.40002, 1345.91003, 91.47000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1703, -1988.56995, 1342.31006, 91.47000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1433, -1989.55005, 1345.16003, 91.65000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1989.68005, 1345.38000, 92.17000,   0.00000, 0.00000, 24.72000);
	CreateDynamicObject(1670, -1989.28003, 1344.93005, 92.17000,   0.00000, 0.00000, 46.26000);
	CreateDynamicObject(1703, -1986.80005, 1339.72998, 91.47000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1989.35999, 1336.55005, 91.47000,   0.00000, 0.00000, 72.90000);
	CreateDynamicObject(2816, -1986.23999, 1337.26001, 92.17000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2344, -1985.78003, 1337.60999, 92.17000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2229, -1982.53003, 1336.31995, 91.47000,   0.00000, 0.00000, -150.06000);
	CreateDynamicObject(2229, -1987.92004, 1333.18994, 91.47000,   0.00000, 0.00000, -150.06000);
	CreateDynamicObject(1786, -1985.07996, 1335.20996, 91.97000,   0.00000, 0.00000, -149.52000);
	CreateDynamicObject(2311, -1985.89001, 1334.82996, 91.47000,   0.00000, 0.00000, 30.90000);
	CreateDynamicObject(2849, -1985.38000, 1335.20996, 91.55000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2841, -2000.06006, 1336.45996, 91.47000,   0.00000, 0.00000, -49.56000);
	CreateDynamicObject(2566, -1998.97998, 1334.78003, 91.87000,   0.00000, 0.00000, 129.42000);
	CreateDynamicObject(2819, -2001.18994, 1336.12000, 91.95000,   0.00000, 0.00000, -82.68000);
	CreateDynamicObject(2894, -2002.53003, 1335.69995, 91.93000,   0.00000, 0.00000, 83.46000);
	CreateDynamicObject(2816, -2000.57996, 1333.43005, 91.93000,   0.00000, 0.00000, 114.84000);
	CreateDynamicObject(322, -2002.56995, 1335.73999, 91.79000,   -35.28000, 95.70000, 0.00000);
	CreateDynamicObject(638, -1993.34998, 1350.68994, 92.17000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.29004, 1353.50000, 92.17000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.29004, 1359.17004, 92.17000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.20996, 1362.46997, 92.17000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.29004, 1369.19995, 92.17000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(638, -1993.22998, 1371.93994, 92.17000,   0.00000, 0.00000, 178.56000);
	CreateDynamicObject(2134, -1983.35999, 1368.41003, 86.01000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1982.35999, 1368.41003, 86.01000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1981.35999, 1368.41003, 86.01000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1980.52002, 1368.45996, 86.01000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1979.85999, 1368.45996, 86.01000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1979.21997, 1368.46997, 86.01000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1978.54004, 1368.45996, 86.01000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2147, -1977.71997, 1368.48999, 86.01000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2132, -1975.72998, 1368.45996, 86.01000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2858, -1979.91003, 1368.38000, 87.15000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2851, -1979.16003, 1368.42004, 87.13000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2134, -1983.35999, 1368.41003, 91.47000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1982.35999, 1368.41003, 91.47000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1981.35999, 1368.41003, 91.47000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1980.52002, 1368.45996, 91.47000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1979.85999, 1368.45996, 91.47000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1979.21997, 1368.46997, 91.47000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2170, -1978.54004, 1368.45996, 91.47000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2147, -1977.71997, 1368.48999, 91.47000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2132, -1975.72998, 1368.45996, 91.47000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2851, -1976.09998, 1368.41003, 87.07000,   0.00000, 0.00000, -47.76000);
	CreateDynamicObject(2851, -1976.09998, 1368.41003, 92.53000,   0.00000, 0.00000, -47.76000);
	CreateDynamicObject(2858, -1979.91003, 1368.38000, 92.59000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2851, -1979.16003, 1368.42004, 92.59000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(338, -1964.31006, 1365.76001, 92.39000,   -32.76000, -91.98000, 30.42000);
	CreateDynamicObject(338, -1966.46997, 1365.56995, 92.39000,   -32.76000, -91.98000, -209.46001);
	CreateDynamicObject(338, -1965.06995, 1366.44995, 92.39000,   -32.76000, -91.98000, 0.00000);
	CreateDynamicObject(2995, -1966.08997, 1366.21997, 92.41000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1964.85999, 1365.72998, 92.41000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.63000, 1365.59998, 92.41000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.56995, 1365.93994, 92.41000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.00000, 1365.51001, 92.41000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.04004, 1366.26001, 92.41000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1964.47998, 1365.98999, 92.15000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1964.41003, 1365.92004, 92.15000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.42004, 1365.78003, 92.13000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.50000, 1365.95996, 92.13000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19172, -1966.08997, 1357.16003, 83.09000,   0.00000, 0.00000, 185.00000);
	CreateDynamicObject(19172, -1966.08997, 1357.16003, 89.09000,   0.00000, 0.00000, 185.00000);
	CreateDynamicObject(19172, -1966.08997, 1357.16003, 94.09000,   0.00000, 0.00000, 185.00000);
	CreateDynamicObject(19174, -1984.97998, 1334.93994, 83.47000,   0.00000, 0.00000, 210.53999);
	CreateDynamicObject(19174, -1984.97998, 1334.93994, 89.47000,   0.00000, 0.00000, 210.53999);
	CreateDynamicObject(19174, -1984.97998, 1334.93994, 94.47000,   0.00000, 0.00000, 210.53999);
	CreateDynamicObject(1433, -1986.15002, 1337.43005, 69.81000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1967.81006, 1367.81006, 69.81000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1963.69995, 1363.40002, 69.81000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1967.80005, 1367.82996, 75.27000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1963.69995, 1363.40002, 75.27000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1986.15002, 1337.43005, 75.27000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1963.69995, 1363.40002, 80.73000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1967.80005, 1367.82996, 80.73000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1986.15002, 1337.43005, 80.73000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1963.69995, 1363.40002, 86.19000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1967.80005, 1367.82996, 86.19000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1986.15002, 1337.43005, 86.19000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1967.80005, 1367.82996, 91.65000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1963.69995, 1363.40002, 91.65000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1986.15002, 1337.43005, 91.65000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1946.51001, 1364.09998, 113.12000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2853, -1944.55005, 1365.05005, 113.63000,   0.00000, 0.00000, -273.35999);
	CreateDynamicObject(2854, -1944.35999, 1365.58997, 113.63000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1575, -1944.18994, 1365.25000, 113.21000,   0.00000, 0.00000, 116.70000);
	CreateDynamicObject(1670, -1944.47998, 1364.54004, 113.65000,   0.00000, 0.00000, -135.60001);
	CreateDynamicObject(3461, -1947.00000, 1368.29004, 114.65000,   0.00000, 0.00000, -7.68000);
	CreateDynamicObject(3461, -1947.01001, 1362.44995, 114.65000,   0.00000, 0.00000, -7.68000);
	CreateDynamicObject(1703, -1942.63000, 1366.00000, 113.12000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2700, -1943.22998, 1359.48999, 116.21000,   0.00000, 0.00000, 114.84000);
	CreateDynamicObject(2700, -1942.22998, 1369.48999, 116.21000,   0.00000, 0.00000, 242.39999);
	CreateDynamicObject(19128, -1967.58997, 1363.70996, 113.12000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19128, -1967.57996, 1367.67004, 113.12000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19128, -1963.60999, 1363.69995, 113.12000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19128, -1963.63000, 1367.68005, 113.12000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1957, -1971.76001, 1365.34998, 114.03000,   0.00000, 0.00000, 94.98000);
	CreateDynamicObject(1957, -1971.75000, 1366.20996, 114.03000,   0.00000, 0.00000, -89.46000);
	CreateDynamicObject(1840, -1971.70996, 1365.72998, 113.12000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2229, -1971.92004, 1364.76001, 113.12000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2229, -1971.93994, 1367.42004, 113.12000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1714, -1973.47998, 1364.70996, 113.13000,   0.00000, 0.00000, 113.04000);
	CreateDynamicObject(1714, -1973.54004, 1367.12000, 113.13000,   0.00000, 0.00000, 50.46000);
	CreateDynamicObject(2255, -1974.31995, 1365.82996, 115.33000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2126, -1943.91003, 1364.56995, 113.13000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1575, -1944.37000, 1364.68005, 113.21000,   0.00000, 0.00000, 49.80000);
	CreateDynamicObject(1575, -1944.58997, 1365.60999, 113.21000,   0.00000, 0.00000, 22.92000);
	CreateDynamicObject(2032, -1971.60999, 1365.30005, 113.13000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2267, -1944.54004, 1370.89001, 115.44000,   0.00000, 0.00000, -27.16000);
	CreateDynamicObject(2283, -1966.09998, 1357.14001, 115.79000,   0.00000, 0.00000, 182.82001);
	CreateDynamicObject(2393, -1992.68005, 1370.18005, 116.17000,   90.00000, 0.00000, -90.00000);
	CreateDynamicObject(1985, -1994.12000, 1370.43994, 115.91000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2341, -1986.65002, 1368.44995, 113.12000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2340, -1986.68005, 1369.44995, 113.13000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2133, -1986.67004, 1370.42004, 113.13000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2133, -1986.67004, 1371.42004, 113.13000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2141, -1986.68994, 1372.42004, 113.13000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2132, -1984.65002, 1368.44995, 113.12000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2133, -1983.65002, 1368.43005, 113.13000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2133, -1982.65002, 1368.43005, 113.13000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2131, -1980.65002, 1368.41003, 113.13000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2133, -1979.65002, 1368.43005, 113.13000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2133, -1978.65002, 1368.43005, 113.13000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2427, -1978.71997, 1368.05005, 114.18000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1484, -1978.17004, 1367.93994, 113.26000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2866, -1982.93005, 1368.30005, 114.18000,   0.00000, 0.00000, 202.38000);
	CreateDynamicObject(2867, -1986.64001, 1369.54004, 114.18000,   0.00000, 0.00000, -121.80000);
	CreateDynamicObject(2915, -1993.34998, 1368.21997, 113.31000,   0.00000, 0.00000, 89.82000);
	CreateDynamicObject(2915, -1993.51001, 1367.29004, 113.31000,   0.00000, 0.00000, 123.96000);
	CreateDynamicObject(2632, -1993.65002, 1367.18994, 113.13000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2629, -1993.56995, 1365.96997, 113.18000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2851, -1985.67004, 1368.34998, 114.06000,   0.00000, 0.00000, -106.32000);
	CreateDynamicObject(2851, -1986.39001, 1368.25000, 114.18000,   0.00000, 0.00000, -89.04000);
	CreateDynamicObject(640, -2001.81006, 1377.15002, 113.81000,   0.00000, 0.00000, -30.84000);
	CreateDynamicObject(2393, -1992.68005, 1360.43005, 116.17000,   90.00000, 0.00000, -90.00000);
	CreateDynamicObject(1985, -1994.09998, 1360.69995, 115.91000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2632, -1993.65002, 1357.94995, 113.13000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2628, -1993.48999, 1358.90002, 113.18000,   0.00000, 0.00000, -88.80000);
	CreateDynamicObject(2627, -1993.91003, 1362.70996, 113.18000,   0.00000, 0.00000, -86.82000);
	CreateDynamicObject(2630, -1993.67004, 1357.29004, 113.18000,   0.00000, 0.00000, -90.48000);
	CreateDynamicObject(1703, -2000.94995, 1368.55005, 113.12000,   0.00000, 0.00000, 61.08000);
	CreateDynamicObject(1703, -1999.67004, 1364.55005, 113.12000,   0.00000, 0.00000, 126.72000);
	CreateDynamicObject(1703, -2000.64001, 1360.10999, 113.12000,   0.00000, 0.00000, 61.08000);
	CreateDynamicObject(1703, -1999.85999, 1355.92004, 113.12000,   0.00000, 0.00000, 126.72000);
	CreateDynamicObject(2566, -1999.01001, 1334.73999, 113.56000,   0.00000, 0.00000, 128.82001);
	CreateDynamicObject(2816, -2002.58997, 1335.77002, 113.61000,   0.00000, 0.00000, -373.07999);
	CreateDynamicObject(2855, -2000.71997, 1333.43994, 113.61000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(348, -2000.73999, 1333.25000, 113.78000,   -86.04000, -57.30000, 0.00000);
	CreateDynamicObject(2818, -2000.10999, 1336.43005, 113.12000,   0.00000, 0.00000, -50.22000);
	CreateDynamicObject(1703, -1997.29004, 1348.17004, 113.12000,   0.00000, 0.00000, -52.14000);
	CreateDynamicObject(1703, -1999.55005, 1343.81995, 113.12000,   0.00000, 0.00000, -231.24001);
	CreateDynamicObject(1703, -1996.15002, 1344.67004, 113.12000,   0.00000, 0.00000, -139.74001);
	CreateDynamicObject(1703, -2000.68994, 1347.08997, 113.12000,   0.00000, 0.00000, 38.58000);
	CreateDynamicObject(2126, -1998.97998, 1345.94995, 113.13000,   0.00000, 0.00000, -52.86000);
	CreateDynamicObject(1670, -1997.91003, 1345.37000, 113.65000,   0.00000, 0.00000, 38.04000);
	CreateDynamicObject(1670, -1998.57996, 1346.27002, 113.65000,   0.00000, 0.00000, 222.78000);
	CreateDynamicObject(2311, -1982.20996, 1337.05005, 113.12000,   0.00000, 0.00000, -148.25999);
	CreateDynamicObject(2311, -1984.28003, 1335.78003, 113.12000,   0.00000, 0.00000, -149.16000);
	CreateDynamicObject(2311, -1986.31995, 1334.52002, 113.12000,   0.00000, 0.00000, -149.16000);
	CreateDynamicObject(1786, -1982.72998, 1336.55005, 113.63000,   0.00000, 0.00000, -158.94000);
	CreateDynamicObject(1786, -1986.91003, 1333.94995, 113.63000,   0.00000, 0.00000, -123.42000);
	CreateDynamicObject(1786, -1984.87000, 1335.19995, 113.63000,   0.00000, 0.00000, -150.60001);
	CreateDynamicObject(1703, -1984.41003, 1340.65002, 113.12000,   0.00000, 0.00000, 20.40000);
	CreateDynamicObject(1703, -1988.56995, 1337.76001, 113.12000,   0.00000, 0.00000, 46.86000);
	CreateDynamicObject(1703, -1990.88000, 1333.75000, 113.12000,   0.00000, 0.00000, 78.90000);
	CreateDynamicObject(14619, -1988.60999, 1335.07996, 113.50000,   0.00000, 0.00000, 102.12000);
	CreateDynamicObject(14467, -1989.56995, 1347.87000, 115.36000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1546, -1978.37000, 1368.41003, 114.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1546, -1978.82996, 1368.44995, 114.32000,   0.00000, 0.00000, 114.42000);
	CreateDynamicObject(2275, -1988.01001, 1374.37000, 115.51000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2273, -1989.59998, 1374.37000, 115.83000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2275, -1991.31006, 1374.37000, 115.51000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(640, -1985.67004, 1379.81006, 113.81000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(640, -1991.15002, 1379.81006, 113.81000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(640, -1996.63000, 1379.81006, 113.81000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3461, -1992.05005, 1348.39001, 114.69000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, -1988.06006, 1348.39001, 114.69000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1982.68005, 1339.27002, 113.30000,   0.00000, 0.00000, 16.56000);
	CreateDynamicObject(1433, -1986.67004, 1337.48999, 113.30000,   0.00000, 0.00000, 47.88000);
	CreateDynamicObject(1433, -1989.06006, 1334.81995, 113.30000,   0.00000, 0.00000, 79.62000);
	CreateDynamicObject(3461, -1983.68005, 1343.43005, 115.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, -1989.14001, 1339.48999, 115.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3461, -1992.70996, 1333.98999, 115.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2190, -1984.03003, 1363.27002, 113.91000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2162, -1987.00000, 1354.70996, 113.12000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2162, -1987.01001, 1356.51001, 113.12000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2163, -1987.00000, 1358.30005, 113.12000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2165, -1986.47998, 1360.13000, 113.12000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2166, -1986.43005, 1362.08997, 113.12000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2171, -1982.55005, 1363.08997, 113.12000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2169, -1984.46997, 1363.05005, 113.12000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1715, -1983.66003, 1362.14001, 113.13000,   0.00000, 0.00000, 222.78000);
	CreateDynamicObject(1715, -1985.63000, 1362.43994, 113.13000,   0.00000, 0.00000, -2.40000);
	CreateDynamicObject(1715, -1985.52002, 1360.80005, 113.13000,   0.00000, 0.00000, -75.42000);
	CreateDynamicObject(2853, -1986.56995, 1361.57996, 113.91000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2853, -1982.20996, 1363.22998, 113.91000,   0.00000, 0.00000, 211.62000);
	CreateDynamicObject(2854, -1985.72998, 1363.13000, 113.91000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2894, -1983.48999, 1363.19995, 113.91000,   0.00000, 0.00000, -19.38000);
	CreateDynamicObject(2600, -1998.18994, 1333.08997, 113.89000,   0.00000, 0.00000, 21.36000);
	CreateDynamicObject(2611, -1984.27002, 1363.56995, 115.45000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(921, -1985.58997, 1363.50000, 115.98000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2051, -1992.78003, 1351.73999, 115.49000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2051, -1992.77002, 1353.72998, 115.49000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1433, -1998.40002, 1353.84998, 113.31000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1998.43005, 1351.40002, 113.31000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(348, -1998.26001, 1354.19995, 113.86000,   90.00000, 8.34000, -71.70000);
	CreateDynamicObject(348, -1998.58997, 1353.60999, 113.86000,   90.00000, 8.34000, 3.18000);
	CreateDynamicObject(348, -1998.63000, 1351.53003, 113.86000,   90.00000, 8.34000, -73.86000);
	CreateDynamicObject(348, -1998.08997, 1351.67004, 113.86000,   90.00000, 8.34000, -142.67999);
	CreateDynamicObject(1670, -1986.60999, 1337.40002, 113.83000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1988.88000, 1334.95996, 113.83000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1982.71997, 1339.25000, 113.83000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2344, -1982.97998, 1339.43005, 113.81000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2344, -1986.51001, 1337.80005, 113.81000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2344, -1989.34998, 1335.13000, 113.81000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2232, -1971.91003, 1363.53003, 113.68000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2232, -1971.72998, 1367.84998, 113.68000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3525, -1997.71997, 1357.50000, 111.20000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(640, -2001.65002, 1377.50000, 102.91000,   0.00000, 0.00000, -28.26000);
	CreateDynamicObject(2286, -2002.06006, 1377.77002, 105.33000,   0.00000, 0.00000, 60.78000);
	CreateDynamicObject(2566, -1999.03003, 1334.75000, 97.32000,   0.00000, 0.00000, 128.34000);
	CreateDynamicObject(2853, -2000.78003, 1333.42004, 97.37000,   0.00000, 0.00000, 27.36000);
	CreateDynamicObject(2854, -2002.63000, 1335.77002, 97.38000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2255, -2001.55005, 1334.70996, 98.86000,   0.00000, 0.00000, 129.06000);
	CreateDynamicObject(3525, -2000.83997, 1333.40002, 99.24000,   0.00000, 0.00000, 129.06000);
	CreateDynamicObject(3525, -2002.73999, 1335.60999, 99.24000,   0.00000, 0.00000, 129.06000);
	CreateDynamicObject(3525, -1984.76001, 1341.98999, 99.92000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2964, -1966.18994, 1364.68994, 96.75000,   0.00000, 0.00000, 140.28000);
	CreateDynamicObject(338, -1966.04004, 1365.51001, 97.69000,   74.00000, -78.30000, 0.00000);
	CreateDynamicObject(338, -1965.68994, 1363.96997, 97.69000,   74.00000, -78.30000, -24.18000);
	CreateDynamicObject(2995, -1966.80005, 1364.97998, 97.69000,   0.00000, 0.00000, -38.04000);
	CreateDynamicObject(2995, -1965.95996, 1365.01001, 97.69000,   61.00000, 0.00000, 4.02000);
	CreateDynamicObject(2995, -1966.79004, 1364.64001, 97.69000,   456.00000, 0.00000, -48.66000);
	CreateDynamicObject(2995, -1966.58997, 1365.38000, 97.69000,   455.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.98999, 1364.08997, 97.69000,   51.00000, 0.00000, -61.20000);
	CreateDynamicObject(2995, -1965.29004, 1364.48999, 97.69000,   21.00000, 21.00000, 0.00000);
	CreateDynamicObject(2995, -1965.60999, 1364.07996, 97.69000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1965.41003, 1364.08997, 97.39000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2995, -1966.94995, 1365.27002, 97.69000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2244, -1986.67004, 1373.40002, 97.69000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(640, -1977.65002, 1368.34998, 97.44000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2298, -1986.06995, 1338.79004, 15.12000,   0.00000, 0.00000, 210.89999);
	CreateDynamicObject(2393, -1982.78003, 1378.14001, 105.03000,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(1985, -1984.14001, 1378.39001, 105.26000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2628, -1989.46997, 1374.60999, 102.25000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2629, -1990.96997, 1374.65002, 102.26000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2298, -1985.82996, 1338.85999, 31.49000,   0.00000, 0.00000, -149.22000);
	CreateDynamicObject(2841, -1987.06006, 1337.18994, 31.49000,   0.00000, 0.00000, 27.30000);
	CreateDynamicObject(2854, -1984.05005, 1335.71997, 32.01000,   0.00000, 0.00000, -152.39999);
	CreateDynamicObject(19173, -1985.02002, 1334.90002, 33.49000,   0.00000, 0.00000, 30.24000);
	CreateDynamicObject(640, -1989.71997, 1374.45996, 32.19000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(640, -2001.73999, 1377.43994, 32.19000,   0.00000, 0.00000, 150.00000);
	CreateDynamicObject(640, -1989.73999, 1348.68005, 32.19000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1999.12000, 1339.38000, 31.49000,   0.00000, 0.00000, -28.14000);
	CreateDynamicObject(1703, -1996.12000, 1336.56006, 31.49000,   0.00000, 0.00000, -89.94000);
	CreateDynamicObject(1433, -1998.10999, 1336.71997, 31.67000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2313, -2000.96997, 1334.05005, 31.49000,   0.00000, 0.00000, 129.12000);
	CreateDynamicObject(948, -2000.35999, 1333.39001, 31.49000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(948, -2002.43994, 1335.71997, 31.49000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1791, -2001.67004, 1334.40002, 31.99000,   0.00000, 0.00000, 130.14000);
	CreateDynamicObject(1703, -1995.45996, 1351.56006, 31.49000,   0.00000, 0.00000, 226.08000);
	CreateDynamicObject(1703, -2000.31995, 1353.22998, 31.49000,   0.00000, 0.00000, 46.14000);
	CreateDynamicObject(1594, -2000.85999, 1363.46997, 32.19000,   0.00000, 0.00000, 38.22000);
	CreateDynamicObject(1594, -1996.87000, 1367.43994, 32.19000,   0.00000, 0.00000, -30.00000);
	CreateDynamicObject(1594, -2000.27002, 1371.23999, 32.19000,   0.00000, 0.00000, 21.78000);
	CreateDynamicObject(2823, -2000.93005, 1363.38000, 32.59000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2823, -1997.03003, 1367.15002, 32.59000,   0.00000, 0.00000, 116.04000);
	CreateDynamicObject(2823, -1996.91003, 1367.50000, 32.59000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2823, -2000.43994, 1371.00000, 32.59000,   0.00000, 0.00000, 126.24000);
	CreateDynamicObject(2823, -2000.17004, 1371.33997, 32.59000,   0.00000, 0.00000, -5.04000);
	CreateDynamicObject(1703, -1963.43994, 1366.64001, 36.95000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1703, -1967.22998, 1368.43994, 36.95000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1965.34998, 1362.87000, 36.95000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1969.25000, 1364.59998, 36.95000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1433, -1966.55005, 1365.76001, 37.13000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1966.77002, 1365.77002, 37.67000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1980.56995, 1362.45996, 36.95000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1978.67004, 1358.44995, 36.95000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1982.79004, 1354.39001, 36.95000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1985.12000, 1350.71997, 36.95000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1742, -1986.97998, 1354.63000, 36.95000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1742, -1986.97998, 1357.48999, 36.95000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1742, -1986.97998, 1356.06995, 36.95000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2841, -1987.06006, 1337.18994, 36.95000,   0.00000, 0.00000, 27.30000);
	CreateDynamicObject(2298, -1985.82996, 1338.85999, 36.95000,   0.00000, 0.00000, -149.22000);
	CreateDynamicObject(19173, -1985.02002, 1334.90002, 38.95000,   0.00000, 0.00000, 30.24000);
	CreateDynamicObject(2854, -1984.05005, 1335.71997, 37.48000,   0.00000, 0.00000, -152.39999);
	CreateDynamicObject(1703, -1996.12000, 1336.56006, 36.95000,   0.00000, 0.00000, -89.94000);
	CreateDynamicObject(1703, -1999.12000, 1339.38000, 36.95000,   0.00000, 0.00000, -28.14000);
	CreateDynamicObject(1433, -1998.10999, 1336.71997, 37.17000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(948, -2000.35999, 1333.39001, 36.95000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1791, -2001.67004, 1334.40002, 37.45000,   0.00000, 0.00000, 130.14000);
	CreateDynamicObject(2313, -2000.96997, 1334.05005, 36.95000,   0.00000, 0.00000, 129.12000);
	CreateDynamicObject(948, -2002.43994, 1335.71997, 36.95000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(640, -2001.73999, 1377.43994, 37.65000,   0.00000, 0.00000, 150.00000);
	CreateDynamicObject(1594, -2000.27002, 1371.23999, 37.65000,   0.00000, 0.00000, 21.78000);
	CreateDynamicObject(1594, -1996.87000, 1367.43994, 37.65000,   0.00000, 0.00000, -30.00000);
	CreateDynamicObject(1594, -2000.85999, 1363.46997, 37.65000,   0.00000, 0.00000, 38.22000);
	CreateDynamicObject(640, -1989.73999, 1348.68005, 37.65000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(640, -1989.71997, 1374.45996, 37.65000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2823, -1996.91003, 1367.50000, 38.05000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2823, -1997.03003, 1367.15002, 38.05000,   0.00000, 0.00000, 116.04000);
	CreateDynamicObject(2823, -2000.17004, 1371.33997, 38.05000,   0.00000, 0.00000, -5.04000);
	CreateDynamicObject(2823, -2000.43994, 1371.00000, 38.05000,   0.00000, 0.00000, 126.24000);
	CreateDynamicObject(2823, -2000.93005, 1363.38000, 38.05000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2632, -1945.13000, 1359.30005, 36.95000,   0.00000, 0.00000, 22.50000);
	CreateDynamicObject(2630, -1944.96997, 1359.29004, 36.95000,   0.00000, 0.00000, -69.72000);
	CreateDynamicObject(2628, -1942.32996, 1360.38000, 36.95000,   0.00000, 0.00000, 200.94000);
	CreateDynamicObject(2823, -1941.59998, 1361.70996, 36.97000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2629, -1944.43994, 1369.47998, 36.95000,   0.00000, 0.00000, -24.18000);
	CreateDynamicObject(2823, -1943.38000, 1368.56006, 36.97000,   0.00000, 0.00000, 94.74000);
	CreateDynamicObject(1703, -1991.07996, 1345.78003, 58.77000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1996.70996, 1339.26001, 58.77000,   0.00000, 0.00000, -58.92000);
	CreateDynamicObject(1703, -1998.55005, 1335.38000, 58.77000,   0.00000, 0.00000, -232.38000);
	CreateDynamicObject(1703, -1987.64001, 1344.44995, 58.77000,   0.00000, 0.00000, -90.86000);
	CreateDynamicObject(1703, -1992.56006, 1342.47998, 58.77000,   0.00000, 0.00000, 90.54000);
	CreateDynamicObject(1824, -1989.98999, 1343.06006, 59.29000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1896, -1981.50000, 1356.12000, 59.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1724, -1981.04004, 1353.08997, 58.77000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1724, -1979.33997, 1354.33997, 58.77000,   0.00000, 0.00000, -137.64000);
	CreateDynamicObject(1724, -1982.97998, 1353.77002, 64.23000,   0.00000, 0.00000, 137.64000);
	CreateDynamicObject(1724, -1981.04004, 1353.08997, 64.23000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1724, -1979.33997, 1354.33997, 64.23000,   0.00000, 0.00000, -137.64000);
	CreateDynamicObject(1896, -1981.50000, 1356.12000, 65.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1824, -1989.98999, 1343.06006, 64.75000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1991.07996, 1345.78003, 64.23000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1987.64001, 1344.44995, 64.23000,   0.00000, 0.00000, -90.86000);
	CreateDynamicObject(1703, -1992.56006, 1342.47998, 64.23000,   0.00000, 0.00000, 90.54000);
	CreateDynamicObject(1703, -1996.70996, 1339.26001, 64.23000,   0.00000, 0.00000, -58.92000);
	CreateDynamicObject(1703, -1998.55005, 1335.38000, 64.23000,   0.00000, 0.00000, -232.38000);
	CreateDynamicObject(1724, -1982.97998, 1353.77002, 53.32000,   0.00000, 0.00000, 137.64000);
	CreateDynamicObject(1724, -1981.04004, 1353.08997, 53.32000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1724, -1979.33997, 1354.33997, 53.32000,   0.00000, 0.00000, -137.64000);
	CreateDynamicObject(1896, -1981.50000, 1356.12000, 54.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1987.64001, 1344.44995, 53.32000,   0.00000, 0.00000, -90.86000);
	CreateDynamicObject(1703, -1991.07996, 1345.78003, 53.32000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1992.56006, 1342.47998, 53.32000,   0.00000, 0.00000, 90.54000);
	CreateDynamicObject(1824, -1989.98999, 1343.06006, 53.82000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1998.55005, 1335.38000, 53.32000,   0.00000, 0.00000, -232.38000);
	CreateDynamicObject(1703, -1996.70996, 1339.26001, 53.32000,   0.00000, 0.00000, -58.92000);
	CreateDynamicObject(1724, -1986.43005, 1350.59998, 58.77000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1724, -1979.33997, 1354.33997, 47.85000,   0.00000, 0.00000, -137.64000);
	CreateDynamicObject(1724, -1981.04004, 1353.08997, 47.85000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1724, -1982.97998, 1353.77002, 47.85000,   0.00000, 0.00000, 137.64000);
	CreateDynamicObject(1703, -1987.64001, 1344.44995, 47.85000,   0.00000, 0.00000, -90.86000);
	CreateDynamicObject(1703, -1991.07996, 1345.78003, 47.85000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1992.56006, 1342.47998, 47.85000,   0.00000, 0.00000, 90.54000);
	CreateDynamicObject(1824, -1989.98999, 1343.06006, 48.36000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1996.70996, 1339.26001, 47.85000,   0.00000, 0.00000, -58.92000);
	CreateDynamicObject(1703, -1998.55005, 1335.38000, 47.85000,   0.00000, 0.00000, -232.38000);
	CreateDynamicObject(1724, -1979.33997, 1354.33997, 42.39000,   0.00000, 0.00000, -137.64000);
	CreateDynamicObject(1724, -1981.04004, 1353.08997, 42.39000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1724, -1982.97998, 1353.77002, 42.39000,   0.00000, 0.00000, 137.64000);
	CreateDynamicObject(1896, -1981.50000, 1356.12000, 43.38000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1896, -1981.50000, 1356.12000, 48.82000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1987.64001, 1344.44995, 42.39000,   0.00000, 0.00000, -90.86000);
	CreateDynamicObject(1703, -1991.07996, 1345.78003, 42.39000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1992.56006, 1342.47998, 42.39000,   0.00000, 0.00000, 90.54000);
	CreateDynamicObject(1703, -1996.70996, 1339.26001, 42.39000,   0.00000, 0.00000, -58.92000);
	CreateDynamicObject(1703, -1998.55005, 1335.38000, 42.39000,   0.00000, 0.00000, -232.38000);
	CreateDynamicObject(1824, -1989.98999, 1343.06006, 42.91000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2131, -1975.62000, 1368.43994, 36.95000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2132, -1977.66003, 1368.47998, 36.95000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1980.65002, 1368.46997, 36.95000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1979.65002, 1368.46997, 36.95000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2822, -1979.56995, 1368.39001, 38.01000,   0.00000, 0.00000, -119.10000);
	CreateDynamicObject(2851, -1978.67004, 1368.27002, 37.87000,   0.00000, 0.00000, 55.92000);
	CreateDynamicObject(2631, -1950.28003, 1365.41003, 53.36000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2631, -1950.28003, 1365.41003, 47.90000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2631, -1950.28003, 1365.41003, 42.44000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2631, -1950.28003, 1365.41003, 58.83000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2631, -1950.28003, 1365.41003, 64.27000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2308, -1986.43005, 1362.15002, 107.66000,   0.00000, 0.00000, 360.00000);
	CreateDynamicObject(2200, -1986.67004, 1359.93994, 107.67000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2205, -1986.34998, 1358.95996, 107.67000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2190, -1986.32996, 1359.27002, 108.60000,   0.00000, 0.00000, 46.80000);
	CreateDynamicObject(2238, -1986.68005, 1357.35999, 109.02000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2008, -1984.44995, 1363.10999, 107.66000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2162, -1982.44995, 1363.59998, 107.66000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1714, -1985.13000, 1358.57996, 107.67000,   0.00000, 0.00000, -54.96000);
	CreateDynamicObject(1714, -1984.23999, 1362.01001, 107.67000,   0.00000, 0.00000, 125.76000);
	CreateDynamicObject(2894, -1986.53003, 1362.82996, 108.45000,   0.00000, 0.00000, 47.40000);
	CreateDynamicObject(2894, -1986.31006, 1357.96997, 108.61000,   0.00000, 0.00000, 115.20000);
	CreateDynamicObject(2255, -1986.40002, 1358.06995, 110.14000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18885, -1974.33997, 1365.93994, 108.75000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3525, -1974.58997, 1364.53003, 110.54000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3525, -1974.58997, 1367.25000, 110.54000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(358, -2000.20996, 1332.81006, 107.96000,   -14.28000, -98.56000, 347.51999);
	CreateDynamicObject(2566, -1998.89001, 1334.64001, 108.05000,   0.00000, 0.00000, 129.84000);
	CreateDynamicObject(1744, -2001.57996, 1333.71997, 109.48000,   0.00000, 0.00000, 129.84000);
	CreateDynamicObject(356, -2001.59998, 1334.22998, 109.88000,   -103.06000, -7.68000, -75.48000);
	CreateDynamicObject(348, -2000.28003, 1333.38000, 108.10000,   90.00000, 0.00000, -106.68000);
	CreateDynamicObject(3052, -2002.93005, 1336.31995, 107.78000,   0.00000, 0.00000, -4.32000);
	CreateDynamicObject(2043, -2002.29004, 1336.04004, 107.77000,   0.00000, 0.00000, 73.86000);
	CreateDynamicObject(351, -2002.62000, 1336.18005, 107.96000,   -101.32000, -13.28000, 126.96000);
	CreateDynamicObject(1704, -2001.30005, 1342.06006, 107.67000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1704, -2002.65002, 1339.78003, 107.67000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1704, -2000.32996, 1338.58997, 107.67000,   0.00000, 0.00000, -180.00000);
	CreateDynamicObject(1433, -2000.76001, 1340.29004, 107.87000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(348, -2001.10999, 1340.10999, 108.39000,   90.00000, 0.00000, 55.86000);
	CreateDynamicObject(348, -2000.66003, 1339.83997, 108.39000,   90.00000, 0.00000, 56.10000);
	CreateDynamicObject(348, -2000.79004, 1340.72998, 108.39000,   90.00000, 0.00000, -27.66000);
	CreateDynamicObject(2254, -2001.73999, 1334.25000, 111.25000,   0.00000, 0.00000, 129.96001);
	CreateDynamicObject(2208, -1997.85999, 1365.23999, 107.66000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2208, -1997.85999, 1358.88000, 107.66000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1722, -1997.97998, 1363.71997, 107.67000,   0.00000, 0.00000, -9.90000);
	CreateDynamicObject(1722, -1996.45996, 1365.90002, 107.67000,   0.00000, 0.00000, 124.80000);
	CreateDynamicObject(1722, -1996.73999, 1367.08997, 107.67000,   0.00000, 0.00000, 70.08000);
	CreateDynamicObject(1722, -1999.42004, 1365.79004, 107.67000,   0.00000, 0.00000, 281.34000);
	CreateDynamicObject(1722, -1999.31006, 1367.43994, 107.67000,   0.00000, 0.00000, 247.44000);
	CreateDynamicObject(1722, -1997.81995, 1369.06006, 107.67000,   0.00000, 0.00000, -209.58000);
	CreateDynamicObject(2212, -1997.87000, 1365.52002, 108.58000,   -25.50000, 23.52000, 27.24000);
	CreateDynamicObject(2212, -1997.81995, 1366.56006, 108.58000,   -25.50000, 23.52000, -173.82001);
	CreateDynamicObject(2212, -1998.13000, 1367.59998, 108.58000,   -25.50000, 23.52000, -89.94000);
	CreateDynamicObject(2894, -1997.93994, 1365.12000, 108.53000,   0.00000, 0.00000, -25.74000);
	CreateDynamicObject(2894, -1997.64001, 1366.96997, 108.53000,   0.00000, 0.00000, 131.10001);
	CreateDynamicObject(3525, -1992.81995, 1367.70996, 110.27000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(3525, -1992.81995, 1363.79004, 110.27000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(3525, -1992.81995, 1358.32996, 110.27000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(3525, -1992.81995, 1353.97998, 110.27000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1704, -1999.30005, 1361.33997, 107.67000,   0.00000, 0.00000, 60.66000);
	CreateDynamicObject(1704, -1995.89001, 1360.73999, 107.67000,   0.00000, 0.00000, 283.79999);
	CreateDynamicObject(1704, -1998.76001, 1357.90002, 107.67000,   0.00000, 0.00000, 492.60001);
	CreateDynamicObject(348, -1997.90002, 1361.50000, 108.53000,   90.00000, 0.00000, -125.46000);
	CreateDynamicObject(348, -1997.63000, 1359.04004, 108.53000,   90.00000, 0.00000, 121.44000);
	CreateDynamicObject(1703, -1999.95996, 1353.30005, 107.66000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1997.91003, 1349.26001, 107.66000,   0.00000, 0.00000, 178.62000);
	CreateDynamicObject(1703, -2001.69995, 1350.32996, 107.66000,   0.00000, 0.00000, 88.86000);
	CreateDynamicObject(1670, -1998.03003, 1358.76001, 108.54000,   0.00000, 0.00000, 139.98000);
	CreateDynamicObject(1670, -1998.03003, 1361.22998, 108.54000,   0.00000, 0.00000, -39.78000);
	CreateDynamicObject(1549, -1999.68005, 1358.93005, 107.67000,   0.00000, 0.00000, 192.36000);
	CreateDynamicObject(1549, -1999.67004, 1361.00000, 107.67000,   0.00000, 0.00000, 239.52000);
	CreateDynamicObject(2894, -1997.77002, 1360.52002, 108.53000,   0.00000, 0.00000, 63.96000);
	CreateDynamicObject(2894, -1997.88000, 1359.77002, 108.53000,   0.00000, 0.00000, 133.67999);
	CreateDynamicObject(2229, -1982.59998, 1336.44995, 107.66000,   0.00000, 0.00000, 218.64000);
	CreateDynamicObject(2229, -1982.95996, 1336.15002, 107.66000,   0.00000, 0.00000, 218.64000);
	CreateDynamicObject(2311, -1984.79004, 1335.27002, 107.66000,   0.00000, 0.00000, 31.02000);
	CreateDynamicObject(2311, -1986.83997, 1334.06006, 107.66000,   0.00000, 0.00000, 31.02000);
	CreateDynamicObject(2232, -1983.76001, 1335.93994, 108.75000,   0.00000, 0.00000, 247.50000);
	CreateDynamicObject(2232, -1986.47998, 1334.29004, 108.75000,   0.00000, 0.00000, 165.12000);
	CreateDynamicObject(2188, -1966.55005, 1371.40002, 108.63000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1963.01001, 1370.96997, 107.66000,   0.00000, 0.00000, 229.86000);
	CreateDynamicObject(1703, -1965.68994, 1368.43005, 107.66000,   0.00000, 0.00000, 178.67999);
	CreateDynamicObject(1703, -1968.87000, 1369.43005, 107.66000,   0.00000, 0.00000, 120.78000);
	CreateDynamicObject(1722, -1966.01001, 1372.90002, 107.67000,   0.00000, 0.00000, -200.64000);
	CreateDynamicObject(1824, -1966.83997, 1363.34998, 108.19000,   0.00000, 0.00000, 0.06000);
	CreateDynamicObject(1703, -1967.87000, 1365.66003, 107.67000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1970.32996, 1362.41003, 107.67000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1963.48999, 1364.40002, 107.67000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1703, -1965.70996, 1360.89001, 107.67000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2393, -1982.78003, 1378.14001, 110.41000,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(1985, -1984.14001, 1378.39001, 110.62000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2631, -1989.64001, 1374.84998, 107.66000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(640, -2001.65002, 1377.50000, 108.36000,   0.00000, 0.00000, -28.26000);
	CreateDynamicObject(2628, -1989.46997, 1374.60999, 107.70000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2629, -1990.96997, 1374.65002, 107.69000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2255, -1990.02002, 1374.33997, 110.42000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2258, -2001.94995, 1377.90002, 111.09000,   0.00000, 0.00000, 60.00000);
	CreateDynamicObject(2131, -1981.52002, 1368.46997, 107.67000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2132, -1978.54004, 1368.47998, 107.67000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1983.56995, 1368.42004, 107.67000,   0.00000, 0.00000, 180.58000);
	CreateDynamicObject(2131, -1985.64001, 1368.56995, 107.67000,   0.00000, 0.00000, 493.98001);
	CreateDynamicObject(2134, -1980.54004, 1368.47998, 107.67000,   0.00000, 0.00000, 180.58000);
	CreateDynamicObject(2256, -1976.31995, 1368.00000, 110.64000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1302, -1980.96997, 1374.00000, 107.67000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1302, -1975.62000, 1373.97998, 107.67000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2862, -1978.55005, 1368.40002, 108.72000,   0.00000, 0.00000, 166.98000);
	CreateDynamicObject(2862, -1980.50000, 1368.43005, 108.72000,   0.00000, 0.00000, 166.98000);
	CreateDynamicObject(1776, -1978.21997, 1373.85999, 108.76000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1714, -1941.39001, 1365.18994, 107.67000,   0.00000, 0.00000, -61.62000);
	CreateDynamicObject(2208, -1942.69995, 1363.31006, 107.67000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2816, -1942.81006, 1365.67004, 108.53000,   0.00000, 0.00000, -117.72000);
	CreateDynamicObject(2855, -1942.66003, 1363.31006, 108.53000,   0.00000, 0.00000, 127.02000);
	CreateDynamicObject(2894, -1942.56995, 1365.01001, 108.53000,   0.00000, 0.00000, 77.04000);
	CreateDynamicObject(2894, -1942.87000, 1364.18994, 108.53000,   0.00000, 0.00000, 304.26001);
	CreateDynamicObject(2202, -1943.34998, 1369.80005, 107.67000,   0.00000, 0.00000, -26.64000);
	CreateDynamicObject(2202, -1943.07996, 1359.80005, 107.67000,   0.00000, 0.00000, 202.08000);
	CreateDynamicObject(1704, -1944.54004, 1365.18005, 107.67000,   0.00000, 0.00000, 52.92000);
	CreateDynamicObject(1704, -1944.18005, 1363.28003, 107.67000,   0.00000, 0.00000, 115.38000);
	CreateDynamicObject(3525, -1947.03003, 1362.20996, 110.61000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3525, -1947.03003, 1368.63000, 110.61000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1948.56995, 1362.87000, 107.67000,   0.00000, 0.00000, 109.56000);
	CreateDynamicObject(1703, -1949.31995, 1366.37000, 107.67000,   0.00000, 0.00000, 63.66000);
	CreateDynamicObject(1433, -1946.93994, 1364.93994, 107.85000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2855, -1946.70996, 1364.68005, 108.36000,   0.00000, 0.00000, 126.36000);
	CreateDynamicObject(2853, -1947.04004, 1365.16003, 108.36000,   0.00000, 0.00000, 39.30000);
	CreateDynamicObject(2229, -1987.64001, 1333.55005, 107.66000,   0.00000, 0.00000, 218.64000);
	CreateDynamicObject(2229, -1988.03003, 1333.32996, 107.66000,   0.00000, 0.00000, 218.64000);
	CreateDynamicObject(2104, -1984.83997, 1335.15002, 108.16000,   0.00000, 0.00000, 215.34000);
	CreateDynamicObject(2101, -1985.62000, 1334.97998, 108.17000,   0.00000, 0.00000, 207.36000);
	CreateDynamicObject(1703, -1985.82996, 1340.32996, 107.67000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1990.50000, 1335.48999, 107.67000,   0.00000, 0.00000, 68.64000);
	CreateDynamicObject(1703, -1989.00000, 1338.77002, 107.67000,   0.00000, 0.00000, 36.54000);
	CreateDynamicObject(1703, -1990.81995, 1347.20996, 107.67000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1992.50000, 1344.09998, 107.67000,   0.00000, 0.00000, 88.68000);
	CreateDynamicObject(1703, -1988.78003, 1342.69995, 107.67000,   0.00000, 0.00000, 176.39999);
	CreateDynamicObject(1433, -1989.92004, 1345.09998, 107.84000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1990.01001, 1345.09998, 108.37000,   0.00000, 0.00000, 93.30000);
	CreateDynamicObject(640, -1989.75000, 1348.54004, 108.36000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(640, -1994.67004, 1332.88000, 108.36000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1704, -1982.67004, 1354.82996, 107.66000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1704, -1983.16003, 1351.71997, 107.66000,   0.00000, 0.00000, 146.52000);
	CreateDynamicObject(1704, -1980.90002, 1352.38000, 107.66000,   0.00000, 0.00000, 225.89999);
	CreateDynamicObject(1433, -1982.22998, 1353.13000, 107.84000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1982.15002, 1353.13000, 108.37000,   0.00000, 0.00000, 59.76000);
	CreateDynamicObject(1704, -1978.03003, 1360.98999, 107.66000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1977.39001, 1358.73999, 107.84000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1704, -1978.21997, 1356.71997, 107.66000,   0.00000, 0.00000, 146.52000);
	CreateDynamicObject(1704, -1975.34998, 1357.73999, 107.66000,   0.00000, 0.00000, 225.89999);
	CreateDynamicObject(1670, -1977.34998, 1358.69995, 108.37000,   0.00000, 0.00000, 136.25999);
	CreateDynamicObject(1704, -1982.71997, 1351.40002, 113.12000,   0.00000, 0.00000, 151.56000);
	CreateDynamicObject(1704, -1980.47998, 1353.00000, 113.12000,   0.00000, 0.00000, 251.46001);
	CreateDynamicObject(1704, -1983.25000, 1354.62000, 113.12000,   0.00000, 0.00000, 14.58000);
	CreateDynamicObject(1433, -1982.22998, 1353.13000, 113.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1982.15002, 1353.13000, 113.82000,   0.00000, 0.00000, 59.76000);
	CreateDynamicObject(1704, -1978.41003, 1357.40002, 113.12000,   0.00000, 0.00000, 117.60000);
	CreateDynamicObject(1704, -1975.65002, 1358.17004, 113.12000,   0.00000, 0.00000, 242.88000);
	CreateDynamicObject(1433, -1977.39001, 1358.73999, 113.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1704, -1977.52002, 1360.67004, 113.12000,   0.00000, 0.00000, -19.62000);
	CreateDynamicObject(1670, -1977.34998, 1358.69995, 113.78000,   0.00000, 0.00000, 136.25999);
	CreateDynamicObject(2611, -1986.84998, 1362.54004, 109.69000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1704, -1975.43994, 1358.98999, 96.75000,   0.00000, 0.00000, 261.00000);
	CreateDynamicObject(1704, -1978.58997, 1357.59998, 96.75000,   0.00000, 0.00000, 124.98000);
	CreateDynamicObject(1704, -1976.82996, 1360.51001, 96.75000,   0.00000, 0.00000, -24.30000);
	CreateDynamicObject(1433, -1977.39001, 1358.73999, 96.93000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1977.35999, 1358.73999, 97.45000,   0.00000, 0.00000, 237.12000);
	CreateDynamicObject(1704, -1981.82996, 1354.65002, 96.75000,   0.00000, 0.00000, -25.14000);
	CreateDynamicObject(1704, -1983.87000, 1353.13000, 96.75000,   0.00000, 0.00000, 73.80000);
	CreateDynamicObject(1704, -1981.27002, 1351.84998, 96.75000,   0.00000, 0.00000, 206.22000);
	CreateDynamicObject(1670, -1982.29004, 1353.10999, 97.47000,   0.00000, 0.00000, 172.74001);
	CreateDynamicObject(1433, -1982.22998, 1353.13000, 96.93000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2010, -1986.25000, 1350.78003, 96.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2164, -1986.85999, 1357.71997, 96.75000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2164, -1986.85999, 1359.47998, 96.75000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2167, -1986.89001, 1361.27002, 96.75000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2779, -1978.07996, 1363.19995, 96.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2778, -1979.64001, 1363.10999, 96.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2779, -1981.25000, 1363.27002, 96.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2640, -1982.59998, 1363.37000, 97.59000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2172, -1984.52002, 1363.18005, 96.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1714, -1983.81995, 1362.37000, 96.75000,   0.00000, 0.00000, -128.94000);
	CreateDynamicObject(1714, -1985.95996, 1362.26001, 96.75000,   0.00000, 0.00000, -244.98000);
	CreateDynamicObject(2193, -1986.50000, 1362.18005, 96.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2611, -1986.84998, 1362.54004, 98.76000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1987.78003, 1346.06006, 96.75000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1703, -1991.17004, 1347.43994, 96.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1989.27002, 1342.68994, 96.75000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1987.28003, 1341.18005, 96.75000,   0.00000, 0.00000, 1.86000);
	CreateDynamicObject(1703, -1990.56995, 1337.94995, 96.75000,   0.00000, 0.00000, 63.06000);
	CreateDynamicObject(2229, -1983.22998, 1336.19995, 96.75000,   0.00000, 0.00000, 209.22000);
	CreateDynamicObject(19175, -1985.23999, 1334.66003, 99.33000,   0.00000, 0.00000, 211.14000);
	CreateDynamicObject(1433, -1987.45996, 1338.97998, 96.95000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1670, -1987.35999, 1338.89001, 97.47000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1992.64001, 1344.10999, 96.75000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1575, -1989.82996, 1344.81006, 97.27000,   0.02000, 0.00000, 73.08000);
	CreateDynamicObject(2823, -1990.43005, 1345.27002, 97.27000,   0.00000, 0.00000, 29.10000);
	CreateDynamicObject(2823, -1989.89001, 1345.35999, 97.28000,   0.00000, 0.00000, -148.74001);
	CreateDynamicObject(2823, -1990.25000, 1344.84998, 97.29000,   0.00000, 0.00000, -61.68000);
	CreateDynamicObject(1433, -1990.18005, 1345.01001, 96.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(640, -1989.47998, 1348.60999, 97.44000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2011, -1993.06995, 1349.38000, 96.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(640, -1993.06006, 1352.56006, 97.44000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(640, -1993.06006, 1358.73999, 97.44000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1996.41003, 1351.42004, 96.75000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1999.56995, 1352.52002, 96.75000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1998.37000, 1355.35999, 96.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1997.45996, 1353.25000, 96.93000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1575, -1997.65002, 1352.93994, 97.43000,   0.00000, 0.00000, 80.34000);
	CreateDynamicObject(1575, -1997.65002, 1352.93994, 97.59000,   0.00000, 0.00000, 52.20000);
	CreateDynamicObject(1575, -1997.72998, 1353.46997, 97.43000,   0.00000, 0.00000, -64.26000);
	CreateDynamicObject(1575, -1997.21997, 1353.52002, 97.61000,   0.00000, 0.00000, 25.26000);
	CreateDynamicObject(1575, -1997.21997, 1353.52002, 97.43000,   0.00000, 0.00000, -47.04000);
	CreateDynamicObject(3525, -1997.71997, 1356.69995, 98.73000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(640, -1993.06006, 1365.02002, 97.44000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(640, -1993.06006, 1370.98999, 97.44000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1998.90002, 1363.91003, 96.75000,   0.00000, 0.00000, 131.10001);
	CreateDynamicObject(1703, -2000.51001, 1366.81006, 96.75000,   0.00000, 0.00000, 401.04001);
	CreateDynamicObject(1703, -1995.43994, 1364.69995, 96.75000,   0.00000, 0.00000, 580.73999);
	CreateDynamicObject(1703, -1997.26001, 1367.83997, 96.75000,   0.00000, 0.00000, -47.52000);
	CreateDynamicObject(1670, -1999.58997, 1366.31006, 96.75000,   0.00000, 0.00000, -84.42000);
	CreateDynamicObject(1433, -1998.02002, 1365.70996, 96.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2860, -1997.90002, 1365.69995, 96.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2259, -1993.16003, 1367.69995, 98.81000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2258, -1992.64001, 1361.92004, 99.02000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2259, -1993.16003, 1356.73999, 98.82000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(640, -2001.65002, 1377.50000, 97.44000,   0.00000, 0.00000, -28.26000);
	CreateDynamicObject(2393, -1982.78003, 1378.14001, 99.73000,   0.00000, 90.00000, 180.00000);
	CreateDynamicObject(1985, -1984.14001, 1378.39001, 99.98000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2628, -1989.06995, 1374.60999, 96.75000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2632, -1989.92004, 1374.80005, 96.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2629, -1990.96997, 1374.65002, 96.75000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1961.31995, 1364.54004, 96.75000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1703, -1962.80005, 1367.44995, 96.75000,   0.00000, 0.00000, -55.50000);
	CreateDynamicObject(1703, -1965.72998, 1368.87000, 96.75000,   0.00000, 0.00000, -18.66000);
	CreateDynamicObject(1703, -1969.06006, 1368.85999, 96.75000,   0.00000, 0.00000, 3.36000);
	CreateDynamicObject(2857, -1963.43005, 1364.65002, 96.75000,   0.00000, 0.00000, 27.66000);
	CreateDynamicObject(2857, -1966.18005, 1367.09998, 96.75000,   0.00000, 0.00000, 105.84000);
	CreateDynamicObject(2857, -1968.18005, 1365.87000, 96.75000,   0.00000, 0.00000, 116.76000);
	CreateDynamicObject(338, -1966.93005, 1364.50000, 97.69000,   74.00000, -78.30000, -74.46000);
	CreateDynamicObject(1209, -1981.10999, 1368.30005, 96.75000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2132, -1982.56995, 1368.35999, 96.75000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2133, -1984.59998, 1368.39001, 96.75000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2133, -1985.58997, 1368.39001, 96.75000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2341, -1986.58997, 1368.37000, 96.75000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2340, -1986.59998, 1369.35999, 97.44000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2131, -1986.33997, 1370.39001, 96.75000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2340, -1986.57996, 1372.44995, 96.75000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2822, -1984.56006, 1368.23999, 97.44000,   0.00000, 0.00000, 95.40000);
	CreateDynamicObject(2851, -1982.90002, 1368.28003, 97.44000,   0.00000, 0.00000, -99.48000);
	CreateDynamicObject(2851, -1983.59998, 1368.26001, 97.44000,   0.00000, 0.00000, -99.48000);
	CreateDynamicObject(19128, -1946.89001, 1365.33997, 96.75000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1943.00000, 1362.48999, 96.75000,   0.00000, 0.00000, -146.46001);
	CreateDynamicObject(1703, -1942.07996, 1366.19995, 96.75000,   0.00000, 0.00000, -89.34000);
	CreateDynamicObject(1703, -1944.57996, 1369.07996, 96.75000,   0.00000, 0.00000, -45.84000);
	CreateDynamicObject(2256, -1942.56995, 1369.91003, 99.41000,   0.00000, 0.00000, -26.70000);
	CreateDynamicObject(2256, -1943.43005, 1359.06006, 99.41000,   0.00000, 0.00000, -157.25999);
	CreateDynamicObject(3525, -1947.09998, 1368.65002, 99.41000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3525, -1947.06006, 1362.17004, 99.41000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2315, -1985.02002, 1335.33997, 96.75000,   0.00000, 0.00000, 30.90000);
	CreateDynamicObject(2315, -1987.08997, 1334.08997, 96.75000,   0.00000, 0.00000, 30.90000);
	CreateDynamicObject(2232, -1986.94995, 1334.18005, 97.83000,   0.00000, 0.00000, 214.08000);
	CreateDynamicObject(2232, -1983.69995, 1336.02002, 97.83000,   0.00000, 0.00000, 214.08000);
	CreateDynamicObject(2229, -1987.91003, 1333.41003, 96.75000,   0.00000, 0.00000, 209.22000);
	CreateDynamicObject(1786, -1985.78003, 1334.54004, 97.23000,   0.00000, 0.00000, 211.44000);
	CreateDynamicObject(1786, -1984.45996, 1335.38000, 97.23000,   0.00000, 0.00000, 211.44000);
	CreateDynamicObject(3525, -1982.81995, 1336.31995, 99.27000,   0.00000, 0.00000, 211.14000);
	CreateDynamicObject(3525, -1987.58997, 1333.50000, 99.27000,   0.00000, 0.00000, 211.14000);
	CreateDynamicObject(2842, -2000.18994, 1336.51001, 96.73000,   0.00000, 0.00000, -52.50000);
	CreateDynamicObject(2286, -2002.06006, 1377.77002, 99.62000,   0.00000, 0.00000, 60.78000);
	CreateDynamicObject(1704, -1980.90002, 1352.38000, 102.21000,   0.00000, 0.00000, 225.89999);
	CreateDynamicObject(1704, -1983.16003, 1351.71997, 102.21000,   0.00000, 0.00000, 146.52000);
	CreateDynamicObject(1704, -1982.67004, 1354.82996, 102.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1704, -1978.21997, 1356.71997, 102.21000,   0.00000, 0.00000, 146.52000);
	CreateDynamicObject(1704, -1975.34998, 1357.73999, 102.21000,   0.00000, 0.00000, 225.89999);
	CreateDynamicObject(1433, -1977.39001, 1358.73999, 102.39000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1704, -1978.03003, 1360.98999, 102.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(18885, -1974.33997, 1365.93994, 103.31000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3525, -1974.58997, 1364.53003, 105.10000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3525, -1974.58997, 1367.25000, 105.10000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1970.32996, 1362.41003, 102.21000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1703, -1968.87000, 1369.43005, 102.21000,   0.00000, 0.00000, 120.78000);
	CreateDynamicObject(1824, -1966.83997, 1363.34998, 102.74000,   0.00000, 0.00000, 0.06000);
	CreateDynamicObject(1703, -1965.70996, 1360.89001, 102.21000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1703, -1963.48999, 1364.40002, 102.21000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1703, -1967.87000, 1365.66003, 102.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1963.01001, 1370.96997, 102.21000,   0.00000, 0.00000, 229.86000);
	CreateDynamicObject(1703, -1965.68994, 1368.43005, 102.21000,   0.00000, 0.00000, 178.67999);
	CreateDynamicObject(2188, -1966.55005, 1371.40002, 103.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1722, -1966.01001, 1372.90002, 102.21000,   0.00000, 0.00000, -200.64000);
	CreateDynamicObject(1302, -1975.62000, 1373.97998, 102.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1776, -1978.21997, 1373.85999, 103.30000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1302, -1980.96997, 1374.00000, 102.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2631, -1989.64001, 1374.84998, 102.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2202, -1943.34998, 1369.80005, 102.21000,   0.00000, 0.00000, -26.64000);
	CreateDynamicObject(1703, -1949.31995, 1366.37000, 102.21000,   0.00000, 0.00000, 63.66000);
	CreateDynamicObject(2202, -1943.07996, 1359.80005, 102.21000,   0.00000, 0.00000, 202.08000);
	CreateDynamicObject(1703, -1948.56995, 1362.87000, 102.21000,   0.00000, 0.00000, 109.56000);
	CreateDynamicObject(1433, -1946.93994, 1364.93994, 102.39000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2853, -1947.04004, 1365.16003, 102.90000,   0.00000, 0.00000, 39.30000);
	CreateDynamicObject(2855, -1946.70996, 1364.68005, 102.90000,   0.00000, 0.00000, 126.36000);
	CreateDynamicObject(1704, -1944.18005, 1363.28003, 102.21000,   0.00000, 0.00000, 115.38000);
	CreateDynamicObject(1704, -1944.54004, 1365.18005, 102.21000,   0.00000, 0.00000, 52.92000);
	CreateDynamicObject(2208, -1942.69995, 1363.31006, 102.21000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2894, -1942.56995, 1365.01001, 103.07000,   0.00000, 0.00000, 77.04000);
	CreateDynamicObject(2894, -1942.87000, 1364.18994, 103.07000,   0.00000, 0.00000, 304.26001);
	CreateDynamicObject(2855, -1942.66003, 1363.31006, 103.07000,   0.00000, 0.00000, 127.02000);
	CreateDynamicObject(2816, -1942.81006, 1365.67004, 103.07000,   0.00000, 0.00000, -117.72000);
	CreateDynamicObject(1714, -1941.39001, 1365.18994, 102.21000,   0.00000, 0.00000, -61.62000);
	CreateDynamicObject(3525, -1947.03003, 1362.20996, 105.05000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3525, -1947.03003, 1368.63000, 105.05000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1982.22998, 1353.13000, 102.39000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2200, -1986.67004, 1359.93994, 102.21000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2205, -1986.34998, 1358.95996, 102.21000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2162, -1982.44995, 1363.59998, 102.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2008, -1984.44995, 1363.10999, 102.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2308, -1986.43005, 1362.15002, 102.21000,   0.00000, 0.00000, 360.00000);
	CreateDynamicObject(2255, -1986.40002, 1358.06995, 104.21000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2611, -1986.84998, 1362.54004, 104.21000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2894, -1986.53003, 1362.82996, 103.00000,   0.00000, 0.00000, 47.40000);
	CreateDynamicObject(1714, -1984.23999, 1362.01001, 102.21000,   0.00000, 0.00000, 125.76000);
	CreateDynamicObject(1714, -1985.13000, 1358.57996, 102.21000,   0.00000, 0.00000, -54.96000);
	CreateDynamicObject(2190, -1986.32996, 1359.27002, 103.15000,   0.00000, 0.00000, 46.80000);
	CreateDynamicObject(1433, -2000.76001, 1340.29004, 102.39000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, -1989.92004, 1345.09998, 102.39000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1990.81995, 1347.20996, 102.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1992.50000, 1344.09998, 102.21000,   0.00000, 0.00000, 88.68000);
	CreateDynamicObject(1703, -1988.80005, 1342.68005, 102.21000,   0.00000, 0.00000, 176.39999);
	CreateDynamicObject(1703, -1985.82996, 1340.32996, 102.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1703, -1990.50000, 1335.48999, 102.21000,   0.00000, 0.00000, 68.64000);
	CreateDynamicObject(1703, -1989.00000, 1338.77002, 102.21000,   0.00000, 0.00000, 36.54000);
	CreateDynamicObject(2229, -1982.59998, 1336.44995, 102.21000,   0.00000, 0.00000, 218.64000);
	CreateDynamicObject(2229, -1982.95996, 1336.15002, 102.21000,   0.00000, 0.00000, 218.64000);
	CreateDynamicObject(2311, -1984.79004, 1335.27002, 102.21000,   0.00000, 0.00000, 31.02000);
	CreateDynamicObject(2229, -1987.64001, 1333.55005, 102.21000,   0.00000, 0.00000, 218.64000);
	CreateDynamicObject(2229, -1988.03003, 1333.32996, 102.21000,   0.00000, 0.00000, 218.64000);
	CreateDynamicObject(2232, -1986.47998, 1334.29004, 103.31000,   0.00000, 0.00000, 165.12000);
	CreateDynamicObject(2101, -1985.62000, 1334.97998, 102.73000,   0.00000, 0.00000, 207.36000);
	CreateDynamicObject(2104, -1984.83997, 1335.15002, 102.71000,   0.00000, 0.00000, 215.34000);
	CreateDynamicObject(2232, -1983.76001, 1335.93994, 103.31000,   0.00000, 0.00000, 247.50000);
	CreateDynamicObject(640, -1994.67004, 1332.88000, 102.91000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(358, -2000.18994, 1332.81006, 102.21000,   -14.28000, -98.56000, 347.51999);
	CreateDynamicObject(2566, -1998.89001, 1334.64001, 102.61000,   0.00000, 0.00000, 129.84000);
	CreateDynamicObject(1744, -2001.57996, 1333.71997, 103.97000,   0.00000, 0.00000, 129.84000);
	CreateDynamicObject(2254, -2001.73999, 1334.25000, 105.73000,   0.00000, 0.00000, 129.96001);
	CreateDynamicObject(348, -2000.28003, 1333.38000, 102.66000,   90.00000, 0.00000, -106.68000);
	CreateDynamicObject(1704, -2002.65002, 1339.78003, 102.21000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1704, -2000.32996, 1338.58997, 102.21000,   0.00000, 0.00000, -180.00000);
	CreateDynamicObject(1704, -2001.30005, 1342.06006, 102.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(348, -2001.10999, 1340.10999, 102.91000,   90.00000, 0.00000, 55.86000);
	CreateDynamicObject(348, -2000.66003, 1339.83997, 102.91000,   90.00000, 0.00000, 56.10000);
	CreateDynamicObject(348, -2000.79004, 1340.72998, 102.91000,   90.00000, 0.00000, -27.66000);
	CreateDynamicObject(1703, -1997.91003, 1349.26001, 102.21000,   0.00000, 0.00000, 178.62000);
	CreateDynamicObject(1703, -2001.69995, 1350.32996, 102.21000,   0.00000, 0.00000, 88.86000);
	CreateDynamicObject(1703, -1999.95996, 1353.30005, 102.21000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1704, -1998.76001, 1357.90002, 102.21000,   0.00000, 0.00000, 492.60001);
	CreateDynamicObject(1704, -1995.89001, 1360.73999, 102.21000,   0.00000, 0.00000, 283.79999);
	CreateDynamicObject(1704, -1999.30005, 1361.33997, 102.21000,   0.00000, 0.00000, 60.66000);
	CreateDynamicObject(1549, -1999.68005, 1358.93005, 102.21000,   0.00000, 0.00000, 192.36000);
	CreateDynamicObject(1549, -1999.67004, 1361.00000, 102.21000,   0.00000, 0.00000, 239.52000);
	CreateDynamicObject(2208, -1997.85999, 1358.88000, 102.21000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3525, -1997.71997, 1357.50000, 105.02000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3525, -1992.81995, 1363.79004, 105.02000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(3525, -1992.81995, 1358.32996, 105.02000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(3525, -1992.81995, 1353.97998, 105.02000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(3525, -1992.81995, 1367.70996, 105.02000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2208, -1997.85999, 1365.23999, 102.21000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1722, -1998.04004, 1363.90002, 102.21000,   0.00000, 0.00000, -9.90000);
	CreateDynamicObject(1722, -1999.42004, 1365.79004, 102.21000,   0.00000, 0.00000, 281.34000);
	CreateDynamicObject(1722, -1999.31006, 1367.43994, 102.21000,   0.00000, 0.00000, 247.44000);
	CreateDynamicObject(1722, -1997.81995, 1369.06006, 102.21000,   0.00000, 0.00000, -209.58000);
	CreateDynamicObject(1722, -1996.45996, 1365.90002, 102.21000,   0.00000, 0.00000, 124.80000);
	CreateDynamicObject(1722, -1996.73999, 1367.08997, 102.21000,   0.00000, 0.00000, 70.08000);
	CreateDynamicObject(2894, -1997.93005, 1365.16003, 103.07000,   0.00000, 0.00000, -25.74000);
	CreateDynamicObject(2212, -1997.71997, 1365.80005, 103.13000,   -25.50000, 23.52000, 27.24000);
	CreateDynamicObject(2894, -1997.64001, 1366.96997, 10.21000,   0.00000, 0.00000, 131.10001);
	CreateDynamicObject(2894, -1997.64001, 1366.96997, 103.07000,   0.00000, 0.00000, 131.10001);
	CreateDynamicObject(2212, -1998.13000, 1367.59998, 103.13000,   -25.50000, 23.52000, -89.94000);
	CreateDynamicObject(2255, -1990.02002, 1374.33997, 104.86000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2134, -1983.56995, 1368.42004, 102.21000,   0.00000, 0.00000, 180.58000);
	CreateDynamicObject(2131, -1981.52002, 1368.46997, 102.21000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2131, -1985.45996, 1368.63000, 102.21000,   0.00000, 0.00000, 493.98001);
	CreateDynamicObject(2134, -1980.54004, 1368.47998, 102.21000,   0.00000, 0.00000, 180.58000);
	CreateDynamicObject(2132, -1978.54004, 1368.47998, 102.21000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2862, -1978.55005, 1368.40002, 103.27000,   0.00000, 0.00000, 166.98000);
	CreateDynamicObject(2862, -1980.50000, 1368.43005, 103.25000,   0.00000, 0.00000, 166.98000);
	CreateDynamicObject(2256, -1976.31995, 1368.00000, 104.96000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1670, -1977.34998, 1358.69995, 102.91000,   0.00000, 0.00000, 136.25999);
	CreateDynamicObject(1670, -1982.15002, 1353.13000, 102.91000,   0.00000, 0.00000, 59.76000);
	CreateDynamicObject(1670, -1990.01001, 1345.09998, 102.91000,   0.00000, 0.00000, 93.30000);
	CreateDynamicObject(2311, -1986.83997, 1334.06006, 102.21000,   0.00000, 0.00000, 31.02000);
	CreateDynamicObject(640, -1989.75000, 1348.54004, 102.91000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1670, -1998.03003, 1361.22998, 103.09000,   0.00000, 0.00000, -39.78000);
	CreateDynamicObject(348, -1997.90002, 1361.50000, 103.09000,   90.00000, 0.00000, -125.46000);
	CreateDynamicObject(348, -1997.63000, 1359.04004, 103.08000,   90.00000, 0.00000, 121.44000);
	CreateDynamicObject(3052, -2002.93005, 1336.26001, 102.32000,   0.00000, 0.00000, -4.32000);
	CreateDynamicObject(351, -2002.59998, 1336.17004, 102.50000,   -101.32000, -13.28000, 126.96000);
	CreateDynamicObject(2043, -2002.29004, 1336.04004, 102.32000,   0.00000, 0.00000, 73.86000);
	CreateDynamicObject(356, -2001.59998, 1334.22998, 104.38000,   -103.06000, -7.68000, -75.48000);
	CreateDynamicObject(2894, -1997.77002, 1360.52002, 103.09000,   0.00000, 0.00000, 63.96000);
	CreateDynamicObject(2894, -1997.88000, 1359.77002, 103.09000,   0.00000, 0.00000, 133.67999);
	CreateDynamicObject(2862, -1980.50000, 1368.43005, 103.09000,   0.00000, 0.00000, 166.98000);
	CreateDynamicObject(2862, -1978.55005, 1368.40002, 103.09000,   0.00000, 0.00000, 166.98000);
	CreateDynamicObject(3525, -1982.81995, 1336.31995, 104.77000,   0.00000, 0.00000, 211.14000);
	CreateDynamicObject(3525, -1987.58997, 1333.50000, 104.77000,   0.00000, 0.00000, 211.14000);
	CreateDynamicObject(2817, -2000.09998, 1336.26001, 107.67000,   0.00000, 0.00000, -50.16000);
	CreateDynamicObject(2817, -2000.09998, 1336.26001, 102.21000,   0.00000, 0.00000, -50.16000);
	CreateDynamicObject(2630, -1992.33997, 1375.26001, 107.67000,   0.00000, 0.00000, -203.58000);
	CreateDynamicObject(2630, -1992.33997, 1375.26001, 102.21000,   0.00000, 0.00000, -203.58000);
	CreateDynamicObject(2627, -1987.16003, 1375.02002, 102.19000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2627, -1987.16003, 1375.02002, 107.66000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2255, -2001.55005, 1334.70996, 114.81000,   0.00000, 0.00000, 129.06000);
#endif
}