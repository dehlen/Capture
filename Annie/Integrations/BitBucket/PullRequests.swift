import Foundation

// MARK: model
struct PullRequest: Codable {
    let id: Int
    let title: String
    let open: Bool
}

struct Pagination<T: Codable>: Codable {
    let size: Int?
    let limit: Int?
    let isLastPage: Bool?
    let start: Int?
    let nextPageStart: Int?
    let next: String?
    let values: T

    private enum CodingKeys: String, CodingKey {
        case size
        case limit
        case isLastPage
        case start
        case nextPageStart
        case next
        case values
    }
}

// MARK: request
extension BitBucketIntegration {
    func pullRequests(_ session: RequestKitURLSession = URLSession.shared, nextParameters: [String: String] = [:], completion: @escaping (_ response: Result<Pagination<[PullRequest]>>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = PullRequestRouter.readPullRequests(configuration, nextParameters)

        return router.load(expectedResultType: Pagination<[PullRequest]>.self, completion: { (response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let paginatedResponse = response {
                completion(.success(paginatedResponse))
            }
        })
    }
}

// MARK: Router
enum PullRequestRouter: Router {
    case readPullRequests(Configuration, [String: String])

    var configuration: Configuration {
        switch self {
        case .readPullRequests(let config, _): return config
        }
    }

    var method: HTTPMethod {
        return .GET
    }

    var encoding: HTTPEncoding {
        return .url
    }

    var params: [String: Any] {
        switch self {
        case .readPullRequests(_, let nextParameters):
            return nextParameters as [String : Any]
        }
    }

    var path: String {
        switch self {
        case .readPullRequests(_, _):
            return "/dashboard/pull-requests"
        }
    }
}
