import AppKit
import CoreText
import Foundation

enum CaptureTreatment {
  case existingDeviceFrame
  case rawScreen
}

struct ScreenshotSpec {
  let fileName: String
  let appLabel: String
  let title: String
  let subtitle: String
  let sourcePath: String
  let treatment: CaptureTreatment
  let accent: String
  let tint: String
}

let canvasWidth: CGFloat = 1320
let canvasHeight: CGFloat = 2868
let rootURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outputDirectory = rootURL.appendingPathComponent(
  "docs/store/app_listing_prototypes/iphone_6_9"
)

let specs = [
  ScreenshotSpec(
    fileName: "catch-consumer-01-events-before-matches-iphone-6_9.png",
    appLabel: "Catch",
    title: "Meet at real events. Match after.",
    subtitle: "Browse hosted singles events near you.",
    sourcePath: "artifacts/marketing/app-screenshots/member-event-discovery.png",
    treatment: .existingDeviceFrame,
    accent: "ff6b4a",
    tint: "f6d9d0"
  ),
  ScreenshotSpec(
    fileName: "catch-consumer-02-event-confidence-iphone-6_9.png",
    appLabel: "Catch",
    title: "Pick a night worth showing up for",
    subtitle: "See the plan, host, price, and who it is for.",
    sourcePath: "artifacts/store/app-listing-prototypes/raw/event_detail_member_ticket/light.png",
    treatment: .rawScreen,
    accent: "f5a23a",
    tint: "f7e3c4"
  ),
  ScreenshotSpec(
    fileName: "catch-consumer-03-attendance-gated-catches-iphone-6_9.png",
    appLabel: "Catch",
    title: "Catch people you actually met",
    subtitle: "Your private Catch window opens after check-in.",
    sourcePath: "artifacts/marketing/app-screenshots/post-run-catch-window.png",
    treatment: .existingDeviceFrame,
    accent: "df4d72",
    tint: "f2d3dc"
  ),
  ScreenshotSpec(
    fileName: "catch-host-01-live-console-iphone-6_9.png",
    appLabel: "Catch Host",
    title: "Run the whole night from one screen",
    subtitle: "Check in guests, move the waitlist, and stay on the run of show.",
    sourcePath: "artifacts/marketing/app-screenshots/host-live-console.png",
    treatment: .existingDeviceFrame,
    accent: "00a88f",
    tint: "c9efe7"
  ),
  ScreenshotSpec(
    fileName: "catch-host-02-guided-publishing-iphone-6_9.png",
    appLabel: "Catch Host",
    title: "Publish in one guided flow",
    subtitle: "Build the event, save a draft, and go live when ready.",
    sourcePath: "artifacts/store/app-listing-prototypes/raw/host_create_success_manage/light.png",
    treatment: .rawScreen,
    accent: "4b74ff",
    tint: "d8e1ff"
  ),
  ScreenshotSpec(
    fileName: "catch-host-03-admission-controls-iphone-6_9.png",
    appLabel: "Catch Host",
    title: "Fill the room on your terms",
    subtitle: "Set capacity, approvals, pricing, cohorts, and waitlists.",
    sourcePath: "artifacts/marketing/app-screenshots/host-create-policy.png",
    treatment: .rawScreen,
    accent: "f5b84b",
    tint: "f6e6bd"
  ),
]

enum GeneratorError: Error, CustomStringConvertible {
  case couldNotLoad(String)
  case couldNotCreateBitmap
  case couldNotEncode(String)
  case invalidOutput(String)

  var description: String {
    switch self {
    case let .couldNotLoad(path):
      return "Could not load image at \(path)"
    case .couldNotCreateBitmap:
      return "Could not create the bitmap context"
    case let .couldNotEncode(path):
      return "Could not encode \(path)"
    case let .invalidOutput(message):
      return message
    }
  }
}

func color(_ hex: String, alpha: CGFloat = 1) -> NSColor {
  let value = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
  var integer: UInt64 = 0
  Scanner(string: value).scanHexInt64(&integer)
  return NSColor(
    calibratedRed: CGFloat((integer >> 16) & 0xff) / 255,
    green: CGFloat((integer >> 8) & 0xff) / 255,
    blue: CGFloat(integer & 0xff) / 255,
    alpha: alpha
  )
}

func topRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> NSRect {
  NSRect(
    x: x,
    y: CGFloat(canvasHeight) - y - height,
    width: width,
    height: height
  )
}

func roundedPath(_ rect: NSRect, radius: CGFloat) -> NSBezierPath {
  NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func drawText(
  _ text: String,
  in rect: NSRect,
  font: NSFont,
  textColor: NSColor,
  alignment: NSTextAlignment = .center,
  lineSpacing: CGFloat = 0
) {
  let paragraph = NSMutableParagraphStyle()
  paragraph.alignment = alignment
  paragraph.lineBreakMode = .byWordWrapping
  paragraph.lineSpacing = lineSpacing
  paragraph.maximumLineHeight = font.pointSize * 1.08
  paragraph.minimumLineHeight = font.pointSize * 1.08

  let attributes: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: textColor,
    .paragraphStyle: paragraph,
  ]
  let attributedString = NSAttributedString(string: text, attributes: attributes)
  let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
  let frame = CTFramesetterCreateFrame(
    framesetter,
    CFRange(location: 0, length: attributedString.length),
    CGPath(rect: rect, transform: nil),
    nil
  )
  if let context = NSGraphicsContext.current?.cgContext {
    context.saveGState()
    context.textMatrix = .identity
    CTFrameDraw(frame, context)
    context.restoreGState()
  }
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

func loadImage(relativePath: String) throws -> NSImage {
  let url = rootURL.appendingPathComponent(relativePath)
  guard let image = NSImage(contentsOf: url) else {
    throw GeneratorError.couldNotLoad(relativePath)
  }
  if let bitmap = image.representations.compactMap({ $0 as? NSBitmapImageRep }).first {
    image.size = NSSize(width: bitmap.pixelsWide, height: bitmap.pixelsHigh)
  }
  return image
}

func drawBackground(spec: ScreenshotSpec, index: Int) {
  color("fbf7ef").setFill()
  NSRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight).fill()

  color("101820").setFill()
  topRect(x: 0, y: 0, width: canvasWidth, height: 620).fill()

  color(spec.accent).setFill()
  topRect(x: 0, y: 620, width: canvasWidth, height: 18).fill()

  color(spec.tint).setFill()
  roundedPath(topRect(x: -140, y: 2140, width: 480, height: 480), radius: 240).fill()

  color(index < 3 ? "f3dfd7" : "d9ece8").setFill()
  roundedPath(topRect(x: 1030, y: 2280, width: 390, height: 390), radius: 195).fill()
}

func drawHeader(spec: ScreenshotSpec) {
  drawText(
    spec.appLabel,
    in: topRect(x: 104, y: 70, width: 1112, height: 44),
    font: NSFont.systemFont(ofSize: 34, weight: .semibold),
    textColor: color(spec.tint)
  )
  drawText(
    spec.title,
    in: topRect(x: 92, y: 138, width: 1136, height: 190),
    font: NSFont.systemFont(ofSize: 76, weight: .bold),
    textColor: color("ffffff"),
    lineSpacing: -2
  )
  drawText(
    spec.subtitle,
    in: topRect(x: 142, y: 382, width: 1036, height: 112),
    font: NSFont.systemFont(ofSize: 34, weight: .regular),
    textColor: color("f4efe7"),
    lineSpacing: 4
  )
}

func drawShadow(for rect: NSRect, radius: CGFloat) {
  NSGraphicsContext.saveGraphicsState()
  let shadow = NSShadow()
  shadow.shadowColor = color("000000", alpha: 0.22)
  shadow.shadowBlurRadius = 38
  shadow.shadowOffset = NSSize(width: 0, height: -16)
  shadow.set()
  color("000000", alpha: 0.14).setFill()
  roundedPath(rect, radius: radius).fill()
  NSGraphicsContext.restoreGraphicsState()
}

func drawExistingDeviceCapture(_ image: NSImage) {
  let maxRect = topRect(x: 120, y: 684, width: 1080, height: 1948)
  let drawRect = aspectFit(imageSize: image.size, in: maxRect)
  drawShadow(for: drawRect.insetBy(dx: 10, dy: 10), radius: 92)
  image.draw(
    in: drawRect,
    from: NSRect(origin: .zero, size: image.size),
    operation: .sourceOver,
    fraction: 1
  )
}

