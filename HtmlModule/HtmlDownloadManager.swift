//
//  HtmlDownloadManager.swift
//  VueAndCacheDemo
//
//  Created by Public on 2018/9/14.
//  Copyright © 2018年 Public. All rights reserved.
//

import UIKit


class HtmlDownloadManager: NSObject {
    //用单例来控制保证页面销毁的时候下载仍然可以继续
    static let `default` = HtmlDownloadManager()
    
    override init() {
        super.init()
    }
    
    func download(downloadUrl:String,name:String,version:String) {
        let htmlDownload = HtmlDownload()
        htmlDownload.download(downloadUrl: downloadUrl, name: name, version: version)
    }
    
}
