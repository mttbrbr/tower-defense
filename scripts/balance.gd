class_name Balance

const START_COINS := 110
const START_LIVES := 20
const SELL_RATIO := 0.7
const SPEEDS := [1, 2, 4, 8, 16]

const ENEMIES := {
	"base": {"name": "Crawler", "hp": 40.0, "speed": 55.0, "reward": 12, "dmg": 1, "armor": 0.0, "r": 14.0, "color": Color("e05c5c")},
	"fast": {"name": "Raider", "hp": 20.0, "speed": 112.0, "reward": 10, "dmg": 1, "armor": 0.0, "r": 11.0, "color": Color("ffd166")},
	"swarm": {"name": "Swarm", "hp": 10.0, "speed": 150.0, "reward": 5, "dmg": 1, "armor": 0.0, "r": 8.0, "color": Color("7ce38b")},
	"armored": {"name": "Armored", "hp": 145.0, "speed": 40.0, "reward": 26, "dmg": 2, "armor": 4.0, "r": 15.0, "color": Color("6a8caf")},
	"boss": {"name": "Boss", "hp": 850.0, "speed": 32.0, "reward": 150, "dmg": 6, "armor": 3.0, "r": 24.0, "color": Color("9b59b6")},
	"behemoth": {"name": "Behemoth", "hp": 1050.0, "speed": 14.0, "reward": 300, "dmg": 10, "armor": 12.0, "r": 28.0, "color": Color("c9403a")},
	"necro": {"name": "Necromancer", "hp": 560.0, "speed": 24.0, "reward": 200, "dmg": 8, "armor": 2.0, "r": 20.0, "color": Color("4a4258")},
}

const POWERS := [
	{"name": "Meteor", "cost": 200, "icon": "res://assets/icons/meteor.png", "desc": "300 damage to all enemies; ignores armor", "kind": "meteor", "flash": Color("ff8c42")},
	{"name": "Blizzard", "cost": 120, "icon": "res://assets/icons/blizzard.png", "desc": "Freezes every enemy for 4s", "kind": "blizzard", "flash": Color("9fe3ff")},
	{"name": "Overclock", "cost": 150, "icon": "res://assets/icons/overclock.png", "desc": "Towers fire 60% faster for 10s", "kind": "overclock", "flash": Color("ffd166")},
]

const TOWERS := [
	{
		"name": "Machine Gun", "cost": 35, "color": Color("7ee787"), "icon": Color("7ee787"), "bullet": Color("ffffff"),
		"bullet_speed": 700.0, "desc": "Anti-swarm",
		"levels": [
			{"dmg": 4.0, "rate": 5.0, "range": 150.0, "splash": 0.0, "pierce": false, "up": 40},
			{"dmg": 7.0, "rate": 5.5, "range": 165.0, "splash": 0.0, "pierce": false, "up": 80},
			{"dmg": 11.0, "rate": 6.0, "range": 185.0, "splash": 0.0, "pierce": false, "up": 0},
		],
	},
	{
		"name": "Sniper", "cost": 200, "color": Color("bd93f9"), "icon": Color("bd93f9"), "bullet": Color("ffe08a"),
		"bullet_speed": 950.0, "desc": "Ignores armor",
		"levels": [
			{"dmg": 40.0, "rate": 0.8, "range": 330.0, "splash": 0.0, "pierce": true, "up": 150},
			{"dmg": 70.0, "rate": 0.85, "range": 370.0, "splash": 0.0, "pierce": true, "up": 250},
			{"dmg": 120.0, "rate": 0.9, "range": 410.0, "splash": 0.0, "pierce": true, "up": 0},
		],
	},
	{
		"name": "Mortar", "cost": 350, "color": Color("ffb86c"), "icon": Color("ffb86c"), "bullet": Color("ffb86c"),
		"bullet_speed": 260.0, "desc": "Area damage",
		"levels": [
			{"dmg": 16.0, "rate": 0.5, "range": 236.0, "splash": 60.0, "pierce": false, "up": 200},
			{"dmg": 26.0, "rate": 0.55, "range": 256.0, "splash": 70.0, "pierce": false, "up": 300},
			{"dmg": 44.0, "rate": 0.6, "range": 276.0, "splash": 86.0, "pierce": false, "up": 0},
		],
	},
]

static func wave_bonus(wave_idx: int, level_id: int) -> int:
	return (wave_idx + 1) * 3 + 25 + level_id * 20
