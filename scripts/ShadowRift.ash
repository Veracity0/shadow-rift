since r27371;
import <vprops.ash>;

// ***************************
// *     Configuration       *
// ***************************

//-------------------------------------------------------------------------
// All of the configuration variables have default values, which apply
// to any character who does not override the variable using the
// appropriate property.
//
// You can edit the default here in the script and it will apply to all
// characters which do not override it.
//
// define_property( PROPERTY, TYPE, DEFAULT )
// define_property( PROPERTY, TYPE, DEFAULT, COLLECTION )
// define_property( PROPERTY, TYPE, DEFAULT, COLLECTION, DELIMITER )
//
// Otherwise, you can change the value for specific characters in the gCLI:
//
//     set PROPERTY=VALUE
//
// Both DEFAULT and a property VALUE will be normalized
//
// All properties used directly by this script start with "VMF."
//-------------------------------------------------------------------------

// What is our quest goal?
//
// artifact             Easiest.
//                      10 combats with normal shadow creatures; mundane shadow item
//                      non-combat offers a choice for the artifact.
// entity               Most profitable, but hardest.
//                      10 combats with normal shadow creatures
//                      non-combat replaced by shadow boss, with combat powers
//                      Each boss always drops two specific mundane shadow items
// items                10 combats with normal shadow creatures.
//                      non-combat offers buffs or stats
//                      costs 3 of a specific mundane shadow item

string quest_goal = define_property( "VSR.QuestGoal", "string", "artifact" );

// If we seek items, the Shadow Labyrinth will give us a buff or stats or extend effects.
// Which one do you want?
//
// muscle               90-100 Muscle substats
// mysticality          90-100 Mysticality substats
// moxie                90-100 Moxie substats
// mainstat             (whichever of the above corresponds to your class's mainstat)
// effects              +3 turns to 3 random effects
// maxHP                30 Shadow's Heart: Maximum HP +300%
// maxMP                30 Shadow's Chill: Maximum MP +300%
// resistance           30 Shadow's Thickness: +5 Spooky, Hot, Sleaze resistance

string labyrinth_goal = define_property( "VSR.LabyrinthGoal", "string", "effects" );

// What is our quest reward?
//
// forge                Opens Shadow Forge until you use an adventure.
//                      You can craft special shadow items from mundane shadow items.
// fountain             (or waters) 30 turns of Shadow Waters:
//                      Initiative: +100, Item Drop: +100, Meat Drop: +200, Combat Rate: -10
// forest               (Once per day) 2-3 each of the 3 mundane items from the
//                      specific ingress you used to enter the Shadow Rift

// Default is "forest" (or "waters" if already looted forest today).
string quest_reward = define_property( "VSR.QuestReward", "string", "forest" );

// Which shadow rift ingress to use?
//
// desertbeach          shadow flame    shadow fluid    shadow sinew
// forestvillage        shadow bread    shadow ice      shadow venom
// mclargehuge          shadow skin     shadow ice      shadow stick
// beanstalk            shadow fluid    shadow glass    shadow nectar
// manor3               shadow sausage  shadow flame    shadow venom
// 8bit                 shadow ice      shadow fluid    shadow glass
// pyramid              shadow sausage  shadow brick    shadow sinew
// giantcastle          shadow sausage  shadow bread    shadow fluid
// woods                shadow flame    shadow nectar   shadow stick
// hiddencity           shadow brick    shadow sinew    shadow nectar
// cemetery             shadow bread    shadow brick    shadow stick
// plains               shadow sausage  shadow skin     shadow venom
// town_right           shadow skin     shadow bread    shadow glass
//
// random               Pick one at random from the 13 possible
//
// This will be the rift we collect the reward from. If Rufus wants "items", we might
// have to pick a different one that has the specific mundane item that Rufus wants.

string rift_ingress = define_property( "VSR.RiftIngress", "string", "random" );

// Should we use only free turns? I.e., require Shadow Affinity to be
// active (or available).  If so, we will prompt for confirmation if you
// attempt a quest where you will run out of free turns.

boolean free_turns_only = define_property( "VSR.FreeTurnsOnly", "boolean", "true" ).to_boolean();

// Should we buy items to fulfill an "items" quest?

boolean buy_shadow_items = define_property( "VSR.BuyShadowItems", "boolean", "true" ).to_boolean();

// Should we use up remaining turns of Shadow Affinity after fulfilling quest?
//
// If you are questing for "items" and are buying them, quests take zero
// turns.  You might want to do that as often as you like and then
// finish up with a different quest which will use up all your free
// turns.

boolean use_up_shadow_affinity = define_property( "VSR.UseUpShadowAffinity", "boolean", "true" ).to_boolean();

// Should we use a Platinum Yendorian Express Card to extend active effects by 5 turns?
//
// We'll use it to gain 5 extra turns of Shadow Affinity - 5 additional
// free fights.  It seems like a strong choice to use the card for this
// purpose, but it is optional.
//
// If you have autoSatisfyWithStash set to true, we will do special
// shenanigans to fetch & retrieve the card from your clan stash.

