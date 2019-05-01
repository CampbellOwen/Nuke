//
//  CategoryListViewController.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-09-28.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import UIKit

private enum Sections: Int, CaseIterable{
    case categories = 0
    case shows
}

class CategoryListViewController: UITableViewController {

    var networkController: NetworkController?
    var showResource = ShowsResource()
    var showTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Checking user is logged in")
//        apiKey = keychain.getApiKey()
        updateModel()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func authenticate(completion: @escaping () -> Void) {
        let loginStoryboard = UIStoryboard.init(name: "Login", bundle: Bundle.main)
        let loginController = loginStoryboard.instantiateInitialViewController()
        if let navigationController = loginController as? UINavigationController, let login = navigationController.viewControllers.last as? LoginViewController {
            login.networkController = networkController
            login.completion = completion
        }
        loginController?.modalPresentationStyle = .formSheet
        loginController?.modalTransitionStyle = .coverVertical
        if let loginController = loginController {
            present(loginController, animated: true, completion: nil)
        }
    }
    
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        updateModel()
    }
    
    // MARK: - Model
    var shows: [Show]? {
        didSet {
            tableView.reloadSections(IndexSet(integer: Sections.shows.rawValue), with: .automatic)
        }
    }
    
    var categories: [Category]? {
        didSet {
            tableView.reloadSections(IndexSet(integer: Sections.categories.rawValue), with: .automatic)
        }
    }
    
    private func updateModel() {
//        api.getCategories(limit: nil, offset: nil, sort: nil) { result in
//            switch result {
//            case .failure(let error):
//                print("Error getting categories:\(error)")
//            case .success(let categories):
//                DispatchQueue.main.async {
//                    self.categories = categories
//                }
//            }
//        }
//        
//        network.getShows(limit: nil, offset: nil, sort: nil) { result in
//            switch result {
//            case .failure(let error):
//                print("Error getting shows:\(error)")
//            case .success(let shows):
//                DispatchQueue.main.async {
//                    self.shows = shows
//                }
//            }
//        }
        print("Updating Model")
        showTask = networkController?.load(with: showResource) { [weak self] (result) in
            print("Finished")
            switch result {
            case .failure(let error):
                switch error {
                case .authenticationError:
                    DispatchQueue.main.async {
                        print("Need to authenticate")
                        self?.authenticate { [weak self] in
                            self?.updateModel()
                        }
                        
                    }
                case .badRequest, .failed, .unableToDecode:
                    print("Error getting shows")
                }
            case .success(let result):
                DispatchQueue.main.async {
                    print("Successfully got shows")
                    var shows = result.results
                    shows.sort { (first, second) in
                        if (first.active && second.active) || (!first.active && !second.active) {
                            return first.name.lowercased() < second.name.lowercased()
                        }
                        return first.active
                    }
                    self?.shows = shows
                }
            }
                
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Sections.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let sectionName = Sections(rawValue: section) else {
            return 0
        }
        switch sectionName {
        case .categories:
            return categories?.count ?? 0
        case .shows:
            return shows?.count ?? 0
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseId", for: indexPath)

        guard let sectionName = Sections(rawValue: indexPath.section) else {
            return cell
        }
        
        switch sectionName {
        case .categories:
            let category = categories?[indexPath.item]
            cell.textLabel?.text = category?.name
        case .shows:
            let show = shows?[indexPath.item]
            cell.textLabel?.text = show?.name
        }

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
