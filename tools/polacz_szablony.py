#!/usr/bin/env python3
"""Tworzy blankiet.png: oryginalny skan (bez czerwonej siatki) + nasza idealna siatka."""

import sys
sys.path.insert(0, 'tools')
from generate_blankiet import rysuj_szablon
from PIL import Image, ImageDraw
import numpy as np


def stworz_blankiet(oryginal="740-1034_0.png", wyjscie="assets/images/blankiet.png"):
    oryg = Image.open(oryginal).convert("RGB")
    arr = np.array(oryg)

    # Czycie oryginal z czerwona siatka - usun ja
    r, g, b = arr[:, :, 0].astype(float), arr[:, :, 1].astype(float), arr[:, :, 2].astype(float)
    # Czerwone linie: R-G > 30 i R-B > 30
    mask = (r - g > 30) & (r - b > 30)
    # Szerszy zakres - usun wiecej czerwieni
    for i in range(2):
        for j in range(2):
            shifted = np.roll(mask, (i, j), axis=(0, 1))
            mask = mask | shifted
    arr[mask] = [255, 255, 255]

    cleaned = Image.fromarray(arr)
    draw = ImageDraw.Draw(cleaned)

    # Narysuj nasza siatke w pozycjach dopasowanych do oryginalnego skanu
    # Top: first row at Y=66 canvas (oryg: 163 img px), shift = 66-52 = 14
    # Bottom: first row at Y=712 canvas (oryg: 1766 img px), offset between copies = 712-66 = 646
    rysuj_szablon(draw, offset_y=14)
    rysuj_szablon(draw, offset_y=660)

    cleaned.save(wyjscie)
    print(f"Zapisano: {wyjscie} ({cleaned.size[0]}x{cleaned.size[1]} px)")


if __name__ == "__main__":
    stworz_blankiet()
