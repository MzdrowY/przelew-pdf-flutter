#!/usr/bin/env python3
"""Kalibracja pozycji na podstawie oryginalnego skanu blankietu - v3.
"""

import cv2
import numpy as np


def znajdz_piki(proj, min_wysokosc, min_odleglosc):
    piki = []
    i = 1
    while i < len(proj) - 1:
        if proj[i] > proj[i - 1] and proj[i] > proj[i + 1] and proj[i] >= min_wysokosc:
            # lokalne maksimum
            left = i
            while left > 0 and proj[left] >= proj[left - 1]:
                left -= 1
            right = i
            while right < len(proj) - 1 and proj[right] >= proj[right + 1]:
                right += 1
            peak = (left + right) // 2
            if not piki or peak - piki[-1] >= min_odleglosc:
                piki.append(peak)
                i = right + min_odleglosc
            else:
                i += 1
        else:
            i += 1
    return piki


def kalibruj(sciezka="740-1034_0.png"):
    img = cv2.imread(sciezka)
    if img is None:
        raise FileNotFoundError(sciezka)
    h, w = img.shape[:2]
    print(f"Rozmiar: {w}x{h}")

    b, g, r = cv2.split(img)
    # Detekcja czerwonych/różowych linii
    # Czerwone linie: R duże, G i B mniejsze i w przybliżeniu równe sobie
    czerwone = (r.astype(int) > 180) & (g.astype(int) < r.astype(int) - 10) & (b.astype(int) < r.astype(int) - 10)
    maska = czerwone.astype(np.uint8) * 255

    # Grubość linii - dilate
    kernel = np.ones((3, 3), np.uint8)
    maska = cv2.dilate(maska, kernel, iterations=1)

    # ROI: pasmo w pionie gdzie jest główna siatka
    roi_y1, roi_y2 = 300, 1700
    roi = maska[roi_y1:roi_y2, :]
    v_proj = np.sum(roi, axis=0)

    # Szukaj głównych pionowych linii (co najmniej 28, krok ~60-65)
    piki_x = znajdz_piki(v_proj, min_wysokosc=5000, min_odleglosc=40)
    print(f"Znaleziono {len(piki_x)} pionowych linii")
    print(piki_x[:40])

    # Znajdź sekwencję 28 linii (27 kratek) o stałym kroku
    def fit_grid(peaks, expected_lines, step_guess):
        best = None
        best_std = 999
        for i in range(len(peaks) - expected_lines + 1):
            seg = peaks[i:i + expected_lines]
            steps = np.diff(seg)
            if abs(np.mean(steps) - step_guess) > 10:
                continue
            std = np.std(steps)
            if std < best_std:
                best_std = std
                best = (seg[0], np.mean(steps), seg)
        return best

    x27 = fit_grid(piki_x, 28, 62)
    x26 = fit_grid(piki_x, 27, 64)

    print(f"\n27-kratek: start={x27[0]:.1f}, krok={x27[1]:.2f}px" if x27 else "Nie znaleziono 27-kratek")
    print(f"26-kratek: start={x26[0]:.1f}, krok={x26[1]:.2f}px" if x26 else "Nie znaleziono 26-kratek")

    # Poziome linie - szukamy głównych poziomych krawędzi pól
    roi_x1, roi_x2 = 400, 2100
    roi_h = maska[:, roi_x1:roi_x2]
    h_proj = np.sum(roi_h, axis=1)
    piki_y = znajdz_piki(h_proj, min_wysokosc=3000, min_odleglosc=20)
    print(f"\nZnaleziono {len(piki_y)} poziomych linii")
    print(piki_y[:40])

    # Zapisz debug
    out = img.copy()
    if x27:
        for x in x27[2]:
            cv2.line(out, (x, 0), (x, h), (0, 255, 0), 2)
    if x26:
        for x in x26[2]:
            cv2.line(out, (x, 0), (x, h), (255, 0, 0), 2)
    for y in piki_y[:20]:
        cv2.line(out, (0, y), (w, y), (0, 0, 255), 1)
    cv2.imwrite("tools/kalibracja_v3.png", out)
    print("Zapisano tools/kalibracja_v3.png")

    return x27, x26, piki_y


if __name__ == "__main__":
    kalibruj()
