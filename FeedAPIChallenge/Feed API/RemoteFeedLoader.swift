//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { [weak self] response in
			guard self != nil else { return }
			switch response {
			case .success(let result): completion(FeedImageMapper.map(data: result.0, from: result.1))
			case .failure: completion(.failure(Error.connectivity))
			}
		}
	}
}
