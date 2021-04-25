
// =========================================== S E R V E R   E V E N T S ==============================================
/*

░█████╗░░█████╗░░█████╗░░█████╗░██╗░░░██╗███╗░░██╗████████╗  ░██████╗██╗░░░██╗░██████╗████████╗███████╗███╗░░░███╗
██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║░░░██║████╗░██║╚══██╔══╝  ██╔════╝╚██╗░██╔╝██╔════╝╚══██╔══╝██╔════╝████╗░████║
███████║██║░░╚═╝██║░░╚═╝██║░░██║██║░░░██║██╔██╗██║░░░██║░░░  ╚█████╗░░╚████╔╝░╚█████╗░░░░██║░░░█████╗░░██╔████╔██║
██╔══██║██║░░██╗██║░░██╗██║░░██║██║░░░██║██║╚████║░░░██║░░░  ░╚═══██╗░░╚██╔╝░░░╚═══██╗░░░██║░░░██╔══╝░░██║╚██╔╝██║
██║░░██║╚█████╔╝╚█████╔╝╚█████╔╝╚██████╔╝██║░╚███║░░░██║░░░  ██████╔╝░░░██║░░░██████╔╝░░░██║░░░███████╗██║░╚═╝░██║
╚═╝░░╚═╝░╚════╝░░╚════╝░░╚════╝░░╚═════╝░╚═╝░░╚══╝░░░╚═╝░░░  ╚═════╝░░░░╚═╝░░░╚═════╝░░░░╚═╝░░░╚══════╝╚═╝░░░░░╚═╝

██████╗░██╗░░░██╗  ░██████╗██╗░░██╗██╗░░░██╗
██╔══██╗╚██╗░██╔╝  ██╔════╝██║░░██║╚██╗░██╔╝
██████╦╝░╚████╔╝░  ╚█████╗░███████║░╚████╔╝░
██╔══██╗░░╚██╔╝░░  ░╚═══██╗██╔══██║░░╚██╔╝░░
██████╦╝░░░██║░░░  ██████╔╝██║░░██║░░░██║░░░
╚═════╝░░░░╚═╝░░░  ╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░
*/
spawnweps <- {};
class PlayerStats
{
Kills = 0;
Deaths = 0;
Cash = 0;
Level = 0;
Registered = false;
Logged = false;
Bank = 0;
AutoLogin = "on";
  Weapons = [];
}
function onServerStart()
{
}

function onServerStop()
{
}

function onScriptLoad()
{
stats <- array ( GetMaxPlayers(), null );
 db <- ConnectSQL("Database.db");
 QuerySQL( db, "CREATE TABLE IF NOT EXISTS Accounts( Nickname TEXT, Password TEXT, IP VARCHAR(32), UID VARCHAR(255), UID2 VARCHAR(255), Kills INTEGER, Deaths INTEGER, Cash INTEGER, Bank INTEGER, Level INTEGER, AutoLogin TEXT )");
 print("Account system by SHy has been loaded."); //This is to keep account system's credits
}

