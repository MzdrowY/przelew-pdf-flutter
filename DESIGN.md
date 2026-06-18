# DESIGN.md — System motywów i stylu aplikacji

## Przegląd architektury

Aplikacja używa **ThemeExtension** (`AppThemeColors`) do definiowania kompletnych palet kolorów dla każdego motywu. To pozwala na:
- Pełną kontrolę nad każdym kolorem bez zależności od Material ColorScheme
- Łatwe przełączanie motywów przez `AppThemeMode` (Riverpod)
- Dostęp do kolorów w widgetach przez `context.appColors`

## Motywy

### 1. Ciemny (domyślny) — `AppThemeColors.dark()`
| Rola | Kolor | Hex | Użycie |
|------|-------|-----|--------|
| Primary | Fioletowy | `#7C75FF` | Przyciski główne, akcenty |
| Primary Soft | Jasny fiolet | `#9D97FF` | Hover, ripple |
| Accent | Cyjan | `#4ECDC4` | Drugorzędne akcje |
| Background Top | Głęboka granat | `#0A0A14` | Górna część tła (gradient) |
| Background Bottom | Ciemniejszy granat | `#14141E` | Dolna część tła |
| Surface | Ciemny granat | `#1A1A26` | Karty, panele |
| Surface Elevated | Nieco jaśniejszy | `#222230` | Podniesione elementy |
| Field | Bardzo ciemny | `#12121E` | Pola formularzy |
| Text Primary | Prawie biały | `#EEEEF4` | Nagłówki, główne treści |
| Text Secondary | Przygaszony | `#88889A` | Opisy, etykiety |
| Text Tertiary | Ciemniejszy | `#5A5A6E` | Placeholdery, pomocnicze |
| Border | Subtelny | `#2A2A3E` | Ramki, podziały |
| Error | Czerwony | `#E0454B` | Błędy walidacji |
| Warning | Pomarańcz | `#E8A838` | Ostrzeżenia |
| Success | Zielony | `#34B78F` | Sukcesy |

**Specyfika:**
- `useAurora: true` — animowany gradient aurory na tle (`AuroraBackground`)
- `isDark: true` — dla logiki komponentów (np. `GlassCard`)

---

### 2. Biuro (jasny) — `AppThemeColors.office()`
| Rola | Kolor | Hex | Użycie |
|------|-------|-----|--------|
| Primary | Terakota | `#C75B33` | Przyciski główne, akcje |
| Primary Soft | Jaśniejsza terakota | `#E07B56` | Hover, ripple |
| Accent | Szałwia | `#4A7C6F` | Drugorzędne akcje |
| Background Top | Ciepły beż | `#F5F0E8` | Tło strony (górne) |
| Background Bottom | Cieńszy beż | `#EBE5DA` | Tło strony (dolne) |
| Surface | **Czysta biel** | `#FFFFFF` | Karty, panele — "papier na biurku" |
| Surface Elevated | Bardzo blady beż | `#FAF8F5` | Zagnieżdżone karty |
| Field | Jasny beż | `#F0EDE6` | Pola formularzy |
| Text Primary | Prawie czarny | `#1A1814` | Główne treści (kontrast ~17:1) |
| Text Secondary | Szaro-brązowy | `#5A564F` | Etykiety, opisy (kontrast ~7.3:1) |
| Text Tertiary | Średni szarobrąz | `#7A756D` | Placeholdery (kontrast ~4.6:1, **WCAG AA**) |
| Border | Widoczny beż | `#D4CEC4` | Ramki pól, kart |
| Error | Ciemnoczerwony | `#BA1A1A` | Błędy |
| Warning | Bursztyn | `#E8A117` | Ostrzeżenia |
| Success | Leśna zieleń | `#2E7D46` | Sukcesy |

**Zasady projektowe (light theme):**
- **Tło jest przygaszone** (beż), **powierzchnie są białe** — karta "unoszy się" nad biurkiem
- Tekst jest **ciemny, wysoki kontrast** — nie "szary na szarym"
- Kolory akcji (primary/accent) są **nasycone**, nie rozjaśnione
- Cienie (`BoxShadow`) zamiast blur — Material elevation
- Brak aurory (`useAurora: false`)

---

## Struktura plików