boolean use_pyec = define_property( "VSR.UsePYEC", "boolean", "true" ).to_boolean();

// *** Combat Preparation

// You probably want an Item Drop familiar. Perhaps we could look at your terrarium and
// pick one, but that could be tricky. A Jumpsuited Hound Dog is a fine choice, but lacking
// such, which one? One with stats? Elemental attacks? Special drops? Perhaps, even if you
// have a Hound Dog, you'd prefer to use your (lubricated) Robortender.
//
// We'll let you specify one, or "none" to mean "whichever familiar is active".

familiar chosen_familiar = define_property( "VSR.ChosenFamiliar", "familiar", "none" ).to_familiar();

// We maximize for Item Drop. You can specify additional parameters for the maximizer expression

string extra_maximizer_parameters = define_property( "VSR.ExtraMaximizerParameters", "string", "" );

// Should we use our custome ShadowRiftConsult.ash script for combats?

boolean use_consult_script = define_property( "VSR.UseShadowRiftConsult", "boolean", "true" ).to_boolean();

// Should we equip a Space Tourist Phaser for combat?
//
// We'll always do this if you are overdrunk, but if your CCS doesn't
// want to use combat spells and/or combat items, this could be
// effective in general.

boolean use_space_tourist_phaser = define_property( "VSR.UseSpaceTouristPhaser", "boolean", "false" ).to_boolean();

// Should we equip a Jurassic Parka?
//
// This is always a strong choice, since it blocks the first attack against you,
// allowing an extra round of prep. The best Item Drop shirt currently gives +25.
//
// The parka also has a mode that gives you 5 uses of a combat skill that
// forces an NC next adventure. More NCs means more quests.
//
// none                 Do not equip a parka.
// hp                   Use kachungasaur mode, which grants Maximum HP +100
// spikes               Use spikolodon mode, which grants the combat skill
//                      It also increases Monster Level by 3 per level, max +33.
//                      That means more XP, but harder fights.
// both                 Use spikolodon mode for normal shadow monsters
//                      and kachungasaur mode for shadow bosses.

string parka_mode = define_property( "VSR.UseJurassicParka", "string", "both" );

// Should we cast Steely-Eyed Squint to double item drops from shadow monster combats?
//
// This is usable once a day and lasts for a single round. Since item
// drop in the Shadow Rift is reduced by 80%, and Shadow Affinity gives
// you 11 free fights a day, this seems like a good use for the skill,
// but it is optional.

boolean cast_steely_eyed_squint = define_property( "VSR.CastSteelyEyedSquint", "boolean", "true" ).to_boolean();

// Should we cast Bend Hell to double Elemental and Elemental Spell damage in shadow monster combats?
//
// This is usable once a day and lasts for a single round. Since shadow
// monsters have scaling elemental resistance - and the bosses can have
// too much HP for a lower-level character to handle - this seems like a
// good use for the skill, but it is optional.
//
// If you will be using Silent Treatment, which eliminates resistances,
// it is less useful.

boolean cast_bend_hell = define_property( "VSR.CastBendHell", "boolean", "true" ).to_boolean();

// ***************************
// *     Shadow Rifts        *
// ***************************

record ShadowRift {
    string ingress;	// Keyword for ingress (as saved in "shadowRiftIngress"
    location loc;	// The location-via-ingress to adventure in
    item[3] items;	// The items you can find through this ingress
};

typedef ShadowRift[int] ShadowRiftArray;
boolean contains_rift(ShadowRiftArray rifts, ShadowRift rift)
{
    foreach n, r in rifts {
	if (r.ingress == rift.ingress) {
	    return true;
	}
    }
    return false;
}

static ShadowRift[string] ingress_to_rift;
static ShadowRiftArray[item] item_to_rifts;

ShadowRift makeShadowRift(string ingress, string container, string... types)
{
    if (count(types) != 3) {
	abort("ShadowRift(" + ingress +") has " + count(types) + " items.");
    }

    location loc = to_location("Shadow Rift (" + container + ")");
    item[] items = {
	to_item("shadow " + types[0]),
	to_item("shadow " + types[1]),
	to_item("shadow " + types[2]),
    };

    ShadowRift rift = new ShadowRift(ingress, loc, items);

    // Add to maps:
    ingress_to_rift[ingress] = rift;

    // Add to map: item -> ShadowRiftArray
    foreach n, it in items {
	ShadowRiftArray array = item_to_rifts[it];
	array[count(array)] = rift;
    }

    return rift;
}

