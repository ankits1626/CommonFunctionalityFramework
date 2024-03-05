//
//  JoyAppWebViewController.swift
//  Flabuless
//
//  Created by Suyesh Kandpal on 13/09/22.
//  Copyright © 2022 Rewardz Private Limited. All rights reserved.
//

import UIKit
import WebKit

public protocol JoyAppWebViewCompletionDone {
    func completedWebViewProcess()
}

public class JoyAppWebViewController: UIViewController,WKUIDelegate,WKNavigationDelegate {
    
    var webView: WKWebView!
    @IBOutlet weak var webViewContainer: UIView!
    public var joyAppBaseUrl : String!
    var loader = MFLoader()
    public var delegate : JoyAppWebViewCompletionDone?
    @IBOutlet weak var tableViewContainer : UIView?
    @IBOutlet weak var headerView : UIView?
    @IBOutlet weak var joyScreenTitle : UILabel?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        joyScreenTitle?.text = "Joy Level".localized
        self.headerView?.backgroundColor = UIColor.getControlColor()
        self.view.backgroundColor = UIColor.getControlColor()
    }
    
    func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.webViewContainer.frame.size.height))
        self.webView = WKWebView (frame: customFrame , configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.webViewContainer.addSubview(webView)
        webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: webViewContainer.rightAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: webViewContainer.leftAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: webViewContainer.heightAnchor).isActive = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        loadRequestInWebview(URLRequest(url: URL(string:joyAppBaseUrl)!))
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableViewContainer?.roundCorners(corners: [.topLeft,.topRight], radius: 8.0)
    }
    
    private func loadRequestInWebview(_ request : URLRequest){
        webView.load(request)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {}
}

//MARK:- Ibactions
extension JoyAppWebViewController {
    @IBAction func backButtonPressed(sender : UIButton) {
        self.delegate?.completedWebViewProcess()
        self.navigationController?.popViewController(animated: true)
    }
}

