//
//  HtmlDownloadManager.swift
//  VueAndCacheDemo
//
//  Created by Public on 2018/9/14.
//  Copyright © 2018年 Public. All rights reserved.
//

import UIKit
import Alamofire
import SSZipArchive

class HtmlDownloadManager: NSObject {
    //用单例来控制保证页面销毁的时候下载仍然可以继续
    static let `default` = HtmlDownloadManager()
    
    override init() {
        super.init()
    }
    
    //下载资源包到本地
    //之前用一个download的类去单独进行下载，发现是个重大的bug，因为如果不是单例的话，对象会直接被销毁掉，导致后续的所有方法都已经无法继续被调用了，所以还是把下载、解压、删除等方法搬到了这个下载管理的单例之中
    //整个下载的设置待设计
    func download(downloadUrl:String,name:String,version:String){
        let destination: DownloadRequest.DownloadFileDestination = { _, response in
            let filePath = HtmlModuleConfig.default.zipPath.appendingFormat("/%@", response.suggestedFilename!)
            return (URL.init(fileURLWithPath: filePath), [.removePreviousFile,.createIntermediateDirectories])
        }
        Alamofire.download(downloadUrl, to: destination).downloadProgress(closure: { (progress) in
            //let percent = Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
            //print(percent)
        }).response {[weak self] (response) in
            // 默认为 `.get` 方法
            if response.response?.statusCode == 200 {
                //下载成功，开始解压
                self?.ziparchiveToDocument(zipPath: (response.destinationURL?.path)!, name: name, version: version)
            }else{
                //下载失败
                self?.deleteResource(name: name)
            }
            //            print(response.destinationURL)
        }
    }
    
    //解压资源到指定位置
    func ziparchiveToDocument(zipPath:String,name:String,version:String){
        //实际的zip包解压应该需要密码，使用时候加上密码即可
        let isSuccess = SSZipArchive.unzipFile(atPath: zipPath, toDestination: HtmlModuleConfig.default.resourcePath, overwrite: true, password: nil, progressHandler: nil, completionHandler: nil)
        
        if isSuccess {
            //解压成功设置成功标志和最新版本号
            HtmlModuleConfig.default.setSuccess(key: name, value: "true")
            HtmlModuleConfig.default.setVersion(key: name, value: version)
        }else{
            //解压失败,删除可能残存的资源包
            self.deleteResource(name: name)
        }
    }
    
    //删除资源包
    func deleteResource(name:String){
        let resourceDestination = HtmlModuleConfig.default.resourcePath+"/"+name
        if FileManager.default.fileExists(atPath: resourceDestination) {
            try!FileManager.default.removeItem(atPath: resourceDestination)
        }
        
        let zipDestination = HtmlModuleConfig.default.zipPath+"/"+name+".zip"
        if FileManager.default.fileExists(atPath: zipDestination) {
            try!FileManager.default.removeItem(atPath: zipDestination)
        }
    }
    
}
