#!/usr/bin/env swift

import AppKit
import CoreText
import Foundation

private let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
private let fontURL = root.appendingPathComponent("assets/fonts/Archivo-Roman-VF.woff2")
private let squareIconURL = root.appendingPathComponent("assets/branding/catch_icon.png")
private let squarePreviewURL = root.appendingPathComponent("assets/branding/catch_icon_square.png")
private let roundIconURL = root.appendingPathComponent("assets/branding/catch_icon_round.png")
private let splashMarkLightURL = root.appendingPathComponent("assets/branding/catch_splash_mark_light.png")
private let splashMarkDarkURL = root.appendingPathComponent("assets/branding/catch_splash_mark_dark.png")
private let hostLogoURL = root.appendingPathComponent("assets/branding/catch_hosts_logo.png")
private let hostIconURL = root.appendingPathComponent("assets/branding/catch_hosts_icon.png")

private let iconSize = 1024
private let hostLogoSize = NSSize(width: 1400, height: 360)
private let squareBackground = NSColor(hex: 0x16140F)
private let squareInk = NSColor(hex: 0xF4F0E8)
private let roundBackground = NSColor(hex: 0xF4F4F1)
private let roundInk = NSColor(hex: 0x16140F)
private let roundLine = NSColor(hex: 0xD6D1C7).withAlphaComponent(0.55)
private let blank = NSColor(hex: 0xD85A3C)
private let hostSubInk = NSColor(hex: 0xBAB2A7)

private let androidIconSizes: [(folder: String, size: Int)] = [
  ("mipmap-mdpi", 48),
  ("mipmap-hdpi", 72),
  ("mipmap-xhdpi", 96),
  ("mipmap-xxhdpi", 144),
  ("mipmap-xxxhdpi", 192),
]

registerArchivoFont()

let square = renderIcon(mask: .square, size: iconSize)
writePNG(square, to: squareIconURL)
writePNG(square, to: squarePreviewURL)

let round = renderIcon(mask: .round, size: iconSize)
writePNG(round, to: roundIconURL)
writeAndroidRoundIcons(from: round)

let splashMarkLight = renderSplashMark(ink: roundInk, size: iconSize)
writePNG(splashMarkLight, to: splashMarkLightURL)

let splashMarkDark = renderSplashMark(ink: squareInk, size: iconSize)
writePNG(splashMarkDark, to: splashMarkDarkURL)

let hostLogo = renderHostLogo(size: hostLogoSize)
writePNG(hostLogo, to: hostLogoURL)

let hostIcon = renderHostIcon(size: iconSize)
writePNG(hostIcon, to: hostIconURL)

print("Generated Catch launcher icons, transparent splash marks, and host marks.")

private enum IconMask {
  case square
  case round
}

private func registerArchivoFont() {
  var error: Unmanaged<CFError>?
  guard CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error) else {
    if let error {
      fatalError("Unable to register Archivo font: \(error.takeRetainedValue())")
    }
    fatalError("Unable to register Archivo font at \(fontURL.path)")
  }
}

private func renderIcon(mask: IconMask, size: Int) -> NSBitmapImageRep {
  let bitmap = makeBitmap(size: size)
  let context = NSGraphicsContext(bitmapImageRep: bitmap)!
  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = context
  defer {
    NSGraphicsContext.restoreGraphicsState()
  }

  NSColor.clear.setFill()
  NSRect(x: 0, y: 0, width: size, height: size).fill()

  switch mask {
  case .square:
    squareBackground.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()
    drawWordmark(ink: squareInk, size: size)
  case .round:
    let inset = CGFloat(size) * 0.018
    let rect = NSRect(
      x: inset,
      y: inset,
      width: CGFloat(size) - (inset * 2),
      height: CGFloat(size) - (inset * 2)
    )
    roundBackground.setFill()
    NSBezierPath(ovalIn: rect).fill()
    roundLine.setStroke()
    let stroke = CGFloat(size) * 0.012
    let ring = NSBezierPath(ovalIn: rect.insetBy(dx: stroke / 2, dy: stroke / 2))
    ring.lineWidth = stroke
    ring.stroke()
    drawWordmark(ink: roundInk, size: size)
  }

  return bitmap
}

private func renderSplashMark(ink: NSColor, size: Int) -> NSBitmapImageRep {
  let bitmap = makeBitmap(size: size)
  let context = NSGraphicsContext(bitmapImageRep: bitmap)!
  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = context
  defer {
    NSGraphicsContext.restoreGraphicsState()
  }

  NSColor.clear.setFill()
  NSRect(x: 0, y: 0, width: size, height: size).fill()
  drawWordmark(ink: ink, size: size)

  return bitmap
}

private func drawWordmark(ink: NSColor, size: Int) {
  let canvas = CGFloat(size)
  let fontSize = canvas * 0.258
  let font =
    NSFont(name: "Archivo-SemiBold", size: fontSize)
    ?? NSFont(name: "ArchivoRoman-SemiBold", size: fontSize)
    ?? NSFont.systemFont(ofSize: fontSize, weight: .semibold)
  let attributes: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: ink,
    .kern: 0,
  ]
  let text = NSAttributedString(string: "Catch", attributes: attributes)
  let textSize = text.size()
  let x = (canvas - textSize.width) / 2
  let y = canvas * 0.42
  text.draw(at: NSPoint(x: x, y: y))

  let blankWidth = canvas * (30.0 / 92.0)
  let blankHeight = max(canvas * (6.0 / 92.0), 2)
  let blankBottom = canvas * (23.0 / 92.0)
  let blankRect = NSRect(
    x: (canvas - blankWidth) / 2,
    y: blankBottom,
    width: blankWidth,
    height: blankHeight
  )
  blank.setFill()
  NSBezierPath(roundedRect: blankRect, xRadius: blankHeight / 2, yRadius: blankHeight / 2).fill()
}

