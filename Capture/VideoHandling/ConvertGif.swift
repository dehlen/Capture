import Foundation
import RegiftOSX
import os

enum GifConversionError: Error {
    case conversionFailed
}

enum ConvertGif {
    enum Constants {
        static var maximumHeight: Int {
            return Int(Current.defaults[.gifHeight] ?? "480") ?? 480
        }
        static var defaultFrameRate: Int {
            return Int(Current.defaults[.gifFrameRate] ?? "20") ?? 20
        }
    }

    static func convert(at source: URL, to destination: URL, frameRate: Int = Constants.defaultFrameRate, maximumHeight: Int = Constants.maximumHeight, completion: @escaping (Result<Void>) -> Void) {
        Regift.createGIFFromSource(source, destinationFileURL: destination, frameCount: frameRate, delayTime: 0, loopCount: 0, size: CGSize(width: 0, height: maximumHeight)) { (result) in
            if let _ = result {
                completion(.success(()))
            } else {
                os_log(.error, log: .gifExport, "GIF export failed")
                completion(.failure(GifConversionError.conversionFailed))
            }
        }
    }
}
