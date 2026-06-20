#!/usr/bin/env python3
"""Wypełnia blankiet przelewu danymi — tekst centrowany w kratkach.

Zamiast zgadywać pozycje, obliczamy je z geometrii siatki:
  - X kratki = lewy_brzeg + i * krok
  - tekst centrowany w poziomie i pionie wewnątrz kratki
  - zero hardcoded offsets — wszystko z jednego źródła prawdy
"""

import json, os, sys
from PIL import Image, ImageDraw, ImageFont

SKALA = 2480.0 / 1000.0  # canvas 1000 → obraz 2480
FONT_PATH = r"C:\Windows\Fonts\cour.ttf"

# ============================================================
# GEOMETRIA SIATKI (canvas px) — jedyne źródło prawdy
# Identyczne jak w rysuj_szablon() z generate_blankiet.py
# ============================================================

# Lewy brzeg siatki kratek (skalibrowane do oryginalnego skanu 740-1034_0.png)
GRID_LEFT = 169.0

# (nazwa_pola, Y_canvas, wysokosc_canvas, liczba_kratek, krok_canvas)
WIERSZE = [
    ("nazwa_odbiorcy_1",          66,  34, 27, 24.00),
    ("nazwa_odbiorcy_2",         100,  34, 27, 24.00),
    ("nr_rachunku_odbiorcy",     146,  40, 26, 24.90),
    ("nr_rachunku_zleceniodawcy", 250, 40, 26, 24.90),
    ("nazwa_zleceniodawcy_1",    302,  34, 27, 24.00),
    ("nazwa_zleceniodawcy_2",    336,  34, 27, 24.00),
    ("tytulem_1",                382,  34, 27, 24.00),
    ("tytulem_2",                416,  34, 27, 24.00),
]

# Wiersz specjalny: Y=198, h=40
# Waluta: x=435, 3 kratki po 24.0
# Kwota:  x=531, 14 kratek po 290/14
WALUTA_X, WALUTA_KROK, WALUTA_N = 435.0, 24.0, 3
KWOTA_X,  KWOTA_KROK,  KWOTA_N  = 531.0, 290.0 / 14.0, 14

OFFSET_DOL = 646.0  # dolny blankiet (oryginalny skan: delta 1603 img px)


def canvas_to_img(x, y=0):
    """canvas px → image px"""
    return int(round(x * SKALA)), int(round(y * SKALA))


def _draw_text_centered(draw, img_x, img_y, img_w, img_h, znak, font, fill=(0,0,0)):
    """Rysuje znak wycentrowany w prostokacie (img_x, img_y, img_w, img_h)."""
    bbox = draw.textbbox((0, 0), znak, font=font)
    sw = bbox[2] - bbox[0]
    sh = bbox[3] - bbox[1]
    # ascender offset — textbbox zwraca bounding box od ascendera
    asc = -bbox[1]
    px = img_x + (img_w - sw) / 2
    py = img_y + (img_h - sh) / 2 - asc * 0.1  # lekka korekta ascendera
    draw.text((px, py), znak, font=font, fill=fill)


