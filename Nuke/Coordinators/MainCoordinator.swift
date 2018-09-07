//
//  MainCoordinator.swift
//  Nuke
//
//  Created by Heather Robyn on 2018-09-03.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import UIKit
import Moya

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    let provider = MoyaProvider<GiantBombService>()

    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = CategoryPickerViewController.instantiate()
        vc.showService = ShowService(with: provider)
        vc.categoryService = CategoryService(with: provider)
        navigationController.pushViewController(vc, animated: false)
        
//        let videoService = VideoService(with: provider)
//        videoService.getVideos(limit: 100) { result in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let videos):
//                print("\nFetching page\n")
//                for video in videos {
//                    print(video)
//                }
//                sleep(1)
//                videoService.getNextPage { result in
//                    switch result {
//                    case .failure(let error):
//                        print(error)
//                    case .success(let videos):
//                        for video in videos {
//                            print(video)
//                        }
//                        sleep(1)
//                        print("\nFetching page\n")
//                        videoService.getNextPage { result in
//                            switch result {
//                            case .failure(let error):
//                                print(error)
//                            case .success(let videos):
//                                for video in videos {
//                                    if video.author == nil {
//                                        print("nil author")
//                                    }
//                                    print(video)
//                                }
//                                sleep(1)
//                                print("\nFetching page\n")
//                                videoService.getNextPage { result in
//                                    switch result {
//                                    case .failure(let error):
//                                        print(error)
//                                    case .success(let videos):
//                                        for video in videos {
//                                            if video.author == nil {
//                                                print("nil author")
//                                            }
//                                            print(video)
//                                        }
//                                        sleep(1)
//                                        print("\nFetching page\n")
//                                        videoService.getNextPage { result in
//                                            switch result {
//                                            case .failure(let error):
//                                                print(error)
//                                            case .success(let videos):
//                                                for video in videos {
//                                                    if video.author == nil {
//                                                        print("nil author")
//                                                    }
//                                                    print(video)
//                                                }
//                                                sleep(1)
//                                                print("\nFetching page\n")
//                                                videoService.getNextPage { result in
//                                                    switch result {
//                                                    case .failure(let error):
//                                                        print(error)
//                                                    case .success(let videos):
//                                                        for video in videos {
//                                                            print(video)
//                                                        }
//                                                    }
//                                                }
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }

        
    }
}
