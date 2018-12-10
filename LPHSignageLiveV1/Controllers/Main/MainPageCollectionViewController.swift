//
//  MainPageCollectionViewController.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 31/10/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit
import Reachability
import CoreData

private let reuseIdentifier = "Cell"

class MainPageCollectionViewController: UICollectionViewController {
	
	//MARK:- Properties
	private var reachability: Reachability?
	private var connection: Bool?
	private lazy var notification: NotificationCenter = {
		var notification = NotificationCenter()
		return notification
	}()
	private var emergencyStatus = false
	private var timeStatus: Int?
	private let hostNames = [nil, "google.com", "invalid host"]
	private let host = 1
	private var features = [Features]()
	private var timer: Timer?
	private var timeToSet: Int?
	private var timeStringStatus = ""
	private var timeSelectionCell: MainCollectionViewCell?
	var managedObjectContext: NSManagedObjectContext!
	
	//MARK:- View did load
	override func viewDidLoad() {
		super.viewDidLoad()
		setupCollectionView()
		startReachability(at: host)
		setUpFeatures()
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.title = "Main menu"
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}
	
	//MARK:- custom funcs
	func setUpFeatures() {
		let timer = Features(title: "Time to Start", image: "cvcitem", category: "utility")
		let emergency = Features(title: "Emergency Alert", image: "cvcitem", category: "utility")
		let deals = Features(title: "Deals", image: "cvcitem", category: "utility")
		features.append(timer)
		features.append(emergency)
		features.append(deals)
	}
	
	func setupCollectionView() {
		//set up cells
		let width = view.frame.width - 10
		let height = view.frame.height / 3
		let cv = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
		cv.itemSize = CGSize(width: width, height: height)
		collectionView.backgroundColor = UIColor.black
		let blur = UIBlurEffect(style: .dark)
		let blurLayer = UIVisualEffectView(effect: blur)
		collectionView.addSubview(blurLayer)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "noInternet" {
			let vc = segue.destination as! NoInternetViewController
			vc.reachability = reachability
		}
		if segue.identifier == "TimeSegue" {
			let vc = segue.destination as! PrimaryTimerViewController
			//Set main page to be the delegate for the PrimaryTimeVC
			vc.delegate = self
			vc.managedObjectContext = managedObjectContext
		}
		if segue.identifier == "emergencySegue" {
			let vc = segue.destination as! EmergencyEventViewController
			vc.delegate = self
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
		return features.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCollectionViewCell
		cell.title.text = features[indexPath.row].title
		cell.image.image = UIImage(named: "cvcitem\(indexPath.row)")
		cell.layer.cornerRadius = 10
		cell.backgroundColor = UIColor.lightGray
		
		switch indexPath.row {
		case 0:
			cell.status.text = "No timer set"
		case 1:
			cell.status.text = "off"
		case 2:
			cell.status.text = "off"
		default:
			cell.status.text = "Status"
		}
		return cell
	}
	
	// MARK: UICollectionViewDelegate
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		switch indexPath.row {
		case 0:
			if !emergencyStatus {
				performSegue(withIdentifier: "TimeSegue", sender: self)
			} else {
				let alert = UIAlertController(title: "Emergency", message: "This feature is unavailable when an emergency is in progress", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
				present(alert, animated: true)
			}
		case 1:
			performSegue(withIdentifier: "emergencySegue", sender: self)
		default:
			let alert = UIAlertController(title: "Feature not currently available", message: "This feature is not currently built for your device", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
			present(alert, animated: true)
		}
	}
}

extension MainPageCollectionViewController: PrimaryViewControllerDelegate {
	//MARK:- PrimaryViewcontroller delegate
	func numberOfTimersRunning(_ controller: PrimaryTimerViewController, numberOf shows: Int) {
		print("there are \(shows) in shows")
		let startIndex = features.startIndex
		let indexPath = IndexPath(item: startIndex, section: 0)
		let timeCell = collectionView.cellForItem(at: indexPath) as! MainCollectionViewCell
		//sets the collection view cell for use
		timeSelectionCell = timeCell
		//safely unwrap it for use
	    guard let timeSelectionCell = timeSelectionCell else {return}
		if shows > 0 {
			timeSelectionCell.status.text = String("\(shows) timers set")
		} else {
			timeSelectionCell.status.text = "No timers set"
		}
	}

	
	@objc func updateCountdown() {
		timeToSet! -= 1
		if timeToSet! > 0 {
			configureTimeLabel(with: Int32(timeToSet!), for: timeSelectionCell!.status)
			//Formats the time into a string
			timeSelectionCell?.status.text = timeStringStatus
		} else {
			timer?.invalidate()
			timeStringStatus = ""
			timeSelectionCell?.status.text = timeStringStatus
		}
	}
}


extension MainPageCollectionViewController: EmergencyEventViewControllerProtocol {
	func didSetEmergencyEvent(_ controller: EmergencyEventViewController, didSetEvent: Bool) {
		emergencyStatus = didSetEvent
		let startIndex = features.startIndex
		let indexPath = IndexPath(item: startIndex + 1, section: 0)
		let emergencyCell = collectionView.cellForItem(at: indexPath) as! MainCollectionViewCell
		switch didSetEvent {
		case true:
			emergencyCell.status.text = "Emergency in progress"
		case false:
			emergencyCell.status.text = "All is fine"
		}
	}
}
