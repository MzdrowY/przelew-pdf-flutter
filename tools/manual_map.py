# -*- coding: utf-8 -*-
"""
Ręczne precyzyjne mapowanie szablonu - na podstawie inspekcji wizualnej.
Tworzy finalna mape pol z prostokatami dokladnie tam gdzie sa kratki w obrazie.
"""
import json

# Precyzyjne pozycje pol w mm - zmierzone z obrazu piksel po pikselu
# Obraz: 2480x3508 px, 1mm = 11.81 px
# A4 = 210x297 mm

# Struktura: pole ma (x, y, w, h) ramki + liczba kratek w poziomie (chars)
# Tekst jest wpisywany z automatycznym letter-spacing rownej szerokosci kazdej kratki

FIELDS = {
    'top': {
        # Górny odcinek (y=13-120mm)
        'nazwa_odbiorcy_1': {'x': 11.0, 'y': 17.5, 'w': 165.0, 'h': 5.0, 'chars': 50, 'align': 'left'},
        'nazwa_odbiorcy_2': {'x': 11.0, 'y': 25.0, 'w': 165.0, 'h': 5.0, 'chars': 50, 'align': 'left'},
        'nr_rachunku_odbiorcy': {'x': 11.0, 'y': 38.0, 'w': 165.0, 'h': 6.0, 'chars': 26, 'align': 'left'},
        'waluta': {'x': 80.0, 'y': 49.0, 'w': 15.0, 'h': 4.0, 'chars': 3, 'align': 'center'},
        'kwota': {'x': 102.0, 'y': 49.0, 'w': 74.0, 'h': 4.0, 'chars': 12, 'align': 'right'},
        'rachunek_zleceniodawcy': {'x': 11.0, 'y': 60.0, 'w': 165.0, 'h': 6.0, 'chars': 26, 'align': 'left'},
        'kwota_slownie': {'x': 11.0, 'y': 60.0, 'w': 165.0, 'h': 6.0, 'chars': 30, 'align': 'left'},
        'nazwa_zleceniodawcy_1': {'x': 11.0, 'y': 68.0, 'w': 165.0, 'h': 5.0, 'chars': 50, 'align': 'left'},
        'nazwa_zleceniodawcy_2': {'x': 11.0, 'y': 75.0, 'w': 165.0, 'h': 5.0, 'chars': 50, 'align': 'left'},
        'tytulem_1': {'x': 11.0, 'y': 81.5, 'w': 165.0, 'h': 5.0, 'chars': 50, 'align': 'left'},
        'tytulem_2': {'x': 11.0, 'y': 87.0, 'w': 165.0, 'h': 5.0, 'chars': 50, 'align': 'left'},
    },
    'bottom': {
        # Dolny odcinek (y=123-230mm)
        'nazwa_odbiorcy_1': {'x': 11.0, 'y': 108.0, 'w': 165.0, 'h': 5.0, 'chars': 50, 'align': 'left'},
        'nazwa_odbiorcy_2': {'x': 11.0, 'y': 115.5, 'w': 165.0, 'h': 5.0, 'chars': 50, 'align': 'left'},
        'nr_rachunku_odbiorcy': {'x': 11.0, 'y': 128.0, 'w': 165.0, 'h': 6.0, 'chars': 26, 'align': 'left'},
        'waluta': {'x': 80.0, 'y': 138.5, 'w': 15.0, 'h': 4.0, 'chars': 3, 'align': 'center'},
        'kwota': {'x': 102.0, 'y': 138.5, 'w': 74.0, 'h': 4.0, 'chars': 12, 'align': 'right'},
        'rachunek_zleceniodawcy': {'x': 11.0, 'y': 149.5, 'w': 165.0, 'h': 6.0, 'chars': 26, 'align': 'left'},
        'kwota_slownie': {'x': 11.0, 'y': 149.5, 'w': 165.0, 'h': 6.0, 'chars': 30, 'align': 'left'},
        'nazwa_zleceniodawcy_1': {'x': 11.0, 'y': 158.0, 'w': 165.0, 'h': 5.0, 'chars': 50, 'align': 'left'},
        'nazwa_zleceniodawcy_2': {'x': 11.0, 'y': 165.0, 'w': 165.0, 'h': 5.0, 'chars': 50, 'align': 'left'},
        'tytulem_1': {'x': 11.0, 'y': 171.5, 'w': 165.0, 'h': 5.0, 'chars': 50, 'align': 'left'},
        'tytulem_2': {'x': 11.0, 'y': 178.0, 'w': 165.0, 'h': 5.0, 'chars': 50, 'align': 'left'},
    }
}

# Zapisz
with open(r'C:\Users\mzdrowy\Desktop\Projekty Opencode\Aplikacje\XX Polecenie przelewuPDF XX\tools\fields_manual.json', 'w', encoding='utf-8') as f:
    json.dump(FIELDS, f, indent=2, ensure_ascii=False)
print('Zapisano: tools/fields_manual.json')
print('Pol: ', sum(len(v) for v in FIELDS.values()))
