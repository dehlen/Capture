import Foundation

public protocol MulitpartFormDataPostRouter: Router {
    func post<T: Codable>(file: URL, session: RequestKitURLSession, decoder: JSONDecoder, expectedResultType: T.Type, completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol?
}

public extension MulitpartFormDataPostRouter {
    public func post<T: Codable>(file: URL, session: RequestKitURLSession = URLSession.shared, decoder: JSONDecoder = JSONDecoder(), expectedResultType: T.Type, completion: @escaping (_ json: T?, _ error: Error?) -> Void) -> URLSessionDataTaskProtocol? {
        guard var request = request() else {
            return nil
        }

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        guard let data = try? createMultipartFormData(from: file, boundary: boundary) else {
            return nil
        }

        let task = session.uploadTask(with: request, fromData: data) { data, response, error in
            if let response = response as? HTTPURLResponse {
                if !response.wasSuccessful {
                    var userInfo = [String: Any]()
                    if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        userInfo[RequestKitErrorKey] = json as Any?
                    } else if let data = data, let string = String(data: data, encoding: String.Encoding.utf8) {
                        userInfo[RequestKitErrorKey] = string as Any?
                    }
                    let error = NSError(domain: self.configuration.errorDomain, code: response.statusCode, userInfo: userInfo)
                    completion(nil, error)
                    return
                }
            }

            if let error = error {
                completion(nil, error)
            } else {
                if let data = data {
                    do {
                        let decoded = try decoder.decode(T.self, from: data)
                        completion(decoded, nil)
                    } catch {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }

    private func createMultipartFormData(from file: URL, boundary: String, params: [String: String] = [:]) throws -> Data {
        var data = Data()
        let fileData = try Data(contentsOf: file)

        for (key, value) in params {
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(value)".data(using: .utf8)!)
        }

        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"files\"; filename=\"\(file.lastPathComponent)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(file.path.mimeType())\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)

        // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
        // According to the HTTP 1.1 specification https://tools.ietf.org/html/rfc7230
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        return data
    }
}
