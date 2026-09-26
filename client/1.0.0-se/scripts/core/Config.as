package core
{
   public class Config
   {
      
      public static const VERSION_NUMBER:String = "1.0.0-se";
      
      public static const VERSION_TEXT:String = "Please! This is supposed to be a happy occasion. Let\'s not bicker and argue over who killed who.";
      
      public static const URL_SERVER:String = "";
      
      public static const URL_SERVER_DVP:String = "http://dynamic.flash1.dev.socialpoint.es/appsfb/socialempiresdev/srvempires/";
      
      public static const URL_SERVER_PROD:String = "http://dynamic01.socialpointgames.com/appsfb/socialempires/srvempires/";
      
      public static const URL_APP_PROD:String = "http://apps.facebook.com/socialempires";
      
      public static const SERVICE_GET_GAME_CONFIG:String = "get_game_config.php";
      
      public static const SERVICE_GET_PLAYER_INFO:String = "get_player_info.php";
      
      public static const SERVICE_REGISTER_FOUND_ITEM:String = "register_found_item.php";
      
      public static const SERVICE_LOAD_CONTINENT:String = "get_continent.php";
      
      public static const SERVICE_LOAD_CONTINENT_RANKING:String = "get_continent_ranking.php";
      
      public static const SERVICE_LOAD_FBID_WORLD:String = "get_user_world.php";
      
      public static const SERVICE_COMMAND:String = "command.php";
      
      public static const SERVICE_REPORT_ERROR:String = "report_error.php";
      
      public static const SERVICE_TOURNAMENT_GET_INFO:String = "tournaments/get_tournament_info.php";
      
      public static const SERVICE_TOURNAMENT_CANCEL:String = "tournaments/cancel_tournament.php";
      
      public static const SERVICE_TOURNAMENT_CREATE:String = "tournaments/create_tournament.php";
      
      public static const SERVICE_TOURNAMENT_JOIN:String = "tournaments/join_tournament.php";
      
      public static const SERVICE_TOURNAMENT_START_MATCH:String = "tournaments/start_tournament_match.php";
      
      public static const SERVICE_TOURNAMENT_END_MATCH:String = "tournaments/finish_tournament_match.php";
      
      public static const SERVICE_TOURNAMENT_CLEAN:String = "tournaments/clean_tournament.php";
      
      public static const SERVICE_TOURNAMENT_LEAVE:String = "tournaments/leave_tournament.php";
      
      public static const SERVICE_KOMPU_TRY:String = "kompu_try.php";
      
      public static const SERVICE_KOMPU_HURRY_UP:String = "kompu_hurry_up.php";
      
      public static const SERVICE_CLEAN_ASSAULTS:String = "clean_assaults.php";
      
      public static const SERVICE_GET_USER_PROFILE:String = "get_public_player_info.php";
      
      public static const GAME_NAME:String = "SocialEmpires";
      
      public static const TEAM_TOURNAMENT:String = "tournament";
      
      public static const TEAM_QUEST:String = "quest";
      
      public static const REQUIRED_CLICKS_COVERED_ITEM:uint = 5;
      
      public static const COVERED_ITEM_IID:uint = 156;
      
      public static const UNCOVERED_ITEM_IID:uint = 157;
      
      public static const COVERED_ITEM_MIN_LEVEL:uint = 3;
      
      public static const EI_MAP_WIDTH:int = 100;
      
      public static const EI_MAP_HEIGHT:int = 100;
      
      public static const EI_TILES_IN_BIGTILE:uint = 20;
      
      public static const EI_INIT_TOPX:int = 0;
      
      public static const EI_INIT_TOPY:int = -2700;
      
      public static const EI_MIN_TOPX:int = -7216;
      
      public static const EI_MAX_TOPX:int = 7134;
      
      public static const EI_MIN_TOPY:int = -6479;
      
      public static const EI_MAX_TOPY:int = 871;
      
      public static const EI_INIT_POSX:int = 84;
      
      public static const EI_INIT_POSY:int = -2679;
      
      public static const EI_ZOOM_BATCHES:int = 5;
      
      public static const EI_TILE_WIDTH_PIXELS:int = 108;
      
      public static const EI_TILE_HEIGHT_PIXELS:int = 54;
      
      public static const EXP_MIN:uint = 5000;
      
      public static const EXP_MAX:uint = 5000;
      
      public static const MAX_GAMEPLAYS:uint = 10;
      
      public static const MAX_MINES_STONE:uint = 1;
      
      public static const MAX_MINES_GOLD:uint = 1;
      
      public static const MAX_MINES_WOOD:uint = 1;
      
      public static const MAX_MINES_FOOD:uint = 1;
      
      public static const MAX_LOADING_BUILDINGS_BUCLE:int = 20;
      
      public static const MAX_SELECTED_OBJECTS:int = 20;
      
      public static const MAX_COLUMNAS:int = 7;
      
      public static const LEFT_MARGIN_SELECTED_ELEMENTS:int = 17;
      
      public static const TOP_MARGIN_SELECTED_ELEMENTS:int = 20;
      
      public static const SPACE_SELECTED_ELEMENTS:int = 50;
      
      public static const SPACEY_SELECTED_ELEMENTS:int = 50;
      
      public static const DISTANCE_INTERACTION:uint = 1;
      
      public static const AGGRO_RANGE:uint = 10;
      
      public static const CLERIC_RANGE:uint = 10;
      
      public static const SHAMAN_RANGE:uint = 15;
      
      public static const CAPTURE_RANGE:uint = 4;
      
      public static const MAX_PROF_FADEBUILDINGS:int = 8;
      
      public static const MAPINITIALIZER_TIMER_RESPAWN_RESOURCES:uint = 60000;
      
      public static const MAPINITIALIZER_TIMER_RESPAWN_MENACES:uint = 180000;
      
      public static const INCREMENT_HEALTH_REPAIR:uint = 25;
      
      public static const MAX_POPULATION:int = 175;
      
      public static const IA_TIME_INTERVAL:uint = 60;
      
      public static const COLLECTIVEIA_ASSAULT_PERCENT_BUILDINGS_TO_DESTROY:uint = 5;
      
      public static const COLLECTIVEIA_ASSAULT_PERCENT_UNITS_TO_DESTROY:uint = 20;
      
      public static const MIN_LEVEL_ATTACKS_1:uint = 10;
      
      public static const MIN_LEVEL_ATTACKS_2:uint = 15;
      
      public static const MIN_LEVEL_ATTACKS_3:uint = 20;
      
      public static const MIN_LEVEL_ATTACK_SIEGE_1:uint = 25;
      
      public static const MIN_LEVEL_ATTACK_SIEGE_2:uint = 30;
      
      public static const MIN_LEVEL_ATTACK_SIEGE_3:uint = 35;
      
      public static const MIN_LEVEL_ATTACK_SIEGE_HEAVY:uint = 25;
      
      public static const MIN_LEVEL_ATTACK_SIEGE_HEAVY_2:uint = 35;
      
      public static const MIN_LEVEL_ATTACK_SIEGE_HEAVY_3:uint = 45;
      
      public static const MIN_LEVEL_PVP:uint = 6;
      
      public static const MIN_LEVEL_QUESTS:uint = 6;
      
      public static const MIN_LEVEL_SURVIVAL:uint = 20;
      
      public static const MIN_LEVEL_TOURNAMENT:uint = 15;
      
      public static const HEAVY_SIEGE_PERIOD:int = 24 * 3600 * 4;
      
      public static const HEAVY_SIEGE_ATTACK_WAIT:int = 6 * 3600;
      
      public static const HEAVY_SIEGE:Boolean = false;
      
      public static const TIMER_NEIGHBOUR:uint = 300000;
      
      public static const TIMER_WAITING_KEYBOARD:uint = 250;
      
      public static const TIMER_HARVEST:uint = 1000;
      
      public static const TIMER_COMMANDS:int = 6;
      
      public static const TIMER_UNITMOVE_COMMANDS:uint = 6000;
      
      public static const TIMER_DEAD_DISAPPEAR:uint = 4000;
      
      public static const TIMER_SPEECH_ACTIVE:uint = 3000;
      
      public static const TIMER_OGRES_VILLAGE:uint = 4 * 60 * 60;
      
      public static const TIMER_REPOSITION:uint = 300;
      
      public static const TIMER_REATACAR:uint = 300;
      
      public static const ASTAR_BAN_TIME_MIN:uint = 1000;
      
      public static const ASTAR_BAN_TIME_MAX:uint = 5000;
      
      public static const DISTANCIA_MINIMA_ARQUEROS:uint = 3;
      
      public static const DOUBLECLICK_SELECTION_RADIUS:int = 10;
      
      public static const FOOD_PER_GOLD_INTRAINING:Number = 2;
      
      public static const THRESHOLD_OVERATTACKED:Number = 2;
      
      public static const MULTIPLIER_PEASANTS:Number = 0.2;
      
      public static const INTERVAL_FRAME_SHOW_PARTICLE_ATTACK:uint = 15;
      
      public static const MAX_TILES_HUNTING:int = 20;
      
      public static const ATTACKS_MAX:int = 3;
      
      public static const ATTACKS_PERIOD_HOURS:int = 6;
      
      public static const ATTACKS_MIN_LEVEL:int = 6;
      
      public static const ATTACKS_SAME_PLAYER_HOURS:int = 4;
      
      public static const SPYINGS_MAX:int = 3;
      
      public static const SPYINGS_PERIOD_HOURS:int = 24;
      
      public static const MARKET_BASE_COSTS:Object = {
         "f":100,
         "s":150,
         "w":100
      };
      
      public static const MARKET_MAX_NUM_TRADES:Number = 20;
      
      public static const MARKET_INCREMENT:Number = 0.02;
      
      public static const MARKET_MAX_INCREMENTS:Number = 200;
      
      public static const MARKET_MAX_DECREMENTS:Number = 25;
      
      public static const MARKET_SELL_PERCENTAGE:Number = 0.75;
      
      public static const MARKET_PERIOD_HOURS:Number = 20;
      
      public static const MARKET_AMOUNT_TRADE:Array = [100,200,300];
      
      public static const CATEGORIA_MODE_EDITOR:int = 9;
      
      public static const CATEGORIA_MODE_NEW:int = 12;
      
      public static const SUBCATEGORIA_LIMITED:String = "121";
      
      public static const NUM_QUESTS:int = 30;
      
      public static const QUEST_PERIOD:int = 4 * 3600;
      
      public static const DIVISOR_SELL:int = 20;
      
      public static const QUESTS_WITH_TEAMS:Array = [Constants.QUEST_HARDCORE_6,Constants.QUEST_HARDCORE_7,Constants.QUEST_GODS_1,Constants.QUEST_GODS_2,Constants.QUEST_GODS_3];
      
      public static const BG_COLOR_GREEN:int = 6724652;
      
      public static const BG_COLOR_BLUE:int = 3052774;
      
      public static const LIMIT_UNIT_HEALERS:int = 5;
      
      public static const LIMIT_UNIT_MONKS:int = 4;
      
      public static const LIMIT_UNIT_ENGINEERS:int = 5;
      
      public static const LIMIT_UNIT_MOBILE_TOWER:int = 4;
      
      public static const LIMIT_UNIT_TROLL_HEALER:int = 4;
      
      public static const LIMIT_UNIT_TROLL_DRUMMER:int = 3;
      
      public static const LIMIT_SPECIAL_UNITS:int = 1;
      
      public static const LIMIT_UNIT_MUMMY:int = LIMIT_SPECIAL_UNITS;
      
      public static const LIMIT_UNIT_NEPTUNE:int = LIMIT_SPECIAL_UNITS;
      
      public static const LIMIT_UNIT_ENT:int = LIMIT_SPECIAL_UNITS;
      
      public static const LIMIT_UNIT_GREATER_DEMON:int = LIMIT_SPECIAL_UNITS;
      
      public static const TIMER_DOUBLECLICK:uint = 1000;
      
      public static const VILLAGER_SPEED:Array = [3,5,5,6,6];
      
      public static const VILLAGER_QUEUE:Array = [3,5,7,9,10];
      
      public static const DIST_PIXELS_ARROW_DAMAGE:int = 100;
      
      public static const DAMAGE_TO_ALERT:int = 50;
      
      public static const COST_BUY_ATTACK:int = 30;
      
      public static const COST_BUY_SPYINGS:int = 15;
      
      public static const ATTACKS_PACK_SIZE:int = 50;
      
      public static const SPYINGS_PACK_SIZE:int = 50;
      
      public static const PRIZE_COLLECTIONS_CASH:Array = [0,5,5,5,5,5,5,5,5,5,15,5,5,5,5,5,5,5,5,5,20,400,400,999];
      
      public static const MAX_GOLD_FROM_ASSAULT:int = 200;
      
      public static const MAX_UNITS_COLLECTIVE_IA_MID_DEFENSIVE:int = 25;
      
      public static const MAX_UNITS_COLLECTIVE_IA_AGGRESSIVE:int = 25;
      
      public static const BUY_GOLD_CASH:int = 5;
      
      public static const BUY_GOLD_GOLD:int = 2500;
      
      public static const HEALTH_SPY_EAGLES:Array = [200,400,800,10000];
      
      public static const REDUCTION_MULTIPLIER_BLACKSMITH:Number = 0.9;
      
      public static const REDUCTION_MULTIPLIER_UNIVERSITY:Number = 0.9;
      
      public static const MAX_TOWERS_PER_BIGTILE:int = 400;
      
      public static const FITNESS_SPEED_INCREMENT:int = 2;
      
      public static const LIBRARY_MEMORY_INCREMENT:int = 2;
      
      public static const RESURRECT_MULTIPLIER:int = 500;
      
      public static const SERVER_KEY:String = "3m0d3pwiupoetn7ysa02";
      
      public static const RESOURCES_MARKET_PER_ALLY:int = 125;
      
      public static const MONK_CONVERSION_LIMIT:int = 4;
      
      public static const MULTIPLIER_UNLOCK:Number = 1 / 3;
      
      public static const TOWN_PRICE_GOLD:int = 100000;
      
      public static const TOWN_PRICE_CASH:int = 22;
      
      public static const COST_HURRY_UP:int = 2;
      
      public static const TROL_RACE_MIN_LEVEL:int = 20;
      
      public static const TROL_RACE_REQUIRED_LEVEL:int = 20;
      
      public static const BG_SKIN_COLORS:Array = [6724652,15383628,14675186,3052774,8796180,3770880,16777215];
      
      public static const MAX_NEIHGBOURS:int = 100;
      
      public static const FRIENDS_ASSIST_DIVISOR:Number = 1 / 4;
      
      public static const FRIENDS_ASSIST_EXPERIENCE:int = 10;
      
      public static const OIL_TOWER_DPT:uint = 5;
      
      public static const OIL_TOWER_ATTACKS:uint = 5;
      
      public static const OIL_TOWER_ATTACK_DELAY:uint = 1000;
      
      public static const ASSIST_ENTER_REWARD_GOLD:int = 25;
      
      public static const ASSIST_ENTER_REWARD_XP:int = 15;
      
      public static const ASSIST_CLICK_REWARD_GOLD:int = 10;
      
      public static const ASSIST_CLICK_REWARD_XP:int = 3;
      
      public static const LEVEL_MAGIC:int = 35;
      
      public static const FEATURE_SELECT_STARTING_POINT:Boolean = true;
      
      public static const FEATURE_HONOR_POINTS:Boolean = true;
      
      public static const FEATURE_MAGICBOX:Boolean = true;
      
      public static const COLLECT_MINUTES:Array = [5,60,240,480];
      
      public static const COLLECT_MULTIPLIER:Array = [0.5,1,2,3];
      
      public static const NUM_ACTIVE_MISSIONS:int = 15;
      
      public static var AUTO_COLLECT:Boolean = true;
      
      public static var SHOW_ANIMATED_PREVIEW:Boolean = true;
      
      public static var SPAWN_DRAGON_NEST_AFTER_TUTORIAL:Boolean = false;
      
      public static var TWEAKED_DAILY_BONUS:Boolean = true;
      
      public static var ENABLE_FAKE_FRIENDS:Boolean = false;
      
      public static const NEW_TOWER_IA_TOWER_COUNT:int = 100;
      
      public static const POPUP_TREASURE_CUSTOM_QUEST:int = 40;
      
      public static const SELL_FOR_ZERO_CASH:Boolean = true;
      
      public static var SHOW_MOROCCO_DEALER:Boolean = true;
      
      public static var POPUP_CHOOSE_YOUR_DRAGON:Boolean = true;
      
      public static var DISABLE_GRAVEYARD:Boolean = false;
      
      public static var HIDE_XP_FROM_STORE:Boolean = false;
      
      public static var CAN_PAY_FOR_GOALS:Boolean = false;
      
      public static var SHOW_ICON_VIDEOS:Boolean = false;
      
      public static const MIN_LEVEL_ORC_DRAGON_ENEMY:uint = 25;
      
      public static var MORE_DESTRUCTION:Boolean = false;
      
      public static var SHOW_ONLY_ONE_LOCKED:Boolean = false;
      
      public static var TEST_ABCD_FEED_TAKE_CARE_FOR_1_CASH:Boolean = false;
      
      public static var DONT_DESTROY:Boolean = false;
      
      public static var COME_BACK_2ND_3RD:Boolean = false;
      
      public static var TEST_ABCD_TAKE_CARE_FOR_FREE:Boolean = false;
      
      public static var FORCE_SYNC_ERROR:Boolean = false;
      
      public static var FORCE_RELOAD_ON_ATTACK_END:Boolean = false;
      
      public static var FORCE_RELOAD_ON_QUEST_END:Boolean = false;
      
      public static var FB_PROMO_URI:String = "";
      
      public static var LESS_REWARD_QUESTS_CHAPTERS:Boolean = false;
      
      public function Config()
      {
         super();
      }
   }
}

