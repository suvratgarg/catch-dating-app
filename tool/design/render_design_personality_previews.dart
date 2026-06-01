// ignore_for_file: avoid_print, depend_on_referenced_packages

import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final out = Directory('/private/tmp/catch_design_personality_previews');
  out.createSync(recursive: true);

  final previews = <String, PreviewPalette>{
    'locked_light': PreviewPalette.lockedLight,
    'locked_dark_event': PreviewPalette.lockedDarkEvent,
    'activity_editorial': PreviewPalette.activityEditorial,
  };

  final rendered = <String, img.Image>{};
  for (final entry in previews.entries) {
    final image = renderPreview(entry.value);
    rendered[entry.key] = image;
    File('${out.path}/${entry.key}.png').writeAsBytesSync(img.encodePng(image));
    print('wrote ${out.path}/${entry.key}.png');
  }

  final comparison = img.Image(width: 1360, height: 940);
  img.fill(comparison, color: rgb(0xe8e2d7));
  var x = 30;
  for (final key in previews.keys) {
    img.compositeImage(comparison, rendered[key]!, dstX: x, dstY: 15);
    x += 445;
  }
  File(
    '${out.path}/comparison.png',
  ).writeAsBytesSync(img.encodePng(comparison));
  print('wrote ${out.path}/comparison.png');
}

img.Image renderPreview(PreviewPalette p) {
  final canvas = img.Image(width: 430, height: 910);
  img.fill(canvas, color: p.stage);

  rounded(canvas, 20, 30, 390, 844, 46, p.bezel);
  shadow(canvas, 23, 34, 384, 836, 42, p.isDark ? 110 : 42);
  rounded(canvas, 28, 38, 374, 828, 38, p.bg);

  // Ambient personality layer.
  img.fillCircle(
    canvas,
    x: 78,
    y: 235,
    radius: 120,
    color: rgba(p.primaryHex, p.isDark ? 28 : 20),
  );
  img.fillCircle(
    canvas,
    x: 410,
    y: 100,
    radius: 116,
    color: rgba(p.accentHex, p.isDark ? 30 : 16),
  );
  for (var y = 146; y < 810; y += 74) {
    img.drawLine(
      canvas,
      x1: 10,
      y1: y,
      x2: 420,
      y2: y - 38,
      color: rgba(p.lineHex, 70),
    );
  }

  drawStatus(canvas, p);
  drawHeader(canvas, p);
  drawHero(canvas, p);
  drawUnlock(canvas, p);
  drawSection(canvas, p);
  drawSwipe(canvas, p);
  drawChatCue(canvas, p);
  drawNav(canvas, p);

  return canvas;
}

void drawStatus(img.Image canvas, PreviewPalette p) {
  text(canvas, '6:42', 55, 52, p.ink, img.arial14);
  text(canvas, 'LTE  WiFi  89%', 292, 52, p.ink, img.arial14);
}

void drawHeader(img.Image canvas, PreviewPalette p) {
  text(canvas, p.name, 48, 88, p.muted, img.arial14);
  text(canvas, p.headline, 48, 108, p.ink, img.arial24);
  rounded(canvas, 346, 82, 42, 42, 16, p.surface, border: p.line);
  text(canvas, '!', 363, 91, p.ink, img.arial24);
}

