#!/usr/bin/env python3
"""Generuje pusty blankiet przelewu (template) - ramki, kratki, napisy.

Canvas 1000x1414 px -> 2480x3508 px (300 DPI A4).
Uzycie: python tools/generate_blankiet.py [--output sciezka] [--fill dane.json]
"""

import argparse, json, os, math
from PIL import Image, ImageDraw, ImageFont

SKALA = 2480.0 / 1000.0
W, H = int(round(1000 * SKALA)), int(round(1414 * SKALA))
FONT_PATH = r"C:\Windows\Fonts\cour.ttf"


def _s(v):
    return int(round(v * SKALA))


def _sf(v):
    return v * SKALA


def rysuj_szablon(draw, offset_y=0):
    """Rysuje strukture blankietu (ramki, kratki, etykiety) na podanym draw.
    offset_y w canvas px (0=gora, 674=kol)."""
    oy = _s(offset_y)
    czarny = (0, 0, 0)
    czerwony = (200, 0, 0)
    szary = (180, 180, 180)

    try:
        fl = ImageFont.truetype(FONT_PATH, 12)
    except IOError:
        fl = ImageFont.load_default()

    # === Główna ramka ===
    bx, by, bw, bh = _s(134), _s(46), _s(732), _s(622)
    draw.rectangle([bx, by + oy, bx + bw, by + bh + oy], outline=czarny, width=2)

    # === Lewy margines ===
    lx, ly, lw, lh = _s(134), _s(463), _s(25), _s(72)
    draw.rectangle([lx, ly + oy, lx + lw, ly + lh + oy], outline=szary, width=1)

    # === Prawy margines ===
    rx, ry, rw, rh = _s(818), _s(463), _s(25), _s(72)
    draw.rectangle([rx, ry + oy, rx + rw, ry + rh + oy], outline=szary, width=1)

    # === Główny blok siatki ===
    gx, gy, gw, gh = _s(166), _s(46), _s(652), _s(572)

    # === Rzędy kratek (skalibrowane do oryginalnego skanu 740-1034_0.png) ===
    pola = [
        ("NAZWA ODBIORCY",        66,  34, 27, 24.00),
        ("",                      100, 34, 27, 24.00),
        ("NR RACHUNKU ODBIORCY", 146,  40, 26, 24.90),
        ("",                      198,  40, 26, 24.50),  # cały rząd (W/P+waluta+kwota)
        ("NR RACHUNKU ZLECENIODAWCY", 250, 40, 26, 24.90),
        ("NAZWA ZLECENIODAWCY",   302,  34, 27, 24.00),
        ("",                      336,  34, 27, 24.00),
        ("TYTUŁEM",               382,  34, 27, 24.00),
        ("",                      416,  34, 27, 24.00),
    ]

    for etykieta, yc, hc, cc, sc in pola:
        yy = _s(yc) + oy
        hh = _s(hc)
        draw.rectangle([gx, yy, gx + gw, yy + hh], outline=czarny, width=1)
        for i in range(1, cc):
            xx = gx + _s(i * sc)
            gruba = (i in (2, 6, 10, 14, 18, 22)) and cc == 26
            draw.line([xx, yy, xx, yy + hh], fill=czerwony if gruba else czarny, width=3 if gruba else 1)
        if etykieta:
            draw.text((gx + 2, yy - _s(8)), etykieta, font=fl, fill=czerwony, anchor="lt")

    # === Wiersz specjalny Y=198: W/P + waluta + kwota ===
    y198 = _s(198) + oy
    h40 = _s(40)

    # W/P
    wp_x = _s(358)
    draw.rectangle([wp_x, y198, wp_x + _s(48), y198 + h40], outline=czarny, width=1)
    draw.line([wp_x + _s(24), y198, wp_x + _s(24), y198 + h40], fill=czarny, width=1)

    # Waluta
    wal_x = _s(435)
    wal_w = _s(72)
    draw.rectangle([wal_x, y198, wal_x + wal_w, y198 + h40], outline=czarny, width=1)
    for i in range(1, 3):
        draw.line([wal_x + _s(i * 24.0), y198, wal_x + _s(i * 24.0), y198 + h40], fill=czarny, width=1)

    # Kwota
    kw_x = _s(531)
    kw_w = _s(290)
    draw.rectangle([kw_x, y198, kw_x + kw_w, y198 + h40], outline=czarny, width=1)
    step_kw = 290.0 / 14.0
    for i in range(1, 14):
        xx = kw_x + _s(i * step_kw)
        draw.line([xx, y198, xx, y198 + h40], fill=czarny, width=1)
    # separator groszy
    draw.line([kw_x + _s(12 * step_kw), y198, kw_x + _s(12 * step_kw), y198 + h40], fill=czarny, width=3)

    # === Dolna sekcja: pieczęć, opłata, stempel ===
    # Pieczęć
    st_x, st_y, st_w, st_h = _s(168), _s(448), _s(332), _s(170)
    draw.rectangle([st_x, st_y + oy, st_x + st_w, st_y + st_h + oy], outline=czarny, width=1)

    # Opłata
    op_x, op_y, op_w, op_h = _s(506), _s(512), _s(104), _s(44)
    draw.rectangle([op_x, op_y + oy, op_x + op_w, op_y + op_h + oy], outline=czarny, width=1)
    for i in range(1, 5):
        draw.line([op_x + _s(i * 20.0), op_y + oy, op_x + _s(i * 20.0), op_y + op_h + oy], fill=czarny, width=1)

    # Stempel (okrąg)
    r = _s(57)
    scx, scy = _s(665), _s(505) + oy
    draw.ellipse([scx - r, scy - r, scx + r, scy + r], outline=czarny, width=1)


