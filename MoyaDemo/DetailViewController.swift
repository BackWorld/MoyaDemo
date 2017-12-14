//
//  DetailViewController.swift
//  MoyaDemo
//
//  Created by zhuxuhong on 2017/12/13.
//  Copyright © 2017年 北大方正电子. All rights reserved.
//

import UIKit
import Moya

class DetailViewController: UITableViewController {

// MARK: - IBOutlets
//    @IBOutlet weak var btn: UIButton!

// MARK: - Properties
	var channelId = "0"
	
	fileprivate var data: [JSONDictionary] = []

// MARK: - Initial Method
    private func setupUI() {
        tableView.estimatedRowHeight = 50
		tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    private func initData() {
        
    }
    
    
// MARK: - Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
		
		requestData(nil)
	}
	
	deinit {
		print("deinit - DetailViewController")
	}
    
// MARK: - Action & IBOutletAction
    /*
     @IBAction func actionControlTouched(_ sender: UIControl) {
     
     }
     */

// MARK: - Override Method
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? PlayerViewController,
			let cell = sender as? UITableViewCell, 
			let row = tableView.indexPath(for: cell)?.row {
			let song = data[row]
			vc.url = song["url"] as? String
			vc.coverImage = cell.imageView?.image
			vc.title = song["title"] as? String
		}
	}

// MARK: - Private Method	
	@IBAction func requestData(_ sender: Any?){
		Network.request(MultiTarget(API.playList(channel: channelId)), viewController: self, success: { 
			guard let array = $0["song"] as? [JSONDictionary] else{
				print("数据解析失败")
				return
			}
			self.data.append(contentsOf: array)
			self.tableView.reloadData()
		}, error: { 
			self.showErrorAlert(title: "数据请求失败", message: $0)
		}) { 
			self.showErrorAlert(title: "网络错误", message: $0.localizedDescription)
		}
	}

// MARK: - Public Method

}

extension DetailViewController{
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	}
}

extension DetailViewController{
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return data.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		
		let song = data[indexPath.row]
		cell.textLabel?.text = song["title"] as? String
		cell.detailTextLabel?.text = song["artist"] as? String
		
		if let url = URL.init(string: song["picture"] as! String),
			let data = try? Data.init(contentsOf: url){
			cell.imageView?.image = UIImage.init(data: data)
		}
		return cell
	}
}
