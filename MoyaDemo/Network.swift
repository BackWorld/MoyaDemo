//
//  Network.swift
//  MoyaDemo
//
//  Created by zhuxuhong on 2017/12/13.
//  Copyright © 2017年 北大方正电子. All rights reserved.
//

import UIKit
import Moya

typealias JSONDictionary = [String: Any]

struct Network {
	typealias Success = ((JSONDictionary) -> Void)
	typealias Error = ((String) -> Void)
	typealias Failure = ((MoyaError) -> Void)
	typealias Progress = ((Double, Bool) -> Void)
	
	static let defaultProvider = MoyaProvider<MultiTarget>(plugins:[
		NetworkLoggerPlugin(verbose: true),
		NetworkActivityPlugin(networkActivityClosure: { 
			print($0 == .began ? "正在加载..." : "加载完成")
		})
	])
	
	static func upload(_ target: MultiTarget, 
	                     progress: @escaping Progress, 
	                     failure: @escaping Failure, 
	                     error: @escaping Error){
		defaultProvider.request(target, queue: DispatchQueue.main, progress: {
			if let response = $0.response{
				response.statusCode == 200 
					? progress($0.progress, $0.completed)
					: failure(MoyaError.statusCode(response))
			}
		}) { 
			switch $0{
			case let .success(response):
				if let json: JSONDictionary = response.json(),
					let meta = json["meta"] as? JSONDictionary,
					let status = meta["status"] as? Int, 
					let msg = meta["msg"] as? String{
					status == 200 && msg == "OK"
						? progress(1, true) 
						: error(msg)
				}
				else{
					error("未知原因")
				}
			case .failure(let error):
				failure(error)
			}
		}
	}
	
	static func download(_ target: MultiTarget, 
	                     progress: @escaping Progress, 
	                     failure: @escaping Failure, 
	                     error: @escaping Error){
		defaultProvider.request(target, queue: DispatchQueue.main, progress: { 
			progress($0.progress, $0.completed)
		}) { 
			switch $0{
			case .success:
				progress(1, true)
			case .failure(let error):
				failure(error)
			}
		}
	}
	
	static func request(_ target: MultiTarget, 
	                    viewController: UIViewController? = nil, 
	                    success: @escaping Success, 
	                    error: @escaping Error, 
	                    failure: @escaping Failure){
		var provider = defaultProvider
		if let vc = viewController {
			provider = MoyaProvider<MultiTarget>(plugins: [ RequestLoadingPlugin(viewController: vc)
			])
		}
		
		provider.request(target) {
			switch $0{
				case .success(let response):
					// 数据解析成JSON
					guard  let json: JSONDictionary = response.json() else{
						failure(.jsonMapping(response))
						return
					}
					
					/* 网络返回的错误提示信息：如用户名不存在等；
					guard let status = json["status"] as? Bool, status else{
						error(json["msg"] as? String ?? "未知错误")
						return
					}*/
					
					// 网络请求成功
					success(json)
				case .failure(let error):
					// 服务器错误：如网络连接失败，请求超时等；
					failure(error)
				}
			}
		}
}
