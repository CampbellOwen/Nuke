//
//  HomeViewController.swift
//  Nuke
//
//  Created by Owen Campbell on 2019-05-01.
//  Copyright © 2019 Owen Campbell. All rights reserved.
//

import UIKit

fileprivate enum RowTypes: String {
    init(index:Int) {
        if (index == 0) {
            self = .hero
        }
        else {
            self = .collection
        }
    }
    case hero = "heroCell"
    case collection = "collectionCell"
}

class HomeViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    var networkController: NetworkController?
    private var latestVideosTask: URLSessionDataTask?
    private var otherShowsTasks: [URLSessionDataTask]?
    var imageCache: NSCache<NSString,UIImage>?
    
    // MARK: - Models
    
    var videoCollections = [VideoCollection(name: "Latest", videos: [], resource: VideosResource())]
    var heroVideo: Video?
    
    func handleErrors(error: NetworkErrorNew) {
        switch error {
        case .authenticationError:
            DispatchQueue.main.async {
                print("Need to authenticate")
                self.networkController?.cancel()
                self.authenticate { [weak self] in
                    self?.loadModels()
                }
                
            }
        case .badRequest, .failed, .unableToDecode:
            print("Error getting shows")
        }
    }
    
    func loadModels() {
        latestVideosTask = networkController?.load(with: videoCollections[0].resource) { [weak self] result in
            switch result {
            case .failure(let error):
                self?.handleErrors(error: error)
            case .success(let result):
                print("Successfully got shows")
                var videos = result.results
                var first_five_shows = [Int]()
                var i = 0
                while i < videos.count && first_five_shows.count < 5 {
                    if let show = videos[i].show {
                        if !first_five_shows.contains(show.id) {
                            first_five_shows.append(show.id)
                        }
                    }
                   
                    i += 1
                }
                self?.add(shows: first_five_shows)
                let heroVideo = videos.remove(at: 0)
                DispatchQueue.main.async {
                    self?.heroVideo = heroVideo
                    self?.videoCollections[0].videos = videos
                    self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: .automatic)
                    
                }
            }
        }
    }
    
    func add(shows ids: [Int]) {
        otherShowsTasks = [URLSessionDataTask]()
        for id in ids {
            let resource = VideosResource()
            resource.filter(show: id)
            resource.limit = 20
            let task = networkController?.load(with: resource) { [weak self, resource] result in
                switch result {
                case .failure(let error):
                    self?.handleErrors(error: error)
                case .success(let videosResult):
                    var videos = videosResult.results
                    let collection = VideoCollection(name: videos[0].show?.name ?? "", videos: videos, resource: resource)
                    DispatchQueue.main.async {
                        self?.videoCollections.append(collection)
                        self?.tableView.insertRows(at: [IndexPath(row: self?.videoCollections.count ?? 1, section: 0)], with: .automatic)
                    }
                }
                
            }
            if let task = task {
                otherShowsTasks?.append(task)
            }
        }
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
    
    
    var storedOffsets = [Int: CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        loadModels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}



extension HomeViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = RowTypes(index: indexPath.row)
        switch type {
        case .hero:
            return self.tableView.frame.width * 9 / 16
        case .collection:
            return 176
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? CollectionTableViewCell else {
            return
        }
        tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? CollectionTableViewCell else {
            return
        }
        
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
}

extension HomeViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoCollections.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = RowTypes(index: indexPath.row)
        
    
        let cell = tableView.dequeueReusableCell(withIdentifier: type.rawValue, for: indexPath)
        
        if let collectionCell = cell as? CollectionTableViewCell {
            collectionCell.populate(with: videoCollections[indexPath.row - 1])
        }
        
        if let heroCell = cell as? HeroTableViewCell, let heroVideo = self.heroVideo {
            heroCell.label.text = heroVideo.name
            
            let imageUrl = heroVideo.images[.screenLarge]
            if let url = imageUrl, let image = imageCache?.object(forKey: NSString(string: url.absoluteString)) {
                heroCell.imageView?.image = image
            }
            else {
                heroCell.imageView?.image = nil
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    if let imageUrl = imageUrl, let imageData = try? Data(contentsOf: imageUrl) {
                        DispatchQueue.main.async { [weak self]  in
                            if let image = UIImage(data: imageData) {
                                self?.imageCache?.setObject(image, forKey: NSString(string: imageUrl.absoluteString))
                                heroCell.heroImageView.image = image
                            }
                            
                        }
                    }
                }
            }
            
            
            
        }
        
        return cell
    }
    
}

extension HomeViewController : UICollectionViewDelegate {
    
}

extension HomeViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoCollections[collectionView.tag - 1].videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let videoCell = cell as? VideoCollectionViewCell {
            let video = videoCollections[collectionView.tag - 1].videos[indexPath.row]
            videoCell.label.text = video.name
            let imageUrl = video.images[.medium]
            if let imageUrl = imageUrl, let image = imageCache?.object(forKey: NSString(string: imageUrl.absoluteString)) {
                videoCell.videoImage.image = image
            }
            else {
                videoCell.videoImage?.image = nil
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    if let imageUrl = imageUrl, let imageData = try? Data(contentsOf: imageUrl) {
                        DispatchQueue.main.async { [weak self]  in
                            if let image = UIImage(data: imageData) {
                                self?.imageCache?.setObject(image, forKey: NSString(string: imageUrl.absoluteString))
                                videoCell.videoImage.image = image
                            }
                            
                        }
                    }
                }
            }
        }
        return cell
    }
    
    
}
