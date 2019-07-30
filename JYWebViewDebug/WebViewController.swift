//
//  WebViewController.swift
//  JYWebViewDebug
//
//  Created by Bennie on 7/3/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebViewController:UIViewController,WKNavigationDelegate  {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {

    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        print("跳转url\(url)")
        decisionHandler(WKNavigationActionPolicy.allow);
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void){
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
        {
            let card = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(URLSession.AuthChallengeDisposition.useCredential, card)
        }
    }

    lazy var webView:WKWebView? = {
        let wv = WKWebView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), configuration: WKWebViewConfiguration.init())
        wv.navigationDelegate = self as WKNavigationDelegate
        return wv
    }()

    public var urlStr:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.webView!)
        guard (self.urlStr != nil) else {
            return;
        }
        self.webView?.load(URLRequest.init(url: URL.init(string: self.urlStr!)!))
    }
}
