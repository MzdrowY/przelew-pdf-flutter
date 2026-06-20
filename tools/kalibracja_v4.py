#!/usr/bin/env python3
"""Kalibracja v4: detekcja glownego bloku siatki i podzial na kratki."""

import cv2
import numpy as np


def kalibruj(sciezka="740-1034_0.png"):
    img = cv2.imread(sciezka)
    h, w = img.shape[:2]
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Detekcja krawedzi
    edges = cv2.Canny(gray, 50, 150)

    # Znajdz kontury duzych prostokatow
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # Szukamy najwiekszego prostokata w gornej polowie
    best = None
    best_area = 0
    for cnt in contours:
        x, y, bw, bh = cv2.boundingRect(cnt)
        if bw > 400 and bh > 300 and y < h // 2 and x > 100 and x + bw < w - 100:
            area = bw * bh
            if area > best_area:
                best_area = area
                best = (x, y, bw, bh)

    if best is None:
        print("Nie znaleziono glownego bloku")
        return

    x, y, bw, bh = best
    print(f"Glowny blok gorny: x={x}, y={y}, w={bw}, h={bh}")

    # Podziel na kratki
    # Zalozmy 27 kratek w poziomie
    step27 = bw / 27.0
    print(f"Krok 27-kratek: {step27:.2f}px")

    # Znajdz poziome linie w bloku - projekcja w obrebie bloku
    roi = edges[y:y+bh, x:x+bw]
    h_proj = np.sum(roi, axis=1)

    def find_peaks(proj, min_h, min_dist):
        peaks = []
        for i in range(1, len(proj) - 1):
            if proj[i] > proj[i-1] and proj[i] > proj[i+1] and proj[i] > min_h:
                if not peaks or i - peaks[-1] >= min_dist:
                    peaks.append(i)
        return peaks

    y_peaks = find_peaks(h_proj, min_h=500, min_dist=20)
    print(f"Poziome podzialy w bloku: {len(y_peaks)}")
    print([y + p for p in y_peaks[:20]])

    # Zapisz debug
    out = img.copy()
    cv2.rectangle(out, (x, y), (x+bw, y+bh), (0, 255, 0), 3)
    for i in range(28):
        cx = int(x + i * step27)
        cv2.line(out, (cx, y), (cx, y+bh), (255, 0, 0), 1)
    for py in y_peaks:
        cv2.line(out, (x, y+py), (x+bw, y+py), (0, 0, 255), 1)
    cv2.imwrite("tools/kalibracja_v4.png", out)
    print("Zapisano tools/kalibracja_v4.png")


if __name__ == "__main__":
    kalibruj()