function onScriptUnload()
{
DiscconectSQL( db );
}
function PlayerInfo(player)
{
local q = QuerySQL( db, "SELECT * FROM Accounts WHERE Nickname='"+player.Name+"'" );
if (q)
{
if ( GetSQLColumnData( q, 2 ) == player.IP && GetSQLColumnData( q, 3 ) == player.UniqueID && GetSQLColumnData( q, 4 ) == player.UniqueID2 && GetSQLColumnData( q, 10 ).tostring() == "on" )
{
Message("[#c00ff2]"+player.Name+" got automatically logged in.");
stats[ player.ID ].Registered = true;
stats[ player.ID ].Logged = true;
stats[ player.ID ].Kills = GetSQLColumnData( q, 5 );
stats[ player.ID ].Deaths = GetSQLColumnData( q, 6 );
AddCash( player, GetSQLColumnData( q, 7 ) ); 
stats[ player.ID ].Bank = GetSQLColumnData( q, 8 );
stats[ player.ID ].Level = GetSQLColumnData( q, 9 );
QuerySQL( db, "UPDATE Accounts SET IP='"+player.IP+"', UID='"+player.UniqueID+"', UID2='"+player.UniqueID2+"' WHERE Nickname='"+player.Name+"'" );
}
else
{
MessagePlayer("[#000fff]The account ( "+player.Name+" ) is registered, please login into it.", player);
stats[ player.ID ].Registered = true;
}
}
else MessagePlayer("[#00ff00]Your account is not registered, type /register to have a control over your account!", player);
}
function RemoveCash( player, amount )
{
local cash = stats[ player.ID ].Cash;
local det = cash - amount;
stats[ player.ID ].Cash = det;
player.Cash = det;
}
function AddCash( player, amount )
{
local cash = stats[ player.ID ].Cash;
local add = cash + amount;
stats[ player.ID ].Cash = add;
player.Cash = add;
}
function UpdateInfo(player)
{
QuerySQL( db, "UPDATE Accounts SET IP='"+player.IP+"', UID='"+player.UniqueID+"', UID2='"+player.UniqueID2+"', Kills = '"+stats[ player.ID ].Kills+"', Deaths='"+stats[ player.ID ].Deaths+"', Cash='"+stats[ player.ID ].Cash+"', Bank = '"+stats[ player.ID ].Bank+"' WHERE Nickname= '" + player.Name + "'" );
print("Stats saved!");
}
// =========================================== P L A Y E R   E V E N T S ==============================================

function onPlayerJoin( player )
{
    spawnweps.rawset(player.Name, {});
    if (spawnweps.rawget(player.Name).rawin("weps"))
    {
        local data = spawnweps.rawget("weps");
        stats[player.ID].Weapons = data;
    }
stats[ player.ID ] = PlayerStats();
Message("[#00ff00]"+player.Name+" [#ffffff]has connected to the server.");
PlayerInfo(player);
}

function onPlayerPart( player, reason )
{
 if ( stats[ player.ID ].Logged ) UpdateInfo(player);
}

function onPlayerRequestClass( player, classID, team, skin )
{
	return 1;
}

function onPlayerRequestSpawn( player )
{
if ( !stats[ player.ID ].Registered ) return MessagePlayer("[#ffffff]Please register to start playing in the server.", player);
else if ( !stats[ player.ID ].Logged ) return MessagePlayer("[#ffffff]The account is registered, please do /login.", player);
else return 1;
}

function onPlayerSpawn( player )
{
        GiveSpawnwep(player);
}

function onPlayerDeath( player, reason )
{
stats[ player.ID ].Deaths++;
if ( stats[ player.ID ].Cash >= 100 ) RemoveCash( player, 100 );
UpdateInfo(player);
}

function onPlayerKill( killer, player, reason, bodypart )
{
stats[ killer.ID ].Kills++;
stats[ player.ID ].Deaths++;
AddCash( killer, 500 );
if ( player.Cash >= 100 ) RemoveCash( player, 100 );
PrivMessage( killer, "You received 500$ as a kill reward.");
PrivMessage( player, "You have lost 100$ for being killed.");
UpdateInfo(killer);
UpdateInfo(player);
}

function onPlayerTeamKill( killer, player, reason, bodypart )
{
killer.Health = 0;
Message("[#0000ff]Auto-Killed "+killer.Name+" for teamkilling.");
stats[ killer.ID ].Deaths++;
stats[ player.ID ].Deaths++;
}

