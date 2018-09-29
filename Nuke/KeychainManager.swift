//
//  KeychainManager.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-09-28.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import Foundation

class KeychainManager {
    
    public func store(apiKey key:String) -> Bool {
        let apiKeyData = key.data(using: .utf8)! as CFData
        var query: [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                   kSecAttrAccount as String: "apiKey",
                                   kSecAttrService as String: "GiantBomb",
                                   kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
                                   ]
        let attributes: [String:Any] = [kSecValueData as String: apiKeyData]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecItemNotFound {
            print("apikey not found in keychain, attempting to add")
            query.merge(attributes) { (current, _) in current}
            let insertStatus = SecItemAdd(query as CFDictionary, nil)
            guard insertStatus == errSecSuccess else {
                print("Inserting api key failed with error: \(insertStatus)")
                return false
            }
            print("Inserted api key successfully")
        }
        else {
            guard updateStatus == errSecSuccess else {
                print("Updating api key failed with error: \(updateStatus)")
                return false
            }
            print("Updated api key successfully")
        }
        
        return true
    }
    
    public func getApiKey() -> String? {
        let query: [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                   kSecAttrAccount as String: "apiKey",
                                   kSecAttrService as String: "GiantBomb",
                                   kSecMatchLimit as String: kSecMatchLimitOne,
                                   kSecReturnData as String: true,
                                   kSecReturnAttributes as String: false]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        guard let apiKeyData = item as? Data, let apiKey = String(data: apiKeyData, encoding: .utf8) else {
            return nil
        }
        return apiKey
    }
    
    public func removeApiKey() -> Bool {
        let query: [String:Any] = [kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "apiKey",
        kSecAttrService as String: "GiantBomb",
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        debugPrint(status)
        let ret = status == errSecSuccess || status == errSecItemNotFound
        
        return ret
    }
}
