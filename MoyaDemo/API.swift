//
//  DouBanAPI.swift
//  MoyaDemo
//
//  Created by zhuxuhong on 2017/12/13.
//  Copyright © 2017年 北大方正电子. All rights reserved.
//

import UIKit
import Moya

extension Moya.Response{
	func json<T>() -> T?{
		guard 
			let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? T else {
				return nil
		}
		return json
	}
}

let DefaultDownloadDestination: DownloadDestination = { temporaryURL, response in
	let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
	
	if !directoryURLs.isEmpty {
		return (directoryURLs[0].appendingPathComponent(response.suggestedFilename!), [.removePreviousFile])
	}
	
	return (temporaryURL, [])
}

enum API {
	case channels
	case playList(channel: String)
	case downloadMP4(String)
	case uploadGif(Data)
}

// MARK: - API Method
extension API: TargetType{	
	var task: Task{
		switch self {
		case .downloadMP4:
			return .download(.request(DefaultDownloadDestination))
		case let .uploadGif(data):
			return .upload(.multipart([
				.init(provider: .data(data), name: "file")
			]))
		default:
			return .request
		}
	}
	
	var baseURL: URL{
		switch self {
		case .channels:
			return URL(string: "https://www.douban.com")!
		case .playList:
			return URL(string: "https://douban.fm")!
		case let .downloadMP4(url):
			return URL(string: url)!
		case .uploadGif:
			return URL(string: "https://upload.giphy.com")!
		}
	}
	
	var path: String{
		switch self {
		case .channels:
			return "/j/app/radio/channels"
		case .playList:
			return "/j/mine/playlist"
		case .uploadGif:
			return "/v1/gifs"
		default:
			return ""
		}
	}
	
	var method: Moya.Method{
		switch self {
		case .uploadGif:
			return .post
		default:
			return .get
		}
	}
	
	var validate: Bool{
		return false
	}
	
	var sampleData: Data{
		switch self {
		case .uploadGif:
			return animatedBirdGifData()
		default:
			return "{}".data(using: .utf8)!
		}
	}
	
	var parameters: [String : Any]?{
		switch self {
		case let .playList(channel):
			return ["channel": channel, 
			        "type": "n", 
			        "from": "mainsite"]
		case .uploadGif:
			return ["api_key": "dc6zaTOxFJmzC", 
			        "username": "Moya"]
		default:
			return nil
		}
	}
	
	var parameterEncoding: ParameterEncoding{
		return URLEncoding.default
	}
}

func animatedBirdGifData() -> Data{
	return Data(base64Encoded: "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", options: [])!
}

extension API{
	var url: String{
		return baseURL.appendingPathComponent(path).absoluteString
	}
	
	var urlEscaped: String{
		return url.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
	}
}