void drawHero(img.Image canvas, PreviewPalette p) {
  final x = 48;
  final y = 144;
  final w = 334;
  final h = 214;
  rounded(canvas, x, y, w, h, p.heroRadius, p.heroBase);
  img.fillCircle(
    canvas,
    x: x + 278,
    y: y + 50,
    radius: 92,
    color: rgba(p.accentHex, p.isDark ? 150 : 96),
  );
  img.fillCircle(
    canvas,
    x: x + 52,
    y: y + 30,
    radius: 104,
    color: rgba(p.primaryHex, 130),
  );
  img.fillRect(
    canvas,
    x1: x + 190,
    y1: y,
    x2: x + w,
    y2: y + h,
    color: rgba(p.secondaryHex, p.isDark ? 40 : 34),
  );

  for (var i = 0; i < 7; i++) {
    img.fillRect(
      canvas,
      x1: x + (i.isEven ? 16 : 120),
      y1: y + 32 + i * 21,
      x2: x + (i.isEven ? 185 : 308),
      y2: y + 40 + i * 21,
      color: rgba(0xffffff, p.isDark ? 26 : 44),
      radius: 999,
    );
  }

  route(canvas, p, x, y);
  pill(canvas, x + 14, y + 13, p.heroPill, p.pillBg, p.pillInk);
  rounded(canvas, x + 286, y + 13, 36, 36, 14, p.floating);
  text(canvas, 'M', x + 297, y + 20, p.floatingInk, img.arial24);

  text(canvas, 'Sunrise 7K', x + 18, y + 115, p.heroInk, img.arial48);
  text(
    canvas,
    'Bandra Striders - Carter Road - 6:30 AM',
    x + 20,
    y + 160,
    rgbaHex(p.heroInkHex, 220),
    img.arial14,
  );

  rounded(canvas, x + 18, y + 180, 156, 42, p.buttonRadius, p.cta);
  text(canvas, 'Book spot', x + 54, y + 190, p.ctaInk, img.arial14);
  metric(canvas, p, x + 184, y + 180, '11', 'left');
  metric(canvas, p, x + 242, y + 180, '5K', 'easy');
}

void route(img.Image canvas, PreviewPalette p, int x, int y) {
  final points = [
    [x + 38, y + 94],
    [x + 70, y + 56],
    [x + 112, y + 132],
    [x + 154, y + 86],
    [x + 206, y + 54],
    [x + 250, y + 122],
  ];
  for (var i = 0; i < points.length - 1; i++) {
    img.drawLine(
      canvas,
      x1: points[i][0],
      y1: points[i][1],
      x2: points[i + 1][0],
      y2: points[i + 1][1],
      color: rgba(0x000000, 55),
      thickness: 11,
    );
    img.drawLine(
      canvas,
      x1: points[i][0],
      y1: points[i][1],
      x2: points[i + 1][0],
      y2: points[i + 1][1],
      color: p.route,
      thickness: 7,
    );
  }
  img.fillCircle(canvas, x: x + 206, y: y + 54, radius: 13, color: p.secondary);
  img.fillCircle(
    canvas,
    x: x + 206,
    y: y + 54,
    radius: 6,
    color: p.secondaryInk,
  );
}

void drawUnlock(img.Image canvas, PreviewPalette p) {
  final x = 48;
  final y = 372;
  surface(canvas, p, x, y, 334, 78);
  avatar(canvas, p, x + 14, y + 20, p.primary, 'M');
  avatar(canvas, p, x + 38, y + 20, p.accent, 'R');
  avatar(canvas, p, x + 62, y + 20, p.secondary, '+', ink: p.secondaryInk);
  text(canvas, 'Unlocks after check-in', x + 98, y + 17, p.ink, img.arial14);
  text(
    canvas,
    '4 checked in. 24h window.',
    x + 98,
    y + 39,
    p.muted,
    img.arial14,
  );
  rounded(canvas, x + 278, y + 12, 44, 52, 17, p.primary);
  text(canvas, '2h', x + 288, y + 19, p.onPrimary, img.arial24);
  text(canvas, 'left', x + 289, y + 43, p.onPrimary, img.arial14);
}

void drawSection(img.Image canvas, PreviewPalette p) {
  text(canvas, 'POST-RUN CATCHES', 48, 474, p.primary, img.arial14);
  text(canvas, 'People you actually ran with', 48, 496, p.ink, img.arial24);
}

