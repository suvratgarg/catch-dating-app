import AppKit
import Foundation

struct ScreenshotSpec {
  let fileName: String
  let title: String
  let subtitle: String
  let sourcePath: String
}

let canvasWidth: CGFloat = 1320
let canvasHeight: CGFloat = 2868

let specs = [
  ScreenshotSpec(
    fileName: "01-event-setup.png",
    title: "Build your host profile",
    subtitle: "Create clubs, add photos, and prepare the organizer details guests see.",
    sourcePath: "artifacts/marketing/app-screenshots/host-create-basics.png"
  ),
  ScreenshotSpec(
    fileName: "02-admission-rules.png",
    title: "Control admission",
    subtitle: "Tune guest limits, approvals, payments, and policies from one host workflow.",
    sourcePath: "artifacts/marketing/app-screenshots/host-create-policy.png"
  ),
  ScreenshotSpec(
    fileName: "03-live-event-flow.png",
    title: "Run live event flow",
    subtitle: "Track check-in, attendance, payouts, and host actions from one console.",
    sourcePath: "artifacts/marketing/app-screenshots/host-live-console.png"
  ),
  ScreenshotSpec(
    fileName: "04-post-event-report.png",
    title: "Review the outcome",
    subtitle: "See aggregate post-event signals without exposing private attendee choices.",
    sourcePath: "artifacts/marketing/app-screenshots/host-post-event-report.png"
  ),
  ScreenshotSpec(
    fileName: "05-guest-details.png",
    title: "Plan guest details",
    subtitle: "Keep venue, directions, schedule, and host guidance in a publish-ready flow.",
    sourcePath: "artifacts/marketing/app-screenshots/host-create-location.png"
  ),
]

let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputDirectory = rootURL.appendingPathComponent("docs/store/catch_host/screenshots/iphone_6_9")
try FileManager.default.createDirectory(
  at: outputDirectory,
  withIntermediateDirectories: true
)

func color(_ hex: String, alpha: CGFloat = 1) -> NSColor {
  let value = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
  var int: UInt64 = 0
  Scanner(string: value).scanHexInt64(&int)

  let red = CGFloat((int >> 16) & 0xff) / 255
  let green = CGFloat((int >> 8) & 0xff) / 255
  let blue = CGFloat(int & 0xff) / 255
  return NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
}

func topRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> NSRect {
  NSRect(x: x, y: canvasHeight - y - height, width: width, height: height)
}

func drawText(
  _ text: String,
  in rect: NSRect,
  font: NSFont,
  color: NSColor,
  alignment: NSTextAlignment = .left,
  lineSpacing: CGFloat = 0
) {
  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.alignment = alignment
  paragraphStyle.lineBreakMode = .byWordWrapping
  paragraphStyle.lineSpacing = lineSpacing

  let attributes: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: color,
    .paragraphStyle: paragraphStyle,
  ]
  NSString(string: text).draw(in: rect, withAttributes: attributes)
}

func aspectFit(imageSize: NSSize, in maxRect: NSRect) -> NSRect {
  let scale = min(maxRect.width / imageSize.width, maxRect.height / imageSize.height)
  let width = imageSize.width * scale
  let height = imageSize.height * scale
  return NSRect(
    x: maxRect.midX - width / 2,
    y: maxRect.midY - height / 2,
    width: width,
    height: height
  )
}

func roundedPath(_ rect: NSRect, radius: CGFloat) -> NSBezierPath {
  NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func loadImage(path: String) throws -> NSImage {
  let imageURL = rootURL.appendingPathComponent(path)
  guard let image = NSImage(contentsOf: imageURL) else {
    throw NSError(
      domain: "CatchHostScreenshotGenerator",
      code: 1,
      userInfo: [NSLocalizedDescriptionKey: "Could not load image at \(path)"]
    )
  }

  if let bitmap = image.representations.compactMap({ $0 as? NSBitmapImageRep }).first {
    image.size = NSSize(width: bitmap.pixelsWide, height: bitmap.pixelsHigh)
  }
  return image
}

func drawDecorativeBackground(index: Int) {
  color("fbf7ef").setFill()
  NSRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight).fill()

  let topBand = topRect(x: 0, y: 0, width: canvasWidth, height: 520)
  color("101820").setFill()
  topBand.fill()

  let accentColors = ["00a88f", "ff6b4a", "f5b84b", "4b74ff", "00a88f"]
  color(accentColors[index % accentColors.count]).setFill()
  topRect(x: 0, y: 520, width: canvasWidth, height: 22).fill()

  color("f1e6d6").setFill()
  roundedPath(topRect(x: -120, y: 2140, width: 500, height: 500), radius: 250).fill()
  color("c9efe7").setFill()
  roundedPath(topRect(x: 980, y: 2250, width: 380, height: 380), radius: 190).fill()
}

