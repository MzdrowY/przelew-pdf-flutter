# -*- coding: utf-8 -*-
"""
PRECYZYJNE mapowanie - wykrywa biale kwadraty (kratki) wewnatrz rozowych pol.
W polach 'nazwa...' i 'tytulem' sa male biale kwadraty (kratki na litery).
W polach 'nr rachunku...' sa kratki oddzielone separatorami.
"""
import json
import sys
import codecs
import cv2
import numpy as np
from PIL import Image

sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer)

IMG_PATH = r'C:\Users\mzdrowy\Desktop\Projekty Opencode\Aplikacje\XX Polecenie przelewuPDF XX\assets\images\blankiet.png'

img_pil = Image.open(IMG_PATH).convert('RGB')
W, H = img_pil.size
PX_PER_MM = W / 210.0

arr_rgb = np.array(img_pil)
r, g, b = arr_rgb[:,:,0], arr_rgb[:,:,1], arr_rgb[:,:,2]

# Maska rozowa (wypelnienie pol)
pink_fill = ((r > 245) & (g < 240) & (b < 240) & (r.astype(int) - b.astype(int) > 5)).astype(np.uint8) * 255

# Odwroc - biale piksele (kratki na litery) wewnatrz rozowych pol
white_in_pink = ((r > 250) & (g > 250) & (b > 250)).astype(np.uint8) * 255

# Otwarcie morfologiczne na biale piksele - zachowaj tylko te ktore sa obwiedzione linia
# Kratki na litery sa malymi bialymi kwadratami
# Najpierw otwarcie z malym kernelem - wyodrebnij pojedyncze kratki
kernel_small = cv2.getStructuringElement(cv2.MORPH_RECT, (3, 3))
white_clean = cv2.morphologyEx(white_in_pink, cv2.MORPH_OPEN, kernel_small)

# Erozja - tylko duze biale obszary (kratki ~15px = 1.3mm)
kernel_erode = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
white_eroded = cv2.erode(white_in_pink, kernel_erode)
# Po erozji odtworz rozmiar
kernel_dilate = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
white_candidates = cv2.dilate(white_eroded, kernel_dilate)

print(f'Biale piksele ogolnie: {(white_in_pink > 0).sum()}')
print(f'Biale po erozji/dylatacji: {(white_candidates > 0).sum()}')

# Wykryj kontury bialych kratek
contours, _ = cv2.findContours(white_candidates, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
print(f'Kontury kratek: {len(contours)}')

cells = []
for cnt in contours:
    x, y, w, h = cv2.boundingRect(cnt)
    # Filtruj: kratki ~1.0-1.5mm (12-18 px) kwadratowe
    w_mm = w / PX_PER_MM
    h_mm = h / PX_PER_MM
    if 0.8 < w_mm < 1.8 and 0.8 < h_mm < 1.8 and abs(w - h) < 4:
        cells.append({
            'x_mm': round(x / PX_PER_MM, 3),
            'y_mm': round(y / PX_PER_MM, 3),
            'w_mm': round(w_mm, 3),
            'h_mm': round(h_mm, 3),
        })

print(f'Kratki po filtracji: {len(cells)}')

# Sortuj po Y, potem po X
cells.sort(key=lambda c: (round(c['y_mm']), c['x_mm']))

# Wyswietl pierwsze 100
print('\nPierwsze 100 kratek:')
for c in cells[:100]:
    print(f"  x={c['x_mm']} y={c['y_mm']} w={c['w_mm']} h={c['h_mm']}")

# Zapisz do JSON
result = {
    'image_size': [W, H],
    'px_per_mm': PX_PER_MM,
    'cells_count': len(cells),
    'cells': cells,
}
with open(r'C:\Users\mzdrowy\Desktop\Projekty Opencode\Aplikacje\XX Polecenie przelewuPDF XX\tools\text_cells.json', 'w', encoding='utf-8') as f:
    json.dump(result, f, indent=2, ensure_ascii=False)
print(f'\nZapisano: tools/text_cells.json ({len(cells)} kratek)')

# Generuj overlay
img_overlay = np.array(img_pil).copy()
for i, c in enumerate(cells):
    x1 = int(c['x_mm'] * PX_PER_MM) - 1
    y1 = int(c['y_mm'] * PX_PER_MM) - 1
    x2 = x1 + int(c['w_mm'] * PX_PER_MM) + 2
    y2 = y1 + int(c['h_mm'] * PX_PER_MM) + 2
    cv2.rectangle(img_overlay, (x1, y1), (x2, y2), (0, 0, 255), 1)  # czerwone

cv2.imwrite(r'C:\Users\mzdrowy\Desktop\Projekty Opencode\Aplikacje\XX Polecenie przelewuPDF XX\tools\text_cells_overlay.png', cv2.cvtColor(img_overlay, cv2.COLOR_RGB2BGR))
print('Zapisano: tools/text_cells_overlay.png (czerwone kwadraty = wykryte kratki)')
