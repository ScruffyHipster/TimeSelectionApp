//
//  MainPageCollectionViewController.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 31/10/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MainPageCollectionViewController: UICollectionViewController {
	
	private let dataSource = DataSource()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupCollectionView()
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.title = "Main menu"
		// Do any additional setup after loading the view.
	}
	
	func setupCollectionView() {
		//set up cells
		let width = view.frame.width - 10
		let height = view.frame.height / 3
		let cv = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
		cv.itemSize = CGSize(width: width, height: height)
	}
	
	// MARK: - Navigation
	
//	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		if segue.identifier == "TimeSelector" {
//			let destination = segue.destination as! TimeSelectorViewController
//		}
//	}
	
	
	
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
			cell.backgroundColor = UIColor.red
			cell.title.text = "Time to start"
		case 1:
			cell.backgroundColor = UIColor.blue
			cell.title.text = "Fire Alarm"
		case 2:
			cell.backgroundColor = UIColor.green
			cell.title.text = "Happy hour"
		default:
			cell.backgroundColor = .white
		}
		cell.layer.cornerRadius = 10
		return cell
	}
	
	// MARK: UICollectionViewDelegate
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if indexPath.row == 0 {
			performSegue(withIdentifier: "TimeSegue", sender: self)
		} else if indexPath.row == 1 {
			performSegue(withIdentifier: "emergencySegue", sender: self)
		}
	}
	
}
