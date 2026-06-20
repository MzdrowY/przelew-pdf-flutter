#!/usr/bin/env python3
"""Generator blankietu — dynamiczny podział strefy, bez sztywnych skoków.

Dla kazdego pola: (X_start, X_koniec, Y_gora, liczba_kratek).
Skrypt sam dzieli strefe i centruje kazdy znak w kratce.
"""

import json, os, sys
from PIL import Image, ImageDraw, ImageFont

SKALA = 2480.0 / 1000.0
FONT_PATH = r"C:\Windows\Fonts\cour.ttf"


def _s(v):
    return int(round(v * SKALA))


def generuj(dane_json: str, sciezka_szablon: str, sciezka_wyjsciowa: str):
    dane = json.loads(dane_json) if isinstance(dane_json, str) else dane_json
    img = Image.open(sciezka_szablon).convert("RGB")
    draw = ImageDraw.Draw(img)

    try:
        font = ImageFont.truetype(FONT_PATH, 20)
    except IOError:
        font = ImageFont.load_default()
        print("UWAGA: Courier New niedostepny, uzywam domyslnego fontu")

    # Współrzędne w canvas 1000×1414 px (skalowane do obrazka ×2.48)
    KONFIG = {
        "nazwa_odbiorcy_1":          (173, 816, 34,  27),
        "nazwa_odbiorcy_2":          (173, 816, 68,  27),
        "nr_rachunku_odbiorcy":      (173, 824, 114, 26),
        "waluta":                    (439, 508, 166, 3),
        "kwota":                     (535, 824, 166, 14),
        "nr_rachunku_zleceniodawcy": (173, 824, 218, 26),
        "nazwa_zleceniodawcy_1":     (173, 816, 270, 27),
        "nazwa_zleceniodawcy_2":     (173, 816, 304, 27),
        "tytulem_1":                 (173, 816, 350, 27),
        "tytulem_2":                 (173, 816, 384, 27),
    }

    OFFSET_DOL = 674

    def rysuj_sekcje(offset_y=0):
        oy = _s(offset_y)
        for klucz, (xs, xe, yg, nk) in KONFIG.items():
            txt = str(dane.get(klucz, "")).upper()
            if not txt:
                continue

            szer = _s(xe) - _s(xs)  # strefa w pix obrazka
            skok = szer / nk         # dynamiczny krok

            start_x = _s(xs)
            y_base = _s(yg) + oy

            for i, zn in enumerate(txt):
                if i >= nk:
                    break
                if zn == ' ':
                    continue

                kratka_x = start_x + i * skok
                bbox = draw.textbbox((0, 0), zn, font=font)
                sw = bbox[2] - bbox[0]
                sh = bbox[3] - bbox[1]

                px = kratka_x + (skok - sw) / 2
                py = y_base + (30 * SKALA - sh) / 2

                draw.text((px, py), zn, font=font, fill=(0, 0, 0))

    rysuj_sekcje(0)
    rysuj_sekcje(OFFSET_DOL)

    img.save(sciezka_wyjsciowa)
    print(f"Zapisano: {sciezka_wyjsciowa} ({img.size[0]}x{img.size[1]} px)")
    return sciezka_wyjsciowa


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--output", "-o", default="tools/wynik.png")
    ap.add_argument("--fill", "-f", default="", help="plik JSON z danymi")
    ap.add_argument("--template", "-t", default="assets/images/blankiet.png")
    args = ap.parse_args()

    if args.fill and os.path.exists(args.fill):
        with open(args.fill, encoding="utf-8") as f:
            dane = f.read()
    else:
        dane = """{
    "nazwa_odbiorcy_1": "FIRMA ABC SP. Z O.O.",
    "nazwa_odbiorcy_2": "UL. KWIATOWA 15, 00-001 WARSZAWA",
    "nr_rachunku_odbiorcy": "04123456789012345678901234",
    "waluta": "PLN",
    "kwota": "1250,50",
    "nr_rachunku_zleceniodawcy": "71987654321098765432109876",
    "nazwa_zleceniodawcy_1": "JAN KOWALSKI",
    "nazwa_zleceniodawcy_2": "UL. SLONECZNA 42, 00-002 WARSZAWA",
    "tytulem_1": "FV 2026/01/001 ZA USLUGI",
    "tytulem_2": "KONSULTINGOWE W STYCZNIU 2026"
}"""

    if not os.path.exists(args.template):
        print(f"Brak szablonu: {args.template}")
        print("Generuje szablon...")
        from generate_blankiet import rysuj_szablon
        w, h = int(round(1000 * SKALA)), int(round(1414 * SKALA))
        tmp = Image.new("RGB", (w, h), (255, 255, 255))
        tmp_draw = ImageDraw.Draw(tmp)
        rysuj_szablon(tmp_draw, 0)
        rysuj_szablon(tmp_draw, 674)
        tmp.save(args.template)
        print(f"Szablon zapisany: {args.template}")

    generuj(dane, args.template, args.output)
