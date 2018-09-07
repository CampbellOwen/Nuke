//
//  Result.swift
//  Nuke
//
//  Created by Heather Robyn on 2018-09-03.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import Foundation

enum Result<T:Decodable> {
    case success(T)
    case failure(Error)
}