void drawSwipe(img.Image canvas, PreviewPalette p) {
  final x = 48;
  final y = 536;
  surface(canvas, p, x, y, 334, 194);
  rounded(canvas, x, y, 154, 194, p.cardRadius, p.portraitTop);
  img.fillCircle(canvas, x: x + 112, y: y + 54, radius: 34, color: p.secondary);
  img.fillCircle(canvas, x: x + 74, y: y + 86, radius: 27, color: p.subject);
  rounded(canvas, x + 42, y + 122, 76, 68, 36, p.subject);
  for (var i = 0; i < 4; i++) {
    img.drawLine(
      canvas,
      x1: x,
      y1: y + 146 + i * 10,
      x2: x + 154,
      y2: y + 132 + i * 10,
      color: rgba(p.photoWashHex, 120),
      thickness: 3,
    );
  }
  pill(
    canvas,
    x + 10,
    y + 10,
    'RAN WITH YOU',
    p.pillBg,
    p.pillInk,
    small: true,
  );
  text(canvas, 'Mira, 27', x + 12, y + 156, p.photoInk, img.arial24);

  text(
    canvas,
    'Steady miles, strong coffee,',
    x + 170,
    y + 18,
    p.ink,
    img.arial14,
  );
  text(
    canvas,
    'no small talk until km 3.',
    x + 170,
    y + 38,
    p.ink,
    img.arial14,
  );
  chip(canvas, p, x + 170, y + 70, '5:40/km');
  chip(canvas, p, x + 242, y + 70, '10K');
  chip(canvas, p, x + 170, y + 102, 'Bandra');
  rounded(canvas, x + 170, y + 138, 50, 42, 999, p.pass);
  text(canvas, 'PASS', x + 180, y + 151, p.onPrimary, img.arial14);
  rounded(canvas, x + 230, y + 138, 82, 42, 999, p.like);
  text(canvas, 'LIKE', x + 253, y + 151, p.onPrimary, img.arial14);
}

void drawChatCue(img.Image canvas, PreviewPalette p) {
  final x = 48;
  final y = 744;
  surface(canvas, p, x, y, 334, 66);
  rounded(canvas, x + 12, y + 10, 44, 44, 17, p.primary);
  text(canvas, 'C', x + 27, y + 18, p.onPrimary, img.arial24);
  text(canvas, "It's a catch with Riya", x + 70, y + 13, p.ink, img.arial14);
  text(
    canvas,
    'You both ran Sunrise 7K. Start with that.',
    x + 70,
    y + 36,
    p.muted,
    img.arial14,
  );
  text(canvas, '>', x + 354, y + 22, p.primary, img.arial24);
}

void drawNav(img.Image canvas, PreviewPalette p) {
  final x = 48;
  final y = 822;
  rounded(canvas, x, y, 334, 64, p.navRadius, p.nav, border: p.line);
  final items = ['Home', 'Clubs', 'Catches', 'Chats', 'You'];
  for (var i = 0; i < items.length; i++) {
    final tx = x + 18 + i * 62;
    final active = items[i] == 'Catches';
    text(
      canvas,
      active ? '*' : 'o',
      tx + 16,
      y + 9,
      active ? p.primary : p.muted,
      img.arial14,
    );
    text(
      canvas,
      items[i],
      tx,
      y + 32,
      active ? p.primary : p.muted,
      img.arial14,
    );
  }
}

void surface(img.Image canvas, PreviewPalette p, int x, int y, int w, int h) {
  shadow(canvas, x + 1, y + 5, w, h, p.cardRadius, p.isDark ? 70 : 24);
  rounded(canvas, x, y, w, h, p.cardRadius, p.surface, border: p.line);
}

void metric(
  img.Image canvas,
  PreviewPalette p,
  int x,
  int y,
  String value,
  String label,
) {
  rounded(canvas, x, y, 50, 42, 15, p.metricBg, border: p.metricBorder);
  text(canvas, value, x + 13, y + 6, p.metricInk, img.arial24);
  text(canvas, label, x + 12, y + 27, p.metricInk, img.arial14);
}

