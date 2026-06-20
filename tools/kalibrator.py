#!/usr/bin/env python3
"""
Kalibrator PPWG — v2.
Uruchom: python tools/kalibrator.py
"""

import json
import os
import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageDraw, ImageFont, ImageTk

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BLANKIET_PATH = os.path.join(BASE, 'assets', 'images', 'blankiet.png')
FONT_PATH = r'C:\Windows\Fonts\courbd.ttf'
EXPORT_PATH = os.path.join(BASE, 'lib', 'core', 'constants', 'field_positions.dart')

BLANKIET_IMG = Image.open(BLANKIET_PATH).convert('RGB')
IW, IH = BLANKIET_IMG.size  # 2480, 3508
C2I = IW / 1000.0  # canvas->image scale 2.48
PT2PX = 300.0 / 72.0

_font_cache = {}
def get_font(pt):
    k = round(pt, 1)
    if k not in _font_cache:
        _font_cache[k] = ImageFont.truetype(FONT_PATH, int(round(k * PT2PX)))
    return _font_cache[k]

FIELDS = [
    ("nazwa_odbiorcy",   "Nazwa odbiorcy",    66,   9.0, 27, 34.0, 2, "JAN KOWALSKI SP Z O O",        "UL. POLNA 123", False),
    ("rach_odbiorcy",    "Rach. odbiorcy",    146,  10.0, 26, 40.0, 1, "12345678901234567890123456", None, False),
    ("waluta",           "Waluta",            198,  8.5, 3,  40.0, 1, "PLN",                         None, False),
    ("kwota",            "Kwota",             198,  8.5, 12, 40.0, 1, "**5,00",                       None, True),
    ("rach_zleceniodawcy","Rach zleceniodawcy",250,  10.0, 26, 40.0, 1,
     "PIEC ZLOTYCH ZERO GROSZY", None, True),
    ("nazwa_zleceniodawcy","Nazwa zleceniodawcy",302,9.0, 27, 34.0, 2, "FIRMA XYZ SP Z O O",         "UL. PRZYKLADOWA 456", False),
    ("tytulem",          "Tytulem",           382,  9.0, 27, 34.0, 2, "FAKTURA NR 1234 Z DNIA",       "01.01.2024", False),
]

