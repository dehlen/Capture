import Foundation
import RegiftOSX
import os

enum GifConversionError: Error {
    case conversionFailed
    case missingAsset
}

enum ConvertGif {
    enum Constants {
        static var maximumHeight: Int {
            return Int(Current.defaults[.gifHeight] ?? "480") ?? 480
        }
        static var defaultFrameRate: Int {
            return Int(Current.defaults[.gifFrameRate] ?? "30") ?? 30
        }
    }

    static func convert(at source: URL,
                        to destination: URL,
                        frameRate: Int = Constants.defaultFrameRate,
                        maximumHeight: Int = Constants.maximumHeight,
                        duration: Float,
                        completion: @escaping (Result<Void>) -> Void) {
        Regift.createGIFFromSource(source,
                                   destinationFileURL: destination,
                                   startTime: 0,
                                   duration: duration,
                                   frameRate: frameRate,
                                   loopCount: 0,
                                   size: CGSize(width: 0, height: maximumHeight),
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