func drawRawScreen(_ image: NSImage) {
  let maxRect = topRect(x: 118, y: 684, width: 1084, height: 1948)
  let screenRect = aspectFit(imageSize: image.size, in: maxRect.insetBy(dx: 62, dy: 26))
  let frameRect = screenRect.insetBy(dx: -30, dy: -30)

  drawShadow(for: frameRect, radius: 68)
  color("101820").setFill()
  roundedPath(frameRect, radius: 68).fill()

  color("ffffff").setFill()
  roundedPath(screenRect.insetBy(dx: -2, dy: -2), radius: 49).fill()

  NSGraphicsContext.saveGraphicsState()
  roundedPath(screenRect, radius: 46).addClip()
  image.draw(
    in: screenRect,
    from: NSRect(origin: .zero, size: image.size),
    operation: .sourceOver,
    fraction: 1
  )
  NSGraphicsContext.restoreGraphicsState()

  color("d6cec1").setStroke()
  let border = roundedPath(frameRect, radius: 68)
  border.lineWidth = 4
  border.stroke()
}

func opaquePNGData(from bitmap: NSBitmapImageRep) throws -> Data {
  guard
    let sourceImage = bitmap.cgImage,
    let context = CGContext(
      data: nil,
      width: Int(canvasWidth),
      height: Int(canvasHeight),
      bitsPerComponent: 8,
      bytesPerRow: Int(canvasWidth) * 4,
      space: CGColorSpaceCreateDeviceRGB(),
      bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    )
  else {
    throw GeneratorError.couldNotCreateBitmap
  }

  context.interpolationQuality = .high
  context.setFillColor(NSColor.white.cgColor)
  context.fill(CGRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight))
  context.draw(sourceImage, in: CGRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight))

  guard
    let opaqueImage = context.makeImage(),
    let png = NSBitmapImageRep(cgImage: opaqueImage).representation(using: .png, properties: [:])
  else {
    throw GeneratorError.couldNotEncode("opaque PNG")
  }
  return png
}

func render(spec: ScreenshotSpec, index: Int) throws {
  guard let bitmap = NSBitmapImageRep(
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
  ) else {
    throw GeneratorError.couldNotCreateBitmap
  }

  NSGraphicsContext.saveGraphicsState()
  guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
    NSGraphicsContext.restoreGraphicsState()
    throw GeneratorError.couldNotCreateBitmap
  }
  NSGraphicsContext.current = context
  context.imageInterpolation = .high
  context.shouldAntialias = true

  drawBackground(spec: spec, index: index)
  drawHeader(spec: spec)

  let sourceImage = try loadImage(relativePath: spec.sourcePath)
  switch spec.treatment {
  case .existingDeviceFrame:
    drawExistingDeviceCapture(sourceImage)
  case .rawScreen:
    drawRawScreen(sourceImage)
  }

  drawText(
    "Demo data shown",
    in: topRect(x: 120, y: 2760, width: 1080, height: 36),
    font: NSFont.systemFont(ofSize: 27, weight: .medium),
    textColor: color("685f55")
  )
  NSGraphicsContext.restoreGraphicsState()

  let png = try opaquePNGData(from: bitmap)
  try png.write(to: outputDirectory.appendingPathComponent(spec.fileName))
}

func checkOutputs() throws {
  for spec in specs {
    let outputURL = outputDirectory.appendingPathComponent(spec.fileName)
    guard
      let data = try? Data(contentsOf: outputURL),
      let representation = NSBitmapImageRep(data: data),
      representation.pixelsWide == Int(canvasWidth),
      representation.pixelsHigh == Int(canvasHeight),
      !representation.hasAlpha
    else {
      throw GeneratorError.invalidOutput(
        "Invalid or missing 1320x2868 opaque output: \(outputURL.path)"
      )
    }
    print("Validated \(outputURL.path)")
  }
}

do {
  if CommandLine.arguments.contains("--check") {
    try checkOutputs()
  } else {
    try FileManager.default.createDirectory(
      at: outputDirectory,
      withIntermediateDirectories: true
    )
    for (index, spec) in specs.enumerated() {
      try render(spec: spec, index: index)
      print("Wrote \(outputDirectory.appendingPathComponent(spec.fileName).path)")
    }
  }
} catch {
  fputs("error: \(error)\n", stderr)
  exit(1)
}
