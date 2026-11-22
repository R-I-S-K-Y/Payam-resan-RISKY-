const _faDigits = '۰۱۲۳۴۵۶۷۸۹';

/// تبدیل ارقام انگلیسی به فارسی.
String faDigits(String input) {
  return input.replaceAllMapped(
    RegExp(r'\d'),
    (m) => _faDigits[int.parse(m[0]!)],
  );
}

/// ساعت به شکل ۱۴:۰۵
String timeLabel(DateTime t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return faDigits('$h:$m');
}
