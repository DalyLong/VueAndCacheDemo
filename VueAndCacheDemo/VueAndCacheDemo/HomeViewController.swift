//
//  HomeViewController.swift
//  VueAndCacheDemo
//
//  Created by Public on 2018/9/14.
//  Copyright © 2018年 Public. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "首页"
        self.view.backgroundColor = UIColor.white
        
        let button = UIButton()
        button.frame = CGRect.init(x: 100, y: 200, width: 200, height: 100)
        button.setTitle("模块一", for: .normal)
        button.backgroundColor = UIColor.blue
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func click() {
        let module = Module()
        module.downloadUrl = "http://localhost/vue.zip"
        module.name = "vue"
        module.url = "http://localhost/vue/#/index"
        module.version = "1.0"
        let hVC = HtmlViewController()
        hVC.module = module
        self.navigationController?.pushViewController(hVC, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