function onPlayerChat( player, text )
{
if ( !stats[ player.ID ].Logged ) return MessagePlayer("[#ff0000]Please login to speak.", player);
else return 1;
}
function onPlayerCommand( player, cmd, text )
{
 if ( cmd == "register" )
 {
 if (!text) MessagePlayer("[#ff0000]Error:[#ffffff] Wrong syntax, use /"+cmd+" <Password>.:", player);
 else if ( stats[ player.ID ].Registered ) MessagePlayer("[#ff0000]Error:[#ffffff] You are already registerd.", player);
 else
 {
 local reward = 5000;
AddCash( player, reward.tointeger() );
 QuerySQL( db, "INSERT INTO Accounts( Nickname , Password, IP, UID, UID2, Kills, Deaths, Cash, Level, Bank, AutoLogin ) VALUES( '"+player.Name+"', '"+SHA256( text )+"', '"+player.IP+"', '"+player.UniqueID+"', '"+player.UniqueID2+"', '0', '0', '0', '1', '0', 'on')" );
 Message("[#ff00ff]"+player.Name+" is a registered user now.");
stats[ player.ID ].Registered = true;
stats[ player.ID ].Logged = true;
 MessagePlayer("[#ff00ff]You have registered your account in the server, you have received "+reward.tointeger()+"$ as a registration reward!", player);
 }
 }
 else if ( cmd == "login" )
 {
 if (!text) MessagePlayer("[#ff0000]Error:[#ffffff] Wrong syntax, use /"+cmd+" <Password>.", player);
 else if ( stats[ player.ID ].Logged ) MessagePlayer("[#ff0000]Error:[#ffffff] You're already logged in.", player);
  else if ( !stats[ player.ID ].Registered ) MessagePlayer("[#ff0000]Error:[#ffffff] You're not registered, please type /register.", player);
else
{
local q = QuerySQL( db, "SELECT * FROM Accounts WHERE Nickname='"+player.Name+"'" );
local Pass = GetSQLColumnData( q, 1 );
if ( SHA256( text ) != Pass ) MessagePlayer("[#ff0000]Error: [#ffffff] The password you entered is wrong.", player);
else{
stats[ player.ID ].Registered = true;
stats[ player.ID ].Logged = true;
stats[ player.ID ].Kills = GetSQLColumnData( q, 5 ).tointeger();
stats[ player.ID ].Deaths = GetSQLColumnData( q, 6 ).tointeger();
AddCash( player, GetSQLColumnData( q, 7 ) );
stats[ player.ID ].Bank = GetSQLColumnData( q, 8 ).tointeger();
stats[ player.ID ].Level = GetSQLColumnData( q, 9 ).tointeger();
stats[ player.ID ].AutoLogin = GetSQLColumnData( q, 10 ).tostring();
Message("[#00ff00]"+player.Name+" has logged into the server.");
MessagePlayer("[#ffffff]You've successfully logged in.", player);
}
}
}
else if ( cmd == "setpass" )
{
if (!text) MessagePlayer("[#ff0000]Error: [#ffffff] /setpass <New Pass>.", player);
else if ( !stats[ player.ID ].Registered ) MessagePlayer("[#ff0000]Error:[#ffffff] You are not registered.", player);
else if ( !stats[ player.ID ].Logged ) MessagePlayer("[#ff0000]Error: [#ffffff] You're not logged in, please /login.", player);
else{
QuerySQL( db, "UPDATE Accounts SET Password='"+SHA256( text )+"' WHERE Nickname='"+player.Name+"'" );
MessagePlayer("[#00ff00]You have successfully changed your password to: ( "+text+" ).", player);
}
}
else if ( cmd == "stats" )
{
if (!text)
{
MessagePlayer("[#00ff00]Your stats: Kills: "+stats[ player.ID ].Kills+", Deaths: "+stats[ player.ID ].Deaths+", Cash: "+stats[ player.ID ].Cash+", Bank:"+stats[ player.ID ].Bank+".", player);
}
else if (text)
{
local plr = FindPlayer(text);
if (!plr) MessagePlayer("[#ff0000]Error:[#ffffff] Player not found.", player);
else{
MessagePlayer("[#f0f0ff] "+plr.Name+" statistics: Kills: "+stats[ plr.ID ].Kills+", Deaths: "+stats[ plr.ID ].Deaths+", Cash: "+stats[ plr.ID ].Cash+", Bank: "+stats[ plr.ID ].Bank+", Level: "+stats[ plr.ID ].Level+".", player);
}
}
}
else if ( cmd == "setautologin" || cmd == "autologin" )
{
if (!text) MessagePlayer("[#ff0000]Error: [#ffffff]Correct syntax: /"+cmd+" <on/off>.", player);
else if ( !stats[ player.ID ].Registered ) MessagePlayer("[#ff0000]Error:[#ffffff] You're not registered.", player);
else if ( !stats[ player.ID ].Logged ) MessagePlayer("[#ff0000]Error:[#ffffff] You're not logged in.", player);
else if ( text == "on" )
{
QuerySQL( db, "UPDATE Accounts SET AutoLogin='on' WHERE Nickname='"+player.Name+"'" );
MessagePlayer("[#00ff00]Your autologin has been turned on.", player);
}
else if ( text == "off" )
{
QuerySQL( db, "UPDATE Accounts SET AutoLogin='off' WHERE Nickname='"+player.Name+"'" );
MessagePlayer("[#00ff00]Your autologin has been turned off.", player);
}
else MessagePlayer("[#ff0000]Error: use /"+cmd+" <on/off>.", player);
}

else if ( cmd =="credits" || cmd == "credts" )
{
MessagePlayer("[#ff000f]Account system by SHy.", player);
}
else if ( cmd == "cmds" || cmd == "commands" )
{
MessagePlayer("[#fff000]Available commands: (/)register, login, setautologin( or autologin ), setpass, stats, deposit, withdraw, givecash.", player);
}
else if ( cmd == "deposit" ) 
{
if (!text) MessagePlayer("[#ff0000]Error:[#ffffff] /deposit <amount>.", player);
else if ( !stats[ player.ID ].Registered ) return MessaagePlayer("[#ff0000]Error:[#ffffff] Command is limited to registered users only.", player);
else if ( !IsNum( text ) ) MessagePlayer("[#00ff00]Amount must be integer....", player);
else if ( player.Cash < text.tointeger() ) return MessagePlayer("[#ff0000]Error: You don't have that much cash which you want to deposit.", player);
else
{
stats[ player.ID ].Bank += text.tointeger();
RemoveCash( player, text.tointeger() );
MessagePlayer("[#fff000]You successfully deposited "+text.tointeger()+" amount in your bank account.", player);
}
}
else if ( cmd == "withdraw" )
{
if (!text) MessagePlayer("[#ff0000]Error:[#ffffff] Use /withdraw <amount>.", player);
else if ( !stats[ player.ID ].Registered ) return MessaagePlayer("[#ff0000]Error:[#ffffff] Command is limited to registered users only.", player);
else if ( !IsNum( text ) ) MessagePlayer("[#00ff00]Amount must be integer....", player);
else if ( stats[ player.ID ].Bank < text.tointeger() ) return MessagePlayer("[#ff0000]Error: You don't have that much cash which you want to withdraw.", player);
else
{
stats[ player.ID ].Bank -= text.tointeger();
AddCash( player, text.tointeger() );
MessagePlayer("[#fff000]You successfully withdrawn "+text.tointeger()+" amount from your bank account.", player);
}
}
else if ( cmd == "givecash" )
{
if (!text) MessagePlayer("[#ff0000]Error:[#ffffff] Use /givecash <Player> <Amount>.", player);
else if ( !stats[ player.ID ].Registered ) return MessaagePlayer("[#ff0000]Error:[#ffffff] Command is limited to registered users only.", player);
else
{
local plr = GetPlayer( GetTok( text, " ", 1 ) );
local amount = GetTok( text, " ", 2 );
if (!plr) MessagePlayer("[#ff0000]Error: Player not found.", player);
else if (!amount) return MessagePlayer("[#ff00000]Error: [#ffffff]Enter amount u want to give.", player);
else if ( !IsNum( amount ) ) return MessagePlayer("[#ff00000]Error: [#ffffff]Amount which you want to give must be integer.", player);
else if ( plr.Name == player.Name ) return MessagePlayer("[#ffff00]You can't send cash cash to yourself.", player);
else
{
RemoveCash( player, amount.tointeger() );
AddCash( plr, amount.tointeger() );
MessagePlayer("[#fffffff]You gave "+amount.tointeger()+"$ to "+plr.Name+".", player);
MessagePlayer("[#fffffff]You have received "+amount.tointeger()+"$ from "+player.Name+".", plr );
}
}
}

else if ( cmd == "cash" || cmd == "bank" )
{
if ( !stats[ player.ID ].Registered ) return MessaagePlayer("[#ff0000]Error:[#ffffff] Command is limited to registered users only.", player);
else
{
if (!text)
{
MessagePlayer("[#fff000]Your money statistics: Cash in hand: "+stats[ player.ID ].Cash+" and Bank account: "+stats[ player.ID ].Bank+".", player);
}
else if ( text )
{
local plr = FindPlayer(text);
if ( !plr) return MessagePlayer("[#ff0000]Error:[#fff000]Player not found.", player);
else if ( !stats[ plr.ID ].Registered ) return MessagePlayer("[#00ff00]Error: The player hasn't registered his account yet.", player);
else
{
MessagePlayer("[#fff000]"+plr.Name+" money statistics: Cash in hand: "+plr.Cash+" and Bank account: "+stats[ plr.ID ].Bank+".", player);
}
}
}
}
else if (cmd == "spawnwep") {
    if (!text) return MessaagePlayer("Please use: /spawnwep <Weapons>.");
 local weps = split( text, " " ),ID, wepsset = null;
            for( local i = 0; i < weps.len(); i++ )
            {
                ( IsNum( weps[ i ] ) ) ? ID = weps[ i ].tointeger() : ID = GetWeaponID( weps[ i ] );                          
                if ( ID >= 33 ) MessagePlayer( "[#ff0000]Error: Invalid Weapon ID/Name.", player ); 
                else
                {
                    player.SetWeapon( ID, 999 );
                    stats[player.ID].Weapons.push(ID);
                    if (wepsset == null) wepsset = " "+ ID;
                    else wepsset += (" " + ID);
                }
            }
            spawnweps.rawget(player.Name).rawset("weps", stats[player.ID].Weapons);
            MessagePlayer( "[#00ff00]Spawnwep saved.",player);
}
else if (cmd == "delspawnwep"){
foreach (idx, val in stats[player.ID].Weapons) {
 stats[player.ID].Weapons.remove(val);
}
if (spawnweps.rawin("weps")) spawnweps.rawdelete("weps");
MessaagePlayer("[#00ff00]Spawnweps have been set to default.", player);
}
else return MessaagePlayer("[#ff0000]Error: Invalid command!", player);
}
function onPlayerPM( player, playerTo, message )
{
	return 1;
}
// SLC's very useful functions
function GetTok( string, separator, n, ... )
{
 local m = ( vargv.len() > 0 ) ? vargv[ 0 ] : n, tokenized = split( string, separator ), text = "";

 if ( ( n > tokenized.len() ) || ( n < 1 ) ) return null;

 for ( ; n <= m; n++ )
 {
  text += text == "" ? tokenized[ n - 1 ] : separator + tokenized[ n - 1 ];
 }

 return text;
}