def wypelnij(img: Image.Image, dane: dict) -> Image.Image:
    """Wypełnia obraz danymi. Zwraca nowy obraz."""
    img = img.copy()
    draw = ImageDraw.Draw(img)

    try:
        font = ImageFont.truetype(FONT_PATH, 30)
    except IOError:
        font = ImageFont.load_default()

    # Wersja bold - Courier New Bold jeśli dostępna
    try:
        font_bold = ImageFont.truetype(r"C:\Windows\Fonts\courbd.ttf", 30)
    except IOError:
        font_bold = font

    # Fonty takie jak w Flutter (field_positions.dart)
    try:
        font_nazwa = ImageFont.truetype(r"C:\Windows\Fonts\cour.ttf", 18)   # nfs=6.5 → ~18px
        font_iban = ImageFont.truetype(r"C:\Windows\Fonts\cour.ttf", 19)    # ifs=7.0 → ~19px
        font_kwota = ImageFont.truetype(r"C:\Windows\Fonts\cour.ttf", 17)   # sfs=6.0 → ~17px
    except IOError:
        font_nazwa = font_iban = font_kwota = font

    def renderuj_sekcje(dane_sekcji, offset_canvas=0):
        off_img = offset_canvas * SKALA

        # Zwykle wiersze
        for nazwa, yc, hc, nk, sc in WIERSZE:
            txt = str(dane_sekcji.get(nazwa, "")).upper()
            if not txt:
                continue
            y_top = yc * SKALA + off_img
            h = hc * SKALA
            krok = sc * SKALA

            # Wybierz font depending na typ pola
            if "rachunku" in nazwa:
                f = font_iban
            else:
                f = font_nazwa

            for i, zn in enumerate(txt):
                if i >= nk:
                    break
                if zn == ' ':
                    continue
                cx = (GRID_LEFT + i * sc) * SKALA
                _draw_text_centered(draw, cx, y_top, krok, h, zn, f)

        # Waluta (3 kratki)
        wal = str(dane_sekcji.get("waluta", "")).upper()
        if wal:
            y198 = 198.0 * SKALA + off_img
            h40 = 40.0 * SKALA
            for i, zn in enumerate(wal):
                if i >= WALUTA_N:
                    break
                if zn == ' ':
                    continue
                cx = (WALUTA_X + i * WALUTA_KROK) * SKALA
                _draw_text_centered(draw, cx, y198, WALUTA_KROK * SKALA, h40, zn, font_kwota)

        # Kwota (14 kratek)
        kwota = str(dane_sekcji.get("kwota", "")).upper()
        if kwota:
            y198 = 198.0 * SKALA + off_img
            h40 = 40.0 * SKALA
            for i, zn in enumerate(kwota):
                if i >= KWOTA_N:
                    break
                if zn in (' ', ',', '.'):
                    continue
                cx = (KWOTA_X + i * KWOTA_KROK) * SKALA
                _draw_text_centered(draw, cx, y198, KWOTA_KROK * SKALA, h40, zn, font_kwota)

    renderuj_sekcje(dane, 0)
    renderuj_sekcje(dane, OFFSET_DOL)

    return img


def generuj_blankiet():
    """Generuje pusty szablon (call generate_blankiet.py)."""
    from generate_blankiet import generuj
    return generuj("assets/images/blankiet.png")


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--output", "-o", default="tools/wynik.png")
    ap.add_argument("--fill", "-f", default="", help="plik JSON z danymi")
    ap.add_argument("--template", "-t", default="assets/images/blankiet.png")
    args = ap.parse_args()

    # Załaduj szablon
    if not os.path.exists(args.template):
        print(f"Brak szablonu: {args.template} — generuję...")
        generuj_blankiet()

    template = Image.open(args.template).convert("RGB")

    # Załaduj dane
    if args.fill and os.path.exists(args.fill):
        with open(args.fill, encoding="utf-8") as f:
            dane = json.load(f)
    else:
        dane = {
            "nazwa_odbiorcy_1": "FIRMA ABC SP. Z O.O.",
            "nazwa_odbiorcy_2": "UL. KWIATOWA 15, 00-001 WARSZAWA",
            "nr_rachunku_odbiorcy": "04123456789012345678901234",
            "waluta": "PLN",
            "kwota": "1250,50",
            "nr_rachunku_zleceniodawcy": "71987654321098765432109876",
            "nazwa_zleceniodawcy_1": "JAN KOWALSKI",
            "nazwa_zleceniodawcy_2": "UL. SLONECZNA 42, 00-002 WARSZAWA",
            "tytulem_1": "FV 2026/01/001 ZA USLUGI",
            "tytulem_2": "KONSULTINGOWE W STYCZNIU 2026",
        }

    wynik = wypelnij(template, dane)
    wynik.save(args.output)
    print(f"Zapisano: {args.output} ({wynik.size[0]}x{wynik.size[1]} px)")
