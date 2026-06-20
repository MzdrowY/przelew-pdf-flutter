# -*- coding: utf-8 -*-
"""
PRECYZYJNE mapowanie kratek - wykrywa pionowe linie w polach,
grupuje bliskie w segmenty kratek (odstep ~1.4mm).
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
# Maska wszystkich linii: czerwone + rozowe (krawedzie kratek)
red_mask = ((r > 170) & (g < 150) & (b < 150) & (r.astype(int) - g.astype(int) > 25)).astype(np.uint8) * 255
pink_mask = ((r > 240) & (g < 240) & (b < 240) & (r.astype(int) - b.astype(int) > 10) & (r > 200)).astype(np.uint8) * 255
lines_mask = cv2.bitwise_or(red_mask, pink_mask)

# Znajdz pionowe linie - w polu konta kazda kratka ma 2 pionowe kreski
# Uzywamy HoughLinesP z malymi parametrami
edges = lines_mask

# Wykryj pionowe linie z HoughLinesP
linesP = cv2.HoughLinesP(edges, rho=1, theta=np.pi/2, threshold=30,
                          minLineLength=15, maxLineGap=2)
vertical_lines = []
if linesP is not None:
    for line in linesP:
        x1, y1, x2, y2 = line[0]
        # Tylko linie pionowe
        if abs(x2 - x1) < 2 and abs(y2 - y1) > 15:
            vertical_lines.append({
                'x_px': (x1 + x2) // 2,
                'y_top_px': min(y1, y2),
                'y_bot_px': max(y1, y2),
                'x_mm': round(((x1 + x2) // 2) / PX_PER_MM, 3),
            })

print(f'Znalezione {len(vertical_lines)} pionowych linii')

# Polacz linie o podobnej pozycji X
vertical_lines.sort(key=lambda l: l['x_px'])
merged = []
for line in vertical_lines:
    if merged and abs(line['x_px'] - merged[-1]['x_px']) < 2:
        # Polacz
        merged[-1]['y_top_px'] = min(merged[-1]['y_top_px'], line['y_top_px'])
        merged[-1]['y_bot_px'] = max(merged[-1]['y_bot_px'], line['y_bot_px'])
    else:
        merged.append(dict(line))

print(f'Po polaczeniu: {len(merged)} unikalnych X')

# Posortuj po X
merged.sort(key=lambda l: l['x_px'])
# Wyswietl w formie mm
print(f'\nWszystkie pionowe linie w mm:')
for line in merged:
    print(f"  x={line['x_mm']}mm, y={line['y_top_px']/PX_PER_MM:.2f}-{line['y_bot_px']/PX_PER_MM:.2f}mm")

# Zapisz do JSON
result = {
    'image_size': [W, H],
    'px_per_mm': PX_PER_MM,
    'vertical_lines': merged,
}
with open(r'C:\Users\mzdrowy\Desktop\Projekty Opencode\Aplikacje\XX Polecenie przelewuPDF XX\tools\vertical_lines.json', 'w', encoding='utf-8') as f:
    json.dump(result, f, indent=2, ensure_ascii=False)
print('\nZapisano: tools/vertical_lines.json')

# Generuj overlay z liniami pionowymi
img_overlay = np.array(img_pil).copy()
for line in merged:
    x1 = line['x_px'] - 2
    y1 = line['y_top_px']
    x2 = line['x_px'] + 2
    y2 = line['y_bot_px']
    cv2.rectangle(img_overlay, (x1, y1), (x2, y2), (0, 255, 0), 1)  # zielone

cv2.imwrite(r'C:\Users\mzdrowy\Desktop\Projekty Opencode\Aplikacje\XX Polecenie przelewuPDF XX\tools\vertical_lines_overlay.png', cv2.cvtColor(img_overlay, cv2.COLOR_RGB2BGR))
print('Zapisano: tools/vertical_lines_overlay.png')