function NumTok(string, separator)
{
    local tokenized = split(string, separator);
    return tokenized.len();
}
function GetPlayer( target )
{
 local target1 = target.tostring();

 if ( IsNum( target ) )
 {
  target = target.tointeger();

  if ( FindPlayer( target) ) return FindPlayer( target );
  else return null;
 }
 else if ( FindPlayer( target ) ) return FindPlayer( target );
 else return null;
}

function onPlayerBeginTyping( player )
{
}

function onPlayerEndTyping( player )
{
}

function onNameChangeable( player )
{
}

function onPlayerSpectate( player, target )
{
}

function onPlayerCrashDump( player, crash )
{
}

function onPlayerMove( player, lastX, lastY, lastZ, newX, newY, newZ )
{
}

function onPlayerHealthChange( player, lastHP, newHP )
{
}

function onPlayerArmourChange( player, lastArmour, newArmour )
{
}

function onPlayerWeaponChange( player, oldWep, newWep )
{
}

function onPlayerAwayChange( player, status )
{
}

function onPlayerNameChange( player, oldName, newName )
{
}

function onPlayerActionChange( player, oldAction, newAction )
{
}

function onPlayerStateChange( player, oldState, newState )
{
}

function onPlayerOnFireChange( player, IsOnFireNow )
{
}

