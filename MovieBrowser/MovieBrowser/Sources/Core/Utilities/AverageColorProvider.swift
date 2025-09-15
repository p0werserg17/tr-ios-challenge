import UIKit
import CoreImage
import SwiftUI

enum AverageColorProvider {

    // Decoded UIImage cache (avoid re-decoding same bytes)
    private static let decodedCache = NSCache<NSString, UIImage>()

    /// Builds a poster-tinted gradient that adapts to the current color scheme.
    static func gradientColors(from imageURL: URL?, colorScheme: ColorScheme) async -> [Color] {
        guard let imageURL else {
            return fallbackGradient(for: colorScheme)
        }

        if let cached = decodedCache.object(forKey: imageURL.absoluteString as NSString),
           let colors = gradient(from: cached, scheme: colorScheme) {
            return colors
        }

        // Hit URLCache first; only load from network if needed
        var request = URLRequest(url: imageURL)
        request.cachePolicy = .returnCacheDataElseLoad
        request.timeoutInterval = 10

        guard
            let (data, _) = try? await URLSession.shared.data(for: request),
            let uiImage = UIImage(data: data),
            let colors = gradient(from: uiImage, scheme: colorScheme)
        else {
            return fallbackGradient(for: colorScheme)
        }

        // Store decoded image for subsequent calls
        decodedCache.setObject(uiImage, forKey: imageURL.absoluteString as NSString)
        return colors
    }

    // MARK: - Private

    private static func gradient(from image: UIImage, scheme: ColorScheme) -> [Color]? {
        guard let avg = averageColor(of: image) else { return nil }

        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard avg.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return nil }

        switch scheme {
        case .light:
            let s1 = clamp(s * 0.55, 0, 0.6)
            let topB = max(b, 0.90)
            let botB = max(b * 0.80, 0.82)
            let top  = Color(hue: Double(h), saturation: Double(s1), brightness: Double(topB))
            let bot  = Color(hue: Double(h), saturation: Double(s1), brightness: Double(botB))
            return [top, bot]

        case .dark:
            let s1 = clamp(s * 0.75, 0, 0.8)
            let topB = clamp(b * 0.35, 0.08, 0.25)
            let botB = clamp(b * 0.22, 0.05, 0.18)
            let top  = Color(hue: Double(h), saturation: Double(s1), brightness: Double(topB))
            let bot  = Color(hue: Double(h), saturation: Double(s1), brightness: Double(botB))
            return [top, bot]

        @unknown default:
            return nil
        }
    }

    private static func averageColor(of image: UIImage) -> UIColor? {
        guard let input = CIImage(image: image) else { return nil }
        let extent = input.extent
        let context = CIContext(options: [.workingColorSpace: NSNull()])
        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: input,
                                                 kCIInputExtentKey: CIVector(cgRect: extent)]),
              let output = filter.outputImage else { return nil }
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(output,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: 1)
    }

    private static func fallbackGradient(for scheme: ColorScheme) -> [Color] {
        switch scheme {
        case .light:
            return [Color(red: 0.96, green: 0.95, blue: 0.99),
                    Color(red: 0.92, green: 0.93, blue: 0.96)]
        case .dark:
            return [Color(red: 0.12, green: 0.16, blue: 0.18),
                    Color(red: 0.06, green: 0.07, blue: 0.09)]
        @unknown default:
            return [Color(.systemBackground), Color(.secondarySystemBackground)]
        }
    }

    private static func clamp(_ x: CGFloat, _ lo: CGFloat, _ hi: CGFloat) -> CGFloat {
        min(max(x, lo), hi)
    }
}