static ShadowRift[] allRifts = {
    // These are sorted by container name. Not that it matters.
    makeShadowRift("desertbeach", "Desert Beach", "flame", "fluid", "sinew"),
    makeShadowRift("forestvillage", "Forest Village", "bread", "ice", "venom"),
    makeShadowRift("mclargehuge", "Mt. McLargeHuge", "skin", "ice", "stick"),
    makeShadowRift("beanstalk", "Somewhere Over the Beanstalk", "fluid", "glass", "nectar"),
    makeShadowRift("manor3", "Spookyraven Manor Third Floor", "sausage", "flame", "venom"),
    makeShadowRift("8bit", "The 8-Bit Realm", "ice", "fluid", "glass"),
    makeShadowRift("pyramid", "The Ancient Buried Pyramid", "sausage", "brick", "sinew"),
    makeShadowRift("giantcastle", "The Castle in the Clouds in the Sky", "sausage", "bread", "fluid"),
    makeShadowRift("woods", "The Distant Woods", "flame", "nectar", "stick"),
    makeShadowRift("hiddencity", "The Hidden City", "brick", "sinew", "nectar"),
    makeShadowRift("cemetery", "The Misspelled Cemetary", "bread", "brick", "stick"),
    makeShadowRift("plains", "The Nearby Plains", "sausage", "skin", "venom"),
    makeShadowRift("town_right", "The Right Side of the Tracks", "skin", "bread", "glass"),
};

string rift_name(string ingress)
{
    if (ingress == "random") {
	return "(a random ingress)";
    }
    if (ingress_to_rift contains ingress) {
	return ingress_to_rift[ingress].loc.to_string();
    }
    // An abort is harsh, but validation should have eliminated this.
    abort("Ingress '" + ingress + "' is unknown");
    // Really, ASH?
    exit;
}

ShadowRift ingress_to_rift(string ingress)
{
    if (ingress == "random") {
	return allRifts[random(count(allRifts))];
    }
    if (ingress_to_rift contains ingress) {
	return ingress_to_rift[ingress];
    }
    // An abort is harsh, but validation should have eliminated this.
    abort("Ingress '" + ingress + "' is unknown");
    // Really, ASH?
    exit;
}

string rift_items(ShadowRift rift)
{
    return rift.items[0] + ", " + rift.items[1] + ", " + rift.items[2];
}

// ***************************
// *      Constants          *
// ***************************

