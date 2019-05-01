//
//  LoginViewController.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-09-28.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    private var beenSeen = false
    var networkController: NetworkController?
    var completion: (() -> Void)?
    private var authTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Loaded")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if beenSeen {
            print("Appeared other time")
            let clipboardString = UIPasteboard.general.string
            if let string = clipboardString, string.count == 6 {
                registrationCode.text = string
                registrationCode.setNeedsLayout()
            }
        }
        else {
            print("Appeared first time")
            beenSeen = true
        }
    }
    
    // MARK: - Outlets
    @IBAction func tryAuthenticate(_ sender: UIButton) {
        print("Authenticating")
        guard let regCode = registrationCode.text else { return }
        authTask = networkController?.authenticate(with: regCode) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let apiKey):
                let keychain = KeychainManager()
                guard keychain.store(apiKey: apiKey) else {
                    print("Keychain failed to store apikey")
                    return
                }
                self?.networkController?.apiKey = apiKey
                
                print("Testing retrive: \(keychain.getApiKey() ?? "not found")")

                DispatchQueue.main.async {
                    print("Dismissing")
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
                    self?.completion?()
                }
            }
        }
    }
    
    @IBOutlet weak var registrationCode: UITextField! {
        didSet {
            registrationCode.delegate = self
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        registrationCode.resignFirstResponder()
        return true
    }
}
