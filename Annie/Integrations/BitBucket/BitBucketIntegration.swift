import Foundation

let bitbucketBaseURL = "https://bitbucket.org/api/2.0/"
let bitbucketWebURL = "https://bitbucket.org/"
let BitBucketIntegrationErrorDomain = "com.davidehlen.Annie"

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