function onPlayerCrouchChange( player, IsCrouchingNow )
{
}

function onPlayerGameKeysChange( player, oldKeys, newKeys )
{
}

function onPlayerUpdate( player, update )
{
}

function onClientScriptData( player )
{
    // receiving client data
    local stream = Stream.ReadByte();
    switch ( stream )
    {
        default:
        break;
    }
}

// ========================================== V E H I C L E   E V E N T S =============================================

function onPlayerEnteringVehicle( player, vehicle, door )
{
	return 1;
}

function onPlayerEnterVehicle( player, vehicle, door )
{
}

function onPlayerExitVehicle( player, vehicle )
{
}

function onVehicleExplode( vehicle )
{
}

function onVehicleRespawn( vehicle )
{
}

function onVehicleHealthChange( vehicle, oldHP, newHP )
{
}

function onVehicleMove( vehicle, lastX, lastY, lastZ, newX, newY, newZ )
{
}

// =========================================== P I C K U P   E V E N T S ==============================================

function onPickupClaimPicked( player, pickup )
{
	return 1;
}

function onPickupPickedUp( player, pickup )
{
}

function onPickupRespawn( pickup )
{
}

// ========================================== O B J E C T   E V E N T S ==============================================

function onObjectShot( object, player, weapon )
{
}

