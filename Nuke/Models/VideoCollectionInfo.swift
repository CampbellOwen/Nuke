//
//  VideoCollectionInfo.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-08-23.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import Foundation

protocol VideoCollectionInfo {
    var id: Int { get set }
    var name: String { get set }
    var siteUrl: URL { get set}
}
