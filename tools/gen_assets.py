#!/usr/bin/env python3
"""Asset v2: pixel-art 16x16 con animazioni, boss dettagliati, lava a 2 frame."""
import os, random, math
from PIL import Image

OUT = os.path.join(os.path.dirname(__file__), "..", "assets")
for sub in ("tiles", "towers", "enemies", "icons", "deco"):
    os.makedirs(os.path.join(OUT, sub), exist_ok=True)

def canvas():
    return Image.new("RGBA", (16, 16), (0, 0, 0, 0))

def px(im, x, y, c):
    s = im.size[0]
    if 0 <= x < s and 0 <= y < s:
        im.putpixel((int(x), int(y)), c)

def rect(im, x, y, w, h, c):
    for j in range(int(y), int(y + h)):
        for i in range(int(x), int(x + w)):
            px(im, i, j, c)

def circ(im, cx, cy, r, c):
    for j in range(int(cy - r), int(cy + r + 1)):
        for i in range(int(cx - r), int(cx + r + 1)):
            if (i - cx) ** 2 + (j - cy) ** 2 <= r * r:
                px(im, i, j, c)

def shade_bottom(im, cy, dark):
    """scurendo i pixel del corpo sotto la meta' crea volume"""
    src = im.copy()
    for y in range(16):
        for x in range(16):
            r, g, b, a = src.getpixel((x, y))
            if a > 200 and y >= cy + 2 and (r, g, b) != dark[:3]:
                px(im, x, y, (int(r * 0.78), int(g * 0.78), int(b * 0.78), 255))

def outline(im, c=(14, 17, 24, 255)):
    src = im.copy()
    s = im.size[0]
    for y in range(s):
        for x in range(s):
            if src.getpixel((x, y))[3] == 0:
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < s and 0 <= ny < s and src.getpixel((nx, ny))[3] > 0:
                        px(im, x, y, c)
                        break

def save(im, path):
    im.save(os.path.join(OUT, path))

C = lambda h: tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (255,)
EYE = (20, 24, 30, 255)
DARK = C("1a1e26")

# ================================================================ TILES
BIOMES = {
    "roma":    dict(g0="6aa939", g1="5f9c33", blade="82c14c", flower=("ffdf6b", "f27d7d"),
                   p0="b07c46", p1="966838", edge="6b4a28", stone="8f8f97"),
    "venezia": dict(g0="3e7ca8", g1="4a8ab6", blade="78b4d2", foam="cfeaf5",
                   p0="b98b52", p1="9c7443", edge="5e3e28", nail="3a2c1e"),
    "milano":  dict(g0="dfe9f2", g1="cfdde9", blade="ffffff", ice="a9cfe8",
                   p0="8e97a3", p1="7a8491", edge="545c67", dot="b8c2cd"),
    "palermo": dict(g0="e0c27a", g1="d4b469", blade="eed89a", shell="f5e6c8",
                   p0="b98f4f", p1="a2793e", edge="78592f", peb="d9c1a0"),
    "etna":    dict(g0="3a2e2e", g1="453636", lava="ff6b35", lava2="ffb347",
                    p0="20181f", p1="2c2129", edge="e04f2a", ash="55484a"),
}

