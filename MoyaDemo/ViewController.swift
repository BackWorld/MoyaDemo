//
//  ViewController.swift
//  MoyaDemo
//
//  Created by zhuxuhong on 2017/12/13.
//  Copyright © 2017年 北大方正电子. All rights reserved.
//

import UIKit
import Moya

class ViewController: UITableViewController {

	var data: [JSONDictionary] = []
	
	@IBOutlet weak var uploadBtn: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		requestChannels(nil)
	}

	@IBAction func requestChannels(_ sender: Any?) {
		Network.request(MultiTarget(API.channels), viewController: self, success: { 
			guard 
				let array = $0["channels"] as? [JSONDictionary] else{
					print("数据解析失败")
					return
			}
			self.data = array
			self.tableView.reloadData()
		}, error: { 
			self.showErrorAlert(title: "数据请求失败", message: $0)
		}) { 
			self.showErrorAlert(title: "网络错误", message: $0.localizedDescription)
		}
	}
	
	@IBAction func uploadGif(_ sender: Any?) {
		uploadBtn.isEnabled = false
		uploadBtn.setTitle("上传中...", for: .normal)
	Network.upload(MultiTarget.init(API.uploadGif(animatedBirdGifData())), progress: { 
			let title = $1 ? "上传完成" : "\(Int($0 * 100)) %"
			self.uploadBtn.titleLabel?.text = title
			self.uploadBtn.setTitle(title, for: .normal)
		}, failure: { 
			handleUploadError($0.localizedDescription)
		}){
			handleUploadError($0)
		}
		
		func handleUploadError(_ error: String){
			self.showErrorAlert(title: "上传Gif失败", message: error)
			self.uploadBtn.isEnabled = true
			self.uploadBtn.setTitle("重新上传", for: .normal)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? DetailViewController, 
			let cell = sender as? UITableViewCell, 
			let row = tableView.indexPath(for: cell)?.row {
			let channel = data[row]
			vc.channelId = channel["channel_id"] as? String ?? "0"
			vc.title = channel["name"] as? String
		}
	}
	
	deinit {
		print("deinit - ViewController")
	}
}

extension ViewController{
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension ViewController{
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		cell.textLabel?.text = data[indexPath.row]["name"] as? String
		
		return cell
	}
}

extension UIViewController{
	func showErrorAlert(title: String?, message: String){
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(.init(title: "OK", style: .cancel, handler: nil))
		
		present(alert, animated: true, completion: nil)
	}
}

