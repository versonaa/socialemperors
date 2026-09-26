import copy
import json
import math
import traceback

from sessions import session, save_session, initial_village
from get_game_config import get_game_config, get_level_from_xp, get_name_from_item_id, get_attribute_from_mission_id, get_xp_from_level, get_attribute_from_item_id, get_item_from_subcat_functional
from constants import Constant
from engine import apply_cost, apply_collect, apply_collect_xp, timestamp_now

# Client constants (core/Config.as) that are not in the game config
TOWN_PRICE_GOLD = 100000
TOWN_PRICE_CASH = 22
MARKET_BASE_COSTS = {"f": 100, "s": 150, "w": 100}
MARKET_INCREMENT = 0.02
MARKET_MAX_INCREMENTS = 200
MARKET_MAX_DECREMENTS = 25
MARKET_SELL_PERCENTAGE = 0.75
MARKET_PERIOD_HOURS = 20
RESOURCE_KEYS = {"g": "coins", "w": "wood", "s": "stone", "f": "food"}
# Starting buildings of a new town, human -> troll
TROLL_TOWN_BUILDINGS = {26: 289, 1: 307, 29: 291} # Town Hall, House I, Tower I

def as3_round(value: float) -> int:
    # Flash's Math.round rounds halves up, Python's round() to even
    return math.floor(value + 0.5)

def add_to_store(map: dict, item_id: int, amount: int = 1) -> None:
    # map["store"]: {"item_id": count}, the storage the client shows as not being gifts
    store = map.setdefault("store", {})
    key = str(item_id)
    store[key] = store.get(key, 0) + amount

def take_from_store(save: dict, map: dict, item_id: int) -> bool:
    store = map.get("store", {})
    key = str(item_id)
    if store.get(key, 0) > 0:
        store[key] -= 1
        if store[key] == 0:
            del store[key]
        return True
    # store_item used to put stored items in the gifts list
    gifts = save["privateState"]["gifts"]
    if isinstance(gifts, list) and item_id < len(gifts) and gifts[item_id] > 0:
        gifts[item_id] -= 1
        while gifts and gifts[-1] == 0:
            gifts.pop()
        return True
    return False

def add_bought_unit(save: dict, item_id: int) -> None:
    # privateState.boughtUnits: units the player ever had, counted by the unit collections
    if get_attribute_from_item_id(item_id, "type") != "u":
        return
    bought = save["privateState"].setdefault("boughtUnits", [])
    if item_id not in bought:
        bought.append(item_id)

def give_pack_resources(save: dict, map: dict, pack: dict, with_xp: bool) -> None:
    # Resources of an offer pack (PromotionPacks.buyPack / buySuperPack)
    map["coins"] += int(pack.get("gold", 0))
    map["stone"] += int(pack.get("stone", 0))
    map["food"] += int(pack.get("food", 0))
    map["wood"] += int(pack.get("wood", 0))
    if with_xp:
        map["xp"] += int(pack.get("xp", 0))
    save["privateState"]["mana"] = save["privateState"].get("mana", 0) + int(pack.get("mana", 0))

def get_offer_pack(pack_id: int) -> dict:
    packs = get_game_config()["offer_packs"]
    return packs[int(pack_id) - 1] if 0 < int(pack_id) <= len(packs) else None

def get_magic(magic_id: int) -> dict:
    for magic in get_game_config()["magics"]:
        if int(magic["id"]) == int(magic_id):
            return magic
    return None

def remove_units(map: dict, unit_id: int, amount: int) -> int:
    removed = 0
    for item in list(map["items"]):
        if removed >= amount:
            break
        if item[0] == unit_id:
            map["items"].remove(item)
            removed += 1
    return removed

def new_town(save: dict, race: str) -> dict:
    town = copy.deepcopy(initial_village()["maps"][0])
    town["id"] = len(save["maps"])
    town["race"] = race
    town["timestamp"] = timestamp_now()
    # Level and xp are shared by all towns
    town["xp"] = save["maps"][0]["xp"]
    town["level"] = save["maps"][0]["level"]
    if race == "t":
        items = []
        for item in town["items"]:
            if get_attribute_from_item_id(item[0], "type") == "u":
                continue # human starting army
            item[0] = TROLL_TOWN_BUILDINGS.get(item[0], item[0])
            items.append(item)
        town["items"] = items
    return town

def get_strategy_type(id):
    if id == 8:
        return "Defensive"
    if id == 9:
        return "Mid Defensive"
    if id == 7:
        return "Mid Aggressive"
    if id == 10:
        return "Aggressive"
    return "Unknown Strategy"

def command(USERID, data):
    timestamp = data["ts"]
    first_number = data["first_number"]
    accessToken = data["accessToken"]
    tries = data["tries"]
    publishActions = data["publishActions"]
    commands = data["commands"]
    
    for i, comm in enumerate(commands):
        cmd = comm["cmd"]
        args = comm["args"]
        # A failing command must not lose the rest of the batch: log it and keep going
        try:
            do_command(USERID, cmd, args)
        except Exception:
            print(f"\n [!] Error in command '{cmd}' {args}:")
            traceback.print_exc()
    save_session(USERID) # Save session

