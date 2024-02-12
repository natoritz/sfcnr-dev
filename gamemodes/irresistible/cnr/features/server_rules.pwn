/*
 * Irresistible Gaming (c) 2018
 * Developed by Lorenc
 * Module: cnr\features\server_rules.pwn
 * Purpose: server rules implementation (/rules) that scans URL
 */

/* ** Includes ** */
#include 							< YSI\y_hooks >

/* ** Variables ** */
	static stock szRules				[ 3300 ];

/* ** Commands ** */
CMD:rules( playerid, params[ ] ) {
	return ShowPlayerRules( playerid );
}

#if defined SERVER_RULES_URL

	/* ** Forwards ** */
	public OnRulesHTTPResponse( index, response_code, data[ ] );

	/* ** Hooks ** */
	hook OnScriptInit( ) {
		HTTP( 0, HTTP_GET, SERVER_RULES_URL, "", "OnRulesHTTPResponse" );
		return 1;
	}

	/* ** Functions ** */
	public OnRulesHTTPResponse( index, response_code, data[ ] ) {
		if ( response_code == 200 ) {
			printf( "[RULES] Rules have been updated! Character Size: %d", strlen( data ) );
			strcpy( szRules, data );
		}
		return 1;
	}

#endif

/* ** Functions ** */
stock ShowPlayerRules( playerid )
{
	/*#if !defined SERVER_RULES_URL
		#pragma unused playerid
		return 1;
	#else
	#endif*/
	format( szRules, sizeof( szRules ), "{FFFFFF}1. Show respect to every player on the server, including obeying administrators, or you will be muted.\n2. Do not spam or flood the chat, otherwise you will be muted.\n3. Do not impersonate any, whether it's a player, administrator, or the owner. You will be banned.\n4. Do not cast commands on a person repeatedly to annoy them.\n5. If you're a law enforcement officer, do not assist criminals or you will be jailed.\n6. Do not camp exteriors of buildings, spam rockets, OR spam your mini-gun at players with combat vehicles.\n7. Using water-emitting vehicles and/or effect-emitting weapons on players is considered abuse.\n8. You must park your personal vehicle near YOUR house portal OR in a parking lot, otherwise your vehicle will be moved OR deleted.\n9. The scamming limit is $10,000. Scamming higher amounts will have your account banned and truncated.\n10. Do not question other people's bans, it's not your business!\n11. Do not farm money, XP, contracts, arrests, OR kills, doing so will result in a ban and truncation.\n12. Report bugs and glitches to administration or on the forums. Do NOT abuse them or you will be banned.\n13. Do not use any hacks!\n14. Administration may suspend users unanimously so long as it is clearly evident and justified." );
	return ShowPlayerDialog( playerid, DIALOG_NULL, DIALOG_STYLE_MSGBOX, "{FFFFFF}Rules", szRules, "Okay", "" ), 1;
}