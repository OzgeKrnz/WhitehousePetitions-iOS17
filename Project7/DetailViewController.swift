//
//  DetailViewController.swift
//  Project7
//
//  Created by özge kurnaz on 1.01.2025.
//

import UIKit
import WebKit
class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: Petition?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let detailItem = detailItem else{return}
        
        let html = """
        <html>
        <head>
        <meta name="viewport" contents="width-device-width, initial-scale=1">
        <style> body { font-size: 370%; } </style>
        </head>
        <body>
        \(detailItem.body)
        </body>
        </html>
        """
        
        
        webView.loadHTMLString(html, baseURL: nil)

    }
}
