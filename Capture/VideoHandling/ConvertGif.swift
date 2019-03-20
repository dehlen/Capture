import Foundation
import RegiftOSX
import os

enum GifConversionError: Error {
    case conversionFailed
    case missingAsset
}

enum ConvertGif {
    enum Constants {
        static var gifFramerates: [Int] = [15, 30, 60]
        static var defaultFrameRate: Int {
            let index = Current.defaults[.selectedFramerateIndex] ?? 1
            return index >= 0 && index < gifFramerates.count ? gifFramerates[index] : gifFramerates[1]
        }
    }

    static func convert(at source: URL,
                        to destination: URL,
                        frameRate: Int = Constants.defaultFrameRate,
                        width: Int = 0,
                        maximumHeight: Int = 480,
                        duration: Float,
                        progressHandler: ((Double) -> Void)? = nil,
                        completion: @escaping (Result<Void>) -> Void) {
        Regift.createGIFFromSource(source,
                                   destinationFileURL: destination,
                                   startTime: 0,
                                   duration: duration,
                                   frameRate: frameRate,
                                   loopCount: 0,
                                   size: CGSize(width: width, height: maximumHeight),
                                   progress: progressHandler,
                                   completion: { (result) in
            if result != nil {
                completion(.success(()))
            } else {
                os_log(.error, log: .gifExport, "GIF export failed")
                completion(.failure(GifConversionError.conversionFailed))
            }
        })
    }
}
