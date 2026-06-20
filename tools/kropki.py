#!/usr/bin/env python3
"""Rysuje czerwone kropki na srodkach kratek według field_positions.dart
i wykrywa rzeczywiste pola na oryginalnym skanie."""

import numpy as np
from PIL import Image, ImageDraw

# Canvas -> image scale
SKALA = 2480.0 / 1000.0
ORYGINAL = "740-1034_0.png"

# Współrzędne z field_positions.dart (canvas px)
FIELDS = [
    ("nazwa_odbiorcy",          169, 66,  27, 24.00, 34),
    ("nazwa_odbiorcy_cd",       169, 100, 27, 24.00, 34),
    ("nr_rachunku_odbiorcy",    169, 146, 26, 24.90, 40),
    ("waluta",                  435, 198, 3,  24.00, 40),
    ("kwota",                   531, 198, 14, 290/14, 40),
    ("nr_rachunku_zlec",        169, 250, 26, 24.90, 40),
    ("nazwa_zleceniodawcy",     169, 302, 27, 24.00, 34),
    ("nazwa_zleceniodawcy_cd",  169, 336, 27, 24.00, 34),
    ("tytulem",                 169, 382, 27, 24.00, 34),
    ("tytulem_cd",              169, 416, 27, 24.00, 34),
]

img = Image.open(ORYGINAL).convert("RGB")
draw = ImageDraw.Draw(img)
w, h = img.size

# Rysuj kropki wg field_positions.dart (czerwone)
for name, xs, yt, nc, st, fh in FIELDS:
    y_img = int(yt * SKALA + fh * SKALA / 2)  # srodek pola
    for i in range(1):  # tylko pierwsza kratka
        x_img = int((xs + 0.5 * st) * SKALA)  # srodek pierwszej kratki
        draw.ellipse([x_img-4, y_img-4, x_img+4, y_img+4], fill=(255, 0, 0))
        # Etykieta
        draw.text((x_img+8, y_img-4), name, fill=(255, 0, 0))

# Wykryj rzeczywiste czerwone linie na skanie (siatka oryginalna)
r_arr = np.array(img)[:, :, 0].astype(float)
g_arr = np.array(img)[:, :, 1].astype(float)
b_arr = np.array(img)[:, :, 2].astype(float)
red = (r_arr - np.maximum(g_arr, b_arr)) / 50.0
red = np.clip(red, 0, 1)

# Projekcja pozioma (szukamy poziomych czerwonych linii)
h_proj = np.sum(red[:, 300:2000], axis=1)
# Znajdz piki
peaks = []
for i in range(2, len(h_proj)-2):
    if h_proj[i] > h_proj[i-1] and h_proj[i] > h_proj[i+1] and h_proj[i] > 5:
        if not peaks or i - peaks[-1] > 15:
            # peak width
            l, r_p = i, i
            while l > 0 and h_proj[l] > 3: l -= 1
            while r_p < len(h_proj)-1 and h_proj[r_p] > 3: r_p += 1
            center = (l + r_p) // 2
            if not peaks or center - peaks[-1] > 15:
                peaks.append(center)

# Rysuj wykryte linie (zielone)
for y in peaks:
    cv2.line(np.array(img), (0, y), (w, y), (0, 255, 0), 1)

print("Wykryte poziome linie (Y img px) od gory:")
for y in peaks:
    canvas_y = y / SKALA
    print(f"  Y_img={y}  Y_canvas={canvas_y:.1f}")

# Znajdz linie w okolicach spodziewanych pol
print("\nSpodziewane vs rzeczywiste:")
for name, xs, yt, nc, st, fh in FIELDS:
    y_expected = yt * SKALA
    # Znajdz najblizsza wykryta linie
    nearby = [y for y in peaks if abs(y - y_expected) < 40]
    nearby_str = ", ".join([f"{y}({y/SKALA:.0f})" for y in nearby]) if nearby else "---"
    print(f"  {name}: oczekiwane Y={y_expected:.0f}img({yt}canv) -> najblizsze: {nearby_str}")

img.save("tools/kalibracja_kropki.png")
print("\nZapisano tools/kalibracja_kropki.png")
