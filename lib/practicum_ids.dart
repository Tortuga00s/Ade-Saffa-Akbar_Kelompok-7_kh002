const nim = '20240801071';
final lastThreeDigits = nim.substring(nim.length - 3);
final shiftedDigits =
    lastThreeDigits[0] + lastThreeDigits[2] + lastThreeDigits[1];
final n = int.parse(shiftedDigits);
final userIdFromNim = 1499 + n;
final adminIdFromNim = 792 + n;
