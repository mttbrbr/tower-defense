#!/usr/bin/env python3
"""SFX chiptune procedurali: onde quadre/sinusoidali con inviluppi, 22050Hz mono."""
import os, wave, math, random

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "sfx")
os.makedirs(OUT, exist_ok=True)
SR = 22050
random.seed(7)

def write(name, samples):
    with wave.open(os.path.join(OUT, name), "w") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(b"".join(
            int(max(-1.0, min(1.0, s)) * 32000).to_bytes(2, "little", signed=True)
            for s in samples))

def env_exp(i, n, k=6.0):
    return math.exp(-k * i / n)

def square(f, t):
    return 1.0 if (t * f) % 1.0 < 0.5 else -1.0

def saw(f, t):
    return 2.0 * ((t * f) % 1.0) - 1.0

def sine(f, t):
    return math.sin(2 * math.pi * f * t)

def tone(dur, freq_fn, wave_fn, vol=0.7, decay=7.0, noise=0.0):
    n = int(SR * dur)
    return [vol * wave_fn(freq_fn(i / SR), i / SR) * env_exp(i, n, decay)
            + (noise * vol * (random.random() * 2 - 1) * env_exp(i, n, decay * 1.6) if noise else 0.0)
            for i in range(n)]

# mitragliatrice: click rapido
write("mg.wav", tone(0.06, lambda t: 620, square, 0.5, 18))
# cecchino: pew che scende
write("sniper.wav", tone(0.16, lambda t: 1300 - 950 * (t / 0.16), sine, 0.7, 9, 0.15))
# mortaio colpo: thump + noise
write("mortar.wav", tone(0.2, lambda t: 180 - 90 * (t / 0.2), sine, 0.8, 8, 0.4))
# esplosione
write("boom.wav", tone(0.4, lambda t: 70, sine, 1.0, 5, 1.0))
# moneta: due blip
write("coin.wav", tone(0.06, lambda t: 660, square, 0.5, 5)
      + tone(0.09, lambda t: 990, square, 0.55, 8))
# morte nemico: splat
write("splat.wav", tone(0.15, lambda t: 420 - 300 * (t / 0.15), saw, 0.5, 12, 0.3))
# perdita vita: allarme calante
write("leak.wav", tone(0.16, lambda t: 330, square, 0.5, 3)
      + tone(0.22, lambda t: 233, square, 0.5, 6))
# potere: arpeggio su
write("power.wav", sum((tone(0.07, lambda t, f=f: f, square, 0.5, 4)
                        for f in (440, 660, 880)), []))
# ruggito boss
write("roar.wav", tone(0.55, lambda t: 90 - 40 * (t / 0.55), saw, 0.9, 3.2, 0.6))
# click ui
write("click.wav", tone(0.04, lambda t: 1100, square, 0.35, 25))
# vittoria: fanfara
write("win.wav", sum((tone(0.12, lambda t, f=f: f, square, 0.5, 5)
                      for f in (523, 659, 784, 1047)), []))
# sconfitta
write("lose.wav", sum((tone(0.16, lambda t, f=f: f, square, 0.5, 5)
                       for f in (392, 330, 262, 196)), []))

print("sfx ok")
