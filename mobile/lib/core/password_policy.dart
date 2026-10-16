/// Admin-set password: min 8, ≥1 letter, ≥1 digit, ≥1 special char.
bool isValidAdminPassword(String password) {
  if (password.length < 8) return false;
  if (!RegExp(r'[A-Za-z]').hasMatch(password)) return false;
  if (!RegExp(r'[0-9]').hasMatch(password)) return false;
  if (!RegExp(r'[^A-Za-z0-9]').hasMatch(password)) return false;
  return true;
}
