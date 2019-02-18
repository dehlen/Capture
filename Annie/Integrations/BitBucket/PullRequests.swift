import Foundation

// MARK: model
struct PullRequest: Codable {
    let id: Int
    let title: String
    let open: Bool
    let toRef: PullRequestReference
}

struct PullRequestReference: Codable {
    let repository: Repository
}

struct Repository: Codable {
    let slug: String
    let project: Project
}

struct Project: Codable {
    let key: String
}

struct Attachments: Codable {
    let attachments: [Attachment]
}

struct Attachment: Codable {
    let url: String
    let id: String
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

    func addAttachment(_ session: RequestKitURLSession = URLSession.shared, attachment: URL, to pullRequest: PullRequest, completion: @escaping (_ response: Result<Attachment>) -> Void) -> URLSessionDataTaskProtocol? {
        let router = AttachmentRouter.attachment(configuration, attachment, pullRequest)
        return router.post(file: attachment, expectedResultType: Attachments.self, completion: { (response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let response = response, let attachment = response.attachments.first {
                completion(.success(attachment))
            }
        })
    }

    func comment(on pullRequest: PullRequest, with attachment: Attachment, completion: @escaping (_ response: Result<Attachment>) -> Void) -> URLSessionDataTaskProtocol? {
        #warning("implement")
        return nil
    }

}

// MARK: Router
enum AttachmentRouter: MulitpartFormDataPostRouter {
    case attachment(Configuration, URL, PullRequest)

    var configuration: Configuration {
        switch self {
        case .attachment(let config, _, _): return config
        }
    }

    var method: HTTPMethod {
        switch self {
        case .attachment(_, _, _): return .POST
        }
    }

    var encoding: HTTPEncoding {
        switch self {
        case .attachment: return .multipartFormData
        }
    }

    var params: [String: Any] {
        switch self {
        case .attachment:
            return [:]
        }
    }

    var path: String {
        switch self {
        case .attachment(_, _, let pullRequest):
            return "/projects/\(pullRequest.toRef.repository.project.key)/repos/\(pullRequest.toRef.repository.slug)/attachments"
        }
    }
}

enum PullRequestRouter: Router {
    case readPullRequests(Configuration, [String: String])

    var configuration: Configuration {
        switch self {
        case .readPullRequests(let config, _): return config
        }
    }

    var method: HTTPMethod {
        switch self {
        case .readPullRequests: return .GET
        }
    }

    var encoding: HTTPEncoding {
        switch self {
        case .readPullRequests: return .url
        }
    }

    var params: [String: Any] {
        switch self {
        case .readPullRequests(_, let nextParameters):
            return nextParameters as [String : Any]
        }
    }

    var path: String {
        switch self {
        case .readPullRequests:
            return "/rest/api/1.0/dashboard/pull-requests"
        }
    }
}
