//
//  HtmlViewController.swift
//  VueAndCacheDemo
//
//  Created by Public on 2018/9/14.
//  Copyright © 2018年 Public. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SSZipArchive

class HtmlViewController: UIViewController {
    
    var module : Module?
    
    var webView : WKWebView?
    var progressView : UIProgressView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        self.loadUrl()
    }
    
    private func initUI(){
        self.navigationItem.title = "加载网页"
        self.view.backgroundColor = UIColor.white
        
        self.webView = WKWebView.init(frame: CGRect.init(x: 0, y: UIApplication.shared.statusBarFrame.height+44, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-UIApplication.shared.statusBarFrame.height-44))
        //禁止3DTouch
        self.webView?.allowsLinkPreview = false
        self.webView?.navigationDelegate = self
        //添加监听
        self.webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        //这行代码可以是侧滑返回webView的上一级，而不是根控制器（*只针对侧滑有效）
        self.webView?.allowsBackForwardNavigationGestures = true
        self.view.addSubview(self.webView!)
        
        self.progressView = UIProgressView.init(progressViewStyle: .default)
        self.progressView?.frame = CGRect.init(x: 0, y: UIApplication.shared.statusBarFrame.height+44, width: UIScreen.main.bounds.width, height: 5)
        self.progressView?.trackTintColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        self.progressView?.progressTintColor = UIColor.green
        self.progressView?.isHidden = true
        self.view.addSubview(self.progressView!)
    }
    
    private func loadUrl(){
        //判断是否是最新版本
        if self.isNewVersion() {
            //有新版本直接调用服务器链接
            self.webView?.load(URLRequest.init(url: URL.init(string: (self.module?.url)!)!))
        }else{
            //判断本地是否有缓存
            if self.isCacheInDocument() {
                //调用本地html文件
                let urlStr1 = HtmlModuleConfig.default.resourcePath+"/"+(self.module?.name)!+"/index.html"
                let urlStr2 = HtmlModuleConfig.default.resourcePath+"/"+(self.module?.name)!
                let urlPath = self.componentFileUrl(filePath: urlStr1, dictionary: ["token":"xcwrk424253mnknk24njnk"])
                if urlPath != nil {
                    self.webView?.loadFileURL(URL.init(fileURLWithPath: urlPath!), allowingReadAccessTo: URL.init(fileURLWithPath: urlStr2))
                }
            }else{
                //无缓存直接调用服务器链接
                let url = (self.module?.url)!+"?token='xcwrk424253mnknk24njnk'"
                self.webView?.load(URLRequest.init(url: URL.init(string: url)!))
            }
        }
    }
    
    //新老版本号的判断
    private func isNewVersion() ->Bool {
        let lastVersion = HtmlModuleConfig.default.versionObjectForKey(key: (self.module?.name)!)
        if (self.module?.version == lastVersion){
            return true
        }else{
            return false
        }
    }
    
    //判断本地是否有缓存
    private func isCacheInDocument() -> Bool{
        let success = HtmlModuleConfig.default.successObjectForKey(key: (self.module?.name)!)
        if success == "true" {
            return true
        }else{
            return false
        }
    }
    
    /**
     本地网页数据拼接
     @param filePath 网页路径
     @param dictionary 拼接的参数
     @return 拼接后网页路径字符串
     */
    private func componentFileUrl(filePath:String,dictionary:[String:String]) -> String?{
        let url = URL.init(fileURLWithPath: filePath, isDirectory: false)
        var urlComponents = URLComponents.init(url: url, resolvingAgainstBaseURL: false)
        var mutArray:Array = [URLQueryItem]()
        for key in dictionary.keys {
            let item = URLQueryItem.init(name: key, value: dictionary[key])
            mutArray.append(item)
        }
        urlComponents?.queryItems = mutArray
        // urlComponents.URL  返回拼接后的URL
        // urlComponents.string 返回拼接后的String
        return urlComponents?.string
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressView?.alpha = 1
            self.progressView?.setProgress(Float((self.webView?.estimatedProgress)!), animated: true)
            if (self.webView?.estimatedProgress)! >= Double(1) {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView?.alpha = 0
                }, completion: { (finished) in
                    self.progressView?.setProgress(0, animated: false)
                })
            }
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    deinit {
        self.webView?.removeObserver(self, forKeyPath: "estimatedProgress", context: nil)
    }
}

extension HtmlViewController : WKNavigationDelegate{
    ///页面开始加载
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.progressView?.isHidden = false
    }
    ///开始获取到网页内容时返回
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    ///页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.progressView?.isHidden = true
        //判断本地是否有缓存
        if self.isCacheInDocument() {
            //有缓存判断缓存的是否为最新版本,如果不为最新版本则下载最新版本
            if !self.isNewVersion() {
                HtmlDownloadManager.default.download(downloadUrl: (self.module?.downloadUrl)!, name: (self.module?.name)!, version: (self.module?.version)!)
            }
        }else{
            //无缓存直接开启下载
            HtmlDownloadManager.default.download(downloadUrl: (self.module?.downloadUrl)!, name: (self.module?.name)!, version: (self.module?.version)!)
        }
    }
    ///页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //判断本地是否有缓存，如果有缓存并且是失败的话，先设置缓存为false，再调用服务器版本
        if self.isCacheInDocument() {
            HtmlModuleConfig.default.setSuccess(key: (self.module?.name)!, value: "false")
            self.webView?.load(URLRequest.init(url: URL.init(string: (self.module?.url)!)!))
        }
    }
}
