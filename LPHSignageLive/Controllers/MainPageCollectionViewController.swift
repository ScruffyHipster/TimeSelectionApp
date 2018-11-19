//
//  MainPageCollectionViewController.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 31/10/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit
import Reachability

private let reuseIdentifier = "Cell"

class MainPageCollectionViewController: UICollectionViewController {
	
	private let dataSource = DataSource()
	private var reachability: Reachability?
	private var connection: Bool?
	private lazy var notification: NotificationCenter = {
		var notification = NotificationCenter()
		return notification
	}()
	private let hostNames = [nil, "google.com", "invalid host"]
	let host = 1
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupCollectionView()
		startReachability(at: host)
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.title = "Main menu"
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
	func setupCollectionView() {
		//set up cells
		let width = view.frame.width - 10
		let height = view.frame.height / 3
		let cv = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
		cv.itemSize = CGSize(width: width, height: height)
		collectionView.backgroundColor = UIColor.lightGray
		let blur = UIBlurEffect(style: .dark)
		let blurLayer = UIVisualEffectView(effect: blur)
		collectionView.addSubview(blurLayer)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "noInternet" {
			let vc = segue.destination as! NoInternetViewController
			vc.reachability = reachability
		}
	}
	
}

extension MainPageCollectionViewController {
	//MARK:- Reachability
	
	@objc func reachabilityChanged(notification: Notification) {
		let reachability = notification.object as! Reachability
		reachability.whenReachable = { reachability in
			switch reachability.connection {
			case .cellular:
				print("cellular")
				self.dismiss(animated: true, completion: nil)
			case .wifi:
				print("wifi")
				self.dismiss(animated: true, completion: nil)
			case .none:
				print("none")
				self.connection = false
			}
		}
		reachability.whenUnreachable = { reachability in
			print("not avaliable")
			self.performSegue(withIdentifier: "noInternet", sender: self)
		}
		
	}
	
	func startReachability(at index: Int) {
		stopNotifier()
		setupReachability(hostNames[index])
		startNotifier()
	}
	
	func setupReachability(_ hostName: String?) {
		guard let hostName = hostName else {return}
		reachability = Reachability(hostname: hostName)
		NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: .reachabilityChanged, object: reachability)
	}
	
	func startNotifier() {
		print("Start notifier")
		do {
			try reachability?.startNotifier()
		} catch {
			print("Notifier failed to start")
		}
	}
	
	func stopNotifier() {
		print("stop notifier")
		reachability?.stopNotifier()
		NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
		reachability = nil
	}
}



extension MainPageCollectionViewController {
	// MARK: UICollectionViewDataSource
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 3
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCollectionViewCell
		switch indexPath.row {
		case 0:
			cell.backgroundColor = UIColor.gray
			cell.title.text = "Time to start"
		case 1:
			cell.backgroundColor = UIColor.gray
			cell.title.text = "Fire Alarm"
		case 2:
			cell.backgroundColor = UIColor.gray
			cell.title.text = "Happy hour"
		default:
			cell.backgroundColor = .white
		}
		cell.image.image = UIImage(named: "cvcitem\(indexPath.row)")
		cell.layer.cornerRadius = 10
		return cell
	}
	
	// MARK: UICollectionViewDelegate
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch indexPath.row {
		case 0:
			performSegue(withIdentifier: "TimeSegue", sender: self)
		case 1:
			performSegue(withIdentifier: "emergencySegue", sender: self)
		default:
			let alert = UIAlertController(title: "Feature not currently available", message: "This feature is not currently built for your device", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
			present(alert, animated: true)
		}
	}
}