void chip(img.Image canvas, PreviewPalette p, int x, int y, String label) {
  rounded(canvas, x, y, 62, 24, 999, p.chip, border: p.chipLine);
  text(canvas, label, x + 8, y + 6, p.chipInk, img.arial14);
}

void pill(
  img.Image canvas,
  int x,
  int y,
  String label,
  img.Color bg,
  img.Color ink, {
  bool small = false,
}) {
  final width = small ? 95 : 126;
  final height = small ? 24 : 28;
  rounded(canvas, x, y, width, height, 999, bg);
  text(canvas, label, x + 10, y + (small ? 6 : 7), ink, img.arial14);
}

void avatar(
  img.Image canvas,
  PreviewPalette p,
  int x,
  int y,
  img.Color color,
  String label, {
  img.Color? ink,
}) {
  img.fillCircle(canvas, x: x + 18, y: y + 18, radius: 19, color: p.surface);
  img.fillCircle(canvas, x: x + 18, y: y + 18, radius: 16, color: color);
  text(canvas, label, x + 13, y + 9, ink ?? p.onPrimary, img.arial14);
}

void shadow(
  img.Image canvas,
  int x,
  int y,
  int w,
  int h,
  int radius,
  int alpha,
) {
  rounded(canvas, x, y, w, h, radius, rgba(0x000000, alpha));
}

void rounded(
  img.Image canvas,
  int x,
  int y,
  int w,
  int h,
  int radius,
  img.Color color, {
  img.Color? border,
}) {
  final maxRadius = ((w < h ? w : h) / 2).floor();
  final safeRadius = radius > maxRadius ? maxRadius : radius;
  img.fillRect(
    canvas,
    x1: x,
    y1: y,
    x2: x + w,
    y2: y + h,
    color: color,
    radius: safeRadius,
  );
  if (border != null) {
    img.drawRect(
      canvas,
      x1: x,
      y1: y,
      x2: x + w,
      y2: y + h,
      color: border,
      radius: safeRadius,
    );
  }
}

void text(
  img.Image canvas,
  String value,
  int x,
  int y,
  img.Color color,
  img.BitmapFont font,
) {
  img.drawString(canvas, value, x: x, y: y, font: font, color: color);
}

img.Color rgb(int hex) => rgba(hex, 255);

img.Color rgba(int hex, int alpha) =>
    img.ColorRgba8((hex >> 16) & 0xff, (hex >> 8) & 0xff, hex & 0xff, alpha);

img.Color rgbaHex(int hex, int alpha) => rgba(hex, alpha);

class PreviewPalette {
  const PreviewPalette({
    required this.name,
    required this.headline,
    required this.stageHex,
    required this.bezelHex,
    required this.bgHex,
    required this.surfaceHex,
    required this.navHex,
    required this.floatingHex,
    required this.floatingInkHex,
    required this.inkHex,
    required this.mutedHex,
    required this.lineHex,
    required this.primaryHex,
    required this.accentHex,
    required this.secondaryHex,
    required this.secondaryInkHex,
    required this.onPrimaryHex,
    required this.ctaHex,
    required this.ctaInkHex,
    required this.chipHex,
    required this.chipInkHex,
    required this.chipLineHex,
    required this.heroBaseHex,
    required this.heroInkHex,
    required this.heroPill,
    required this.pillBgHex,
    required this.pillInkHex,
    required this.routeHex,
    required this.photoWashHex,
    required this.portraitTopHex,
    required this.subjectHex,
    required this.photoInkHex,
    required this.likeHex,
    required this.passHex,
    required this.metricBgHex,
    required this.metricBorderHex,
    required this.metricInkHex,
    required this.heroRadius,
    required this.cardRadius,
    required this.buttonRadius,
    required this.navRadius,
    required this.isDark,
  });

