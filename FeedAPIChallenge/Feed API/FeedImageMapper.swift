//
//  FeedImageMapper.swift
//  FeedAPIChallenge
//
//  Created by Tea Jeremic on 19.8.21..
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
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

	static private let ValidStatusCode = 200
	internal static func map(data: Data, from response: HTTPURLResponse) -> FeedLoader.Result {
		guard response.statusCode == ValidStatusCode, let remoteObject = try? JSONDecoder().decode(RemoteObject.self, from: data) else {
			return .failure(RemoteFeedLoader.Error.invalidData)
		}

		return .success(remoteObject.feedImages)
	}
}