private func renderHostLogo(size: NSSize) -> NSBitmapImageRep {
  let bitmap = makeBitmap(width: Int(size.width), height: Int(size.height))
  let context = NSGraphicsContext(bitmapImageRep: bitmap)!
  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = context
  defer {
    NSGraphicsContext.restoreGraphicsState()
  }

  NSColor.clear.setFill()
  NSRect(origin: .zero, size: size).fill()

  let fontSize = size.height * 0.58
  let font = hostFont(size: fontSize)
  let catchText = NSAttributedString(
    string: "Catch",
    attributes: hostTextAttributes(font: font, color: squareInk)
  )
  let hostText = NSAttributedString(
    string: "Hosts",
    attributes: hostTextAttributes(font: font, color: hostSubInk)
  )
  let catchSize = catchText.size()
  let hostSize = hostText.size()
  let gap = size.width * 0.035
  let totalWidth = catchSize.width + gap + hostSize.width
  let x = (size.width - totalWidth) / 2
  let y = (size.height - max(catchSize.height, hostSize.height)) / 2

  catchText.draw(at: NSPoint(x: x, y: y))
  hostText.draw(at: NSPoint(x: x + catchSize.width + gap, y: y))

  return bitmap
}

private func renderHostIcon(size: Int) -> NSBitmapImageRep {
  let bitmap = makeBitmap(size: size)
  let context = NSGraphicsContext(bitmapImageRep: bitmap)!
  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = context
  defer {
    NSGraphicsContext.restoreGraphicsState()
  }

  let canvas = CGFloat(size)
  squareBackground.setFill()
  NSRect(x: 0, y: 0, width: size, height: size).fill()

  let fontSize = canvas * 0.248
  let font = hostFont(size: fontSize)
  let catchText = NSAttributedString(
    string: "Catch",
    attributes: hostTextAttributes(font: font, color: squareInk)
  )
  let hostText = NSAttributedString(
    string: "Hosts",
    attributes: hostTextAttributes(font: font, color: hostSubInk)
  )
  let catchSize = catchText.size()
  let hostSize = hostText.size()
  let overlap = canvas * 0.034
  let totalHeight = catchSize.height + hostSize.height - overlap
  let startY = (canvas - totalHeight) / 2

  catchText.draw(at: NSPoint(x: (canvas - catchSize.width) / 2, y: startY + hostSize.height - overlap))
  hostText.draw(at: NSPoint(x: (canvas - hostSize.width) / 2, y: startY))

  return bitmap
}

private func hostFont(size: CGFloat) -> NSFont {
  NSFont(name: "Archivo-Bold", size: size)
    ?? NSFont(name: "ArchivoRoman-Bold", size: size)
    ?? NSFont(name: "Archivo-SemiBold", size: size)
    ?? NSFont(name: "ArchivoRoman-SemiBold", size: size)
    ?? NSFont.systemFont(ofSize: size, weight: .bold)
}

private func hostTextAttributes(font: NSFont, color: NSColor) -> [NSAttributedString.Key: Any] {
  [
    .font: font,
    .foregroundColor: color,
    .kern: 0,
  ]
}

private func writeAndroidRoundIcons(from image: NSBitmapImageRep) {
  for entry in androidIconSizes {
    let resized = image.resized(to: entry.size)
    let url = root.appendingPathComponent(
      "android/app/src/main/res/\(entry.folder)/ic_launcher_round.png"
    )
    writePNG(resized, to: url)
  }
}

private func writePNG(_ image: NSBitmapImageRep, to url: URL) {
  guard let data = image.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode PNG for \(url.path)")
  }
  try! FileManager.default.createDirectory(
    at: url.deletingLastPathComponent(),
    withIntermediateDirectories: true
  )
  try! data.write(to: url, options: [.atomic])
}

private func makeBitmap(size: Int) -> NSBitmapImageRep {
  makeBitmap(width: size, height: size)
}

private func makeBitmap(width: Int, height: Int) -> NSBitmapImageRep {
  let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: width,
    pixelsHigh: height,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
  )!
  bitmap.size = NSSize(width: width, height: height)
  return bitmap
}

private extension NSBitmapImageRep {
  func resized(to pixelSize: Int) -> NSBitmapImageRep {
    let source = NSImage(size: size)
    source.addRepresentation(self)

    let bitmap = makeBitmap(size: pixelSize)
    let context = NSGraphicsContext(bitmapImageRep: bitmap)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context
    context.imageInterpolation = .high
    source.draw(in: NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize))
    NSGraphicsContext.restoreGraphicsState()
    return bitmap
  }
}

private extension NSColor {
  convenience init(hex: Int) {
    self.init(
      calibratedRed: CGFloat((hex >> 16) & 0xFF) / 255,
      green: CGFloat((hex >> 8) & 0xFF) / 255,
      blue: CGFloat(hex & 0xFF) / 255,
      alpha: 1
    )
  }
}
