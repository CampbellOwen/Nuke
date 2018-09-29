//
//  AuthenticationResponse.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-09-28.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import Foundation

struct AuthenticationRespone: Codable {
    var status: String
    var creationTime: String
    var regToken: String
    var expiration: String
    var customerId: String?
}