func drawRawCaptureInPhoneFrame(image: NSImage) {
  let maxScreenRect = topRect(x: 145, y: 650, width: 1030, height: 1970)
  let screenRect = aspectFit(
    imageSize: image.size,
    in: maxScreenRect.insetBy(dx: 90, dy: 42)
  )
  let frameRect = screenRect.insetBy(dx: -34, dy: -34)

  NSGraphicsContext.saveGraphicsState()
  let shadow = NSShadow()
  shadow.shadowColor = color("000000", alpha: 0.22)
  shadow.shadowBlurRadius = 36
  shadow.shadowOffset = NSSize(width: 0, height: -16)
  shadow.set()
  color("101820").setFill()
  roundedPath(frameRect, radius: 68).fill()
  NSGraphicsContext.restoreGraphicsState()

  color("101820").setFill()
  roundedPath(frameRect, radius: 68).fill()
  color("ffffff").setFill()
  roundedPath(screenRect.insetBy(dx: -2, dy: -2), radius: 48).fill()

  NSGraphicsContext.saveGraphicsState()
  roundedPath(screenRect, radius: 44).addClip()
  image.draw(
    in: screenRect,
    from: NSRect(origin: .zero, size: image.size),
    operation: .sourceOver,
    fraction: 1
  )
  NSGraphicsContext.restoreGraphicsState()

  color("d6cec1").setStroke()
  let strokePath = roundedPath(frameRect, radius: 68)
  strokePath.lineWidth = 4
  strokePath.stroke()
}

func drawExistingDeviceCapture(image: NSImage) {
  let maxImageRect = topRect(x: 145, y: 650, width: 1030, height: 1970)
  let drawRect = aspectFit(imageSize: image.size, in: maxImageRect)

  NSGraphicsContext.saveGraphicsState()
  let shadow = NSShadow()
  shadow.shadowColor = color("000000", alpha: 0.20)
  shadow.shadowBlurRadius = 34
  shadow.shadowOffset = NSSize(width: 0, height: -14)
  shadow.set()
  color("000000", alpha: 0.14).setFill()
  roundedPath(drawRect.insetBy(dx: 12, dy: 12), radius: 92).fill()
  NSGraphicsContext.restoreGraphicsState()

  image.draw(
    in: drawRect,
    from: NSRect(origin: .zero, size: image.size),
    operation: .sourceOver,
    fraction: 1
  )
}

func drawCapture(image: NSImage) {
  if image.size.width >= 800 {
    drawExistingDeviceCapture(image: image)
  } else {
    drawRawCaptureInPhoneFrame(image: image)
  }
}

for (index, spec) in specs.enumerated() {
  let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(canvasWidth),
    pixelsHigh: Int(canvasHeight),
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
  )

  guard let bitmap else {
    throw NSError(
      domain: "CatchHostScreenshotGenerator",
      code: 2,
      userInfo: [NSLocalizedDescriptionKey: "Could not create bitmap context"]
    )
  }

  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
  NSGraphicsContext.current?.imageInterpolation = .high

  drawDecorativeBackground(index: index)

  drawText(
    "Catch Host",
    in: topRect(x: 104, y: 118, width: 1112, height: 58),
    font: NSFont.systemFont(ofSize: 42, weight: .semibold),
    color: color("c9efe7"),
    alignment: .center
  )
  drawText(
    spec.title,
    in: topRect(x: 104, y: 210, width: 1112, height: 126),
    font: NSFont.systemFont(ofSize: 90, weight: .bold),
    color: color("ffffff"),
    alignment: .center
  )
  drawText(
    spec.subtitle,
    in: topRect(x: 152, y: 356, width: 1016, height: 104),
    font: NSFont.systemFont(ofSize: 39, weight: .regular),
    color: color("f4efe7"),
    alignment: .center,
    lineSpacing: 5
  )

  let sourceImage = try loadImage(path: spec.sourcePath)
  drawCapture(image: sourceImage)

  drawText(
    "Demo data shown",
    in: topRect(x: 120, y: 2748, width: 1080, height: 48),
    font: NSFont.systemFont(ofSize: 28, weight: .medium),
    color: color("685f55"),
    alignment: .center
  )

  NSGraphicsContext.restoreGraphicsState()

  guard let data = bitmap.representation(using: .png, properties: [:]) else {
    throw NSError(
      domain: "CatchHostScreenshotGenerator",
      code: 3,
      userInfo: [NSLocalizedDescriptionKey: "Could not encode \(spec.fileName)"]
    )
  }

  let outputURL = outputDirectory.appendingPathComponent(spec.fileName)
  try data.write(to: outputURL)
  print("Wrote \(outputURL.path)")
}
