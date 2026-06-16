# AGENTS.md — Polecenie przelewu PDF

## Projekt

Aplikacja desktopowa (Windows) do generowania wypełnionych poleceń przelewu / wpłat gotówkowych w PDF.

- **Framework:** Flutter 3.41 / Dart 3.11
- **Architektura:** feature-based (`data/` / `domain/` / `presentation/`)
- **Stan:** Riverpod (StateNotifier)
- **Routing:** GoRouter
- **PDF:** pakiet `pdf` + `printing` — generowanie od zera, bez zewnętrznego szablonu PDF

## Build i testy

```bash
flutter pub get
flutter test
flutter build windows --release
```

Efekt końcowy: `build/windows/x64/runner/Release/przelew_pdf.exe`

## Ważne notatki

- Repozytorium było puste — pierwszy commit zawiera pełny kod Flutter.
- Ikona aplikacji (`windows/runner/resources/app_icon.ico`) to tymczasowa domyślna ikona z pluginu Flutter. Warto zastąpić własną.
- Pozycje pól w PDF są zakodowane w `lib/core/constants/field_positions.dart` w mm. Użytkownik może je korygować suwakami w UI.
- `IbanValidator.format(26cyfr)` miał buga `RangeError` przy ostatnim chunku — naprawiono.
- `transferRepositoryProvider` był zdefiniowany w dwóch plikach — naprawiono.

## Style i konwencje

- Ciemny motyw (dark theme), glassmorphism, aurora background.
- Nazwy polskie w modelach biznesowych, angielskie w nazwach plików/widgetów.
- Kod jest czysty; linter (`flutter_lints`) bez ostrzeżeń.

## Co warto robić dalej

- Dodawać testy jednostkowe przy zmianach w `core/utils/`.
- Rozważyć podział `transfer_form_page.dart` (największy plik).
- Aktualizować README przy zmianach funkcjonalnych.