def generuj(sciezka_wyjsciowa, dane_json=None):
    img = Image.new("RGB", (W, H), (255, 255, 255))
    draw = ImageDraw.Draw(img)

    # Górny blankiet
    rysuj_szablon(draw, 0)
    # Dolny blankiet
    rysuj_szablon(draw, 674)

    # === Wypełnij danymi (jeśli podane) ===
    if dane_json:
        dane = json.loads(dane_json) if isinstance(dane_json, str) else dane_json
        try:
            fd = ImageFont.truetype(FONT_PATH, 20)
        except IOError:
            fd = ImageFont.load_default()

        # Ostateczne wartości — perfekt
        X0 = 173.0
        pola_map = [
            ("nazwa_odbiorcy_1",   X0,  34, 23.85),
            ("nazwa_odbiorcy_2",   X0,  68, 23.85),
            ("nr_rachunku_odbiorcy", X0, 114, 25.40),
            ("waluta",             439.0, 166, 23.85),
            ("kwota",              535.0, 166, 20.7),
            ("nr_rachunku_zleceniodawcy", X0, 218, 25.40),
            ("nazwa_zleceniodawcy_1", X0, 270, 23.85),
            ("nazwa_zleceniodawcy_2", X0, 304, 23.85),
            ("tytulem_1",          X0, 350, 23.85),
            ("tytulem_2",          X0, 384, 23.85),
        ]

        def rysuj_tekst(offset_y=0):
            oy_f = offset_y * SKALA
            for k, xc, yc, sc in pola_map:
                txt = str(dane.get(k, "")).upper()
                if not txt:
                    continue
                start_f = xc * SKALA + 1.0
                y_f = yc * SKALA + oy_f + 5.0
                step_f = sc * SKALA
                for i, zn in enumerate(txt):
                    if zn == ' ':
                        continue
                    px = int(round(start_f + i * step_f))
                    draw.text((px, int(round(y_f))), zn, font=fd, fill=(0, 0, 0), anchor="lt")

        rysuj_tekst(0)
        rysuj_tekst(674)

    img.save(sciezka_wyjsciowa)
    print(f"Zapisano: {sciezka_wyjsciowa} ({W}x{H} px)")
    return sciezka_wyjsciowa


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--output", "-o", default="assets/images/blankiet.png")
    ap.add_argument("--fill", "-f", default=None, help="plik JSON z danymi do wypelnienia")
    args = ap.parse_args()

    dane = None
    if args.fill:
        with open(args.fill, encoding="utf-8") as f:
            dane = f.read()

    generuj(args.output, dane)