def do_command(USERID, cmd, args):
    save = session(USERID)
    print (" [+] COMMAND: ", cmd, "(", args, ") -> ", sep='', end='')

    if cmd == Constant.CMD_GAME_STATUS:
        print(" ".join(args))

    elif cmd == Constant.CMD_BUY:
        id = args[0]
        x = args[1]
        y = args[2]
        frame = args[3] # TODO ??
        town_id = args[4]
        bool_dont_modify_resources = bool(args[5]) # 1 if the game "buys" for you, so does not substract whatever the item cost is.
        price_multiplier = args[6]
        type = args[7]
        print("Add", str(get_name_from_item_id(id)), "at", f"({x},{y})")
        collected_at_timestamp = timestamp_now()
        level = 0 # TODO 
        orientation = 0
        map = save["maps"][town_id]
        if not bool_dont_modify_resources:
            apply_cost(save["playerInfo"], map, id, price_multiplier)
            xp = int(get_attribute_from_item_id(id, "xp"))
            map["xp"] = map["xp"] + xp
        map["items"] += [[id, x, y, orientation, collected_at_timestamp, level]]
        add_bought_unit(save, id)

    elif cmd == Constant.CMD_BUY_UNIT_WITH_CASH:
        id = args[0]
        x = args[1]
        y = args[2]
        frame = args[3] # TODO ??
        town_id = args[4]
        print("Add", str(get_name_from_item_id(id)), "at", f"({x},{y})", "paid with cash")
        map = save["maps"][town_id]
        cost = int(get_attribute_from_item_id(id, "cost_unit_cash"))
        save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - cost, 0)
        map["xp"] = map["xp"] + int(get_attribute_from_item_id(id, "xp"))
        map["items"] += [[id, x, y, 0, timestamp_now(), 0]]
        add_bought_unit(save, id)

    elif cmd == Constant.CMD_COMPLETE_TUTORIAL:
        tutorial_step = args[0]
        print("Tutorial step", tutorial_step, "reached.")
        if tutorial_step >= 31: # 31 is Dragon choosing. After that, you have some freedom. There's at least until step 45.
            print("Tutorial COMPLETED!")
            save["playerInfo"]["completed_tutorial"] = 1
            save["privateState"]["dragonNestActive"] = 1 
    
    elif cmd == Constant.CMD_MOVE:
        ix = args[0]
        iy = args[1]
        id = args[2]
        newx = args[3]
        newy = args[4]
        frame = args[5]
        town_id = args[6]
        reason = args[7] # "Unitat", "moveTo", "colisio", "MouseUsed"
        print("Move", str(get_name_from_item_id(id)), "from", f"({ix},{iy})", "to", f"({newx},{newy})")
        map = save["maps"][town_id]
        for item in map["items"]:
            if item[0] == id and item[1] == ix and item[2] == iy:
                item[1] = newx
                item[2] = newy
                break
    
    elif cmd == Constant.CMD_COLLECT:
        x = args[0]
        y = args[1]
        town_id = args[2]
        id = args[3]
        # Buildings send 7 args; resources (trees, stones...) and social feeds only the first 4
        num_units_contained_when_harvested = args[4] if len(args) > 4 else 0 #TODO does this affect multiplier?
        resource_multiplier = args[5] if len(args) > 5 else 1
        cash_to_substract = args[6] if len(args) > 6 else 0
        print("Collect", str(get_name_from_item_id(id)))
        map = save["maps"][town_id]
        apply_collect(save["playerInfo"], map, id, resource_multiplier)
        save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - cash_to_substract, 0)
    
    elif cmd == Constant.CMD_SELL:
        x = args[0]
        y = args[1]
        id = args[2]
        town_id = args[3]
        bool_dont_modify_resources = args[4]
        reason = args[5]
        print("Remove", str(get_name_from_item_id(id)), "from", f"({x},{y}). Reason: {reason}")
        map = save["maps"][town_id]
        for item in map["items"]:
            if item[0] == id and item[1] == x and item[2] == y:
                map["items"].remove(item)
                break
        if not bool_dont_modify_resources:
            price_multiplier = -0.05
            if get_attribute_from_item_id(id, "cost_type") != "c":
                apply_cost(save["playerInfo"], save["maps"][town_id], id, price_multiplier)
        if reason == 'KILL':
            pass # TODO : add to graveyard
    
    elif cmd == Constant.CMD_KILL:
        x = args[0]
        y = args[1]
        id = args[2]
        town_id = args[3]
        type = args[4]
        print("Kill", str(get_name_from_item_id(id)), "from", f"({x},{y}).")
        map = save["maps"][town_id]
        for item in map["items"]:
            if item[0] == id and item[1] == x and item[2] == y:
                apply_collect_xp(map, id)
                map["items"].remove(item)
                break
    
    elif cmd == Constant.CMD_COMPLETE_MISSION:
        mission_id = args[0]
        skipped_with_cash = len(args) > 1 and bool(args[1]) # the admin panel sends only the id
        print("Complete mission", mission_id, ":", str(get_attribute_from_mission_id(mission_id, "title")))
        if skipped_with_cash:
            cash_to_substract = int(get_game_config()["globals"]["PRICE_COMPLETE_GOAL"])
            save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - cash_to_substract, 0)
        if mission_id not in save["privateState"]["completedMissions"]:
            save["privateState"]["completedMissions"] += [mission_id]
    
    elif cmd == Constant.CMD_REWARD_MISSION:
        town_id = args[0]
        mission_id = args[1]
        print("Reward mission", mission_id, ":", str(get_attribute_from_mission_id(mission_id, "title")))
        if mission_id in save["privateState"]["rewardedMissions"]:
            return
        reward = int(get_attribute_from_mission_id(mission_id, "reward") or 0) # gold
        save["maps"][town_id]["coins"] += reward
        save["privateState"]["rewardedMissions"] += [mission_id]
    
    elif cmd == Constant.CMD_PUSH_UNIT:
        unit_x = args[0]
        unit_y = args[1]
        unit_id = args[2]
        b_x = args[3]
        b_y = args[4]
        town_id = args[5]
        print("Push", str(get_name_from_item_id(unit_id)), "to", f"({b_x},{b_y}).")
        map = save["maps"][town_id]
        # Unit into building
        for item in map["items"]:
            if item[1] == b_x and item[2] == b_y:
                if len(item) < 7:
                    item += [[]]
                item[6] += [unit_id]
                break
        # Remove unit
        for item in map["items"]:
            if item[0] == unit_id and item[1] == unit_x and item[2] == unit_y:
                map["items"].remove(item)
                break
    
    elif cmd == Constant.CMD_POP_UNIT:
        b_x = args[0]
        b_y = args[1]
        town_id = args[2]
        unit_id = args[3]
        place_popped_unit = len(args) > 4
        if place_popped_unit:
            unit_x = args[4]
            unit_y = args[5]
            unit_frame = args[6] # unknown use
        print("Pop", str(get_name_from_item_id(unit_id)), "from", f"({b_x},{b_y}).")
        map = save["maps"][town_id]
        # Remove unit from building
        for item in map["items"]:
            if item[1] == b_x and item[2] == b_y:
                if len(item) < 7 or unit_id not in item[6]:
                    break
                item[6].remove(unit_id)
                break
        if place_popped_unit:
            # Spawn unit outside
            collected_at_timestamp = timestamp_now()
            level = 0 # TODO 
            orientation = 0
            map["items"] += [[unit_id, unit_x, unit_y, orientation, collected_at_timestamp, level]]
    
    elif cmd == Constant.CMD_RT_LEVEL_UP:
        new_level = args[0]
        print("Level Up!:", new_level)
        map = save["maps"][0] # TODO : xp must be general, since theres no given town_id
        map["level"] = args[0]
        current_xp = map["xp"]
        min_expected_xp = get_xp_from_level(max(0, new_level - 1))
        map["xp"] = max(min_expected_xp, current_xp) # try to fix problems with not counting XP... by keeping up with client-side level counting
        # Mana reward, as MagicManager.onLevelUp
        globals = get_game_config()["globals"]
        if new_level >= int(globals["START_LEVEL_MANA_REWARD"]):
            save["privateState"]["mana"] = save["privateState"].get("mana", 0) + int(globals["MANA_REWARD_PER_LEVEL"])

    elif cmd == Constant.CMD_RT_PUBLISH_SCORE:
        new_xp = args[0]
        print("xp set to", new_xp)
        map = save["maps"][0] # TODO : xp must be general, since theres no given town_id
        map["xp"] = new_xp
        map["level"] = get_level_from_xp(new_xp)

    elif cmd == Constant.CMD_EXPAND:
        land_id = args[0]
        resource = args[1]
        town_id = int(args[2])
        print("Expansion", land_id, "purchased")
        map = save["maps"][town_id]
        if land_id in map["expansions"]:
            return
        # Substract resources
        expansion_prices = get_game_config()["expansion_prices"]
        exp = expansion_prices[len(map["expansions"]) - 1]
        if resource == "gold":
            to_substract = exp["coins"]
            save["maps"][town_id]["coins"] = max(save["maps"][town_id]["coins"] - to_substract, 0)
        elif resource == "cash":
            to_substract = exp["cash"]
            save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - to_substract, 0)
        # Add expansion
        map["expansions"].append(land_id)

    elif cmd == Constant.CMD_NAME_MAP:
        town_id =int(args[0])
        new_name = args[1]
        print(f"Map name changed to '{new_name}'.")
        save["playerInfo"]["map_names"][town_id] = new_name

    elif cmd == Constant.CMD_EXCHANGE_CASH:
        town_id = args[0]
        print("Exchange cash -> coins.")
        save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - 5, 0)#maybe make function for editing resources
        save["maps"][town_id]["coins"] += 2500

    elif cmd == Constant.CMD_STORE_ITEM or cmd == Constant.CMD_STORE_ITEM_FROMBUG:
        x = args[0]
        y = args[1]
        town_id = int(args[2])
        item_id = args[3]
        print("Store", str(get_name_from_item_id(item_id)), "from", f"({x},{y})")
        map = save["maps"][town_id]
        for item in map["items"]:
            if item[0] == item_id and item[1] == x and item[2] == y:
                map["items"].remove(item)
                break
        add_to_store(map, item_id)

    elif cmd == Constant.CMD_STORE_ADD_ITEMS:
        item_ids = json.loads(args[0])
        print("Store", ", ".join(str(get_name_from_item_id(i)) for i in item_ids))
        map = save["maps"][0] # no town given; the client only loads the storage of the first town
        for item_id in item_ids:
            add_to_store(map, int(item_id))

    elif cmd == Constant.CMD_PLACE_STORED_ITEM:
        item_id = args[0]
        x = args[1]
        y = args[2]
        frame = args[3]
        town_id = args[4]
        print("Add stored", str(get_name_from_item_id(item_id)), "at", f"({x},{y})")
        map = save["maps"][town_id]
        if not take_from_store(save, map, item_id):
            print("   > not in storage")
        map["items"] += [[item_id, x, y, frame, timestamp_now(), 0]]

    elif cmd == Constant.CMD_SELL_STORED:
        item_id = args[0]
        town_id = args[1]
        print("Sell stored", str(get_name_from_item_id(item_id)))
        map = save["maps"][town_id]
        if not take_from_store(save, map, item_id):
            print("   > not in storage")
            return
        # Same refund as GiftButtonLarge.sellGift: 5%, nothing for cash items
        if get_attribute_from_item_id(item_id, "cost_type") != "c" and item_id not in (Constant.ID_BUILDING_ZEPPELIN_TOWER, Constant.ID_BUILDING_DOCK):
            apply_cost(save["playerInfo"], map, item_id, -0.05)

    elif cmd == Constant.CMD_PLACE_GIFT:
        item_id = args[0]
        x = args[1]
        y = args[2]
        frame = args[3]
        town_id = args[4]
        print("Add", str(get_name_from_item_id(item_id)), "at", f"({x},{y})")
        map = save["maps"][town_id]
        collected_at_timestamp = timestamp_now()
        level = 0
        map["items"] += [[item_id, x, y, frame, collected_at_timestamp, level]]#maybe make function for adding items
        # Placing a gift gives its xp; the level up statue gives what is left to level up
        if item_id == Constant.ID_BUILDING_LEVELUP_STATUE:
            map["xp"] = max(map["xp"], get_xp_from_level(get_level_from_xp(map["xp"])))
        else:
            map["xp"] += int(get_attribute_from_item_id(item_id, "xp"))
        save["privateState"]["gifts"][item_id] -= 1
        if save["privateState"]["gifts"][item_id] == 0: #removes excess zeros at end if necessary
            while(len(save["privateState"]["gifts"]) != 0 and save["privateState"]["gifts"][-1] == 0):
                save["privateState"]["gifts"].pop()  

    elif cmd == Constant.CMD_SELL_GIFT:
        item_id = args[0]
        town_id = args[1]
        print("Gift", str(get_name_from_item_id(item_id)), "sold on town:",town_id)
        gifts = save["privateState"]["gifts"]
        gifts[item_id] -= 1
        if gifts[item_id] == 0: #removes excess zeros at end if necessary
            while(len(gifts) != 0 and gifts[-1] == 0):
                gifts.pop()
        price_multiplier = -0.05
        if get_attribute_from_item_id(item_id, "cost_type") != "c":
            apply_cost(save["playerInfo"], save["maps"][town_id], item_id, price_multiplier)
    
    elif cmd == Constant.CMD_ACTIVATE_DRAGON:
        currency = args[0]
        print("Dragon nest activated.")
        if currency == 'c':
            save["playerInfo"]["cash"] = max(int(save["playerInfo"]["cash"] - 50), 0)
        elif currency == 'g':
            map = save["maps"]
            map[0]["coins"] = max(int(map[0]["coins"] - 100000), 0)
        save["privateState"]["dragonNestActive"] = 1
        save["privateState"]["timeStampTakeCare"] = -1 # remove timer if any
    
    elif cmd == Constant.CMD_DESACTIVATE_DRAGON:
        print("Dragon nest deactivated.")
        pState = save["privateState"]
        pState["dragonNestActive"] = 0
        # reset step and dragon numbers
        pState["stepNumber"] = 0
        pState["dragonNumber"] = 0
        pState["timeStampTakeCare"] = -1 # remove timer if any

    elif cmd == Constant.CMD_NEXT_DRAGON_STEP:
        unknown = args[0]
        print("Dragon step increased.")
        pState = save["privateState"]
        pState["stepNumber"] += 1
        pState["timeStampTakeCare"] = timestamp_now()

    elif cmd == Constant.CMD_NEXT_DRAGON:
        print("Dragon step reset and dragonNumber increased.")
        pState = save["privateState"]
        pState["stepNumber"] = 0
        pState["dragonNumber"] += 1
        pState["timeStampTakeCare"] = -1 # remove timer

    elif cmd == Constant.CMD_DRAGON_BUY_STEP_CASH:
        price = args[0]
        print("Buy dragon step with cash.")
        save["playerInfo"]["cash"] = max(int(save["playerInfo"]["cash"] - price), 0)
        save["privateState"]["timeStampTakeCare"] = -1 # remove timer

    elif cmd == Constant.CMD_RIDER_BUY_STEP_CASH:
        price = args[0]
        print("Buy rider step with cash.")
        save["playerInfo"]["cash"] = max(int(save["playerInfo"]["cash"] - price), 0)
        save["privateState"]["riderTimeStamp"] = -1 # remove timer

    elif cmd == Constant.CMD_NEXT_RIDER_STEP:
        print("Rider step increased.")
        pState = save["privateState"]
        pState["riderStepNumber"] += 1
        pState["riderTimeStamp"] = timestamp_now()
    
    elif cmd == Constant.CMD_SELECT_RIDER:
        number = int(args[0])
        pState = save["privateState"]
        if number == 1 or number == 2 or number == 3:
            pState["riderNumber"] = number
            print("Rider", number, "Selected.")
        else:
            pState["riderNumber"] = 0
            pState["riderStepNumber"] = 0
            pState["riderTimeStamp"] = -1 # remove timer
            print("Rider reset.")
    
    elif cmd == Constant.CMD_ORIENT:
        x = args[0]
        y = args[1]
        new_orientation = args[2]
        town_id = args[3]
        print("Item at", f"({x},{y})", "changed to orientation", new_orientation)
        map = save["maps"][town_id]
        for item in map["items"]:
            if item[1] == x and item[2] == y:
                item[3] = new_orientation
                break
    
    elif cmd == Constant.CMD_MONSTER_BUY_STEP_CASH:
        price = args[0]
        print("Buy monster step with cash.")
        save["playerInfo"]["cash"] = max(int(save["playerInfo"]["cash"] - price), 0)
        save["privateState"]["timeStampTakeCareMonster"] = -1 # remove timer
    
    elif cmd == Constant.CMD_ACTIVATE_MONSTER:
        currency = args[0]
        print("Monster nest activated.")
        if currency == 'c':
            save["playerInfo"]["cash"] = max(int(save["playerInfo"]["cash"] - 50), 0)
        elif currency == 'g':
            map = save["maps"]
            map[0]["coins"] = max(int(map[0]["coins"] - 100000), 0)
        save["privateState"]["monsterNestActive"] = 1
        save["privateState"]["timeStampTakeCareMonster"] = -1 # remove timer if any
    
    elif cmd == Constant.CMD_DESACTIVATE_MONSTER: # cmd called too late
        print("Monster nest deactivated.")
        pState = save["privateState"]
        pState["monsterNestActive"] = 0
        pState["stepMonsterNumber"] = 0
        pState["MonsterNumber"] = 0
        pState["timeStampTakeCareMonster"] = -1 # remove timer if any


    elif cmd == Constant.CMD_NEXT_MONSTER_STEP:
        print("Monster Step increased.")
        pState = save["privateState"]
        pState["stepMonsterNumber"] += 1
        pState["timeStampTakeCareMonster"] = timestamp_now()

    elif cmd == Constant.CMD_NEXT_MONSTER:
        print("Monster Step reset and Monster Number increased.")
        pState = save["privateState"]
        pState["stepMonsterNumber"] = 0
        pState["monsterNumber"] += 1
        pState["timeStampTakeCareMonster"] = -1 # remove timer

    elif cmd == Constant.CMD_WIN_BONUS:
        coins = args[0]
        town_id = args[1]
        hero = args[2]
        claimId = args[3]
        cash = args[4]

        print("Claiming Win Bonus")
        map = save["maps"][town_id]

        if cash != 0:
            save["playerInfo"]["cash"] = save["playerInfo"]["cash"] + cash
            print("Added " + str(cash) + " Cash to players balance")

        if coins != 0:
            map["coins"] = map["coins"] + coins
            print("Added " + str(coins) + " Gold to players balance")

        if hero != 0:
            length = len(save["privateState"]["gifts"])
            if length <= hero:
                for i in range(hero - length + 1):
                    save["privateState"]["gifts"].append(0)
            save["privateState"]["gifts"][hero] += 1
            print("Added Hero ID=" + str(hero))

        pState = save["privateState"]
        pState["bonusNextId"] = claimId + 1
        pState["timestampLastBonus"] = timestamp_now()

    elif cmd == Constant.CMD_ADMIN_ADD_ANIMAL:
        subcatFunc = str(args[0])
        toBeAdded = int(args[1])
        print("Added", toBeAdded, get_item_from_subcat_functional(subcatFunc)["name"])

        # TODO
        oAnimals: dict = save["privateState"]["arrayAnimals"]
        oAnimals[subcatFunc] = toBeAdded + (oAnimals[subcatFunc] if subcatFunc in oAnimals else 0)
    
    elif cmd == Constant.CMD_GRAVEYARD_BUY_POTIONS:
        # no args
        print("Graveyard buy potion")
        # info from config
        graveyard_potions = get_game_config()["globals"]["GRAVEYARD_POTIONS"]
        amount = graveyard_potions["amount"]
        price_cash = graveyard_potions["price"]["c"]
        # pay
        save["playerInfo"]["cash"] = max(int(save["playerInfo"]["cash"] - price_cash), 0)
        # add potion
        save["privateState"]["potion"] += amount

    elif cmd == Constant.CMD_RESURRECT_HERO:
        unit_id = args[0]
        x = args[1]
        y = args[2]
        town_id = args[3]
        bool_used_potion = len(args) > 4 and args[4] == '1'
        print("Resurrect", str(get_name_from_item_id(unit_id)), "from graveyard")
        # pay
        if bool_used_potion:
            quantity = 1
            save["privateState"]["potion"] = max(int(save["privateState"]["potion"] - quantity), 0)
        else:
            pass # TODO 
        # Place unit
        collected_at_timestamp = timestamp_now()
        level = 0 # TODO 
        orientation = 0
        save["maps"][town_id]["items"] += [[unit_id, x, y, orientation, collected_at_timestamp, level]]

    elif cmd == Constant.CMD_BUY_SUPER_OFFER_PACK:
        town_id = args[0]
        pack_id = args[1]
        items = args[2]
        cash_used = args[3]
        
        map = save["maps"][town_id]

        # The client puts the prizes in its storage (not gifts) and adds the pack resources, without xp
        for item in items.split(','):
            add_to_store(map, int(item))
            add_bought_unit(save, int(item))
        pack = get_offer_pack(pack_id)
        if pack:
            give_pack_resources(save, map, pack, with_xp=False)

        save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - cash_used, 0)#maybe make function for editing resources
        print(f"Used {cash_used} cash to buy super offer pack!")

    elif cmd == Constant.CMD_BUY_OFFER_PACK:
        town_id = args[0]
        pack_id = args[1]
        random_item = args[2] if len(args) > 2 else None # random packs send the item that came out
        pack = get_offer_pack(pack_id)
        print("Buy offer pack", pack_id)
        map = save["maps"][town_id]
        save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - int(pack["cost_cash"]), 0)
        give_pack_resources(save, map, pack, with_xp=True)
        items = [random_item] if random_item is not None else (pack.get("items") or [])
        for item_id in items:
            add_to_store(map, int(item_id))
            add_bought_unit(save, int(item_id))

    elif cmd == Constant.CMD_BUY_MANA:
        town_id = args[0]
        with_cash = args[1] == 1
        globals = get_game_config()["globals"]
        print("Buy mana", "with cash" if with_cash else "with gold")
        if with_cash:
            save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - int(globals["COST_MANA_CASH"]), 0)
        else:
            save["maps"][town_id]["coins"] = max(save["maps"][town_id]["coins"] - int(globals["COST_MANA_GOLD"]), 0)
        save["privateState"]["mana"] = save["privateState"].get("mana", 0) + int(globals["MANA_PER_PURCHASE"])

    elif cmd == Constant.CMD_COLLECT_TREASURE:
        # Chapter (quest in map) finished: rewards and the next chapter
        gold, xp, next_chapter, food, stone, town_id = args[:6]
        print("Chapter finished, next chapter", next_chapter)
        map = save["maps"][town_id]
        map["coins"] += gold
        map["xp"] += xp
        map["food"] += food
        map["stone"] += stone
        map["idCurrentTreasure"] = next_chapter
        if gold or xp:
            map["timestampLastTreasure"] = timestamp_now() # countdown to the next chapter
        # MapInitializer sends 0 rewards when it only skips a chapter that does not apply

    elif cmd == Constant.CMD_SET_QUEST_VAR:
        # Progress inside the current chapter (spawned, activators, boss, treasure)
        town_id, key, value = args[:3]
        save["maps"][town_id].setdefault("currentQuestVars", {})[key] = json.loads(value)
        print("Chapter state", key, "=", value)

    elif cmd == Constant.CMD_ADD_UNIT_WAREHOUSE:
        x, y, town_id, unit_id = args[:4]
        print("Unit", str(get_name_from_item_id(unit_id)), "to the warehouse")
        map = save["maps"][town_id]
        for item in map["items"]:
            if item[0] == unit_id and item[1] == x and item[2] == y:
                map["items"].remove(item)
                break
        else:
            remove_units(map, unit_id, 1) # position not up to date
        # map.warehousedUnits: {"unit_id": count}
        warehoused = map.setdefault("warehousedUnits", {})
        warehoused[str(unit_id)] = warehoused.get(str(unit_id), 0) + 1

    elif cmd == Constant.CMD_PLACE_WAREHOUSED_ITEM:
        unit_id, x, y, frame, town_id = args[:5]
        print("Unit", str(get_name_from_item_id(unit_id)), "out of the warehouse")
        map = save["maps"][town_id]
        warehoused = map.setdefault("warehousedUnits", {})
        if warehoused.get(str(unit_id), 0) > 0:
            warehoused[str(unit_id)] -= 1
            if warehoused[str(unit_id)] == 0:
                del warehoused[str(unit_id)]
        map["items"] += [[unit_id, x, y, frame, timestamp_now(), 0]]

    elif cmd == Constant.CMD_BUY_WAREHOUSE_CAPACITY_NEW:
        town_id = args[0]
        price = int(get_game_config()["globals"]["WAREHOUSE_CAPACITY_INCREASE_PRICE_SINGLE"])
        map = save["maps"][town_id]
        map["warehouseAditionalCapacitySingle"] = int(map.get("warehouseAditionalCapacitySingle", 0)) + 1
        save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - price, 0)
        print("Warehouse slots:", map["warehouseAditionalCapacitySingle"])

    elif cmd == Constant.CMD_RESET_WAREHOUSE:
        # The warehouse was stored: its units go to the storage, the bought slots stay
        town_id = args[0]
        map = save["maps"][town_id]
        for unit_id, count in map.get("warehousedUnits", {}).items():
            add_to_store(map, int(unit_id), int(count))
        map["warehousedUnits"] = {}
        print("Warehouse emptied into storage")

    elif cmd == Constant.CMD_SET_STRATEGY:
        strategy_type = args[0]
        type_name = get_strategy_type(strategy_type)
        save["privateState"]["strategy"] = strategy_type
        print(f"Set defense strategy type to {type_name}")

    elif cmd == Constant.CMD_START_QUEST:
        quest_id = args[0]
        town_id = args[1]
        print(f"Start quest {quest_id}")

    elif cmd == Constant.CMD_END_QUEST:
        data = json.loads(args[0])
        town_id = data["map"]
        gold_gained = data["resources"]["g"]
        xp_gained = data["resources"]["x"]
        units = data["units"]
        win = data["win"] == 1
        duration_sec = data["duration"]
        voluntary_end = data["voluntary_end"] == 1
        quest_id = int(data["quest_id"])
        item_rewards = data["item_rewards"] if "item_rewards" in data else None
        activators_left = data["activators_left"] if "activators_left" in data else None
        difficulty = data["difficulty"]

        # Resources
        save["maps"][town_id]["coins"] += int(gold_gained)
        save["maps"][town_id]["xp"] += int(xp_gained)

        # Update quests data
        # Stars: the highest difficulty won. The next island in ISLE_ORDER is unlocked.
        pState = save["privateState"]
        if win:
            ranks = pState.get("questsRank")
            if not isinstance(ranks, dict):
                ranks = pState["questsRank"] = {}
            ranks[str(quest_id)] = max(int(ranks.get(str(quest_id), 0)), int(difficulty))
            isle_order = [str(i) for i in get_game_config()["globals"]["ISLE_ORDER"]]
            if str(quest_id) in isle_order:
                pState["unlockedQuestIndex"] = max(isle_order.index(str(quest_id)) + 1, int(pState.get("unlockedQuestIndex", 0)))
        # save["maps"]["questTimes"] [quest_id] = TODO min (... , duration_sec)
        # save["maps"]["lastQuestTimes"] [quest_id] = TODO min (... , duration_sec)

        print(f"Ended quest {quest_id}.")

    elif cmd == Constant.CMD_BUY_STORED_ITEM_CASH:
        town_id = args[0]
        item_id = args[1]
        price = int(args[2])
        print("Buy", str(get_name_from_item_id(item_id)), "for", price, "cash, to storage")
        save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - price, 0)
        add_to_store(save["maps"][town_id], item_id)
        add_bought_unit(save, item_id) # counts for its unit collection

    elif cmd == Constant.CMD_UNIT_COLLECTION_COMPLETED:
        category_id = int(args[0])
        pState = save["privateState"]
        completed = pState.setdefault("unitCollectionsCompleted", [])
        if category_id in completed:
            return
        completed.append(category_id)
        category = get_game_config()["units_collections_categories"].get(str(category_id))
        print("Unit collection", category_id, "completed")
        # The client shows the reward unit and adds 1 cash (PopupAllUnits.getCollectionReward)
        save["playerInfo"]["cash"] += 1
        if category and category.get("rewards"):
            add_to_store(save["maps"][0], int(category["rewards"]))
            add_bought_unit(save, int(category["rewards"]))

    elif cmd == Constant.CMD_ADD_COLLECTABLE:
        collection_id = args[0]
        collectible_id = args[1]
        # TODO 

    elif cmd == Constant.CMD_BUY_MAGIC:
        magic_id = args[0]
        town_id = args[1]
        with_cash = args[2] == 1
        magic = get_magic(magic_id)
        print("Learn spell", magic["name"], "with cash" if with_cash else "with gold")
        if with_cash:
            save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - int(magic["cash"]), 0)
        else:
            save["maps"][town_id]["coins"] = max(save["maps"][town_id]["coins"] - int(magic["gold"]), 0)
        # Learning a spell also fills the mana it costs (SelectedMagic.updateMagicEntry)
        pState = save["privateState"]
        pState["mana"] = pState.get("mana", 0) + int(magic["mana"])
        pState["magics"].setdefault(str(magic_id), 0)

    elif cmd == Constant.CMD_USE_MAGIC:
        magic_id = args[0]
        magic = get_magic(magic_id)
        print("Cast spell", magic["name"])
        pState = save["privateState"]
        pState["mana"] = max(pState.get("mana", 0) - int(magic["mana"]), 0)
        pState["magics"][str(magic_id)] = pState["magics"].get(str(magic_id), 0) + 1 # uses

    elif cmd == Constant.CMD_ATTACK_PLAYER:
        victim_id = str(args[0])
        print("Attack player", victim_id)
        pState = save["privateState"]
        pState.setdefault("attacksSent", []).append({"victim_id": victim_id, "time": timestamp_now()})
        if pState.get("attacksPack", 0) > 0:
            pState["attacksPack"] -= 1

    elif cmd == Constant.CMD_END_ATTACK:
        data = json.loads(args[0])
        town_id = int(data["attacker"]["map"])
        win = data["win"] == 1
        map = save["maps"][town_id]
        map["coins"] += int(data["resources"]["g"])
        map["xp"] += int(data["resources"]["x"])
        # attacker_units: [unit_id, sent, killed, recovered]; killed units that were not recovered are lost
        lost = 0
        for unit in data["attacker_units"]:
            lost += remove_units(map, int(unit[0]), int(unit[2]) - int(unit[3]))
        # Conquered island on the continent
        position = data["victim"].get("posicion") if isinstance(data["victim"], dict) else None
        if win and position is not None and position not in map["universAttackWin"]:
            map["universAttackWin"].append(position)
        print("Attack", "won" if win else "lost", "- gold:", data["resources"]["g"], "xp:", data["resources"]["x"], "units lost:", lost)

    elif cmd == Constant.CMD_SURVIVAL_START:
        print("Start survival")
        # A life is a timestamp in survivalVidaTimeStamp until it regenerates; extra lives are used after the 3 regular ones
        pState = save["privateState"]
        now = timestamp_now()
        regenerate = int(get_game_config()["globals"]["SURVIVAL_HOURS_LIVE_REGENERATE"]) * 3600
        used = [int(ts) for ts in pState.get("survivalVidaTimeStamp", []) if int(ts) + regenerate > now]
        if len(used) < 3:
            used.append(now)
        elif pState.get("survivalVidasExtra", 0) > 0:
            pState["survivalVidasExtra"] -= 1
        pState["survivalVidaTimeStamp"] = used

    elif cmd == Constant.CMD_SURVIVAL_END:
        survival_map = str(args[0])
        time_survived = int(args[1])
        rewards = json.loads(args[2]) if len(args) > 2 and args[2] else {}
        print(f"End survival {survival_map}: {time_survived}s, rewards {rewards}")
        pState = save["privateState"]
        record = pState.setdefault("survivalMaps", {}).setdefault(survival_map, {"ts": 0, "tp": 0})
        record["ts"] = timestamp_now()
        record["tp"] = max(int(record["tp"]), time_survived) # best time
        for item_id, amount in rewards.items():
            add_to_store(save["maps"][0], int(item_id), int(amount))

    elif cmd == Constant.CMD_SURVIVAL_BUY_MAP:
        survival_map = str(args[0])
        price = int(args[1])
        print("Unlock survival map", survival_map)
        save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - price, 0)
        save["privateState"].setdefault("survivalMaps", {})[survival_map] = {"ts": 0, "tp": 0}

    elif cmd == Constant.CMD_SURVIVAL_BUY_LIFE:
        price = int(args[0])
        print("Buy survival life")
        save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - price, 0)
        save["privateState"]["survivalVidasExtra"] = save["privateState"].get("survivalVidasExtra", 0) + 1

    elif cmd == Constant.CMD_TRADE_RESOURCE:
        town_id = args[0]
        resource = args[1]
        sell = args[2] == 1
        amount = int(args[3])
        map = save["maps"][town_id]
        traded = map.setdefault("resourcesTraded", {})
        # Price as ButtonMarket.refreshCost
        base = MARKET_BASE_COSTS[resource] * (amount / 100)
        cost = as3_round(base + base * traded.get(resource, 0) * MARKET_INCREMENT)
        if sell:
            cost = as3_round(cost * MARKET_SELL_PERCENTAGE)
        direction = 1 if sell else -1
        map["coins"] = max(map["coins"] + direction * cost, 0)
        key = RESOURCE_KEYS[resource]
        map[key] = max(map[key] - direction * amount, 0)
        traded[resource] = min(max(-MARKET_MAX_DECREMENTS, traded.get(resource, 0) - direction), MARKET_MAX_INCREMENTS)
        # Trades per period, reset when the period is over (as the client does on load)
        now = timestamp_now()
        if now - map.get("timestampLastTrade", 0) > MARKET_PERIOD_HOURS * 3600:
            map["timestampLastTrade"] = now
            map["numTradesDone"] = 0
        map["numTradesDone"] = map.get("numTradesDone", 0) + 1
        print("Sold" if sell else "Bought", amount, key, "for", cost, "gold")

    elif cmd == Constant.CMD_DARTS_RESET:
        seed = args[0]
        print("Darts reset")
        now = timestamp_now()
        pState = save["privateState"]
        pState["timeStampDartsReset"] = now
        pState["timeStampDartsNewFree"] = now
        pState["dartsBalloonsShot"] = []
        pState["dartsRandomSeed"] = seed
        pState["dartsHasFree"] = True
        pState["dartsGotExtra"] = False

    elif cmd == Constant.CMD_DARTS_NEW_FREE:
        print("Darts free throw")
        save["privateState"]["timeStampDartsNewFree"] = timestamp_now()
        save["privateState"]["dartsHasFree"] = True

    elif cmd == Constant.CMD_DARTS_SHOOT_BALLOON:
        balloon = args[0]
        paid = args[1] == 1
        got_extra = args[2] == 1
        print("Darts balloon", balloon, "paid" if paid else "free")
        # The prizes arrive in store_add_items
        pState = save["privateState"]
        if paid:
            price = int(get_game_config()["globals"]["DART_COST_CASH"])
            save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - price, 0)
        else:
            pState["dartsHasFree"] = False
        pState["dartsBalloonsShot"].append(balloon)
        if got_extra:
            pState["dartsGotExtra"] = True

    elif cmd == Constant.CMD_BUY_MAP:
        town_id = int(args[0])
        with_cash = args[1] == 1
        race = args[2]
        from_town = int(args[3])
        print("Buy town", town_id, "race", race, "with cash" if with_cash else "with gold")
        if town_id < len(save["maps"]):
            print("   > already owned")
            return
        if with_cash:
            save["playerInfo"]["cash"] = max(save["playerInfo"]["cash"] - TOWN_PRICE_CASH, 0)
        else:
            save["maps"][from_town]["coins"] = max(save["maps"][from_town]["coins"] - TOWN_PRICE_GOLD, 0)
        save["maps"].append(new_town(save, race))
        save["playerInfo"]["map_names"].append(save["playerInfo"]["map_names"][0])
        save["privateState"]["maps"] = [{"r": town["race"]} for town in save["maps"]]

    elif cmd == Constant.CMD_SET_VARIABLES:
        gold, cash, xp, level, stone, wood, food, town_id = args[:8]
        print("Set variables (admin)")
        map = save["maps"][town_id]
        map["coins"] = gold
        save["playerInfo"]["cash"] = cash
        map["xp"] = xp
        map["level"] = level
        map["stone"] = stone
        map["wood"] = wood
        map["food"] = food

    else:
        print(f"Unhandled command '{cmd}' -> args", args)
        return
    
