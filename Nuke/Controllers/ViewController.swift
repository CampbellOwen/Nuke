//
//  ViewController.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-08-22.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import UIKit
import Moya

class ViewController: UIViewController {

    private let provider = MoyaProvider<GiantBombService>(plugins: [NetworkLoggerPlugin(verbose:true)])
    private lazy var videoService = VideoService(with: provider)
    private lazy var showService = ShowService(with: provider)
    private lazy var categoryService = CategoryService(with: provider)
    
    private var categories: [Category]? {
        didSet { updateViewsFromModel() }
    }
    private var shows: [Show]? {
        didSet { updateViewsFromModel() }
    }
    
    private var videoTypes: [VideoCollectionInfo] {
        return (categories ?? [Category]()) as [VideoCollectionInfo] + (shows ?? [Show]()) as [VideoCollectionInfo]
    }
    
    private func updateViewsFromModel() {
        print(videoTypes)
    }
    
    private func updateModels() {
        categoryService.getCategories { response in self.categories = response.results }
        showService.getShows {response in self.shows = response.results }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateModels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

