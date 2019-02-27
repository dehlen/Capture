import Foundation

let bitbucketBaseURL = "https://bitbucket.org"
let bitbucketWebURL = "https://bitbucket.org"
let BitBucketIntegrationErrorDomain = "com.davidehlen.Capture"

struct BitBucketIntegration {
    let configuration: TokenConfiguration

    init(_ config: TokenConfiguration) {
        configuration = config
    }
}

internal extension Router {
    internal var urlRequest: Foundation.URLRequest? {
        return request()
    }
}