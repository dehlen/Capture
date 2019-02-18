import Foundation

struct OAuthConfiguration: Configuration {
    var apiEndpoint: String
    var accessToken: String?
    let token: String
    let secret: String
    let scopes: [String]
    let webEndpoint: String
    let errorDomain = BitBucketIntegrationErrorDomain
    var authorizationHeader: String? = "Bearer"

    init(_ url: String = bitbucketBaseURL, webURL: String = bitbucketWebURL,
        token: String, secret: String, scopes: [String]) {
            self.apiEndpoint = url
            self.webEndpoint = webURL
            self.token = token
            self.secret = secret
            self.scopes = []
    }

    func authenticate() -> URL? {
        return OAuthRouter.authorize(self).urlRequest?.url
    }

    func authorize(_ session: RequestKitURLSession, code: String, completion: @escaping (_ config: TokenConfiguration) -> Void) {
        let request = OAuthRouter.accessToken(self, code).urlRequest
        if let request = request {
            let task = session.dataTask(with: request) { data, response, err in
                if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        return
                    } else if let data = data {
                        if let config = try? JSONDecoder().decode(TokenConfiguration.self, from: data) {
                            completion(config)
                        }
                    }
                }
            }
            task.resume()
        }
    }

    func handleOpenURL(_ session: RequestKitURLSession = URLSession.shared, url: URL, completion: @escaping (_ config: TokenConfiguration) -> Void) {
        let params = url.URLParameters()
        if let code = params["code"] {
            authorize(session, code: code) { config in
                completion(config)
            }
        }
    }
}
