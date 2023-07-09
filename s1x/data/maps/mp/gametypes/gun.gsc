// S1 GSC SOURCE
// Dumped by https://github.com/xensik/gsc-tool

main()
{
    maps\mp\gametypes\_globallogic::init();
    maps\mp\gametypes\_callbacksetup::setupcallbacks();
    maps\mp\gametypes\_globallogic::setupcallbacks();
    setguns();
    maps\mp\_utility::registertimelimitdvar( level.gametype, 10 );
    setdvar( "scr_gun_scorelimit", level.gun_guns.size );
    maps\mp\_utility::registerscorelimitdvar( level.gametype, level.gun_guns.size );
    level thread reinitializescorelimitonmigration();
    maps\mp\_utility::registerroundlimitdvar( level.gametype, 1 );
    maps\mp\_utility::registerwinlimitdvar( level.gametype, 0 );
    maps\mp\_utility::registernumlivesdvar( level.gametype, 0 );
    maps\mp\_utility::registerhalftimedvar( level.gametype, 0 );
    level.matchrules_randomize = 0;
    level.matchrules_damagemultiplier = 0;
    level.matchrules_vampirism = 0;

    setspecialloadout();
    level.teambased = 0;
    level.doprematch = 1;
    level.onstartgametype = ::onstartgametype;
    level.onspawnplayer = ::onspawnplayer;
    level.getspawnpoint = ::getspawnpoint;
    level.onplayerkilled = ::onplayerkilled;
    level.ontimelimit = ::ontimelimit;
    level.onplayerscore = ::onplayerscore;
    level.bypassclasschoicefunc = ::gungameclass;
    level.assists_disabled = 1;
    level.setbacklevel = maps\mp\_utility::getintproperty( "scr_setback_levels", 1 );
    level.lastguntimevo = 0;

    if ( level.matchrules_damagemultiplier )
        level.modifyplayerdamage = maps\mp\gametypes\_damage::gamemodemodifyplayerdamage;

    setteammode( "ffa" );
    game["dialog"]["gametype"] = "gg_intro";
    game["dialog"]["defense_obj"] = "gbl_start";
    game["dialog"]["offense_obj"] = "gbl_start";
    game["dialog"]["humiliation"] = "gg_humiliation";
    game["dialog"]["lastgun"] = "at_anr1_gg_lastgun";

    if ( maps\mp\_utility::isgrapplinghookgamemode() )
        game["dialog"]["gametype"] = "grap_" + game["dialog"]["gametype"];
}

initializematchrules()
{
    maps\mp\_utility::setcommonrulesfrommatchrulesdata( 1 );
    level.matchrules_randomize = getmatchrulesdata( "gunData", "randomize" );
    setdvar( "scr_gun_scorelimit", level.gun_guns.size );
    maps\mp\_utility::registerscorelimitdvar( level.gametype, level.gun_guns.size );
    setdvar( "scr_gun_winlimit", 1 );
    maps\mp\_utility::registerwinlimitdvar( "gun", 1 );
    setdvar( "scr_gun_roundlimit", 1 );
    maps\mp\_utility::registerroundlimitdvar( "gun", 1 );
    setdvar( "scr_gun_halftime", 0 );
    maps\mp\_utility::registerhalftimedvar( "gun", 0 );
    setdvar( "scr_gun_playerrespawndelay", 0 );
    setdvar( "scr_gun_waverespawndelay", 0 );
    setdvar( "scr_player_forcerespawn", 1 );
    setdvar( "scr_setback_levels", getmatchrulesdata( "gunData", "setbackLevels" ) );
}

reinitializescorelimitonmigration()
{
    setdvar( "scr_gun_scorelimit", level.gun_guns.size );
    maps\mp\_utility::registerscorelimitdvar( level.gametype, level.gun_guns.size );
}

onstartgametype()
{
    setclientnamemode( "auto_change" );
    maps\mp\_utility::setobjectivetext( "allies", &"OBJECTIVES_DM" );
    maps\mp\_utility::setobjectivetext( "axis", &"OBJECTIVES_DM" );
    maps\mp\_utility::setobjectivescoretext( "allies", &"OBJECTIVES_DM_SCORE" );
    maps\mp\_utility::setobjectivescoretext( "axis", &"OBJECTIVES_DM_SCORE" );
    maps\mp\_utility::setobjectivehinttext( "allies", &"OBJECTIVES_DM_HINT" );
    maps\mp\_utility::setobjectivehinttext( "axis", &"OBJECTIVES_DM_HINT" );
    initspawns();
    var_0 = [];
    maps\mp\gametypes\_gameobjects::main( var_0 );
    level.quickmessagetoall = 1;
    level.blockweapondrops = 1;
    level thread onplayerconnect();
}

