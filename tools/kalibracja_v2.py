#!/usr/bin/env python3
"""Kalibracja pozycji na podstawie oryginalnego skanu blankietu - wersja 2.

Strategia: wycinamy ROI w okolicach glownej siatki, liczymy projekcje,
szukamy rownomiernych pikow odleglych o ~60-65 px.
"""

import cv2
import numpy as np


def znajdz_równomierne_linie(proj, start_min, start_max, expected_count, expected_step, step_tol=5):
    """Szuka sekwencji expected_count pikow o kroku expected_step +/- step_tol."""
    # znajdz wszystkie piki
    peaks = []
    for i in range(1, len(proj) - 1):
        if proj[i] > proj[i - 1] and proj[i] > proj[i + 1] and proj[i] > 1000:
            peaks.append(i)

    best_score = -1
    best = None
    for s in range(start_min, start_max):
        # sprawdz czy s jest blisko piku
        nearest_peak = min(peaks, key=lambda p: abs(p - s)) if peaks else s
        if abs(nearest_peak - s) > 5:
            continue
        start = nearest_peak
        # znajdz piki w okolicy oczekiwanych pozycji
        found = [start]
        for i in range(1, expected_count):
            expected = start + i * expected_step
            matches = [p for p in peaks if abs(p - expected) <= step_tol]
            if matches:
                found.append(min(matches, key=lambda p: abs(p - expected)))
            else:
                break
        if len(found) == expected_count:
            steps = np.diff(found)
            score = -np.std(steps)  # im mniejszy std tym lepiej
            if score > best_score:
                best_score = score
                best = (start, np.mean(steps), found)
    return best


def kalibruj(sciezka="740-1034_0.png"):
    img = cv2.imread(sciezka)
    if img is None:
        raise FileNotFoundError(sciezka)
    h, w = img.shape[:2]
    print(f"Rozmiar: {w}x{h}")

    b, g, r = cv2.split(img)
    # mocniejsza maska czerwieni
    mask = (r.astype(int) > 170) & (g.astype(int) < 120) & (b.astype(int) < 120)
    mask = mask.astype(np.uint8) * 255

    # ROI: srodek obrazu w pionie, gdzie jest glowna siatka (y ~ 400-1500)
    roi_y1, roi_y2 = 400, 1500
    roi = mask[roi_y1:roi_y2, :]
    v_proj = np.sum(roi, axis=0)

    # Szukaj 28 pionowych linii (27 kratek), krok ~60-65 px
    x27 = znajdz_równomierne_linie(v_proj, 350, 500, 28, 62, step_tol=8)
    x26 = znajdz_równomierne_linie(v_proj, 350, 500, 27, 64, step_tol=8)

    print(f"27-kratek: start={x27[0]:.1f}, krok={x27[1]:.2f}px")
    print(f"26-kratek: start={x26[0]:.1f}, krok={x26[1]:.2f}px")

    # Zapisz debug
    out = img.copy()
    if x27:
        for x in x27[2]:
            cv2.line(out, (x, 0), (x, h), (0, 255, 0), 2)
    cv2.imwrite("tools/kalibracja_v2.png", out)
    print("Zapisano tools/kalibracja_v2.png")

    return x27, x26


if __name__ == "__main__":
    kalibruj()