  final String name;
  final String headline;
  final int stageHex;
  final int bezelHex;
  final int bgHex;
  final int surfaceHex;
  final int navHex;
  final int floatingHex;
  final int floatingInkHex;
  final int inkHex;
  final int mutedHex;
  final int lineHex;
  final int primaryHex;
  final int accentHex;
  final int secondaryHex;
  final int secondaryInkHex;
  final int onPrimaryHex;
  final int ctaHex;
  final int ctaInkHex;
  final int chipHex;
  final int chipInkHex;
  final int chipLineHex;
  final int heroBaseHex;
  final int heroInkHex;
  final String heroPill;
  final int pillBgHex;
  final int pillInkHex;
  final int routeHex;
  final int photoWashHex;
  final int portraitTopHex;
  final int subjectHex;
  final int photoInkHex;
  final int likeHex;
  final int passHex;
  final int metricBgHex;
  final int metricBorderHex;
  final int metricInkHex;
  final int heroRadius;
  final int cardRadius;
  final int buttonRadius;
  final int navRadius;
  final bool isDark;

  img.Color get stage => rgb(stageHex);
  img.Color get bezel => rgb(bezelHex);
  img.Color get bg => rgb(bgHex);
  img.Color get surface => rgb(surfaceHex);
  img.Color get nav => rgb(navHex);
  img.Color get floating => rgb(floatingHex);
  img.Color get floatingInk => rgb(floatingInkHex);
  img.Color get ink => rgb(inkHex);
  img.Color get muted => rgb(mutedHex);
  img.Color get line => rgba(lineHex, 48);
  img.Color get primary => rgb(primaryHex);
  img.Color get accent => rgb(accentHex);
  img.Color get secondary => rgb(secondaryHex);
  img.Color get secondaryInk => rgb(secondaryInkHex);
  img.Color get onPrimary => rgb(onPrimaryHex);
  img.Color get cta => rgb(ctaHex);
  img.Color get ctaInk => rgb(ctaInkHex);
  img.Color get chip => rgb(chipHex);
  img.Color get chipInk => rgb(chipInkHex);
  img.Color get chipLine => rgba(chipLineHex, 90);
  img.Color get heroBase => rgb(heroBaseHex);
  img.Color get heroInk => rgb(heroInkHex);
  img.Color get pillBg => rgb(pillBgHex);
  img.Color get pillInk => rgb(pillInkHex);
  img.Color get route => rgb(routeHex);
  img.Color get portraitTop => rgb(portraitTopHex);
  img.Color get subject => rgb(subjectHex);
  img.Color get photoInk => rgb(photoInkHex);
  img.Color get like => rgb(likeHex);
  img.Color get pass => rgb(passHex);
  img.Color get metricBg => rgba(metricBgHex, 238);
  img.Color get metricBorder => rgba(metricBorderHex, 90);
  img.Color get metricInk => rgb(metricInkHex);

  static const lockedLight = PreviewPalette(
    name: 'LOCKED LIGHT',
    headline: 'Show up. Then swipe.',
    stageHex: 0xfff2e7,
    bezelHex: 0x15100d,
    bgHex: 0xfff5ec,
    surfaceHex: 0xffffff,
    navHex: 0xffffff,
    floatingHex: 0xffffff,
    floatingInkHex: 0x15100d,
    inkHex: 0x17110e,
    mutedHex: 0x6b5c50,
    lineHex: 0x17110e,
    primaryHex: 0xff4a1f,
    accentHex: 0x2447ff,
    secondaryHex: 0xc7ff44,
    secondaryInkHex: 0x12130b,
    onPrimaryHex: 0xffffff,
    ctaHex: 0x17110e,
    ctaInkHex: 0xffffff,
    chipHex: 0xffe7da,
    chipInkHex: 0xda3e19,
    chipLineHex: 0xff4a1f,
    heroBaseHex: 0xff6b2b,
    heroInkHex: 0xffffff,
    heroPill: 'TONIGHT 6:30',
    pillBgHex: 0xffffff,
    pillInkHex: 0xff4a1f,
    routeHex: 0xffffff,
    photoWashHex: 0xffffff,
    portraitTopHex: 0xffb68b,
    subjectHex: 0x1b110e,
    photoInkHex: 0xffffff,
    likeHex: 0xff4a1f,
    passHex: 0x17110e,
    metricBgHex: 0xffffff,
    metricBorderHex: 0xffffff,
    metricInkHex: 0x17110e,
    heroRadius: 32,
    cardRadius: 24,
    buttonRadius: 18,
    navRadius: 28,
    isDark: false,
  );