initspawns()
{
    level.spawnmins = ( 0, 0, 0 );
    level.spawnmaxs = ( 0, 0, 0 );
    level.spawn_name = "mp_dm_spawn";
    maps\mp\gametypes\_spawnlogic::addspawnpoints( "allies", level.spawn_name );
    maps\mp\gametypes\_spawnlogic::addspawnpoints( "axis", level.spawn_name );
    level.mapcenter = maps\mp\gametypes\_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
    setmapcenter( level.mapcenter );
}

onplayerconnect()
{
    for (;;)
    {
        level waittill( "connected", player );
        player.gungamegunindex = 0;
        player.gungameprevgunindex = 0;
        player.stabs = 0;
        player.mysetbacks = 0;
        player.lastleveluptime = 0;
        player.showsetbacksplash = 0;

        if ( level.matchrules_randomize )
            player.gunlist = common_scripts\utility::array_randomize( level.gun_guns );

        player thread refillammo();
        player thread refillsinglecountammo();
        player thread watchforhostmigration();
    }
}

getspawnpoint()
{
    var_0 = maps\mp\gametypes\_spawnlogic::getteamspawnpoints( self.pers["team"] );

    if ( level.ingraceperiod )
        var_1 = maps\mp\gametypes\_spawnlogic::getspawnpoint_random( var_0 );
    else
        var_1 = maps\mp\gametypes\_spawnscoring::getspawnpoint_freeforall( var_0 );

    maps\mp\gametypes\_spawnlogic::recon_set_spawnpoint( var_1 );
    return var_1;
}

gungameclass()
{
    self.pers["class"] = "gamemode";
    self.pers["lastClass"] = "";
    self.pers["gamemodeLoadout"] = level.gun_loadout;
    self.class = self.pers["class"];
    self.lastclass = self.pers["lastClass"];
    self loadweapons( level.gun_guns[0] );
}

onspawnplayer()
{
    thread waitloadoutdone();
}

waitloadoutdone()
{
    level endon( "game_ended" );
    self endon( "disconnect" );
    level waittill( "player_spawned" );
    givenextgun( 1 );

    if ( self.showsetbacksplash )
    {
        self.showsetbacksplash = 0;
        thread maps\mp\_events::decreasegunlevelevent();
    }
}

watchforhostmigration()
{
    level endon( "game_ended" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "player_migrated" );

        if ( self.sessionstate == "spectator" )
            maps\mp\gametypes\_menus::handleclasschoicedisallowed();
    }
}

onplayerscore( var_0, var_1, var_2 )
{
    if ( var_0 == "gained_gun_score" )
    {
        var_3 = maps\mp\gametypes\_rank::getscoreinfovalue( var_0 );
        var_1 maps\mp\_utility::setextrascore0( var_1.extrascore0 + var_3 );
        var_1 maps\mp\gametypes\_gamescore::updatescorestatsffa( var_1, var_3 );
        return 1;
    }

    if ( var_0 == "dropped_gun_score" )
    {
        var_4 = min( level.setbacklevel, self.score );
        return int( var_4 * -1 );
    }

    return 0;
}

