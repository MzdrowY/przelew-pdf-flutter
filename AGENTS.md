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

---

# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
