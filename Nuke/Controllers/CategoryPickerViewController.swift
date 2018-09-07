//
//  ViewController.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-08-22.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import UIKit
import Moya

class CategoryPickerViewController: UIViewController, Storyboarded, UITableViewDataSource {
    
    enum TableViewSections: Int {
        case shows = 1
        case categories = 0
    }
    private let numSections = 2
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numSections
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        guard let sectionName = TableViewSections(rawValue: section) else { return nil }
//
//        switch sectionName {
//        case .shows:
//            return "Shows"
//        case .categories:
//            return "Categories"
//        }
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionName = TableViewSections(rawValue: section) else { return 0 }
        switch sectionName {
        case .shows:
            return shows?.count ?? 0
        case .categories:
            return categories?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")!
        
        guard let sectionName = TableViewSections(rawValue: indexPath.section) else {
            return cell
        }
        
        switch sectionName {
        case .shows:
            cell.textLabel?.text = shows?[indexPath.row].name ?? ""
        case .categories:
            cell.textLabel?.text = categories?[indexPath.row].name ?? ""
        }
        
        return cell
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var showService: ShowService?
    var categoryService: CategoryService?
    
    private var categories: [Category]? {
        didSet { tableView.reloadSections(IndexSet(integer: TableViewSections.categories.rawValue), with: UITableViewRowAnimation.right) }
    }
    private var shows: [Show]? {
        didSet { tableView.reloadSections(IndexSet(integer: TableViewSections.shows.rawValue), with: UITableViewRowAnimation.right) }
    }
    
    private var videoTypes: [VideoCollectionInfo] {
        return (shows ?? [Show]()) as [VideoCollectionInfo] + (categories ?? [Category]()) as [VideoCollectionInfo]
    }
    
    private func updateViewsFromModel() {
        print(videoTypes)
    }
    
    private func updateModels() {
        categoryService?.getCategories { response in
            switch response {
            case .failure(let error):
                print("Error getting categories: \(error)")
            case .success(let categories):
                self.categories = categories
            }
        }
        showService?.getShows { response in
            switch response {
            case .failure(let error):
                print("Error getting shows: \(error)")
            case .success(let shows):
                self.shows = shows
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateModels()

        
        tableView.dataSource = self
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

