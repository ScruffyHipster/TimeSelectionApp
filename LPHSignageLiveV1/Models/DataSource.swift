//
//  DataSource.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 31/10/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

class DataSource {
	
	private var features = [Features]()
	private var sections = [String]()
	
	
	var featuresCount: Int {
		return features.count
	}
	
	var sectionsCount: Int {
		return sections.count
	}
	
	//MARK:- Helper Functions
	
	func titleForSection(at indexPath: IndexPath) -> String? {
		if indexPath.section < sections.count {
			return sections[indexPath.section]
		}
		return nil
	}
	
	func numberOfFeaturesInSection(_ index: Int) -> Int {
		let numberOfFeatures = featuresForSection(index)
		return numberOfFeatures.count
	}
	
	private func featuresForSection(_ index: Int) -> [Features] {
		let section = sections[index]
		let featureForSection = features.filter { (feature: Features) -> Bool in
			return feature.category == section
		}
		return featureForSection
	}
	
}
