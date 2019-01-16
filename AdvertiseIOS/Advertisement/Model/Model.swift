//
//  Model.swift
//  Advertisement
//
//  Created by Nishant Sharma on 3/1/19.
//  Copyright © 2019 Personal. All rights reserved.
//


import Foundation
import Foundation

struct RealEstateResult: Codable {
    let items: [Item]
}

struct Item: Codable {
    let id: Int
    let title: String
    let price: Int
    let location: Location
    let images: [Image]?
    //let favorite: Bool
}

struct Image: Codable {
    let id: Int
    let url: String
}

struct Location: Codable {
    let address: String
    let latitude, longitude: Double
}