onplayerkilled( var_0, var_1, var_2, var_3, var_4, var_5, var_6, var_7, var_8, var_9 )
{
    if ( !isdefined( var_1 ) )
        return;

    if ( var_3 == "MOD_TRIGGER_HURT" && !isplayer( var_1 ) )
        var_1 = self;

    if ( var_3 == "MOD_FALLING" || isplayer( var_1 ) )
    {
        if ( var_3 == "MOD_FALLING" || var_1 == self || maps\mp\_utility::ismeleemod( var_3 ) && var_4 != "riotshield_mp" || var_4 == "boost_slam_mp" || var_4 == "iw5_dlcgun12loot8_mp" )
        {
            self playlocalsound( "mp_war_objective_lost" );
            self.gungameprevgunindex = self.gungamegunindex;
            self.gungamegunindex = int( max( 0, self.gungamegunindex - level.setbacklevel ) );
            self.lastkillweapon = undefined;

            if ( self.gungameprevgunindex > self.gungamegunindex )
            {
                self.mysetbacks++;
                maps\mp\_utility::setextrascore1( self.mysetbacks );
                self.showsetbacksplash = 1;

                if ( maps\mp\_utility::ismeleemod( var_3 ) || var_4 == "boost_slam_mp" || var_4 == "iw5_dlcgun12loot8_mp" )
                {
                    var_1.stabs++;
                    var_1.assists = var_1.stabs;
                    var_1 thread maps\mp\_events::setbackenemygunlevelevent();

                    if ( self.gungameprevgunindex == level.gun_guns.size - 1 )
                    {
                        var_1 thread maps\mp\_events::setbackfirstplayergunlevelevent();
                        var_1 maps\mp\_utility::leaderdialogonplayer( "humiliation", "status" );
                    }
                }
            }
        }
        else if ( var_3 == "MOD_PISTOL_BULLET" || var_3 == "MOD_RIFLE_BULLET" || var_3 == "MOD_HEAD_SHOT" || var_3 == "MOD_PROJECTILE" || var_3 == "MOD_PROJECTILE_SPLASH" || var_3 == "MOD_EXPLOSIVE" || var_3 == "MOD_IMPACT" || var_3 == "MOD_GRENADE" || var_3 == "MOD_GRENADE_SPLASH" || maps\mp\_utility::ismeleemod( var_3 ) && var_4 == "riotshield_mp" )
        {
            if ( isdefined( var_1.lastkillweapon ) && var_1.lastkillweapon == var_4 )
                return;

            var_10 = level.gun_guns;

            if ( level.matchrules_randomize )
                var_10 = var_1.gunlist;

            var_11 = var_10[var_1.gungamegunindex];

            if ( !issubstr( var_4, maps\mp\_utility::getbaseweaponname( var_11 ) ) )
                return;

            var_1.lastkillweapon = var_4;

            if ( var_1.lastleveluptime + 3000 > gettime() )
                var_1 thread maps\mp\_events::quickgunlevelevent();

            var_1.lastleveluptime = gettime();
            var_1.gungameprevgunindex = var_1.gungamegunindex;
            var_1.gungamegunindex++;
            var_1 thread maps\mp\_events::increasegunlevelevent();

            if ( var_1.gungamegunindex == level.gun_guns.size - 1 )
            {
                maps\mp\_utility::playsoundonplayers( "mp_enemy_obj_captured" );
                level thread maps\mp\_utility::teamplayercardsplash( "callout_top_gun_rank", var_1 );
                var_12 = gettime();

                if ( level.lastguntimevo + 4500 < var_12 )
                {
                    level thread maps\mp\_utility::leaderdialogonplayers( "lastgun", level.players, "status" );
                    level.lastguntimevo = var_12;
                }
            }

            if ( var_1.gungamegunindex < level.gun_guns.size )
                var_1 givenextgun( 0, var_4 );
        }
    }
}

givenextgun( var_0, var_1 )
{
    self endon( "disconnect" );
    var_2 = getnextgun();
    self.gun_curgun = var_2;
    var_2 = addattachments( var_2 );

    while ( !self loadweapons( var_2 ) )
        waitframe();

    if ( isdefined( var_1 ) )
        self takeweapon( var_1 );
    else
        self takeallweapons();

    maps\mp\_utility::_giveweapon( var_2 );
    self switchtoweaponimmediate( var_2 );

    if ( isdefined( var_0 ) && var_0 == 1 )
        self setspawnweapon( var_2 );

    var_3 = maps\mp\_utility::getbaseweaponname( var_2 );
    self.pers["primaryWeapon"] = var_3;
    self.primaryweapon = var_2;
    self givestartammo( var_2 );
    self switchtoweapon( var_2 );
    self.gungameprevgunindex = self.gungamegunindex;
}

getnextgun()
{
    var_0 = level.gun_guns;
    var_1 = [];
    var_2 = undefined;

    if ( level.matchrules_randomize )
        var_0 = self.gunlist;

    var_2 = var_0[self.gungamegunindex];
    var_1[var_1.size] = var_2;

    if ( self.gungamegunindex + 1 < var_0.size )
        var_1[var_1.size] = var_0[self.gungamegunindex + 1];

    if ( self.gungamegunindex > 0 )
        var_1[var_1.size] = var_0[self.gungamegunindex - 1];

    self loadweapons( var_1 );
    return var_2;
}

addattachments( var_0 )
{
    if ( getdvarint( "scr_gun_loot_variants", 0 ) == 1 )
    {
        var_1 = tablelookup( "mp/statstable.csv", 4, var_0, 40 );

        if ( isdefined( var_1 ) && var_1 != "" )
            var_2 = maps\mp\gametypes\_class::buildweaponname( var_0, var_1, "none", "none", 0, 0 );
        else
            var_2 = maps\mp\gametypes\_class::buildweaponname( var_0, "none", "none", "none", 0, 0 );
    }
    else
        var_2 = maps\mp\gametypes\_class::buildweaponname( var_0, "none", "none", "none", 0, 0 );

    return var_2;
}

ontimelimit()
{
    level.finalkillcam_winner = "none";
    var_0 = gethighestprogressedplayers();

    if ( !isdefined( var_0 ) || !var_0.size )
        thread maps\mp\gametypes\_gamelogic::endgame( "tie", game["end_reason"]["time_limit_reached"] );
    else if ( var_0.size == 1 )
        thread maps\mp\gametypes\_gamelogic::endgame( var_0[0], game["end_reason"]["time_limit_reached"] );
    else if ( var_0[var_0.size - 1].gungamegunindex > var_0[var_0.size - 2].gungamegunindex )
        thread maps\mp\gametypes\_gamelogic::endgame( var_0[var_0.size - 1], game["end_reason"]["time_limit_reached"] );
    else
        thread maps\mp\gametypes\_gamelogic::endgame( "tie", game["end_reason"]["time_limit_reached"] );
}

