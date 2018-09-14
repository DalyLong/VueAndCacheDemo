//
//  HtmlModuleConfig.swift
//  VueAndCacheDemo
//
//  Created by Public on 2018/9/14.
//  Copyright © 2018年 Public. All rights reserved.
//

import UIKit

class HtmlModuleConfig: NSObject {
    
    ///单例
    static let `default` = HtmlModuleConfig()
    
    ///zip和解压文件的总路径
    private(set) var basePath : String=""
    ///zip存放的总路径
    private(set) var zipPath : String=""
    ///解压后的文件存放的总路径
    private(set) var resourcePath : String=""
    ///设置module是否缓存成功plist路径
    private var successPath : String=""
    ///设置module版本号plist路径
    private var versionPath : String=""
    
    private override init() {
        super.init()
        basePath = NSHomeDirectory() + "/Documents/HtmlDownloads"
        zipPath = basePath+"/Zip"
        resourcePath = basePath+"/Resource"
        successPath = basePath+"/success.plist"
        versionPath = basePath+"/version.plist"
        
        if (!FileManager.default.fileExists(atPath: basePath)) {
            //创建文件夹
            try!FileManager.default.createDirectory(atPath: basePath, withIntermediateDirectories: true, attributes: nil)
        }
        
        if (!FileManager.default.fileExists(atPath: zipPath)) {
            //创建文件夹
            try!FileManager.default.createDirectory(atPath: zipPath, withIntermediateDirectories: true, attributes: nil)
        }
        
        if (!FileManager.default.fileExists(atPath: resourcePath)) {
            //创建文件夹
            try!FileManager.default.createDirectory(atPath: resourcePath, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func setSuccess(key:String,value:String) {
        var dic = NSMutableDictionary.init(contentsOfFile: self.successPath)
        if dic == nil {
            dic = NSMutableDictionary()
        }
        dic?.setValue(value, forKey: key)
        dic?.write(toFile: self.successPath, atomically: true)
    }
    
    func setVersion(key:String,value:String) {
        var dic = NSMutableDictionary.init(contentsOfFile: self.versionPath)
        if dic == nil {
            dic = NSMutableDictionary()
        }
        dic?.setValue(value, forKey: key)
        dic?.write(toFile: self.versionPath, atomically: true)
    }
    
    func successObjectForKey(key:String) -> String {
        let dic = NSMutableDictionary.init(contentsOfFile: self.successPath)
        if  dic != nil {
            let value = dic?.object(forKey: key)
            if value != nil {
                return value as! String
            }else{
                return ""
            }
        }else{
            return ""
        }
    }
    
    func versionObjectForKey(key:String) -> String{
        let dic = NSMutableDictionary.init(contentsOfFile: self.versionPath)
        if dic != nil {
            let value = dic?.object(forKey: key)
            if value != nil {
                return value as! String
            }else{
                return ""
            }
        }else{
            return ""
        }
    }
}
