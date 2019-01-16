//
//  RealEstateViewModel.swift
//  Advertisement
//
//  Created by Nishant Sharma on 3/1/19.
//  Copyright © 2019 Personal. All rights reserved.
//

import Foundation
typealias FetchDataCallback = (Error?) -> Void
final class RealEstateViewModel {
    var realEstateNames: [String]? //list of names from the first page of data
    let realEstateService: RealEstateService
    let syncCordinator: CoreDataSyncCordinator
    init(service: RealEstateService, syncCordinator: CoreDataSyncCordinator) {
        self.realEstateService = service
        self.syncCordinator = syncCordinator
    }
    func fetchData(_ urlString:String, completionHandler: @escaping FetchDataCallback){
        realEstateService.getRealEstateList(forRequestURL: urlString) { (result, error) in
            guard let realEstateResult = result else {
                return
            }
            DispatchQueue.main.async {
                self.syncCordinator.fetchedRealEstateData(realEstateResult.items, completion: { (error) in
                    completionHandler(error)
                })
            }
            
        }
    }
}


