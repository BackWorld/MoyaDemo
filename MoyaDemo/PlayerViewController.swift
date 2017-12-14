//
//  PlayerViewController.swift
//  MoyaDemo
//
//  Created by zhuxuhong on 2017/12/13.
//  Copyright © 2017年 北大方正电子. All rights reserved.
//

import UIKit
import MediaPlayer
import Moya

class PlayerViewController: UIViewController {

// MARK: - IBOutlets
	@IBOutlet weak var coverIV: UIImageView!
	@IBOutlet weak var downloadBtn: UIButton!

// MARK: - Properties
	var url: String?
	
	var coverImage: UIImage?
	
	fileprivate lazy var player: AVPlayer? = {
		guard 
			let url = self.url, 
			let URL = URL.init(string: url) else {
			return nil
		}
		let player = AVPlayer(url: URL)
		return player
	}()
	
	fileprivate lazy var playerLayer: AVPlayerLayer = {
		let layer = AVPlayerLayer(player: self.player)
		layer.frame = self.view.bounds
		
		return layer
	}()
	

// MARK: - Initial Method
    private func setupUI() {
        view.layer.addSublayer(playerLayer)
		
		coverIV.image = coverImage
		coverIV.clipsToBounds = true
		coverIV.layer.borderWidth = 5
		coverIV.layer.borderColor = UIColor.lightGray.cgColor
		coverIV.layer.cornerRadius = coverIV.bounds.width / 2
    }
    
    private func initData() {
        
    }
    
    
// MARK: - Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
		
		initData()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		player?.play()
		
		animateCoverIV()
	}
	
    
// MARK: - Action & IBOutletAction
	@IBAction func downloadMP4(_ sender: Any){
		self.downloadBtn.isEnabled = false
		Network.download(MultiTarget(API.downloadMP4(url ?? "")), progress: {
			let title = ($0 >= 1 && $1) ? "已下载" : "\(Int($0 * 100)) %"
			self.downloadBtn.titleLabel?.text = title
			self.downloadBtn.setTitle(title, for: .normal)
			
		}, failure: { 
			self.showErrorAlert(title: "下载失败", message: $0.errorDescription ?? "未知错误")
			self.downloadBtn.isEnabled = true
		}) {
			self.showErrorAlert(title: "下载失败", message: $0)
			self.downloadBtn.isEnabled = true
		}
	}

// MARK: - Override Method

// MARK: - Private Method
	fileprivate func animateCoverIV(){
		let anim = CABasicAnimation(keyPath: "transform.rotation.z")
		anim.fromValue = 0
		anim.toValue = CGFloat.pi * 2
		anim.duration = 20
		anim.repeatCount = Float.infinity
		anim.isRemovedOnCompletion = false
		coverIV.layer.add(anim, forKey: nil)
	}

// MARK: - Public Method

}
