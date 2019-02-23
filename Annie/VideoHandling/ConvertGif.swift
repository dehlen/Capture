import Foundation

enum ConvertGif {
    enum Constants {
        static var maximumHeight: Int {
            return Int(Current.defaults[.gifHeight] ?? "720") ?? 720
        }
        static var defaultFrameRate: Int {
            return Int(Current.defaults[.gifFrameRate] ?? "20") ?? 20
        }
    }

    private static var ffmpeg: URL {
        guard let ffmpeg = Bundle.main.url(forResource: "ffmpeg", withExtension: nil) else { fatalError("ffmpeg not found") }

        return ffmpeg
    }

    static func convert(at source: URL, to destination: URL, frameRate: Int = Constants.defaultFrameRate, maximumHeight: Int = Constants.maximumHeight, completion: @escaping (Result<Void>) -> Void) {
        let palettePath = "palette.png"
        let filters = "fps=\(frameRate),scale=\(maximumHeight):-1:flags=lanczos"

        do {
            try Process.run(ffmpeg, arguments: ["-y", "-i", source.path, "-vf", "\(filters),palettegen", palettePath]) { _ in
                do {
                    try Process.run(ffmpeg, arguments: ["-i", source.path, "-i", palettePath, "-lavfi", "\(filters)[x];[x][1:v]paletteuse", destination.path]) { _ in
                        completion(.success(()))
                    }
                } catch let error {
                        completion(.failure(error))
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }

}