rng = random.Random(1234)
for b, s in BIOMES.items():
    for idx, gk in ((0, "g0"), (1, "g1")):
        im = canvas()
        rect(im, 0, 0, 16, 16, C(s[gk]))
        for _ in range(10):
            px(im, rng.randrange(16), rng.randrange(16), C(s.get("blade", s.get("ash", "888888")))[:3] + (45,))
        if b == "roma":
            for _ in range(3):
                x, y = rng.randrange(2, 12), rng.randrange(2, 13)
                rect(im, x, y, 1, 2, C(s["blade"]))
                px(im, x + 1, y - 1, C(s["blade"]))
            fx, fy = rng.randrange(2, 13), rng.randrange(2, 13)
            col = C(s["flower"][idx % 2])
            rect(im, fx, fy, 1, 1, col); px(im, fx - 1, fy, col); px(im, fx + 1, fy, col); px(im, fx, fy - 1, C("fff6c8"))
        elif b == "venezia":
            for y in (3, 7, 11, 14):
                for x in range(16):
                    if (x + y + idx) % 7 < 2:
                        px(im, x, y, C(s["blade"])[:3] + (180,))
            px(im, rng.randrange(16), rng.randrange(16), C(s["foam"]))
        elif b == "milano":
            circ(im, 3 + idx * 8, 5 + idx * 4, 2, C(s["ice"])[:3] + (150,))
            for _ in range(4):
                px(im, rng.randrange(16), rng.randrange(16), C(s["blade"]))
        elif b == "palermo":
            for _ in range(6):
                x, y = rng.randrange(16), rng.randrange(16)
                rect(im, x, y, 2, 1, C(s["blade"])[:3] + (150,))
            if idx:
                sx, sy = 6, 11
                rect(im, sx, sy, 3, 2, C(s["shell"])); px(im, sx + 1, sy - 1, C(s["shell"]))
        elif b == "etna":
            x = 4 + idx * 6
            for y in range(2, 14, 2):
                glow = C(s["lava"] if (y // 2) % 2 == idx else s["lava2"])
                px(im, x + (y % 4 - 2) // 2, y, glow[:3] + (230,))
                px(im, x, y + 1, C(s["lava"])[:3] + (140,))
        save(im, f"tiles/{b}_g{idx}.png")
    im = canvas()
    rect(im, 0, 0, 16, 16, C(s["p0"]))
    for _ in range(10):
        px(im, rng.randrange(16), rng.randrange(16), C(s["p1"]))
    if b == "roma":
        px(im, 5, 10, C(s["stone"])); px(im, 10, 4, C(s["stone"])); px(im, 6, 10, C(s["stone"]))
    elif b == "venezia":
        for y in (0, 7):
            rect(im, 0, y, 16, 1, C(s["edge"]))
        for x in (2, 9):
            px(im, x, y - 1, C(s["nail"]))
    elif b == "milano":
        for x in (3, 11):
            for y in (2, 9):
                px(im, x, y, C(s["dot"]))
        rect(im, 0, 5, 16, 1, C(s["edge"])[:3] + (90,))
    elif b == "palermo":
        for x in (4, 10, 13):
            px(im, x, 3 + (x % 5), C(s["peb"]))
    elif b == "etna":
        for y in range(1, 15, 4):
            px(im, (y * 3) % 14, y, C(s["edge"]))
        px(im, 8, 8, C(s["lava2"]))
    save(im, f"tiles/{b}_path.png")
    if b == "etna":  # frame 2 del bagliore
        im2 = im.copy()
        rect(im2, 0, 0, 16, 16, (0, 0, 0, 0))
        im2 = im.copy()
        for _ in range(6):
            x, y = rng.randrange(16), rng.randrange(16)
            px(im2, x, y, C(s["lava2"])[:3] + (255,))
            px(im2, x + 1, y, C(s["edge"])[:3] + (200,))
        save(im2, "tiles/etna_path2.png")

# ================================================================ TORRI (16x16, griglia coerente)
STONE = "4a4f5a"
STONE_L = "5e6470"

def tower(kind, lvl):
    im = canvas()
    body = {"mg": ("3fbf6f", "1f6b3e", "8fe36b"), "sniper": ("8f7fff", "4a3a96", "c9bdff"),
            "mortar": ("ff9f43", "a05a14", "ffd0a0")}[kind]
    # piedistallo in pietra comune a tutte
    rect(im, 3, 13, 10, 2, C(STONE))
    rect(im, 3, 13, 10, 1, C(STONE_L))
    if kind == "mg":
        rect(im, 4, 6, 7, 7, C(body[0]))               # cassa tozza
        rect(im, 4, 6, 7, 1, C(body[2]))
        rect(im, 4, 12, 7, 1, C(body[1]))
        circ(im, 6, 9, 1, C(body[1]))                  # caricatore
        rect(im, 11, 7, 5, 1, C("2b3342"))             # canne
        rect(im, 11, 9, 5, 1, C("2b3342"))
        px(im, 15, 7, C("0c0f14")); px(im, 15, 9, C("0c0f14"))
    elif kind == "sniper":
        rect(im, 6, 8, 4, 5, C(body[0]))               # corpo snello
        rect(im, 6, 8, 4, 1, C(body[2]))
        rect(im, 5, 13, 1, 1, C(body[1])); rect(im, 9, 13, 1, 1, C(body[1]))
        rect(im, 7, 4, 3, 3, C("262e3c"))              # ottica
        rect(im, 7, 5, 1, 1, C("9fe3ff")); px(im, 9, 5, C("ffffff"))
        rect(im, 10, 9, 6, 1, C("2b3342"))             # canna lunga
        rect(im, 14, 8, 2, 1, C("0c0f14"))
    else:
        rect(im, 3, 12, 1, 1, C("262e3c")); rect(im, 12, 12, 1, 1, C("262e3c"))
        rect(im, 5, 10, 6, 3, C(body[1]))              # affusto
        circ(im, 8, 7, 3, C(body[0]))                  # tubo
        circ(im, 8, 6, 1, C("141820"))                 # bocca
        px(im, 7, 5, C(body[2]))
        px(im, 11, 11, C("ffd166"))                    # granata
    if lvl >= 2:
        rect(im, 4, 14, 8, 1, C("ffd166")[:3] + (220,))
        px(im, 5, 7, C("ffe08a")) if kind != "mortar" else None
    if lvl >= 3:
        circ(im, 8, 3, 1, C("9fe3ff"))                 # cristallo
        px(im, 8, 2, C("ffffff"))
    outline(im)
    return im

for k in ("mg", "sniper", "mortar"):
    for l in (1, 2, 3):
        save(tower(k, l), f"towers/{k}{l}.png")

# ================================================================ NEMICI (3 frame)
def body_enemy(pal, eyes, legs, bob, horn, big, hood=None):
    im = canvas()
    cy = 9 + bob
    r = 6 if big else 5
    circ(im, 8, cy + 1, r, C(pal[1]))                 # ombra
    circ(im, 8, cy, r, C(pal[0]))
    circ(im, 7, cy - 1, max(r - 2, 1), C(pal[2]))     # luce
    circ(im, 8, cy + 2, max(r - 1, 1), C(pal[1]))     # pancia scura
    circ(im, 8, cy + 1, max(r - 2, 1), C(pal[0]))
    if hood:
        for x in range(8 - 5, 8 + 6):
            py = (3 if not big else 2) + bob + abs(x - 8) // 2
            rect(im, x, py, 1, 2, C(hood))
        rect(im, 6, 6 + bob, 5, 3, C("1a1e26"))       # volto in ombra
        rect(im, 7, 7 + bob, 1, 1, C("6effa0")); rect(im, 9, 7 + bob, 1, 1, C("6effa0"))
    else:
        px(im, 6, cy, C("ffffff")); px(im, 10, cy, C("ffffff"))
        px(im, 6, cy + (1 if bob > 0 else 0), eyes)
        px(im, 10, cy + (1 if bob > 0 else 0), eyes)
        rect(im, 7, cy + 3, 3, 1, C(pal[1]))          # bocca
    for i in range(horn):
        px(im, 3 - i, cy - r + i, C(pal[2]))
        px(im, 12 + i, cy - r + i, C(pal[2]))
        px(im, 4 - i, cy - r + 1 + i, C(pal[1]))
        px(im, 11 + i, cy - r + 1 + i, C(pal[1]))
    if legs:
        offs = {0: 0, 1: 1, 2: -1}
        for i, lx in enumerate((4, 7, 10)):
            h = 2 + (1 if (i + legs) % 3 == 0 else 0)
            rect(im, lx + offs[(legs + i) % 3], cy + r - 1, 1, h, DARK)
    outline(im)
    return im

def frames(prefix, pal, eyes=EYE, legs=True, horn=0, big=False, hood=None, extras=()):
    for f in range(3):
        im = body_enemy(pal, eyes, f if legs else 0, (0, -1, 0)[f], horn, big, hood)
        for ex in extras:
            ex(im, f)
        save(im, f"enemies/{prefix}_{f}.png")

frames("base", ("d95f4f", "9e3b2f", "f08b7a"))
frames("fast", ("f5c542", "c78f1f", "ffe08a"), horn=1)
frames("armored", ("8fa8c8", "5d7896", "c8d6e8"), horn=2)
def armor_plates(im, f):
    rect(im, 4, 4 + (0, -1, 0)[f], 9, 2, C("dce6f2"))
    px(im, 8, 5 + (0, -1, 0)[f], C("5d7896"))
frames("armored", ("8fa8c8", "5d7896", "c8d6e8"), horn=2, extras=(armor_plates,))
# riscrivi armored con piastre (ignora il primo set base)
def boss_extras(im, f):
    rect(im, 5, 2 + (0, -1, 0)[f], 6, 1, C("ffd166"))  # corona
    for cx in (5, 8, 10):
        px(im, cx, 1 + (0, -1, 0)[f], C("ffe08a"))
frames("boss", ("a259c9", "6d3591", "c98fe8"), horn=2, big=True, extras=(boss_extras,))
def beh_extras(im, f):
    bob = (0, -1, 0)[f]
    for sx, sy in ((3, 4 + bob), (12, 4 + bob), (8, 1 + bob)):
        px(im, sx, sy, C("ffe08a"))
    rect(im, 5, 12, 3, 2, C("3a1010")); rect(im, 9, 12, 3, 2, C("3a1010"))
frames("behemoth", ("c9403a", "7c221f", "f07a6e"), eyes=C("ffd166"), horn=3, big=True, extras=(beh_extras,))
def necro_staff(im, f):
    rect(im, 13, 4, 1, 10, C("8a5a2f"))
    orb_y = 3 - (0, 1, 0)[f]
    circ(im, 13, orb_y, 1, C("6effa0")); px(im, 13, orb_y - 1, C("d8ffe8"))
frames("necro", ("4a4258", "2c2736", "6e6482"), legs=0, hood="2c2736", extras=(necro_staff,))
def swarm(f):
    im = canvas()
    off = (0, -1, 0)[f]
    circ(im, 5, 9 + off, 2, C("59b85e")); circ(im, 11, 8 + off, 2, C("7ce38b"))
    px(im, 5, 9 + off, C("1a3a1a")); px(im, 11, 8 + off, C("1a3a1a"))
    for lx, lo in ((3, 0), (7, 1), (9, 1), (13, 0)):
        h = 1 + ((f + lx) % 2)
        rect(im, lx, 11 + off, 1, h, DARK)
    outline(im)
    return im
for f in range(3):
    save(swarm(f), f"enemies/swarm_{f}.png")

# ================================================================ ICONES
def icon(fn):
    im = canvas(); fn(im); outline(im); return im

def meteor(im):
    circ(im, 10, 10, 3, C("ff8c42")); circ(im, 9, 9, 1, C("ffe08a"))
    circ(im, 11, 11, 1, C("9e3b2f"))
    for i, x in enumerate(range(2, 8)):
        rect(im, x, 3 + i, 2, 1, C("ff5f3c" if i % 2 == 0 else "ffd166"))
def blizzard(im):
    rect(im, 7, 2, 2, 12, C("9fe3ff")); rect(im, 2, 7, 12, 2, C("9fe3ff"))
    for d in ((4, 4), (11, 4), (4, 11), (11, 11)):
        rect(im, d[0], d[1], 2, 2, C("e6f7ff"))
    circ(im, 8, 8, 2, C("e6f7ff")); px(im, 8, 8, C("3d8bfd"))
def overclock(im):
    zig = [(9, 2), (8, 3), (7, 4), (6, 5), (7, 6), (8, 7), (7, 8), (6, 9), (5, 10), (6, 11), (7, 12), (4, 13)]
    for x, y in zig:
        px(im, x, y, C("ffd166")); px(im, x + 1, y, C("fff3c4"))
def portal(im):
    rect(im, 3, 2, 10, 13, C("2e3646"))
    for y in range(2, 15):
        px(im, 3, y, C("4fae52")); px(im, 12, y, C("4fae52"))
    rect(im, 4, 3, 8, 11, C("1a1e26"))
    for y in (5, 9):
        rect(im, 5, y, 6, 1, C("4fae52")[:3] + (120,))
    rect(im, 3, 14, 10, 1, C("4fae52"))
def base_icon(im):
    rect(im, 3, 6, 10, 9, C("8a3a34")); rect(im, 2, 5, 12, 2, C("c0392b"))
    for x in range(2, 14):
        px(im, x, 4, C("c0392b"))
    rect(im, 6, 9, 4, 6, C("20242c"))
    rect(im, 4, 8, 1, 1, C("ffd166")); rect(im, 11, 8, 1, 1, C("ffd166"))
    px(im, 8, 2, C("ff6b6b")); rect(im, 7, 3, 3, 1, C("ff6b6b"))

save(icon(meteor), "icons/meteor.png")
save(icon(blizzard), "icons/blizzard.png")
save(icon(overclock), "icons/overclock.png")
save(icon(portal), "icons/portal.png")
save(icon(base_icon), "icons/portal_end.png")

# ================================================================ VIGNETTA
vig = Image.new("RGBA", (160, 90), (0, 0, 0, 0))
for y in range(90):
    for x in range(160):
        dx = (x - 80) / 80.0
        dy = (y - 45) / 45.0
        d = math.sqrt(dx * dx * 0.9 + dy * dy * 1.15)
        a = max(0.0, min(0.42, (d - 0.62) * 0.95))
        vig.putpixel((x, y), (5, 4, 10, int(a * 255)))
vig.save(os.path.join(OUT, "fx", "vignette.png"))
print("vignette ok")