  static const lockedDarkEvent = PreviewPalette(
    name: 'LOCKED DARK EVENT',
    headline: 'The after-event window.',
    stageHex: 0x060a12,
    bezelHex: 0x000000,
    bgHex: 0x070a12,
    surfaceHex: 0x111722,
    navHex: 0x111722,
    floatingHex: 0xdbff3d,
    floatingInkHex: 0x070a12,
    inkHex: 0xf8fbff,
    mutedHex: 0x9aa9b9,
    lineHex: 0xffffff,
    primaryHex: 0x00e7ff,
    accentHex: 0xff2d72,
    secondaryHex: 0xdbff3d,
    secondaryInkHex: 0x070a12,
    onPrimaryHex: 0x070a12,
    ctaHex: 0xdbff3d,
    ctaInkHex: 0x070a12,
    chipHex: 0x102b52,
    chipInkHex: 0x85f5ff,
    chipLineHex: 0x00e7ff,
    heroBaseHex: 0x101829,
    heroInkHex: 0xffffff,
    heroPill: 'LIVE SOON',
    pillBgHex: 0x00e7ff,
    pillInkHex: 0x070a12,
    routeHex: 0xdbff3d,
    photoWashHex: 0x00e7ff,
    portraitTopHex: 0x172b52,
    subjectHex: 0xff2d72,
    photoInkHex: 0xffffff,
    likeHex: 0xff2d72,
    passHex: 0x00e7ff,
    metricBgHex: 0x111722,
    metricBorderHex: 0x00e7ff,
    metricInkHex: 0xffffff,
    heroRadius: 22,
    cardRadius: 20,
    buttonRadius: 999,
    navRadius: 999,
    isDark: true,
  );

  static const activityEditorial = PreviewPalette(
    name: 'ACTIVITY EDITORIAL',
    headline: 'A better way to meet.',
    stageHex: 0xede6da,
    bezelHex: 0x17130e,
    bgHex: 0xf2ede3,
    surfaceHex: 0xfffcf5,
    navHex: 0xfffcf5,
    floatingHex: 0x1c1a14,
    floatingInkHex: 0xfffcf5,
    inkHex: 0x1c1a14,
    mutedHex: 0x6d604f,
    lineHex: 0x1c1a14,
    primaryHex: 0xc7502c,
    accentHex: 0x43532b,
    secondaryHex: 0xd8a14a,
    secondaryInkHex: 0x1c1a14,
    onPrimaryHex: 0xfffcf5,
    ctaHex: 0xc7502c,
    ctaInkHex: 0xfffcf5,
    chipHex: 0xf4ddd1,
    chipInkHex: 0x9d3b22,
    chipLineHex: 0xc7502c,
    heroBaseHex: 0xc7502c,
    heroInkHex: 0xfffcf5,
    heroPill: 'SUNDAY CLUB',
    pillBgHex: 0xfffcf5,
    pillInkHex: 0xc7502c,
    routeHex: 0xfffcf5,
    photoWashHex: 0xfffcf5,
    portraitTopHex: 0xe8b27c,
    subjectHex: 0x1c1a14,
    photoInkHex: 0xfffcf5,
    likeHex: 0xc7502c,
    passHex: 0x1c1a14,
    metricBgHex: 0xfffcf5,
    metricBorderHex: 0xfffcf5,
    metricInkHex: 0x1c1a14,
    heroRadius: 18,
    cardRadius: 16,
    buttonRadius: 12,
    navRadius: 18,
    isDark: false,
  );
}
