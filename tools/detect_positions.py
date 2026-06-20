#!/usr/bin/env python3
"""Znajdz dokladne Y gornego i dolnego blankietu w oryginalnym skanie."""

import cv2
import numpy as np


def znajdz(sciezka="740-1034_0.png"):
    img = cv2.imread(sciezka)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    h, w = gray.shape

    # Srednia jasnosc w poziomie - miejsca ciemniejsze to ramki
    brightness = np.mean(gray, axis=1)

    # Znajdz ostre spadki jasnosci (krawedzie poziome)
    diff = np.abs(np.diff(brightness.astype(float)))
    threshold = np.max(diff) * 0.4
    edges_y = np.where(diff > threshold)[0]

    # Klasteryzuj - zgrupuj pobliskie
    clusters = []
    current = []
    for y in edges_y:
        if not current or y - current[-1] <= 10:
            current.append(y)
        else:
            if len(current) >= 3:
                clusters.append(int(np.mean(current)))
            current = [y]
    if current and len(current) >= 3:
        clusters.append(int(np.mean(current)))

    print(f"Znaleziono {len(clusters)} poziomych linii")
    print(f"Y: {clusters}")

    # Szukaj dwoch grup: gorny blankiet i dolny blankiet
    # Gorny blankiet ma linie w gornej polowie, dolny w dolnej
    mid = h // 2
    top_ys = [y for y in clusters if y < mid]
    bottom_ys = [y for y in clusters if y > mid]

    print(f"\nGorny blankiet: {top_ys}")
    print(f"Dolny blankiet: {bottom_ys}")

    if top_ys and bottom_ys:
        # Zakladamy ze pierwsza linia gornego = gorna krawedz pierwszego rzedu
        top_start = top_ys[0]
        bottom_start = bottom_ys[0]
        offset = bottom_start - top_start

        print(f"\nGorny blankiet start: Y={top_start} px")
        print(f"Dolny blankiet start: Y={bottom_start} px")
        print(f"Offset (piksele obrazka): {offset} px")
        print(f"Offset (canvas px, /2.48): {offset/2.48:.1f} px")

    # Zapisz debug
    out = img.copy()
    for y in clusters:
        cv2.line(out, (0, y), (w, y), (0, 255, 0), 2)
    if top_ys and bottom_ys:
        cv2.line(out, (0, bottom_ys[0]), (w, bottom_ys[0]), (0, 0, 255), 2)
    cv2.imwrite("tools/blankiet_pozycje_v2.png", out)
    print("\nZapisano tools/blankiet_pozycje_v2.png")


if __name__ == "__main__":
    znajdz()
