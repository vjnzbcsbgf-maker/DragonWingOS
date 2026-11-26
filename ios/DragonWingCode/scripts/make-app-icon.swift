import AppKit
import Foundation

let output = URL(fileURLWithPath: "DragonWingCode/Assets.xcassets/AppIcon.appiconset")
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
let size = 1024
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()
let rect = NSRect(x: 0, y: 0, width: size, height: size)
let path = NSBezierPath(roundedRect: rect.insetBy(dx: 18, dy: 18), xRadius: 220, yRadius: 220)
NSGradient(colors: [NSColor(calibratedRed: 0.015, green: 0.12, blue: 0.42, alpha: 1), NSColor(calibratedRed: 0.0, green: 0.42, blue: 0.95, alpha: 1), NSColor(calibratedRed: 0.0, green: 0.78, blue: 0.92, alpha: 1)])!.draw(in: path, angle: -45)
NSColor(calibratedRed: 0.20, green: 0.88, blue: 1.0, alpha: 1).setStroke()
path.lineWidth = 10
path.stroke()
if let symbol = NSImage(systemSymbolName: "chevron.left.forwardslash.chevron.right", accessibilityDescription: "DragonWing Code")?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 390, weight: .bold)) {
    let tinted = symbol.isTemplate ? symbol : symbol
    tinted.draw(in: NSRect(x: 145, y: 300, width: 734, height: 420), from: .zero, operation: .sourceOver, fraction: 1)
}
let title = "DW"
let attrs: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 112, weight: .heavy), .foregroundColor: NSColor.white]
let text = NSAttributedString(string: title, attributes: attrs)
let textSize = text.size()
text.draw(at: NSPoint(x: (CGFloat(size) - textSize.width) / 2, y: 125))
image.unlockFocus()
guard let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Could not render app icon")
}
try png.write(to: output.appendingPathComponent("AppIcon.png"))
let contents = """
{
  "images" : [
    {
      "filename" : "AppIcon.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
"""
try contents.write(to: output.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
