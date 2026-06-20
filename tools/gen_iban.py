"""Generuje prawidlowe IBAN-y."""

def big_mod97(s):
    rem = 0
    for c in s:
        rem = (rem * 10 + int(c)) % 97
    return rem

# Dla dzialajacego: nrb + "2521" + check mod 97 = 1
# To znaczy rearranged = nrb(24) + "2521" + check(2), i ten mod 97 = 1
#
# Zeby obliczyc check: rearranged = nrb + "2521" + check, rearranged mod 97 = 1
# rearranged = nrb * 10^4 + (2521 * 10^2 + check)
# = nrb * 10^4 + 252100 + check
#
# (nrb * 10^4 + 252100 + check) mod 97 = 1
# (nrb * 10^4 + 252100) mod 97 + check mod 97 = 1 (jesli check < 97)
#
# Ale problem: 10^4 mod 97 = 76, a rearranged ma 28 znakow, wiec mnozenie przez 10^4 to nie dziala prosto.

# Inne podejscie: symuluj rearranged z check=00, oblicz mod 97, potem check = 98 - rem

def compute_check(nrb24):
    # rearranged z placeholder check=00
    s = nrb24 + "2521" + "00"
    rem = big_mod97(s)
    # Chcemy rearranged z check=X: rearranged = nrb + "2521" + X
    # (nrb + "2521" + 0) + X mod 97 = 1
    # (rem + X) mod 97 = 1
    # X mod 97 = (1 - rem) mod 97
    # X = (1 - rem) mod 97, ale X musi byc 0-99
    if rem == 1:
        return "00"  # rem == 1 oznacza ze X=0
    X = (1 - rem) % 97
    if X == 0:
        X = 97
    return f'{X:02d}'

# Test
working_nrb = '109010140000071219812874'
working_check = compute_check(working_nrb)
print(f'Working NRB: {working_nrb}')
print(f'Computed check: {working_check} (oczekiwane: 61)')

# Inne NRB
nrb1 = '12345678901234567890' + '1234'
iban1 = compute_check(nrb1) + nrb1
print()
print(f'NRB1: {nrb1}')
print(f'IBAN1: {iban1}')

# Weryfikacja
def verify(iban26):
    iban = 'PL' + iban26
    rearranged = iban[4:] + iban[:4]
    numeric = ''
    for ch in rearranged:
        if ch.isalpha():
            numeric += str(ord(ch) - ord('A') + 10)
        else:
            numeric += ch
    return big_mod97(numeric)

print(f'  Weryfikacja: {verify(iban1)} (powinno byc 1)')

nrb2 = '98765432109876543210' + '9876'
iban2 = compute_check(nrb2) + nrb2
print()
print(f'NRB2: {nrb2}')
print(f'IBAN2: {iban2}')
print(f'  Weryfikacja: {verify(iban2)} (powinno byc 1)')

# Format
def format_groups(iban):
    return ' '.join([iban[i:i+4] for i in range(0, 26, 4)])

print()
print(f'Sformatowane:')
print(f'  IBAN1: {format_groups(iban1)}')
print(f'  IBAN2: {format_groups(iban2)}')
