//
//  Coordinator.swift
//  Nuke
//
//  Created by Heather Robyn on 2018-09-03.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}
