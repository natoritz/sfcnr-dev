/*
 * Irresistible Gaming 2018
 * Developed by Lorenc
 * Module: settings.inc
 * Purpose: defines general server settings
 */

// DUMP: mysqldump -u service -p{password} sa-mp > ~/dump01.sql
// LOAD: zcat dump_2018-06-09.sql.gz | mysql -u service -p"{password}" sa-mp

/* ** MySQL Settings ** */
#if !defined DEBUG_MODE
	#define MYSQL_HOST				"127.0.0.1"
	#define MYSQL_USER				"root"
	#define MYSQL_PASS				""
	#define MYSQL_DATABASE			"sa-mp"
#else
	#define MYSQL_HOST				"127.0.0.1"
	#define MYSQL_USER				"root"
	#define MYSQL_PASS				""
	#define MYSQL_DATABASE			"sa-mp"
#endif

/* ** Error Checking ** */
#if defined FILTERSCRIPT
	#endinput
#endif

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Variables ** */
stock dbHandle;
stock bool: serverLocked = false;

/* ** Variables ** */
hook OnScriptInit( )
{
	// Attempt to connect to database
	if ( mysql_errno( ( dbHandle = mysql_connect( MYSQL_HOST, MYSQL_USER, MYSQL_DATABASE, MYSQL_PASS ) ) ) ) {
		print( "[MYSQL]: Couldn't connect to MySQL database." ), serverLocked = true;
	} else {
		print( "[MYSQL]: Connection to database is successful." );
	}
	return 1;
}

hook OnGameModeExit( )
{
    mysql_close( );
    return 1;
}

hook OnPlayerConnect( playerid )
{
	if ( serverLocked ) {
		SendClientMessage( playerid, 0xa9c4e4ff, "The server is locked due to false server configuration. Please wait for the operator." );
	    return KickPlayerTimed( playerid ), 1;
	}
	return 1;
}
