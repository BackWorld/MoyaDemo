//
//  LoadingPlugin.swift
//  MoyaDemo
//
//  Created by zhuxuhong on 2017/12/13.
//  Copyright © 2017年 北大方正电子. All rights reserved.
//

import UIKit
import Moya
import Result

final class RequestLoadingPlugin: PluginType {
	private let viewController: UIViewController
	private var spinner: UIActivityIndicatorView!
	
	init(viewController: UIViewController) {
		self.viewController = viewController
		
		let view = UIView(frame: viewController.view.bounds)
		view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
		spinner.center = view.center
		view.addSubview(spinner)
		viewController.view.addSubview(view)
	}
	//协议方法
	func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
		
		spinner.startAnimating()
		
		print("[Network Request] : \(request.url?.absoluteString ?? "")")
		
		return request
	}
	
	func willSend(_ request: RequestType, target: TargetType) {
		print("[Network Request Target] : \(target)")
	}
	
	func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
		spinner.stopAnimating()
		spinner.superview?.removeFromSuperview()
		print("请求完成")
		
		guard case let Result.failure(error) = result else { return }
		
		let alert = UIAlertController(title: "数据请求失败", message: error.errorDescription ?? "未知错误", preferredStyle: .alert)
		alert.addAction(.init(title: "好", style: .cancel, handler: nil))
		viewController.present(alert, animated: true, completion: nil)
	}
	
	func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
		print("数据处理")
		return result
	}
}