gethighestprogressedplayers()
{
    var_0 = -1;
    var_1 = [];

    foreach ( var_3 in level.players )
    {
        if ( isdefined( var_3.gungamegunindex ) && var_3.gungamegunindex >= var_0 )
        {
            var_0 = var_3.gungamegunindex;
            var_1[var_1.size] = var_3;
        }
    }

    return var_1;
}

refillammo()
{
    level endon( "game_ended" );
    self endon( "disconnect" );

    for (;;)
    {
        self waittill( "reload" );
        self givestartammo( self.primaryweapon );
    }
}

refillsinglecountammo()
{
    level endon( "game_ended" );
    self endon( "disconnect" );

    for (;;)
    {
        if ( maps\mp\_utility::isreallyalive( self ) && self.team != "spectator" && isdefined( self.primaryweapon ) && self getammocount( self.primaryweapon ) == 0 )
        {
            wait 2;
            self notify( "reload" );
            wait 1;
            continue;
        }

        wait 0.05;
    }
}

setguns()
{
    var_0 = getdvarint( "scr_gun_loot_variants", 0 );
    level.gun_guns = [];
    level.gun_guns[0] = "iw5_asm1";
    level.gun_guns[1] = "iw5_asaw";
    level.gun_guns[2] = "iw5_himar";
    level.gun_guns[3] = "iw5_kf5";
    level.gun_guns[4] = "iw5_hbra3";
    level.gun_guns[5] = "iw5_mp11";
    level.gun_guns[6] = "iw5_ak12";
    level.gun_guns[7] = "iw5_sn6";
    level.gun_guns[8] = "iw5_arx160";
    level.gun_guns[9] = "iw5_hmr9";
    level.gun_guns[10] = "iw5_maul";
    level.gun_guns[11] = "iw5_dlcgun3";
    level.gun_guns[12] = "iw5_em1";
    level.gun_guns[13] = "iw5_uts19";
    level.gun_guns[14] = "iw5_lsat";
    level.gun_guns[15] = "iw5_rhino";
    level.gun_guns[16] = "iw5_exoxmg";
    level.gun_guns[17] = "iw5_epm3";
    level.gun_guns[18] = "iw5_mors";
    level.gun_guns[19] = "iw5_rw1";
    level.gun_guns[20] = "iw5_vbr";
    level.gun_guns[21] = "iw5_pbw";
    level.gun_guns[22] = "iw5_thor";
    level.gun_guns[23] = "iw5_mahem";
    level.gun_guns[24] = "iw5_exocrossbow";

    if ( isdefined( var_0 ) && var_0 )
    {
        for ( var_1 = 0; var_1 < level.gun_guns.size; var_1++ )
        {
            var_2 = level.gun_guns[var_1];

            if ( maps\mp\_utility::getweaponclass( var_2 ) == "weapon_projectile" || maps\mp\_utility::getweaponclass( var_2 ) == "weapon_sec_special" )
                var_2 = assign_random_loot_variant( var_2, 4 );
            else
                var_2 = assign_random_loot_variant( var_2, 10 );

            level.gun_guns[var_1] = var_2;
        }
    }
}

assign_random_loot_variant( var_0, var_1 )
{
    var_2 = randomint( var_1 );

    switch ( var_2 )
    {
        case 0:
            var_0 += "loot0";
            break;
        case 1:
            var_0 += "loot1";
            break;
        case 2:
            var_0 += "loot2";
            break;
        case 3:
            var_0 += "loot3";
            break;
        case 4:
            var_0 += "loot4";
            break;
        case 5:
            var_0 += "loot5";
            break;
        case 6:
            var_0 += "loot6";
            break;
        case 7:
            var_0 += "loot7";
            break;
        case 8:
            var_0 += "loot8";
            break;
        case 9:
            var_0 += "loot9";
            break;
        default:
            break;
    }

    return var_0;
}

setspecialloadout()
{
    level.gun_loadout = maps\mp\gametypes\_class::getemptyloadout();

    if ( maps\mp\gametypes\_class::isvalidprimary( level.gun_guns[0] ) )
        level.gun_loadout["loadoutPrimary"] = level.gun_guns[0];
    else if ( maps\mp\gametypes\_class::isvalidsecondary( level.gun_guns[0], 0 ) )
        level.gun_loadout["loadoutSecondary"] = level.gun_guns[0];
}
