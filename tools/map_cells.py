# -*- coding: utf-8 -*-
"""
PRECYZYJNE mapowanie szablonu blankietu - piksel po pikselu.

Wykrywa:
- Ramki poszczegolnych pol (prostokaty otaczajace)
- Kratki wewnatrz pol (male kwadraciki)
- Grubosc linii (ramki vs kratki)
- Pozycje (x, y, w, h) kazdej kratki w mm

Wynik: tools/cells_map.json z pelna mapa
       tools/cells_overlay.png z naniesionymi kratkami
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
print(f'Obraz: {W}x{H} px, {PX_PER_MM:.4f} px/mm, A4 = 210x297 mm')
print(f'1 mm = {PX_PER_MM:.2f} px')
print(f'1 px = {1/PX_PER_MM:.4f} mm')

# Konwersja do numpy (BGR dla OpenCV)
arr_rgb = np.array(img_pil)
arr_bgr = cv2.cvtColor(arr_rgb, cv2.COLOR_RGB2BGR)

# Maska czerwieni - bardziej liberalna
r, g, b = arr_rgb[:,:,0], arr_rgb[:,:,1], arr_rgb[:,:,2]
red_mask = ((r > 170) & (g < 150) & (b < 150) & (r.astype(int) - g.astype(int) > 25)).astype(np.uint8) * 255

# Maska rozowego (kratki w polach) - mniej nasycone
pink_mask = ((r > 240) & (g < 240) & (b < 240) & (r.astype(int) - b.astype(int) > 10) & (r > 200)).astype(np.uint8) * 255

# Polaczona maska wszystkich linii
lines_mask = cv2.bitwise_or(red_mask, pink_mask)

print(f'Czerwone piksele: {(red_mask > 0).sum()}')
print(f'Rozowe piksele: {(pink_mask > 0).sum()}')
print(f'Lacznie linie: {(lines_mask > 0).sum()}')

# Zapisz maske do wizualizacji
cv2.imwrite(r'C:\Users\mzdrowy\Desktop\Projekty Opencode\Aplikacje\XX Polecenie przelewuPDF XX\tools\mask_lines.png', lines_mask)
print('Zapisano: tools/mask_lines.png')

# Wykryj linie poziome i pionowe za pomoca Hough transform
# HoughLinesP wymaga obrazu binarnego z liniami
edges = lines_mask

# Wykryj linie poziome - dlugie
# W tym celu zrob morphological z elementem poziomym
horizontal_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (40, 1))
horizontal_lines = cv2.morphologyEx(edges, cv2.MORPH_OPEN, horizontal_kernel)
# Znajdz kontury linii poziomych
contours_h, _ = cv2.findContours(horizontal_lines, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
print(f'Linie poziome: {len(contours_h)}')

horizontal_segments = []
for cnt in contours_h:
    x, y, w, h = cv2.boundingRect(cnt)
    if w > 30:  # Ignoruj krotkie linie
        horizontal_segments.append({
            'x_px': int(x), 'y_px': int(y),
            'x_mm': round(x / PX_PER_MM, 3),
            'y_mm': round(y / PX_PER_MM, 3),
            'w_px': int(w), 'w_mm': round(w / PX_PER_MM, 3)
        })

horizontal_segments.sort(key=lambda s: s['y_px'])
print(f'Znalezione {len(horizontal_segments)} linii poziomych (>30px):')
for seg in horizontal_segments[:30]:
    print(f"  y_px={seg['y_px']}, y_mm={seg['y_mm']}, x={seg['x_px']}-{seg['x_px']+seg['w_px']}px ({seg['x_mm']}-{seg['x_mm']+seg['w_mm']}mm)")

# Wykryj linie pionowe
vertical_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (1, 40))
vertical_lines = cv2.morphologyEx(edges, cv2.MORPH_OPEN, vertical_kernel)
contours_v, _ = cv2.findContours(vertical_lines, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
print(f'\nLinie pionowe: {len(contours_v)}')

vertical_segments = []
for cnt in contours_v:
    x, y, w, h = cv2.boundingRect(cnt)
    if h > 20:
        vertical_segments.append({
            'x_px': int(x), 'y_px': int(y),
            'x_mm': round(x / PX_PER_MM, 3),
            'y_mm': round(y / PX_PER_MM, 3),
            'h_px': int(h), 'h_mm': round(h / PX_PER_MM, 3)
        })

vertical_segments.sort(key=lambda s: s['x_px'])
print(f'Znalezione {len(vertical_segments)} linii pionowych (>20px):')
for seg in vertical_segments[:50]:
    print(f"  x_px={seg['x_px']}, x_mm={seg['x_mm']}, y={seg['y_px']}-{seg['y_px']+seg['h_px']}px ({seg['y_mm']}-{seg['y_mm']+seg['h_mm']}mm)")

# Zapisz mape do JSON
result = {
    'image_size': [W, H],
    'px_per_mm': PX_PER_MM,
    'horizontal_lines': horizontal_segments,
    'vertical_lines': vertical_segments,
}
with open(r'C:\Users\mzdrowy\Desktop\Projekty Opencode\Aplikacje\XX Polecenie przelewuPDF XX\tools\cells_map.json', 'w', encoding='utf-8') as f:
    json.dump(result, f, indent=2, ensure_ascii=False)
print('\nZapisano: tools/cells_map.json')
