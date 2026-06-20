# Polecenie Przelewu PDF

Aplikacja desktopowa (Windows) do generowania wypełnionych poleceń przelewu / wpłat gotówkowych w PDF na oryginalnym blankiecie PPWG.

![screenshot](screenshot.png)

## Funkcje

- Generowanie PDF na skanie oryginalnego blankietu (2480×3508 px)
- Obsługa przelewów i wpłat gotówkowych (kwota słownie)
- Kalibrator pozycji pól (suwaki shiftX/Y, fontSize, offsetY, cellW)
- Automatyczne dopasowanie czcionki (squeeze) dla długich tekstów
- Historia przelewów (do 1000 wpisów) — kliknij, aby powtórzyć
- Lista odbiorców — szybkie wypełnianie danych
- Ciemny motyw z glassmorphism + aurora background
- Motyw biurowy (jasny)
- Instalator Windows (Inno Setup)

## Instalacja

### Opcja A: Instalator (zalecane)

Pobierz `PoleceniePrzelewuPDF_v2.0.0.exe` z katalogu `installer/` i uruchom.

### Opcja B: Budowa ze źródła

```bash
flutter pub get
flutter build windows --release
```

Efekt: `build\windows\x64\runner\Release\przelew_pdf.exe`

## Użycie

1. Wypełnij dane nadawcy w **Ustawieniach**
2. Wpisz dane odbiorcy, kwotę, tytuł przelewu
3. Kliknij **Generuj PDF** → podgląd
4. Kliknij **Drukuj** lub **Zapisz PDF**

Pozycje pól możesz korygować w kalibratorze (zakładka Ustawienia → Kalibrator).

## Wymagania

- Windows 10/11 (64-bit)
- Flutter 3.41+ / Dart 3.11+ (do budowy ze źródła)

## Tech Stack

- **Framework:** Flutter 3.41 / Dart 3.11
- **Stan:** Riverpod (StateNotifier)
- **Routing:** GoRouter
- **PDF:** pakiet `pdf` + `printing`
- **Font:** Courier New Bold (wbudowany)

## Autor

**MzdrowY** — mzdrowy@gmail.com

Strona: [https://przelewpdf.pl](https://przelewpdf.pl)

Zgłoszenia błędów, sugestie i pomysły: email lub Issues na GitHub.

## Licencja

MIT
