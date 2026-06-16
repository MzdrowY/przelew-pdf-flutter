# Polecenie Przelewu PDF

Aplikacja desktopowa (Windows) do generowania wypełnionych poleceń przelewu / wpłat gotówkowych w formacie PDF.

## Opis

Program pozwala na szybkie i łatwe tworzenie wydruków poleceń przelewu. Dane wprowadzane są w formularzu, a aplikacja generuje PDF z automatycznie wypełnionym szablonem. Zawiera bazę odbiorców, walidację IBAN, historię przelewów oraz kalibrację pozycji pól.

## Funkcje

- Generowanie PDF przelewów z automatycznym wypełnianiem pól
- Baza odbiorców (lokalny plik JSON)
- Walidacja IBAN (algorytm mod 97)
- Konwersja kwoty na formę słowną (PL)
- Historia ostatnich 20 przelewów
- Kalibracja pozycji pól (X/Y, font, offset, szerokość komórki)
- Tryb wpłaty gotówkowej (bez numeru konta)
- Wybór odcinków do druku (górny/dolny/oba)
- Ciemny motyw z efektem szkła (glassmorphism) i animowanym tłem aurora

## Wymagania

- Windows 10/11 (64-bit)
- Brak dodatkowego oprogramowania

## Instalacja

1. Pobierz najnowszą wersję z zakładki Releases
2. Wypakuj folder do dowolnej lokalizacji
3. Uruchom `przelew_pdf.exe`

## Użycie

### Ustawienia zleceniodawcy
Wpisz swoje dane w sekcji Ustawienia (nazwa, adres, konto nadawcy) — są zapisywane automatycznie.

### Dodawanie odbiorcy
Na stronie Odbiorcy kliknij `+`, wypełnij dane (alias, nazwę, adres, konto) i zapisz.

### Generowanie przelewu
1. Wybierz odbiorcę z listy lub wpisz dane ręcznie
2. Wpisz kwotę i tytuł przelewu
3. Wybierz odcinki do druku (górny/dolny/oba)
4. Kliknij "Generuj przelew"
5. W podglądzie kliknij "Generuj PDF" — plik zostanie zapisany i otwarty

## Konfiguracja / Kalibracja

Dostępne w panelu bocznym przed generowaniem:

- **Shift X/Y** — przesunięcie wszystkich pól (mm)
- **Font pt** — rozmiar czcionki
- **Offset Y** — dodatkowe przesunięcie pionowe
- **Szer. rubryki** — szerokość komórki dla pól numerycznych

## Technologia

- **Framework:** Flutter 3.41 (Dart 3.11)
- **Stan:** Riverpod
- **Routing:** GoRouter
- **PDF:** pdf + printing (czysta generacja, bez zewnętrznego szablonu)
- **Platforma:** Windows (desktop)

## Budowanie z źródła

```bash
flutter pub get
flutter build windows --release
```

## Licencja

MIT — zobacz plik [LICENSE](LICENSE).