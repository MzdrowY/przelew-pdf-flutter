# -*- coding: utf-8 -*-
"""
PRECYZYJNE wykrycie granic pol (ramki) - piksel po pikselu.

Dla kazdego pola: lewa, prawa, gorna, dolna krawedz ramki.
Na tej podstawie aplikacja dopasowuje tekst do kratek.
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
# Maska silnych linii (ciemnoczerwone)
red_mask = ((r > 170) & (g < 150) & (b < 150) & (r.astype(int) - g.astype(int) > 25)).astype(np.uint8) * 255
# Maska slabszych (rozowe) - obwodki kratek
pink_mask = ((r > 240) & (g < 240) & (b < 240) & (r.astype(int) - b.astype(int) > 10) & (r > 200)).astype(np.uint8) * 255

# Wykryj DUZE ramki pol - linie ciagnace sie przez wiekszosc szerokosci
# Filtrujemy dlugie linie (min 100 pikseli ~ 8.5mm)
edges_long = red_mask.copy()
# Otwarcie morfologiczne z dlugim elementem poziomym
h_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (100, 1))
h_lines = cv2.morphologyEx(edges_long, cv2.MORPH_OPEN, h_kernel)

# Wykryj linie pionowe
v_kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (1, 100))
v_lines = cv2.morphologyEx(edges_long, cv2.MORPH_OPEN, v_kernel)

# Polacz
edges_combined = cv2.bitwise_or(h_lines, v_lines)

# Wykryj kontury duzych ramkach
contours, hierarchy = cv2.findContours(edges_combined, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
print(f'Znalezione {len(contours)} duzych konturow (ramek)')

# Analizuj kazdy kontur
fields = []
for cnt in contours:
    x, y, w, h = cv2.boundingRect(cnt)
    if w < 30 or h < 15:  # Ignoruj male
        continue
    # Aproksymacja do prostokata
    peri = cv2.arcLength(cnt, True)
    approx = cv2.approxPolyDP(cnt, 0.02 * peri, True)
    fields.append({
        'x_px': int(x), 'y_px': int(y),
        'w_px': int(w), 'h_px': int(h),
        'x_mm': round(x / PX_PER_MM, 3),
        'y_mm': round(y / PX_PER_MM, 3),
        'w_mm': round(w / PX_PER_MM, 3),
        'h_mm': round(h / PX_PER_MM, 3),
        'vertices': len(approx),
    })

# Sortuj po Y, potem po X
fields.sort(key=lambda f: (f['y_mm'], f['x_mm']))

print(f'\nRamki pol (po filtracji): {len(fields)}')
for f in fields:
    print(f"  x={f['x_mm']} y={f['y_mm']} w={f['w_mm']} h={f['h_mm']} (vert={f['vertices']})")

# Generuj overlay
img_overlay = np.array(img_pil).copy()
for i, f in enumerate(fields):
    x = f['x_px']
    y = f['y_px']
    w = f['w_px']
    h = f['h_px']
    # Rysuj zielony prostokat
    cv2.rectangle(img_overlay, (x, y), (x + w, y + h), (0, 255, 0), 2)
    # Numer
    cv2.putText(img_overlay, str(i), (x + 5, y + 20),
                cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)

cv2.imwrite(r'C:\Users\mzdrowy\Desktop\Projekty Opencode\Aplikacje\XX Polecenie przelewuPDF XX\tools\fields_overlay.png', cv2.cvtColor(img_overlay, cv2.COLOR_RGB2BGR))
print('\nZapisano: tools/fields_overlay.png')

# Zapisz do JSON
result = {
    'image_size': [W, H],
    'px_per_mm': PX_PER_MM,
    'fields': fields,
}
with open(r'C:\Users\mzdrowy\Desktop\Projekty Opencode\Aplikacje\XX Polecenie przelewuPDF XX\tools\fields_map.json', 'w', encoding='utf-8') as f:
    json.dump(result, f, indent=2, ensure_ascii=False)
print('Zapisano: tools/fields_map.json')
