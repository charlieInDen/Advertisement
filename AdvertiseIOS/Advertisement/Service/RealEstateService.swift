//
//  RealEstateService.swift
//  Advertisement
//
//  Created by Nishant Sharma on 3/1/19.
//  Copyright © 2019 Personal. All rights reserved.
//
/* Summary: Networking Coordinator that connects to the API to fetch list from the network. It provides public method to get data with completion closure as the parameter.
 */
import Foundation

typealias RealEstateServiceCallback = (_ data: RealEstateResult?, _ error: Error?) -> Void
protocol RealEstateService {
    func getRealEstateList(forRequestURL url: String,
                      andCallback callback: @escaping RealEstateServiceCallback)
}
enum RealEstateListError: Error {
    case invalidURL
    case invalidData
    case none
}
class RealEstateServiceImpl: RealEstateService {
    func getRealEstateList(forRequestURL urlStr: String,
                       andCallback callback: @escaping RealEstateServiceCallback) {
        // Make it look like method needs some time to communicate with the server
        //Read data from URL
        guard let url = URL.init(string: urlStr) else {
            callback(nil, RealEstateListError.invalidURL)
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
            }
            guard let jsonData = data else {
                callback(nil, RealEstateListError.invalidData)
                return
            }
            //Convert responseData to json
            guard let responseJson = try? JSONDecoder().decode(RealEstateResult.self, from: jsonData) else {
                callback(nil, RealEstateListError.invalidData)
                return
            }
            callback(responseJson, RealEstateListError.none)
            }.resume()
    }
}
