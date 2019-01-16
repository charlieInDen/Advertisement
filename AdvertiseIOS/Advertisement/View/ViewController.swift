//
//  ViewController.swift
//  Advertisement
//
//  Created by Nishant Sharma on 3/1/19.
//  Copyright © 2019 Personal. All rights reserved.
//
/* Summary: we use NSFetchRequest to fetch the entity, then tells it sort the result by name in ascending order. We initialize the NSFetchedResultController with the FetchRequest. The ViewController will also be assigned as the delegate so it can react and update the TableView when the underlying data changes.
 */
import UIKit
import CoreData
enum ViewControllerType {
    case MainViewController
    case FavoriteViewController
    case none
}
class ViewController: UIViewController {
    
    @IBOutlet weak var failLabel: UILabel!
    @IBOutlet weak var realEstateTableView: UITableView!
    var type:ViewControllerType = ViewControllerType.none
    var viewModel: RealEstateViewModel?
    var localData:[RealEstate]?
    private let realEstateURLStr = "https://private-91146-mobiletask.apiary-mock.com/realestates"
    private lazy var fetchedResultsController: NSFetchedResultsController<RealEstate> = {
        let fetchRequest = NSFetchRequest<RealEstate>(entityName:"RealEstate")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending:true)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: (viewModel?.syncCordinator.viewContext)!,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocalData()
        self.realEstateTableView.rowHeight = UITableView.automaticDimension
        if NetworkReachability.isConnectedToNetwork() == true || (self.fetchedResultsController.sections?[0].numberOfObjects ?? 0) > 0 {
            failLabel.isHidden = true
        }
        //Refresh only one time and use offline data throughout, We can add refresh button to fetch latest data again instead of making every time request on the launch of application to provide high performance application
        if (self.fetchedResultsController.sections?[0].numberOfObjects ?? 0) == 0 {
            viewModel?.fetchData(realEstateURLStr, completionHandler: { error  in
                DispatchQueue.main.async {
                    if error != nil {
                        print("Error in fetching Data")
                    }else {
                        self.updateLocalData()
                        
                    }
                }
            })
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var row = 0
        let rowCount = localData?.count ?? 0
        if rowCount > 0 {
            row = rowCount + rowCount/3
        }
        return row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

            let isAdvertise = (indexPath.row+1)%3 == 0 ? true: false
            cell.textLabel?.numberOfLines = 0
            if isAdvertise == true {
                cell.textLabel?.text = nil
                cell.imageView?.image = #imageLiteral(resourceName: "advertiseImage.jpg")
                cell.imageView?.autoresizingMask = [.flexibleWidth,.flexibleHeight]
                cell.imageView?.center = CGPoint.init(x: cell.contentView.bounds.size.width/2, y: cell.contentView.bounds.size.height/2)
            } else {
                let index = IndexPath.init(row: indexPath.row - indexPath.row/3, section: indexPath.section)
                if let realEstate = localData?[index.row] {
                cell.textLabel?.text = realEstate.title + "\n" + String(realEstate.price) + "\n" + realEstate.address
                    cell.imageView?.image = #imageLiteral(resourceName: "noImage.jpg")
                    if let URL = URL.init(string: realEstate.url) {
                        cell.imageView?.loadImage(url: URL)
                    }
                    cell.accessoryType =  ((realEstate.favorite == true) ? .checkmark : .none)
                }
        }

        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.row)!")
        let index = IndexPath.init(row: indexPath.row - indexPath.row/3, section: indexPath.section)
        if let realEstate = localData?[index.row] {
            if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
                let isAdvertise = (indexPath.row+1)%3 == 0 ? true: false
                if isAdvertise == true {
                    cell.accessoryType = .none
                }
                else {
                    realEstate.favorite = !realEstate.favorite
                    cell.accessoryType =  ((realEstate.favorite == true) ? .checkmark : .none)
                }
            }
            try? viewModel?.syncCordinator.viewContext.save()
            
            if type != ViewControllerType.MainViewController
            {
                tableView.reloadData()
            }
        }
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        updateLocalData()
        realEstateTableView.reloadData()
    }
    func updateLocalData(){
        if type == ViewControllerType.MainViewController
        {
            localData = self.fetchedResultsController.fetchedObjects ?? []
        }else{
            let arr = self.fetchedResultsController.fetchedObjects ?? []
            localData?.removeAll()
            localData = []
            for elem in arr {
                if elem.favorite == true {
                    localData?.append(elem)
                }
            }
            self.realEstateTableView.reloadData()
        }
    }
}
    
extension UIImageView {
    func loadImage(url: URL) {
        DispatchQueue.global().async {
            if let responseData = try? Data(contentsOf: url) {
                if let image = UIImage.init(data: responseData){
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
        }
    }
}

