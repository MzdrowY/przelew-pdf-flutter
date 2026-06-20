# -*- coding: utf-8 -*-
"""Oblicz srodki kazdej kratki w kazdym polu. Wymaga dokladnej analizy."""
import json
import sys
import codecs
from PIL import Image
import numpy as np

sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer)

img = Image.open(r'C:\Users\mzdrowy\Desktop\Projekty Opencode\Aplikacje\XX Polecenie przelewuPDF XX\assets\images\blankiet.png')
W, H = img.size
PX_PER_MM = W / 210.0

arr = np.array(img.convert('RGB'))
r, g, b = arr[:,:,0], arr[:,:,1], arr[:,:,2]
red_mask = (r > 180) & (g < 130) & (b < 130) & (r.astype(int) - g.astype(int) > 30)

# Dla kazdego pola: znajdz pionowe kreski, grupuj bliskie, oblicz srodki
def cell_centers(y1_mm, y2_mm, x1_mm, x2_mm, max_gap_mm=2.5):
    y1 = int(y1_mm * PX_PER_MM)
    y2 = int(y2_mm * PX_PER_MM)
    x1 = int(x1_mm * PX_PER_MM)
    x2 = int(x2_mm * PX_PER_MM)
    cc = red_mask[y1:y2, x1:x2].sum(axis=0)
    cols = np.where(cc >= 1)[0]
    if len(cols) == 0:
        return [], (x1_mm, x2_mm)
    # Grupuj bliskie kolumny
    groups = []
    cur = [cols[0]]
    for c in cols[1:]:
        if c - cur[-1] <= 2:
            cur.append(c)
        else:
            groups.append(int(np.mean(cur)))
            cur = [c]
    groups.append(int(np.mean(cur)))

    # Filtruj grupy: kratki to te co sa blisko siebie (odstep < 5mm)
    # W innym wypadku to ramki
    centers = []
    if len(groups) > 1:
        # Pierwsza i ostatnia linia zazwyczaj to ramki
        # Wyciagnij tylko pary bliskich linii
        pairs = []
        for i in range(len(groups)-1):
            d_px = groups[i+1] - groups[i]
            d_mm = d_px / PX_PER_MM
            if d_mm <= max_gap_mm:
                center_px = (groups[i] + groups[i+1]) / 2.0
                center_mm = (x1_mm + center_px / PX_PER_MM) if False else (groups[i] + groups[i+1]) / 2.0 / PX_PER_MM
                pairs.append({
                    "x_center_mm": round(center_mm, 3),
                    "left_mm": round((groups[i] + x1) / PX_PER_MM, 3),
                    "right_mm": round((groups[i+1] + x1) / PX_PER_MM, 3),
                    "width_mm": round(d_mm, 3),
                })
        centers = pairs
    return centers, (x1_mm, x2_mm)

pola = [
    ("nazwa_odbiorcy_1", 15.5, 22.5, 28, 175),
    ("nazwa_odbiorcy_2", 23.0, 30.0, 28, 175),
    ("nr_rachunku_odbiorcy", 33.0, 44.0, 11, 175),
    ("waluta", 47.0, 51.0, 80, 95),
    ("kwota", 47.0, 51.0, 102, 175),
    ("nr_rachunku_zleceniodawcy", 56.0, 65.0, 28, 175),
    ("kwota_slownie", 56.0, 65.0, 28, 175),
    ("nazwa_zleceniodawcy_1", 66.0, 72.0, 28, 175),
    ("nazwa_zleceniodawcy_2", 72.0, 77.0, 28, 175),
    ("tytulem_1", 78.0, 84.0, 28, 175),
    ("tytulem_2", 84.0, 90.0, 28, 175),
]

result = {"px_per_mm": PX_PER_MM, "fields": {}}
print("Srodki kratek w poszczegolnych polach:")
print("=" * 60)
for name, y1, y2, x1, x2 in pola:
    centers, (x1mm, x2mm) = cell_centers(y1, y2, x1, x2)
    if centers:
        widths = [c["width_mm"] for c in centers]
        print(f"{name}: {len(centers)} kratek, szerokosc {min(widths):.2f}-{max(widths):.2f}mm")
    else:
        print(f"{name}: brak kratek w ({x1},{x2})mm")
    result["fields"][name] = {
        "y_text_mm": round((y1+y2)/2, 2),
        "x_range_mm": [x1, x2],
        "cells": centers,
    }

with open('tools/cells_map.json', 'w', encoding='utf-8') as f:
    json.dump(result, f, indent=2, ensure_ascii=False)
print("\nZapisano: tools/cells_map.json")
