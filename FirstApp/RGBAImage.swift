import UIKit

public struct Pixel {
    public var value: UInt32
    
    public var red: UInt8 {
        get {
            return UInt8(value & 0xFF)
        }
        set {
            value = UInt32(newValue) | (value & 0xFFFFFF00)
        }
    }
    
    public var green: UInt8 {
        get {
            return UInt8((value >> 8) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF)
        }
    }
    
    public var blue: UInt8 {
        get {
            return UInt8((value >> 16) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF)
        }
    }
    
    public var alpha: UInt8 {
        get {
            return UInt8((value >> 24) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF)
        }
    }
}




public struct RGBAImage {
    public var pixels: UnsafeMutableBufferPointer<Pixel>
    
    public var width: Int
    public var height: Int
    
    public init?(image: UIImage) {
        guard let cgImage = image.CGImage else { return nil }
        
        // Redraw image for correct pixel format
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var bitmapInfo: UInt32 = CGBitmapInfo.ByteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.PremultipliedLast.rawValue & CGBitmapInfo.AlphaInfoMask.rawValue
        
        width = Int(image.size.width)
        height = Int(image.size.height)
        let bytesPerRow = width * 4
        
        let imageData = UnsafeMutablePointer<Pixel>.alloc(width * height)
        
        guard let imageContext = CGBitmapContextCreate(imageData, width, height, 8, bytesPerRow, colorSpace, bitmapInfo) else { return nil }
        CGContextDrawImage(imageContext, CGRect(origin: CGPointZero, size: image.size), cgImage)
        
        pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
        print(imageContext)
    }
    
    public func toUIImage() -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.ByteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.PremultipliedLast.rawValue & CGBitmapInfo.AlphaInfoMask.rawValue
        
        let bytesPerRow = width * 4
        
        let imageContext = CGBitmapContextCreateWithData(pixels.baseAddress, width, height, 8, bytesPerRow, colorSpace, bitmapInfo, nil, nil)
        
        guard let cgImage = CGBitmapContextCreateImage(imageContext) else {return nil}
        let image = UIImage(CGImage: cgImage)
        
        return image
    }
}

import UIKit


class imageFilter{
    
    
    func increaseContrast(image: UIImage) -> UIImage{
        let rgbaImage = RGBAImage(image: image)!
        var totalRed = 0
        var totalGreen = 0
        var totalBlue = 0
        let pixelCount = rgbaImage.width * rgbaImage.height
        
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                let pixel = rgbaImage.pixels[index]
                totalRed += Int(pixel.red)
                totalGreen += Int(pixel.green)
                totalBlue += Int(pixel.blue)
            }
        }
        
        
        let avgRed = totalRed/pixelCount
        let avgGreen = totalGreen/pixelCount
        let avgBlue = totalBlue/pixelCount
        
        
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                let redDelta = Int(pixel.red) - avgRed
                let greenDelta = Int(pixel.green) - avgGreen
                let blueDelta = Int(pixel.blue) - avgBlue
                pixel.red = UInt8(max(min(255, avgRed + 2 * redDelta), 0))
                pixel.blue = UInt8(max(min(255, avgBlue + 2 * blueDelta), 0))
                pixel.green = UInt8(max(min(255, avgGreen + 2 * greenDelta), 0))
                rgbaImage.pixels[index] = pixel
                
                
            }
        }
        let finished = rgbaImage.toUIImage()!
        return (finished)
    }
    
    
}