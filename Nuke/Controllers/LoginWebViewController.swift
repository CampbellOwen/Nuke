//
//  LoginWebViewController.swift
//  Nuke
//
//  Created by Owen Campbell on 2018-09-28.
//  Copyright © 2018 Owen Campbell. All rights reserved.
//

import UIKit
import WebKit

class LoginWebViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let url = URL(string: "https://www.giantbomb.com/app/Nuke")
        let request = URLRequest(url: url!)
        webView.load(request)
        activityIndicator.startAnimating()
    }
    
    // MARK - Outlets
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            webView.navigationDelegate = self
        }
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
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

}

extension LoginWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
}