function onObjectBump( object, player )
{
}

// ====================================== C H E C K P O I N T   E V E N T S ==========================================

function onCheckpointEntered( player, checkpoint )
{
}

function onCheckpointExited( player, checkpoint )
{
}

// =========================================== B I N D   E V E N T S =================================================

function onKeyDown( player, key )
{
}

function onKeyUp( player, key )
{
}

// ================================== E N D   OF   O F F I C I A L   E V E N T S ======================================


function SendDataToClient( player, ... )
{
    if( vargv[0] )
    {
        local     byte = vargv[0],
                len = vargv.len();
                
        if( 1 > len ) devprint( "ToClent <" + byte + "> No params specified." );
        else
        {
            Stream.StartWrite();
            Stream.WriteByte( byte );

            for( local i = 1; i < len; i++ )
            {
                switch( typeof( vargv[i] ) )
                {
                    case "integer": Stream.WriteInt( vargv[i] ); break;
                    case "string": Stream.WriteString( vargv[i] ); break;
                    case "float": Stream.WriteFloat( vargv[i] ); break;
                }
            }
            
            if( player == null ) Stream.SendStream( null );
            else if( typeof( player ) == "instance" ) Stream.SendStream( player );
            else devprint( "ToClient <" + byte + "> Player is not online." );
        }
    }
    else devprint( "ToClient: Even the byte wasn't specified..." );
}

function GiveSpawnwep(player) {
    foreach (idx, ID in stats[player.ID].Weapons) {
        player.SetWeapon(ID, 9999);
    }
}