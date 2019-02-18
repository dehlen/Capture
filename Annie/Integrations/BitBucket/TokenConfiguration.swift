import Foundation

struct TokenConfiguration: Configuration, Codable {
    var apiEndpoint: String = bitbucketBaseURL
    var accessToken: String?
    var refreshToken: String?
    var expirationDate: Date?
    let errorDomain = BitBucketIntegrationErrorDomain
    var authorizationHeader: String? = "Bearer"

    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expirationDate = "expires_in"
    }

    init(apiEndpoint: String, accessToken: String) {
        self.apiEndpoint = apiEndpoint
        self.accessToken = accessToken
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try values.decodeIfPresent(String.self, forKey: .accessToken)
        refreshToken = try values.decodeIfPresent(String.self, forKey: .refreshToken)
        let expiresIn = try values.decodeIfPresent(Int.self, forKey: .expirationDate)
        expirationDate = Date().addingTimeInterval(TimeInterval(expiresIn ?? 0))
    }
}
