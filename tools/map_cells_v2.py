# -*- coding: utf-8 -*-
"""
PRECYZYJNE mapowanie kratek blankietu - piksel po pikselu.

Wykrywa pozycje (x, y, w, h) kazdej kratki w kazdym polu.
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

# Maska rozowych kratek
r, g, b = arr_rgb[:,:,0], arr_rgb[:,:,1], arr_rgb[:,:,2]
pink_mask = ((r > 240) & (g < 240) & (b < 240) & (r.astype(int) - b.astype(int) > 10) & (r > 200)).astype(np.uint8) * 255

# Definiuj regiony (x1, y1, x2, y2) w mm dla kazdego pola
# Wartosci przyblizone - zostana doprecyzowane po analizie
REGIONS = {
    'nazwa_odbiorcy_1_top': (28, 14, 178, 22),
    'nazwa_odbiorcy_2_top': (28, 22, 178, 30),
    'nr_rachunku_odbiorcy_top': (11, 32, 178, 44),
    'waluta_top': (80, 46, 95, 52),
    'kwota_top': (102, 46, 178, 52),
    'rachunek_zleceniodawcy_top': (11, 55, 178, 65),
    'kwota_slownie_top': (28, 55, 178, 65),
    'nazwa_zleceniodawcy_1_top': (28, 65, 178, 72),
    'nazwa_zleceniodawcy_2_top': (28, 72, 178, 78),
    'tytulem_1_top': (28, 78, 178, 84),
    'tytulem_2_top': (28, 84, 178, 90),
}

# Funkcja: wykryj kratki w regionie
def detect_cells_in_region(x1_mm, y1_mm, x2_mm, y2_mm, name):
    x1 = int(x1_mm * PX_PER_MM)
    y1 = int(y1_mm * PX_PER_MM)
    x2 = int(x2_mm * PX_PER_MM)
    y2 = int(y2_mm * PX_PER_MM)
    region = pink_mask[y1:y2, x1:x2]
    # Detekcja konturow
    contours, _ = cv2.findContours(region, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    cells = []
    for cnt in contours:
        x, y, w, h = cv2.boundingRect(cnt)
        # Filtruj: tylko kratki (kwadratowe, ~12-15 px = 1-1.3mm)
        if 0.7 < w / PX_PER_MM < 1.8 and 0.7 < h / PX_PER_MM < 1.8 and abs(w - h) < 5:
            cells.append({
                'x_mm': round((x1 + x) / PX_PER_MM, 3),
                'y_mm': round((y1 + y) / PX_PER_MM, 3),
                'w_mm': round(w / PX_PER_MM, 3),
                'h_mm': round(h / PX_PER_MM, 3),
            })
    # Sortuj po y, potem po x
    cells.sort(key=lambda c: (c['y_mm'], c['x_mm']))
    return cells

# Wykryj kratki w kazdym polu
all_cells = {}
for name, (x1, y1, x2, y2) in REGIONS.items():
    cells = detect_cells_in_region(x1, y1, x2, y2, name)
    all_cells[name] = cells
    print(f'{name}: {len(cells)} kratek w regionie ({x1},{y1})-({x2},{y2})mm')
    if cells:
        # Wyswietl pierwsze 5
        for c in cells[:5]:
            print(f"  x={c['x_mm']} y={c['y_mm']} w={c['w_mm']} h={c['h_mm']}")

# Zapisz mape
result = {
    'image_size': [W, H],
    'px_per_mm': PX_PER_MM,
    'regions': REGIONS,
    'cells': all_cells,
}
with open(r'C:\Users\mzdrowy\Desktop\Projekty Opencode\Aplikacje\XX Polecenie przelewuPDF XX\tools\cells_map.json', 'w', encoding='utf-8') as f:
    json.dump(result, f, indent=2, ensure_ascii=False)
print('\nZapisano: tools/cells_map.json')

# Generuj overlay - nanies wykryte kratki na obraz
img_array = np.array(img_pil).copy()
for name, cells in all_cells.items():
    for c in cells:
        x1 = int(c['x_mm'] * PX_PER_MM)
        y1 = int(c['y_mm'] * PX_PER_MM)
        x2 = x1 + int(c['w_mm'] * PX_PER_MM)
        y2 = y1 + int(c['h_mm'] * PX_PER_MM)
        # Rysuj zolty prostokat
        cv2.rectangle(img_array, (x1, y1), (x2, y2), (0, 255, 255), 1)

cv2.imwrite(r'C:\Users\mzdrowy\Desktop\Projekty Opencode\Aplikacje\XX Polecenie przelewuPDF XX\tools\cells_overlay.png', cv2.cvtColor(img_array, cv2.COLOR_RGB2BGR))
print('Zapisano: tools/cells_overlay.png (zolte kratki = wykryte)')