static item PAY_PHONE = $item[closed-circuit pay phone];
static item SHADOW_LODESTONE = $item[Rufus's shadow lodestone];
static item DRUNKULA = $item[Drunkula's wineglass];
static item PARKA = $item[Jurassic Parka];
static item PYEC = $item[Platinum Yendorian Express Card];
static item SPACE_TOURIST_PHASER = $item[Space Tourist Phaser];
static effect SHADOW_AFFINITY = $effect[Shadow Affinity];
static location SHADOW_RIFT = $location[Shadow Rift];
static skill STEELY_EYED_SQUINT = $skill[Steely-Eyed Squint];
static skill BEND_HELL = $skill[Bend Hell];

static int[string] rufus_option = {
    "entity": 1,
    "artifact": 2,
    "items": 3,
};

static int[string] reward_option = {
    "forge": 1,
    "waters": 2,
    "forest": 3,
};

string plural_name(item it, int count) {
    return (count == 1) ? it.name : it.plural;
}

// ***************************
// *      Validation         *
// ***************************

static string_set quest_goal_options = $strings[
    artifact,
    entity,
    items
];

static string_set labyrinth_goal_options = $strings[
    muscle,
    mysticality,
    moxie,
    effects,
    maxHP,
    maxMP,
    resistance
];

static string_set quest_reward_options = $strings[
    forge,
    waters,
    forest
];

static string_set shadow_item_options = $strings[
    bread,
    brick,
    flame,
    fluid,
    glass,
    ice,
    nectar,
    sausage,
    sinew,
    skin,
    stick,
    venom,
];

static string_set parka_options = $strings[
    none,
    hp,
    spikes,
    both,
];

void validate_configuration()
{
    boolean valid = true;

    print( "Validating configuration..." );

    if ( !( quest_goal_options contains quest_goal ) ) {
	print( "VSR.QuestGoal: '" + quest_goal + "' is invalid.", "red" );
	valid = false;
    }

    if ( !( labyrinth_goal_options contains labyrinth_goal ) &&
	 ( labyrinth_goal != "mainstat" ) ) {
	print( "VSR.LabyrinthGoal: '" + labyrinth_goal + "' is invalid.", "red" );
	valid = false;
    }

    if ( !( quest_reward_options contains quest_reward ) ) {
	print( "VSR.QuestReward: '" + quest_goal + "' is invalid.", "red" );
	valid = false;
    }

    if ( ( rift_ingress != "random" ) &&
	 !( ingress_to_rift contains rift_ingress ) ) {
	print( "VSR.RiftIngress: '" + rift_ingress + "' is invalid.", "red" );
	valid = false;
    }

    if ( !( parka_options contains parka_mode ) ) {
	print( "VSR.UseJurassicParka: '" + parka_mode + "' is invalid.", "red" );
	valid = false;
    }

    // Verify we have the chosen familiar
    if ( chosen_familiar != $familiar[ none ] &&
	 !have_familiar( chosen_familiar ) ) {
	print( "VSR.ChosenFamiliar: '" + chosen_familiar + "' is unavailable.", "red" );
	valid = false;
    }

    if ( !valid ) {
	abort( "Correct those errors and try again." );
    }

    print( "All is well!" );
}

// ***************************
// *        Setup            *
// ***************************

// We can adventure if overdrunk if we have (and can equip) Drunkula's wineglass.
boolean overdrunk = my_inebriety() > inebriety_limit();
boolean have_wineglass = (available_amount(DRUNKULA) > 0 && can_equip(DRUNKULA));
if (overdrunk) {
    // Drunkula's wineglass disallows combat skills, spells, and items,
    // forcing you to attack. This weapon converts physical attacks to
    // elemental, bypassing shadow monster 100% physical resistance.
    use_space_tourist_phaser = true;
}

// We can equip a Jurassic Parka only if we actually own one.
boolean have_parka = (available_amount(PARKA) > 0 && can_equip(PARKA));
if (!have_parka) {
    parka_mode = "none";
}

void print_help()
{
    print();
    print("ShadowRift KEYWORD [KEYWORD]...");
    print();
    print("KEYWORD can be a command:");
    print("help - print this message");
    print("check - visit Rufus and see what he is looking for.");
    print();
    print("KEYWORD can override configuration properties:");
    print();
    print("What kind of quest to accept (VSR.QuestGoal):");
    print("artifact, entity, items");
    print();
    print("What reward to get at the Labyrinth of Shadows (VSR.LabyrinthGoal - 'items' only)");
    print("muscle, mysticality, moxie, (mainstat), effects, maxHP, maxMP, resistance");
    print();
    print("What reward to get with your shadow lodestone (VSR.QuestReward)");
    print("forge, fountain (or waters), forest (once per day; chooses waters subsequently)");
    print();
    print("Which shadow rift ingress to use for getting the quest reward (VSR.RiftIngress)");
    print("(also used for adventuring, except for 'items', if it doesn't have what Rufus wants)");
    print("desertbeach, forestvillage, mclargehuge, beanstalk, manor3, 8bit");
    print("pyramid, giantcastle, woods, hiddencity, cemetery, plains, town_right");
    print();
    print("random - pick an ingress at random. For 'items', one which has what Rufus wants.");
    print();
    print("What kind of shadow item you want to harvest.");
    print("(randomly selects one of the 3-4 ingresses that provide that item.)");
    print("bread, brick, flame, fluid, glass, ice");
    print("nectar, sausage, sinew, skin, stick, venom");
    print();
    print("Use free turns (Shadow Affinity) only? (VSR.FreeTurnsOnly)");
    print("(If not and you attempt it, you'll get a nag to confirm.");
    print("onlyfree, notonlyfree");
    print();
    print("Buy shadow items to full Rufus's needs for an 'items' quest? (VSR.BuyShadowItems)");
    print("(This will let you finish the quest with no turns spent.)");
    print("buy, nobuy");
    print();
    print("Use up Shadow Affinity if fulfill quest with turns available? (VSR.UseUpShadowAffinity)");
    print("allfree, notallfree");
}

// Forward reference
void call_rufus();

string print_current_rufus_quest()
{
    string type = get_property("rufusQuestType");
    string verb = "";
    string target = get_property("rufusQuestTarget");
    switch (type) {
    case "artifact":
	verb = "get a ";
	break;
    case "entity":
	verb = "fight a ";
	break;
    case "items":
	verb = "get 3 ";
	target = target.to_item().plural;
	break;
    }
    print("You are on an '" + type + "' quest to " + verb + target + " for Rufus");
    return type;
}

void check_rufus()
{
    switch (get_property("questRufus")) {
    case "unstarted":
	print("You are not currently on a quest for Rufus.");
	call_rufus();	// Call him
	run_choice(6);	// Hang up on him
	print("He'd like you to fight a " + get_property("rufusDesiredEntity"));
	print("He'd like you to retrieve a " + get_property("rufusDesiredArtifact"));
	print("He'd like you to fetch 3 " + get_property("rufusDesiredItems").to_item().plural);
	return;
    case "started":
	print_current_rufus_quest();
	return;
    case "step1":
	print_current_rufus_quest();
	print("You are ready to call him back and turn it in!");
	return;
    }
}

void parse_parameters(string... parameters)
{
    print();
    print( "Checking arguments...." );

    // Parameters are optional. Depending on how the script is invoked,
    // there may be a single string with space-separated keywords, or
    // multiple strings. Whichever, turn into an array of keywords.
    string[] params = parameters.join_strings(" ").split_string(" ");

    boolean valid = true;
    foreach n, keyword in params {
	// Commands
	switch (keyword) {
	case "help":
	    print_help();
	    exit;
	case "check":
	    check_rufus();
	    exit;
	}

	// Keywords that match values of configuration properties
	if (quest_goal_options contains keyword) {
	    quest_goal = keyword;
	    continue;
	}
	if (quest_reward_options contains keyword) {
	    quest_reward = keyword;
	    continue;
	}
	if (ingress_to_rift contains keyword) {
	    rift_ingress = keyword;
	    continue;
	}
	if (labyrinth_goal_options contains keyword) {
	    labyrinth_goal = keyword;
	    continue;
	}

	// Keywords that match an item are like "random",
	// selected from the rifts that supply that item.
	if (shadow_item_options contains keyword) {
	    item it = to_item("shadow " + keyword);
	    ShadowRiftArray rifts = item_to_rifts[it];
	    ShadowRift rift = rifts[random(count(rifts))];
	    rift_ingress = rift.ingress;
	    print("We'll look for " + it.plural + " in " + rift.loc.to_string() + ".");
	    continue;
	}

	// Keywords that alter configuration properties, but are not
	// exact matches. For example, keywords corresponding to "true"
	// or "false" for boolean properties.
	switch (keyword) {
	case "shadow":
	    // So you can use "shadow brick". Ignore.
	    continue;
	case "random":
	    rift_ingress = keyword;
	    continue;
	case "mainstat":
	    labyrinth_goal = my_primestat().to_string().to_lower_case();
	    print("You want " + labyrinth_goal + " substats from the Labyrinth of Shadows.");
	    continue;
	case "fountain":
	    quest_reward = "waters";
	    continue;
	case "onlyfree":
	    free_turns_only = true;
	    continue;
	case "notonlyfree":
	    free_turns_only = false;
	    continue;
	case "buy":
	    buy_shadow_items = true;
	    continue;
	case "nobuy":
	    buy_shadow_items = false;
	    continue;
	case "allfree":
	    use_up_shadow_affinity = true;
	    continue;
	case "notallfree":
	    use_up_shadow_affinity = false;
	    continue;
	}

	print("Unrecognized keyword: " + keyword, "red");
	valid = false;
    }

    if (!valid) {
	abort("Try 'ShadowRift help' to learn command syntax.");
    }

    print( "Cool, cool." );
}

int get_quest_turns()
{
    // It normally takes 10 turns of affinity to complete a quest:
    // 10 shadow monster combats (each burning affinity)
    // artifact: Shadow Labyrinth (no turns, no affinity)
    // entity: shadow boss (no turns, burns 1 affinity)
    //
    // Since the labyring or boss are both free, we can visit them
    // even if affinity had just run out.
    int turns = 10;

    // If we are using spikes, a quest requires 1 turn:
    // 1 shadow monster combat (burning affinity)
    // labyrinth or boss (no turns, burning 0 or 1 affinity)
    if ( (parka_mode == "spikes" || parka_mode == "both") &&
	 get_property("_spikolodonSpikeUses").to_int() < 5) {
	turns = 1;
    }

    return turns;
}

int turns_until_nc()
{
    // How many turns to complete a quest?
    int turns_for_quest = get_quest_turns();

    // How soon will the labyrinth or boss appear? (If you burned
    // affinity yesterday, you effectively started the quest then.)
    int turns_until_choice = get_property("encountersUntilSRChoice").to_int();

    return min(turns_for_quest, turns_until_choice);
}

boolean confirmed_free_adventures()
{
    // If don't care if turns are free, ok
    if (!free_turns_only) {
	return true;
    }

    // If Rufus's quest is ready to turn in, no turns are needed
    if (get_property("questRufus") == "step1") {
	return true;
    }

    // If we are willing to buy items for Rufus, no turns are neded
    if (quest_goal == "items" && buy_shadow_items) {
	return true;
    }

    // If we haven't gotten Shadow Affinity today, accepting a quest gives
    // us 11 free turns, which is enough for an artifact or entity quest.
    //
    // Caveat: we cannot predict how long adventuring for items will take.
    // Hope for the best.
    if (!get_property("_shadowAffinityToday").to_boolean()) {
	return true;
    }

    // We already got Shadow Affinity today and we will be adventuring.

    // How many turns of affinity are needed to get to the next NC?
    int needed = turns_until_nc();

    // Do we have any left?
    int affinity_turns = have_effect(SHADOW_AFFINITY);

    // A shadow boss and the Labyrinth of Shadows are both free turns,
    // hence ">=" rather than ">"
    if (affinity_turns >= needed) {
	return true;
    }

    string message =
	"You have " + affinity_turns + " of Shadow Affinity (and can't get any more today). " +
	"The labyrinth or shadow boss will arrive in " + needed + " turns. " +
	"Are you sure you want to use non-free turns to fulfill a quest for Rufus?";
    return user_confirm(message);
}

// Forward reference
void collect_reward(ShadowRift rift, int lodestones);

void check_quest_state()
{
    print();
    print( "Checking quest state..." );

    if (overdrunk) {
	// If you are overdrunk, you can enter a shadow rift only if you
	// have and can equip Drunkula's wine glass.
	print("You are falling-down drunk.");
	if (!have_wineglass) {
	    print("Try later, after you sober up.");
	    exit;
	}
	print("Fortunately, Drunkula's wineglass will let you proceed.");
    }

    int lodestones = item_amount(SHADOW_LODESTONE);
    if (lodestones > 0 ) {
	print("You have " + lodestones + " " + SHADOW_LODESTONE.plural_name(lodestones) +
	      " in inventory. Let's turn one in!");
	print("You want to enter " + rift_name(rift_ingress) + ".");
	ShadowRift rift = ingress_to_rift(rift_ingress);
	if (rift_ingress == "random") {
	    print("We chose " + rift.loc.to_string() + " for you.");
	}
	collect_reward(rift, lodestones);
	exit;
    }

    string questState = get_property("questRufus");
    if (questState != "unstarted") {
	quest_goal = print_current_rufus_quest();
    }

    if (questState == "step1") {
	print("You have fulfilled Rufus's request and just need to call him back!");
    } else if (!confirmed_free_adventures()) {
	exit;
    }

    print( "Clean. Ready to go!" );
}

// ***************************
// *        Tasks            *
// ***************************

void platinum_yendorian_express_card()
{
    // If we have already used it today, can't use again.
    if ( get_property( "expressCardUsed" ).to_boolean() ) {
	return;
    }

    boolean should_use_stash = get_property( "autoSatisfyWithStash" ).to_boolean();
    boolean from_stash = false;
    boolean available = false;

    // Special shenanigans if might borrow/return from clan stash
    if ( should_use_stash ) {
	// See if it is available without using the stash
	try {
	    set_property( "autoSatisfyWithStash", false );
	    available = available_amount( PYEC ) > 0;
	} finally {
	    set_property( "autoSatisfyWithStash", true );
	}

	// If not, see if it is available with the stash
	if ( !available ) {
	    // Refresh the stash
	    get_stash();
	    from_stash = available = available_amount( PYEC ) > 0;
	}
    } else {
	available = available_amount( PYEC ) > 0;
    }

    // If we can't get one, we can't use one
    if ( !available ) {
	return;
    }	

    // Even though we verified that a PYEC is available, retrieve_item()
    // can fail, since a PYEC is a karma-regulated item in a clan stash.
    if ( retrieve_item( 1, PYEC ) ) {
	use( 1, PYEC );

	// If we borrowed from the stash, put it back
	if ( from_stash ) {
	    put_stash( 1, PYEC );
	}
    }
}

void prepare_for_combat()
{
    // How many turns of Shadow Affinity do we currently have?
    int affinity_turns = have_effect(SHADOW_AFFINITY);

    // If we have Shadow Affinity, use PYEC to extend all effects by 5 turns.
    if (affinity_turns > 0 && use_pyec) {
	platinum_yendorian_express_card();
	affinity_turns = have_effect(SHADOW_AFFINITY);
    }

    // How many turns until we hit the NC?
    int turns_until_nc = turns_until_nc();

    // Will we use up a turn of Shadow Affinity during our first encounter?
    int affinity_used =
	// If don't have Shadow Affinity, none is used
	affinity_turns == 0 ? 0 :
	// If not about to hit the NC, next up is a mundane shadow monster
	turns_until_nc > 0 ? 1 :
	// shadow bosses use up Shadow Affinity
	quest_goal == "entity" ? 1 :
	// A Labyrinth of Shadows does not use up Shadow Affinity
	0;

    boolean will_fight()
    {
	// If we want to consume remaining turns of Shadow Affinity -
	// and there are some to use - we will adventure and fight.
	if (use_up_shadow_affinity && affinity_turns > affinity_used) {
	    return true;
	}
	// If we are ready to call back Rufus, no adventuring.
	if (get_property("questRufus") == "step1" ) {
	    return false;
	} 
	// If we want items and will buy them, no adventuring.
	if (quest_goal == "items" && buy_shadow_items) {
	    return false;
	}
	// If we are about to encounter the NC, the shadow boss is a
	// fight but the Labyrinth of Shadows is not a fight.
	if (turns_until_nc == 0) {
	    return quest_goal == "entity";
	}
	// Otherwise, we will be fighting a mundane shadow monster
	return true;
    }

    // If we will not fight, nothing more to do here
    if (!will_fight()) {
	return;
    }

    // If we've designated a familiar to fight with us,
    // put it at our side.
    if (chosen_familiar != $familiar[none] ) {
	use_familiar( chosen_familiar );
    }

    // Mazimize for items.
    string expression = "Item Drop";

    // The user can augment the maximization expression
    if (extra_maximizer_parameters != "") {
	expression += " " + extra_maximizer_parameters;
    }

    // If overdrunk or user has chosen to attack rather than use
    // combat spells and/or combat items
    if (use_space_tourist_phaser) {
	expression += " +equip Space Tourist Phaser";
    }

    // If the user wants to wear a Jurassic Parka
    if (parka_mode != "none") {
	expression += " +equip Jurassic Parka";
    }

    maximize(expression, false);

    // If we equipped a Jurassic Parka, set the desired mode
    if (have_equipped(PARKA)) {
	string mode =
	    parka_mode == "spikes" ?
	    "spikolodon" :
	    parka_mode == "hp" ?
	    "kachungasaur" :
	    parka_mode == "both" ?
	    (turns_until_nc == 0 ? "kachungasaur" : "spikolodon") :
	    "kachungasaur";
	cli_execute("parka " + mode);
    }

    // If we are using free turns, get Steely-Eyed Squint,
    // which doubles Item Drop bonuses for one turn.
    if (affinity_turns > affinity_used && cast_steely_eyed_squint) {
	if (have_skill(STEELY_EYED_SQUINT) &&
	    !get_property("_steelyEyedSquintUsed").to_boolean()) {
	    use_skill(1, STEELY_EYED_SQUINT);
	}
    }

    // If we are using free turns, get Bend Hell, which doubles
    // Elemental damage and spell damage bonuses for one turn.
    if (affinity_turns > affinity_used && cast_bend_hell) {
	if (have_skill(BEND_HELL) &&
	    !get_property("_bendHellUsed").to_boolean()) {
	    use_skill(1, BEND_HELL);
	}
    }

    // If you want to use ShadowRiftConsult, tell KoLmafia to do so
    if (use_consult_script) {
	set_property("battleAction", "consult ShadowRiftConsult.ash");
    }
}

void adventure_once(ShadowRift rift)
{
    // The first time you go through the rift to The 8-bit Realm, we
    // will equip the continuum transfunctioner. Subsequent adventures
    // do not need it, so restore item drop outfit.
    boolean checkpoint = rift.ingress != get_property("shadowRiftIngress");
    try {
	if (checkpoint) {
	    cli_execute( "checkpoint" );
	}
	if (!adv1(rift.loc, 0)) {
	    print("Aborting automation.", "red");
	    exit;
	}
    } finally {
	if (checkpoint) {
	    cli_execute( "outfit checkpoint" );
	}
    }
}

void prepare_for_boss()
{
    // If we want to have Jurassic Parka in kachungasaur mode for bosses, make it so.
    if (parka_mode == "both" & get_property("parkaMode") != "kachungasaur") {
	cli_execute("parka kachungasaur");
    }

    // Restore to 100% HP to avoid insta-kill from the shadow scythe
    restore_hp(my_maxhp());

    switch (get_property("rufusQuestTarget")) {
    case "shadow cauldron":
	// Always loses initiative
	// Physical Resistance: 100%
	// Passive hot damage
	break;
    case "shadow matrix":
	// Initiative: 1000
	// Physical Resistance: 100%
	// Blocks physical attacks
	break;
    case "shadow orrery":
	// Always loses initiative
	// Physical Resistance: 100%
	// Enhanced Elemental Resistance
	// Reflects spells to damage you
	break;
    case "shadow scythe":
	// Always wins initiative
	// Physical Resistance: 100%
	// Hits for 90%  of your Max HP every round
	break;
    case "shadow spire":
	// Always loses initiative
	// Physical Resistance: 100%
	// Hits for 30-35%  of your Max HP every round
	break;
    case "shadow tongue":
	// Initiative: 200
	// Physical Resistance: 100%
	// Passive sleaze damage
	break;
    }
}

void fulfill_quest(ShadowRift rift)
{
    if (quest_goal == "items") {
	item it = get_property("rufusQuestTarget").to_item();
	if (buy_shadow_items) {
	    retrieve_item(3, it);
	    return;
	}

	// If we are adventuring for items, we need to adventure in a
	// rift that drops them.
	ShadowRiftArray rifts = item_to_rifts[it];
	if (!rifts.contains_rift(rift)) {
	    print(rift.loc + " does not offer " + it.plural);
	    rift = rifts[random(count(rifts))];
	    print("We'll find them in " + rift.loc.to_string() + ".");
	}
    }

    // If the goal is "entity", the boss replaces the Shadow Labyrinth.
    // If the goal is "artifact", automation will find it in the Shadow Labyrinth.
    // If the goal is "items", automation will find the desired goal in the Shadow Labyrinth.
    // KoLmafia will not automate if the shadowLabyrinthGoal is "Manual Control".
    // So, set it for either "artifact" or "items".
    if (quest_goal == "artifact" || quest_goal == "items") {
	set_property("shadowLabyrinthGoal", labyrinth_goal);
    }

    while (get_property("encountersUntilSRChoice") > 0 &&
	   get_property("questRufus") != "step1") {
	adventure_once(rift);
    }

    if (quest_goal == "entity") {
	prepare_for_boss();
    }

    if (get_property("questRufus") != "step1") {
	// Fight the boss or traverse the Shadow Labyrinth
	adventure_once(rift);
    }
}

void call_rufus()
{
    visit_url("inv_use.php?&whichitem=" + PAY_PHONE.to_int() + "&pwd");
}

void accept_quest()
{
    // Sanity check: Time to Call Rufus and start a quest
    if (get_property("questRufus") != "unstarted") {
	return;
    }

    call_rufus();
    run_choice(rufus_option[quest_goal]);
    print("You accepted an '" + get_property("rufusQuestType") + "' quest to get " + get_property("rufusQuestTarget"));
}

void fulfill_quest()
{
    // Sanity check: Time to Call Back Rufus
    if (get_property("questRufus") != "step1") {
	return;
    }

    // Report success and get lodestone
    call_rufus();
    run_choice(1);

    // You should now have Rufus's shadow lodestone
    int lodestones = item_amount(SHADOW_LODESTONE);
    if (lodestones == 0 ) {
	abort("You didn't get a shadow lodestone!");
    }
}

void collect_reward(ShadowRift rift, int lodestones)
{
    // Sanity check
    if (lodestones == 0) {
	return;
    }

    string reward = quest_reward;
    if (reward == "forest" && get_property("_shadowForestLooted").to_boolean()) {
	reward = "waters";
    }
    set_property("choiceAdventure1500", reward_option[reward]);

    // You still need a wineglass to collect a reward if overdrunk.
    boolean checkpoint = overdrunk && !have_equipped(DRUNKULA);
    try {
	if (checkpoint) {
	    cli_execute( "checkpoint" );
	    equip(DRUNKULA);
	}

	// The non-combat can be preempted by Violet Fog, at least.
	// Repeat until a shadow lodestone has been used.
	repeat {
	    adventure_once(rift);
	} until (item_amount(SHADOW_LODESTONE) < lodestones);

    } finally {
	if (checkpoint) {
	    cli_execute( "outfit checkpoint" );
	}
    }
}    

// ***************************
// *      Action          *
// ***************************

void main(string parameters)
{
    // Check initial configuration
    validate_configuration();

    // Parse parameters and override configuration
    parse_parameters(parameters);

    // Check quest state to ensure we can handle this
    check_quest_state();

    print();
    print("You want to accept an " + quest_goal + " quest from Rufus.");
    print("You want the '" + quest_reward + "' reward for accomplishing that.");
    if (quest_reward == "forest" && get_property("_shadowForestLooted").to_boolean()) {
	print("(You have already looted the forest today, so instead, you will get Shadow Waters.)");
    }
    if (quest_goal == "items") {
	if (buy_shadow_items) {
	    print("You are willing to buy items to fulfill Rufus's request.");
	    print("This means this quest will take no turns!");
	} else {
	    print("You are not willing to buy items for Rufus, so you will need to adventure to find them.");
	    print("We will stop, ready or not, once you reach the Shadow Labyrinth.");
	    print("You want the '" + labyrinth_goal + "' result from the Shadow Labyrinth.");
	}
    }

    print("You want to enter " + rift_name(rift_ingress) + ".");

    // Choose the rift you will actually enter.
    ShadowRift rift = ingress_to_rift(rift_ingress);
    if (rift_ingress == "random") {
	print("We chose " + rift.loc.to_string() + " for you.");
    }
    print("You will find the following items there: " + rift_items(rift));
    print("After fulfilling Rufus's quest, you " + (!use_up_shadow_affinity ? "do not" : "") + " want to use up any remaining daily free fights.");

    void execute_quest()
    {
	if (get_property("questRufus") == "unstarted") {
	    // Accept a quest from Rufus.
	    accept_quest();
	}

	// If we will be fighting, maximize equipment and set CCS.
	prepare_for_combat();

	// We already checked that Drunkula's wineglass is available.
	// You need it to enter a Shadow Rift, even if no combat.
	if (overdrunk) {
	    equip(DRUNKULA);
	}

	// If our goal is not already fulfilled, buy items or
	// adventure for artifact, entity, or items
	if (get_property("questRufus") == "started") {
	    fulfill_quest(rift);
	} 

	if (get_property("questRufus") != "step1") {
	    // Perhaps you didn't have enough items and were counting on
	    // free-turn adventuring to get them for you. Or perhaps the
	    // shadow boss beat you.
	    abort("Could not fulfill Rufus's quest.");
	}

	// Fulfill the quest with Rufus
	fulfill_quest();

	// Adventure once more to collect your reward
	collect_reward(rift, 1);
    }

    boolean have_enough_affinity_for_quest(int affinity_turns)
    {
	// Given a particular number of turns of Shadow Affinity, do we
	// have enough to do a quest?

	// If we are buying items, it takes no turns and burns no Shadow
	// Affinity. If we are not buying items, we cannot predict how
	// long it will take, since it depends on item drop.
	//
	// Therefore, don't consider items quests
	if (quest_goal == "items") {
	    return false;
	}

	return affinity_turns >= get_quest_turns();
    }

    boolean have_enough_affinity_for_quest()
    {
	// Consider all currently available turns of Shadow Affinity
	int affinity_turns = have_effect(SHADOW_AFFINITY);
	return have_enough_affinity_for_quest(affinity_turns);
    }

    // Quests may or may not require combat, but in case they do,
    // save current state so we can restore it when we finish.
    string current_battle_action = get_property("battleAction");
    familiar current_familiar = my_familiar();
    cli_execute( "checkpoint" );

    try {
	// Execute the desired quest
	execute_quest();

	// If user wants to use up left over turns of Shadow Affinity,
	// do more quests and/or adventure in our selected Shadow Rift.
	if (use_up_shadow_affinity) {
	    // If we have time to complete a quest, do it.
	    while (have_enough_affinity_for_quest()) {
		execute_quest();
	    }

	    // If we still have turns of Shadow Affinity, adventure.
	    int affinity_turns = have_effect(SHADOW_AFFINITY);
	    while (affinity_turns-- > 0) {
		adventure_once(rift);
	    }
	}
    } finally {
	set_property("battleAction", current_battle_action);
	use_familiar(current_familiar);
	cli_execute( "outfit checkpoint" );
    }

    print("Done adventuring in the Shadow Rift!");
}
