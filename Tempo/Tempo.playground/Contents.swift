//: A Cocoa based Playground to present user interface

import AppKit
import PlaygroundSupport
import SwiftUI

// let nibFile = NSNib.Name("MyView")
// var topLevelObjects : NSArray?
//
// Bundle.main.loadNibNamed(nibFile, owner:nil, topLevelObjects: &topLevelObjects)
// let views = (topLevelObjects as! Array<Any>).filter { $0 is NSView }
//
//// Present the view in Playground
// PlaygroundPage.current.liveView = views[0] as! NSView

func makeImage(size: CGSize) -> CGImage {
    let ctx = CGContext(
        data: nil,
        width: Int(size.width),
        height: Int(size.height),
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    )!
    let rect = CGRect(origin: .zero, size: size)
    ctx.setFillColor(red: 0.9, green: 0.4, blue: 0.6, alpha: 1.0)
    ctx.fill(rect)
    let image = ctx.makeImage()!
    return image
}

enum IconSize: CGFloat {
    case phoneNotification = 20.0
    case phoneSettings = 29.0
    case phoneSpotlight = 40.0
    case phoneApp = 60.0
    case padApp = 76.0
    case padProApp = 83.5

    case mac16 = 16.0
    case mac32 = 32.0
    case mac128 = 128.0
    case mac256 = 256.0
    case mac512 = 512.0
}

extension IconSize: CustomStringConvertible {
    var description: String {
        switch self {
        case .phoneNotification: return "iPhone/iPad Notification (\(rawValue))"
        case .phoneSettings: return "iPhone/iPad Settings (\(rawValue))"
        case .phoneSpotlight: return "iPhone/iPad Spotlight (\(rawValue))"
        case .phoneApp: return "iPhone App (\(rawValue))"
        case .padApp: return "iPad App (\(rawValue))"
        case .padProApp: return "iPad Pro App (\(rawValue))"
        case .mac16: return "macOS (\(rawValue))"
        case .mac32: return "macOS (\(rawValue))"
        case .mac128: return "macOS (\(rawValue))"
        case .mac256: return "macOS (\(rawValue))"
        case .mac512: return "macOS (\(rawValue))"
        }
    }
}

extension View {
    func renderAsImage(size: CGSize) -> CGImage? {
        let view = NoInsetHostingView(rootView: self)
        view.setFrameSize(size)
        return view.cgImage
    }
}

class NoInsetHostingView<V>: NSHostingView<V> where V: View {
    override var safeAreaInsets: NSEdgeInsets {
        .init()
    }
}

public extension NSView {
    var cgImage: CGImage? {
        guard let rep = bitmapImageRepForCachingDisplay(in: bounds) else {
            return nil
        }
        cacheDisplay(in: bounds, to: rep)
        return rep.cgImage
    }

    func bitmapImage() -> NSImage? {
        guard let cgImage = cgImage else {
            return nil
        }
        return NSImage(cgImage: cgImage, size: bounds.size)
    }
}

struct IconVariant {
    let size: IconSize
    let scale: CGFloat

    var scaledSize: CGSize {
        let scaled = scale * size.rawValue
        return CGSize(width: scaled, height: scaled)
    }
}

extension IconVariant: CustomStringConvertible {
    var description: String { "\(size) @ \(scale)x" }
}

extension IconVariant: Identifiable, Hashable {
    var id: String { description }
}

let icons: [IconVariant] = [
    //    IconVariant(size: .phoneNotification, scale: 2),
//    IconVariant(size: .phoneNotification, scale: 3),
//    IconVariant(size: .phoneSettings, scale: 2),
//    IconVariant(size: .phoneSettings, scale: 3),
//    IconVariant(size: .phoneSpotlight, scale: 2),
//    IconVariant(size: .phoneSpotlight, scale: 3),
//    IconVariant(size: .phoneApp, scale: 2),
//    IconVariant(size: .phoneApp, scale: 3),
//    IconVariant(size: .phoneNotification, scale: 1),
//    IconVariant(size: .phoneSettings, scale: 1),
//    IconVariant(size: .phoneSpotlight, scale: 1),
//    IconVariant(size: .padApp, scale: 1),
//    IconVariant(size: .padApp, scale: 2),
//    IconVariant(size: .padProApp, scale: 2),
    IconVariant(size: .mac16, scale: 1),
    IconVariant(size: .mac16, scale: 2),
    IconVariant(size: .mac32, scale: 1),
    IconVariant(size: .mac32, scale: 2),
    IconVariant(size: .mac128, scale: 1),
    IconVariant(size: .mac128, scale: 2),
    IconVariant(size: .mac256, scale: 1),
    IconVariant(size: .mac256, scale: 2),
    IconVariant(size: .mac512, scale: 1),
    IconVariant(size: .mac512, scale: 2),
]

struct ClockPreviewView: View {
    let scale: CGSize

    var body: some View {
        ClockView()
            .frame(width: scale.width, height: scale.height)
    }
}

struct IconView: View {
    let clocks: [(IconVariant, CGImage)] = icons.map {
        ($0, ClockPreviewView(scale: $0.scaledSize).renderAsImage(size: $0.scaledSize)!)
    }

    var body: some View {
        VStack {
//            ForEach(icons) { icon in
//                HStack {
//                    let cgImage = ClockView().renderAsImage(size: icon.scaledSize)!
//                    Text(String(describing: icon))
//                    Image(cgImage, scale: 1.0, label: Text(String(describing: icon)))
//                        .onDrag {
//                            NSItemProvider(object: IconProvider(image: cgImage))
//                        }
//                }
//            }
            ForEach(clocks, id: \.0) { icon, cgImage in
                HStack {
                    Text(String(describing: icon))
                    Image(cgImage, scale: 1.0, label: Text(String(describing: icon)))
                        .onDrag {
                            NSItemProvider(object: IconProvider(image: cgImage))
                        }
                }
            }
        }
    }
}

PlaygroundPage.current.setLiveView(IconView())

extension CGImage {
    var png: Data? {
        guard let mutableData = CFDataCreateMutable(nil, 0),
              let destination = CGImageDestinationCreateWithData(mutableData, "public.png" as CFString, 1, nil)
        else { return nil }
        CGImageDestinationAddImage(destination, self, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
}

final class IconProvider: NSObject, NSItemProviderWriting {
    struct UnrecognizedTypeIdentifierError: Error {
        let identifier: String
    }

    let image: CGImage

    init(image: CGImage) {
        self.image = image
    }

    func loadData(
        withTypeIdentifier typeIdentifier: String,
        forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void
    ) -> Progress? {
        guard typeIdentifier == "public.png" else {
            completionHandler(nil, UnrecognizedTypeIdentifierError(identifier: typeIdentifier))
            return nil
        }
        completionHandler(image.png, nil)
        // Progress: all done in one step.
        let progress = Progress(parent: nil)
        progress.totalUnitCount = 1
        progress.completedUnitCount = 1
        return progress
    }

    static var writableTypeIdentifiersForItemProvider: [String] {
        ["public.png"]
    }
}
