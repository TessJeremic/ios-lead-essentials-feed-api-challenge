//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

internal final class FeedImageMapper {
	private struct RemoteObject: Decodable {
		var items: [RemoteFeedImage]
		var feedImages: [FeedImage] {
			return items.map { $0.feedImage }
		}
	}

	private struct RemoteFeedImage: Decodable {
		let image_id: UUID
		let image_desc: String?
		let image_loc: String?
		let image_url: URL

		var feedImage: FeedImage {
			return FeedImage(id: image_id, description: image_desc, location: image_loc, url: image_url)
		}
	}

	internal static func map(data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == 200, let remoteObject = try? JSONDecoder().decode(RemoteObject.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(remoteObject.feedImages)
	}
}

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
		client.get(from: url) { response in
			switch response {
			case .success(let result): completion(FeedImageMapper.map(data: result.0, from: result.1))
			case .failure: completion(.failure(Error.connectivity))
			}
		}
	}
}
