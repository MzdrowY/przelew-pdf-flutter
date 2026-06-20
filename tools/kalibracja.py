#!/usr/bin/env python3
"""Kalibracja pozycji na podstawie oryginalnego skanu blankietu."""

import cv2
import numpy as np
from collections import defaultdict


def wykryj_kratki(sciezka="740-1034_0.png"):
    img = cv2.imread(sciezka)
    if img is None:
        raise FileNotFoundError(sciezka)
    h, w = img.shape[:2]
    print(f"Rozmiar obrazu: {w}x{h}")

    # Siatka jest czerwona/różowa. Wykorzystajmy fakt, że czerwony kanał jest mocniejszy
    b, g, r = cv2.split(img)
    # Maska czerwonych linii: R duże, G i B małe
    red_mask = (r.astype(int) > 150) & (g.astype(int) < 130) & (b.astype(int) < 130)
    red_mask = red_mask.astype(np.uint8) * 255

    # Zapisanie maski dla debugu
    cv2.imwrite("tools/maska_czerwona.png", red_mask)

    # Projektowie pionowe i poziome
    vertical_proj = np.sum(red_mask, axis=0)
    horizontal_proj = np.sum(red_mask, axis=1)

    # Szukamy pików
    def find_peaks(proj, min_height=5000, min_dist=20):
        peaks = []
        i = 1
        while i < len(proj) - 1:
            if proj[i] > proj[i - 1] and proj[i] > proj[i + 1] and proj[i] >= min_height:
                peaks.append(i)
                i += min_dist
            else:
                i += 1
        return peaks

    xs = find_peaks(vertical_proj, min_height=3000, min_dist=15)
    ys = find_peaks(horizontal_proj, min_height=3000, min_dist=15)

    print(f"Pionowe linie (X): {len(xs)} szt.")
    print(xs[:60])
    print(f"Poziome linie (Y): {len(ys)} szt.")
    print(ys[:60])

    # Znajdź główny blok kratek — szukamy sekwencji 28 linii pionowych (27 kratek) lub 27 linii (26 kratek)
    def find_grid_run(lines, expected_count, tol=8):
        best = None
        best_std = 9999
        for i in range(len(lines) - expected_count + 1):
            segment = lines[i:i + expected_count]
            steps = [segment[j + 1] - segment[j] for j in range(len(segment) - 1)]
            std = np.std(steps)
            if std < best_std and max(steps) - min(steps) <= tol * 2:
                best_std = std
                best = (segment[0], np.mean(steps))
        return best

    x27 = find_grid_run(xs, 28)
    x26 = find_grid_run(xs, 27)

    print(f"\n27-kratkowy rzad: start={x27[0] if x27 else None}, krok={x27[1] if x27 else None}")
    print(f"26-kratkowy rzad: start={x26[0] if x26 else None}, krok={x26[1] if x26 else None}")

    # Zapisz obraz z zaznaczonymi liniami
    out = img.copy()
    for x in xs:
        cv2.line(out, (x, 0), (x, h), (0, 255, 0), 1)
    for y in ys:
        cv2.line(out, (0, y), (w, y), (255, 0, 0), 1)
    cv2.imwrite("tools/kalibracja_kratki.png", out)
    print("Zapisano tools/kalibracja_kratki.png")


if __name__ == "__main__":
    wykryj_kratki()
