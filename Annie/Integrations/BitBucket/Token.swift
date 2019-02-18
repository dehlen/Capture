import Foundation

// MARK: request
extension BitBucketIntegration {
    func refreshToken(_ session: RequestKitURLSession, oauthConfig: OAuthConfiguration, refreshToken: String, completion: @escaping (_ response: Response<TokenConfiguration>) -> Void) -> URLSessionDataTaskProtocol? {
        let request = TokenRouter.refreshToken(oauthConfig, refreshToken).urlRequest
        var task: URLSessionDataTaskProtocol?
        if let request = request {
            task = session.dataTask(with: request) { data, response, err in
                guard let response = response as? HTTPURLResponse else { return }
                guard let data = data else { return }
                do {
                    if response.statusCode != 200 {
                        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        if let responseJSON = responseJSON as? [String: AnyObject] {
                            let errorDescription = responseJSON["error_description"] as? String ?? ""
                            let error = NSError(domain: BitBucketIntegrationErrorDomain, code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])
                            completion(Response.failure(error))
                        }
                    } else {
                        if let tokenConfig = try? JSONDecoder().decode(TokenConfiguration.self, from: data) {
                            completion(Response.success(tokenConfig))
                        }
                    }
                }
            }
            task?.resume()
        }
        return task
    }
}

enum TokenRouter: Router {
    case refreshToken(OAuthConfiguration, String)

    var configuration: Configuration {
        switch self {
        case .refreshToken(let config, _): return config
        }
    }

    var method: HTTPMethod {
        return .POST
    }

    var encoding: HTTPEncoding {
        return .form
    }

    var params: [String: Any] {
        switch self {
        case .refreshToken(_, let token):
            return ["refresh_token": token, "grant_type": "refresh_token"]
        }
    }

    var path: String {
        switch self {
        case .refreshToken(_, _):
            return "site/oauth2/access_token"
        }
    }

    var urlRequest: URLRequest? {
        switch self {
        case .refreshToken(let config, _):
            let url = URL(string: path, relativeTo: URL(string: config.webEndpoint)!)
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            return request(components!, parameters: params)
        }
    }
}
