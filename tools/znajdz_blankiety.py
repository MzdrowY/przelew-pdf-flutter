#!/usr/bin/env python3
"""Wykrywa pozycje górnego i dolnego blankietu w oryginalnym skanie."""

import cv2
import numpy as np
from PIL import Image


def znajdz_blankiety(sciezka="740-1034_0.png"):
    img = Image.open(sciezka).convert("RGB")
    arr = np.array(img)
    h, w = arr.shape[:2]

    # Wykryj poziome linie (czerwone/czarne) - blankiet ma ramki
    gray = cv2.cvtColor(arr, cv2.COLOR_RGB2GRAY)
    edges = cv2.Canny(gray, 50, 150)

    # Pozioma projekcja krawedzi
    h_proj = np.sum(edges, axis=1)

    # Szukaj mocnych poziomych pasm (górna i dolna ramka kazdego blankietu)
    def find_strong_lines(proj, min_h, min_dist):
        lines = []
        for i in range(1, len(proj) - 1):
            if proj[i] > proj[i-1] and proj[i] > proj[i+1] and proj[i] > min_h:
                if not lines or i - lines[-1] >= min_dist:
                    lines.append(i)
        return lines

    strong = find_strong_lines(h_proj, min_h=np.max(h_proj) * 0.3, min_dist=100)
    print(f"Mocne poziome linie: {strong}")

    # Znajdz najdluzsze biale obszary miedzy ramkami
    # Prostsza metoda: srednia jasosc w poziomie
    brightness = np.mean(gray, axis=1)
    # Miejsca ciemne (ramki) vs jasne (wnetrze)
    dark = brightness < 240

    # Znajdz poczatek i koniec ciemnych pasm
    transitions = np.diff(dark.astype(int))
    starts = np.where(transitions == 1)[0]
    ends = np.where(transitions == -1)[0]

    print(f"Poczatki ciemnych pasm: {starts[:20]}")
    print(f"Konce ciemnych pasm: {ends[:20]}")

    # Znajdz dwa najdluzsze ciemne pasma (gorna i dolna ramka blankietow)
    bands = []
    for s, e in zip(starts, ends):
        if e - s > 50:
            bands.append((s, e, e - s))
    bands.sort(key=lambda x: x[2], reverse=True)
    print(f"Najdluzsze pasma: {bands[:10]}")

    # Zapisz debug
    out = arr.copy()
    for y in strong:
        out[y, :] = [0, 255, 0]
    Image.fromarray(out).save("tools/blankiety_pozycje.png")
    print("Zapisano tools/blankiety_pozycje.png")


if __name__ == "__main__":
    znajdz_blankiety()