class App:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Kalibrator PPWG v2")
        self.root.geometry("1500x950")

        # State: all params as DoubleVar
        self.P = {}
        for k, v in [("startX",169),("bottomOff",646),("step27",24.0),("step26",24.9)]:
            self.P[k] = tk.DoubleVar(value=v)
        for fid, _, y, sz, ch, rh, rows, t1, t2, _ in FIELDS:
            self.P[f"{fid}_y"] = tk.DoubleVar(value=y)
            self.P[f"{fid}_size"] = tk.DoubleVar(value=sz)
            xdef = {"waluta": 435, "kwota": 531}.get(fid, 169)
            self.P[f"{fid}_x"] = tk.DoubleVar(value=xdef)
            if fid == "kwota":
                self.P[f"{fid}_step"] = tk.DoubleVar(value=290.0/12.0)
            elif fid == "waluta":
                self.P[f"{fid}_step"] = tk.DoubleVar(value=24.0)
            elif ch == 27:
                self.P[f"{fid}_step"] = tk.DoubleVar(value=24.0)
            else:  # 26-char fields
                self.P[f"{fid}_step"] = tk.DoubleVar(value=24.9)
        self._show_grid = tk.BooleanVar(value=True)
        self._show_text = tk.BooleanVar(value=True)
        self._zoom = tk.DoubleVar(value=0.25)
        self._photo = None
        self._pending = False

        self._build()
        self._load_state()
        self._render()

    def _vals(self):
        return {k: v.get() for k, v in self.P.items()}

    def _render(self):
        v = self._vals()
        img = BLANKIET_IMG.copy()
        draw = ImageDraw.Draw(img)
        sg = self._show_grid.get()
        st = self._show_text.get()

        for fid, label, y_def, sz_def, ch, rh, rows, t1, t2, fillDashes in FIELDS:
            cx = v.get(f"{fid}_x", 169.0)
            cy = v.get(f"{fid}_y", y_def)
            size = v.get(f"{fid}_size", sz_def)
            step = v.get(f"{fid}_step", 24.0)

            for off_name, off_val in [("gorny",0), ("dolny",v.get("bottomOff",646))]:
                oy = cy + off_val
                cx_i = cx * C2I
                cy_i = oy * C2I
                st_i = step * C2I
                rh_i = rh * C2I

                if sg:
                    c = (255,0,0) if off_val==0 else (0,0,255)
                    for ri in range(rows+1):
                        yy = cy_i + ri * rh_i
                        draw.line([(cx_i,yy),(cx_i+ch*st_i,yy)],fill=c,width=2)
                    for ci in range(ch+1):
                        xx = cx_i + ci * st_i
                        draw.line([(xx,cy_i),(xx,cy_i+rows*rh_i)],fill=c,width=1)

                if st:
                    font = get_font(size)
                    texts = [t1]
                    if rows > 1 and t2:
                        texts.append(t2)
                    for ri, txt in enumerate(texts):
                        if len(txt) > ch:
                            ratio = ch / len(txt)
                            eff_step = st_i * ratio
                            for ci, ch_ in enumerate(txt):
                                if ch_ == ' ':
                                    continue
                                cl = cx_i + ci * eff_step
                                cc = cl + eff_step / 2
                                bb = draw.textbbox((0,0), ch_.upper(), font=font)
                                cw = bb[2]-bb[0]
                                chh = bb[3]-bb[1]
                                tx = cc - cw/2
                                ty = cy_i + ri*rh_i + (rh_i - chh)/2
                                draw.text((tx,ty), ch_.upper(), fill='black', font=font)
                        else:
                            limit = ch if fillDashes else len(txt)
                            for ci in range(limit):
                                ch_ = txt[ci] if ci < len(txt) else '-'
                                if ch_ == ' ':
                                    continue
                                cl = cx_i + ci * st_i
                                cc = cl + st_i / 2
                                bb = draw.textbbox((0,0), ch_.upper(), font=font)
                                cw = bb[2]-bb[0]
                                chh = bb[3]-bb[1]
                                tx = cc - cw/2
                                ty = cy_i + ri*rh_i + (rh_i - chh)/2
                                draw.text((tx,ty), ch_.upper(), fill='black', font=font)

        z = self._zoom.get()
        nw = max(1, int(img.width * z))
        nh = max(1, int(img.height * z))
        disp = img.resize((nw, nh), Image.LANCZOS)
        self._photo = ImageTk.PhotoImage(disp)
        self.canvas.delete("all")
        self.canvas.create_image(0, 0, image=self._photo, anchor=tk.NW)
        self.canvas.config(scrollregion=(0,0,nw,nh))

    def _schedule(self, _=None):
        if self._pending:
            return
        self._pending = True
        self.root.after(30, self._do_render)

    def _do_render(self):
        self._pending = False
        self._render()

    def _build(self):
        pw = ttk.PanedWindow(self.root, orient=tk.HORIZONTAL)
        pw.pack(fill=tk.BOTH, expand=True)

        lf = ttk.Frame(pw)
        pw.add(lf, weight=3)
        tb = ttk.Frame(lf)
        tb.pack(fill=tk.X, padx=5, pady=2)
        ttk.Checkbutton(tb, text="Siatka", variable=self._show_grid,
            command=self._schedule).pack(side=tk.LEFT, padx=2)
        ttk.Checkbutton(tb, text="Tekst", variable=self._show_text,
            command=self._schedule).pack(side=tk.LEFT, padx=2)
        ttk.Label(tb, text="Zoom:").pack(side=tk.LEFT, padx=(10,2))
        zs = ttk.Scale(tb, from_=0.05, to=1.0, variable=self._zoom,
            orient=tk.HORIZONTAL, command=self._schedule)
        zs.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0,10))
        ttk.Label(tb, textvariable=self._zoom, width=5).pack(side=tk.RIGHT, padx=2)

        cf = ttk.Frame(lf)
        cf.pack(fill=tk.BOTH, expand=True)
        self.hbar = ttk.Scrollbar(cf, orient=tk.HORIZONTAL)
        self.vbar = ttk.Scrollbar(cf, orient=tk.VERTICAL)
        self.canvas = tk.Canvas(cf, xscrollcommand=self.hbar.set,
            yscrollcommand=self.vbar.set, bg='#555')
        self.hbar.config(command=self.canvas.xview)
        self.vbar.config(command=self.canvas.yview)
        self.hbar.pack(side=tk.BOTTOM, fill=tk.X)
        self.vbar.pack(side=tk.RIGHT, fill=tk.Y)
        self.canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self.canvas.bind("<MouseWheel>", self._wheel)
        self.canvas.bind("<ButtonPress-3>", self._drag_start)
        self.canvas.bind("<B3-Motion>", self._drag_move)
        self._dd = {"x":0,"y":0}

        rf = ttk.Frame(pw, width=420)
        pw.add(rf, weight=1)
        nb = ttk.Notebook(rf)
        nb.pack(fill=tk.BOTH, expand=True, padx=3, pady=3)

        gf = ttk.Frame(nb)
        nb.add(gf, text="Global")
        for k, lbl, lo, hi in [
            ("startX","Start X", 80, 300),
            ("bottomOff","Bottom offset", 400, 900),
            ("step27","Step 27-znak", 15, 35),
            ("step26","Step 26-znak", 15, 35),
        ]:
            self._slder(gf, lbl, k, lo, hi)

        for fid, label, y_def, sz_def, ch, rh, rows, t1, t2, _ in FIELDS:
            ff = ttk.Frame(nb)
            nb.add(ff, text=label)
            xlo, xhi = {"kwota": (300,700), "waluta": (200,650)}.get(fid, (50,400))
            self._slder(ff, "X", f"{fid}_x", xlo, xhi)
            self._slder(ff, "Y", f"{fid}_y", 0, 800)
            self._slder(ff, "Font size", f"{fid}_size", 2, 16)
            self._slder(ff, "Step", f"{fid}_step", 15, 35)

        bf = ttk.Frame(rf)
        bf.pack(fill=tk.X, padx=5, pady=5)
        ttk.Button(bf, text="Load state", command=self._load_state).pack(
            side=tk.LEFT, padx=1, fill=tk.X, expand=True)
        ttk.Button(bf, text="Save state", command=self._save_state).pack(
            side=tk.LEFT, padx=1, fill=tk.X, expand=True)
        ttk.Button(bf, text="Export", command=self._export).pack(
            side=tk.LEFT, padx=1, fill=tk.X, expand=True)

    def _slder(self, parent, label, key, lo, hi):
        f = ttk.Frame(parent)
        f.pack(fill=tk.X, padx=4, pady=2)
        ttk.Label(f, text=label, width=12, anchor=tk.W).pack(side=tk.LEFT)
        var = self.P[key]
        s = ttk.Scale(f, from_=lo, to=hi, variable=var,
            orient=tk.HORIZONTAL, command=self._schedule)
        s.pack(side=tk.LEFT, fill=tk.X, expand=True)
        ttk.Label(f, textvariable=var, width=7).pack(side=tk.RIGHT, padx=2)
        ttk.Label(f, text=str(round((hi-lo)/2+lo,1)), width=0).pack()

    def _save_state(self):
        sf = os.path.join(BASE, 'tools', 'kalibrator_state.json')
        with open(sf, 'w') as f:
            json.dump(self._vals(), f, indent=2)

    def _load_state(self):
        sf = os.path.join(BASE, 'tools', 'kalibrator_state.json')
        saved = None
        if os.path.exists(sf):
            try:
                with open(sf) as f:
                    saved = json.load(f)
            except Exception:
                pass
        if saved is None and os.path.exists(EXPORT_PATH):
            saved = {}
            try:
                for line in open(EXPORT_PATH):
                    line = line.strip()
                    for key in ["bottomOffsetPx","cellStep27Px","cellStep26Px"]:
                        if line.startswith(f"static const double {key} ="):
                            saved[key] = float(line.split("=")[1].strip().rstrip(";"))
                    for key in ["walutaXPx","walutaStepPx","kwotaXPx"]:
                        if line.startswith(f"static const double {key} ="):
                            saved[key] = float(line.split("=")[1].strip().rstrip(";"))
                    for xkey, fid in [("nazwaOdbiorcyXPx","nazwa_odbiorcy"),
                                      ("nrRachunkuOdbiorcyXPx","rach_odbiorcy"),
                                      ("rachunekZleceniodawcyXPx","rach_zleceniodawcy"),
                                      ("nadawcaNazwaXPx","nazwa_zleceniodawcy"),
                                      ("tytulemXPx","tytulem")]:
                        if line.startswith(f"static const double {xkey} ="):
                            saved[f"{fid}_x"] = float(line.split("=")[1].strip().rstrip(";"))
                    for ykey, fid in [("nazwaOdbiorcyTop","nazwa_odbiorcy"),
                                      ("nrRachunkuOdbiorcyTop","rach_odbiorcy"),
                                      ("kwotaTop","kwota"),
                                      ("rachunekZleceniodawcyTop","rach_zleceniodawcy"),
                                      ("nadawcaNazwaTop","nazwa_zleceniodawcy"),
                                      ("tytulemTop","tytulem")]:
                        if line.startswith(f"static const double {ykey} ="):
                            saved[f"{fid}_y"] = float(line.split("=")[1].strip().rstrip(";"))
                mapping = {"bottomOffsetPx":"bottomOff",
                           "cellStep27Px":"step27","cellStep26Px":"step26",
                           "walutaXPx":"waluta_x","walutaStepPx":"waluta_step",
                           "kwotaXPx":"kwota_x"}
                dart_to_cal = {}
                for dk, ck in mapping.items():
                    if dk in saved:
                        dart_to_cal[ck] = saved[dk]
                for line in open(EXPORT_PATH):
                    if "kwotaStepPx" in line and "/" in line:
                        parts = line.split("=>")[-1].strip().rstrip(";")
                        try:
                            num, den = parts.split("/")
                            dart_to_cal["kwota_step"] = float(num.strip()) / float(den.strip())
                        except: pass
                        break
                for k, var in self.P.items():
                    if k in dart_to_cal:
                        var.set(dart_to_cal[k])
            except Exception as e:
                print(f"Load from export err: {e}")
                saved = None
        if saved:
            for k, var in self.P.items():
                if k in saved:
                    var.set(saved[k])

    def _export(self):
        v = self._vals()
        def g(k, d=0):
            return round(v.get(k, d), 1)
        bo = g("bottomOff", 646)
        s27 = g("step27", 24.0)
        s26 = g("step26", 24.9)

        def y(fid):
            return g(f"{fid}_y", 66)
        def x(fid):
            return g(f"{fid}_x", 169)
        def step(fid):
            return g(f"{fid}_step", 24.0)

        wX = x("waluta")
        wStep = step("waluta")
        kwX = x("kwota")
        kwStep = step("kwota")
        ny = y("nazwa_odbiorcy")
        nx = x("nazwa_odbiorcy")
        rx = x("rach_odbiorcy")
        rry = y("rach_odbiorcy")
        kwy = y("kwota")
        rzx = x("rach_zleceniodawcy")
        rzy = y("rach_zleceniodawcy")
        nzx = x("nazwa_zleceniodawcy")
        nzy = y("nazwa_zleceniodawcy")
        tx = x("tytulem")
        tyt = y("tytulem")

        c = f"""/// Pozycje pol na blankiecie w pikselach (canvas 1000x1414 px).
/// GENERATED by tools/kalibrator.py
class FieldPositions {{
  FieldPositions._();

  static const double pxToPt = 595.28 / 1000.0;

  static const double bottomOffsetPx = {bo};

  static const double cellStep27Px = {s27};
  static const double cellWidth27Px = 21.0;
  static const double cellStep26Px = {s26};
  static const double cellWidth26Px = 22.0;

  static const double nazwaOdbiorcyXPx = {nx};
  static const double nazwaOdbiorcyTop = {ny};
  static const double nazwaOdbiorcyH = 34.0;
  static const double nazwaOdbiorcyCdTop = {round(ny+34,1)};
  static const double nazwaOdbiorcyCdH = 34.0;
  static const double nrRachunkuOdbiorcyXPx = {rx};
  static const double nrRachunkuOdbiorcyTop = {rry};
  static const double nrRachunkuOdbiorcyH = 40.0;
  static const double kwotaTop = {kwy};
  static const double kwotaH = 40.0;
  static const double rachunekZleceniodawcyXPx = {rzx};
  static const double rachunekZleceniodawcyTop = {rzy};
  static const double rachunekZleceniodawcyH = 40.0;
  static const double nadawcaNazwaXPx = {nzx};
  static const double nadawcaNazwaTop = {nzy};
  static const double nadawcaNazwaH = 34.0;
  static const double nadawcaAdresTop = {round(nzy+34,1)};
  static const double nadawcaAdresH = 34.0;
  static const double tytulemXPx = {tx};
  static const double tytulemTop = {tyt};
  static const double tytulemH = 34.0;
  static const double tytulemCdTop = {round(tyt+34,1)};
  static const double tytulemCdH = 34.0;

  static const double walutaXPx = {wX};
  static const double walutaStepPx = {wStep};
  static const double kwotaXPx = {kwX};
  static const double kwotaStepPx = {kwStep};
  static const double kwotaCellWidthPx = 18.0;
}}
"""
        with open(EXPORT_PATH, 'w', encoding='utf-8') as f:
            f.write(c)
        self._save_state()
        print(f"OK -> {EXPORT_PATH}")

    def _wheel(self, e):
        z = self._zoom.get()
        dz = 0.05 if e.delta > 0 else -0.05
        self._zoom.set(max(0.05, min(2.0, z+dz)))
        self._render()

    def _drag_start(self, e):
        self._dd["x"] = e.x; self._dd["y"] = e.y

    def _drag_move(self, e):
        dx = self._dd["x"] - e.x; dy = self._dd["y"] - e.y
        self.canvas.xview_scroll(dx, "units")
        self.canvas.yview_scroll(dy, "units")
        self._dd["x"] = e.x; self._dd["y"] = e.y

    def run(self):
        self.root.mainloop()

if __name__ == '__main__':
    App().run()