```
lib/core/theme/
├── app_theme_colors.dart    # ThemeExtension + palety (dark, office)
├── app_theme.dart           # ThemeData factory (AppTheme.forMode)
└── app_theme_mode.dart      # Enum + Provider (Riverpod)

lib/utils/
└── window_utils.dart        # MethodChannel do natywnego paska tytułowego

lib/shared/widgets/
├── glass_card.dart          # Karta: dark=blur+glow, light=shadow+border
├── custom_text_field.dart   # Pole formularza (theme-aware)
└── app_button.dart          # Przycisk (gradient w dark, solid w light)

windows/runner/
├── window_utils.h           # Deklaracje natywnego kanału
├── window_utils.cpp         # Implementacja DWM title bar
├── flutter_window.cpp       # Rejestracja kanału w OnCreate
└── CMakeLists.txt           # Dodanie window_utils.cpp do buildu
```

---

## Jak dodać nowy motyw

1. Dodaj `factory AppThemeColors.nowaNazwa()` w `app_theme_colors.dart`
2. Dodaj `case` w `AppThemeMode` enum (`app_theme_mode.dart`)
3. Rozszerz `AppTheme.forMode()` w `app_theme.dart`
4. Zaktualizuj `SettingsPage` (dropdown motywów)
5. Jeśli motyw ma inny pasek tytułowy, dostosuj logikę w `WindowUtils.setTitleBarDarkMode` lub dodaj nowe metody w `window_utils.cpp`

---

## Górny pasek tytułowy (Windows Title Bar)

Pasek tytułowy jest sterowany natywnie przez C++, a nie przez zewnętrzny pakiet. To unika problemów z renderowaniem, które wystąpiły przy próbie użycia `window_manager`/`WindowCaption`.

### Implementacja

**Dart:** `lib/utils/window_utils.dart`
- `WindowUtils.setTitleBarDarkMode(bool isDark)` wysyła wiadomość przez `MethodChannel('window_utils')`.
- Wywoływany przy starcie aplikacji oraz przy każdej zmianie motywu (`app.dart`).

**C++:** `windows/runner/window_utils.cpp`, `window_utils.h`
- Rejestruje kanał `window_utils` w silniku Flutter.
- Obsługuje metodę `setTitleBarDarkMode` i ustawia `DWMWA_USE_IMMERSIVE_DARK_MODE` dla głównego HWND okna.
- `TRUE` → ciemny pasek (motyw ciemny)
- `FALSE` → jasny pasek bez niebieskiego akcentu systemowego (motyw Biuro)

**Integracja:** `windows/runner/flutter_window.cpp`
- `RegisterWindowUtils(flutter_controller_->engine(), GetHandle())` jest wywoływane po `RegisterPlugins`.

**Build:** `windows/runner/CMakeLists.txt`
- Dołączono `window_utils.cpp` do listy źródeł.
- `dwmapi.lib` jest już linkowany.

---

## Dostęp do kolorów w kodzie

```dart
final colors = context.appColors;
Container(color: colors.surface);
Text('Tekst', style: TextStyle(color: colors.textPrimary));
```

---

## Zasady kontrastu (WCAG)

| Para | Wymaganie AA | Wymaganie AAA | Stan w `office` |
|------|--------------|---------------|-----------------|
| textPrimary / surface | 4.5:1 | 7:1 | **17:1** ✓ |
| textSecondary / surface | 4.5:1 | 7:1 | **7.3:1** ✓ (AA/AAA large) |
| textTertiary / surface | 4.5:1 | 7:1 | **4.6:1** ✓ (AA) |
| border / surface | 3:1 | 4.5:1 | **2.3:1** ⚠ (UI component) |

`textTertiary` spełnia AA dla tekstu (>18pt lub bold >14pt). Dla mniejszych rozmiarów rozważyć przyciemnienie do `#6A655D`.

---

## GlassCard — zachowanie per motyw

```dart
// Dark
BackdropFilter(blur: 12) + gradient surface + primary glow shadow

// Light
Brak blur. Czysty surface (white) + border + 2 warstwy BoxShadow:
  - 0x0A000000, blur 8, offset (0,2)
  - 0x05000000, blur 4, offset (0,1)
```

---

## AppButton — zachowanie per motyw

```dart
// Dark
gradient: [primary, primaryGlow], shadow: primary @ 0.20

// Light
gradient: [primary, primaryGlow], shadow: primary @ 0.35 (mocniejszy na białym)
```

---

## Testowanie

```bash
flutter analyze    # lint
flutter test       # testy jednostkowe
flutter build windows --release  # produkcyjny EXE
```

---

## Uwagi do dalszego rozwoju

- Rozważyć `ThemeMode.system` (obserwacja systemowego motywu)
- Dodać motyw "High Contrast" dla dostępności
- Ikona aplikacji (`windows/runner/resources/app_icon.ico`) — zastąpić własną
- Rozważyć podział `transfer_form_page.dart` (największy plik)