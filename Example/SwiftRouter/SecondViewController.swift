//
//  SecondViewController.swift
//  SwiftRouter
//
//  Created by lichen on 2017/6/7.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import Foundation
import UIKit
import SwiftRouter

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.red
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func pageConfig(param: [String: Any]?, callback: (Error?) -> Void) {
        print("second vc config")
        callback(nil)
    }
}

extension UIViewController: RouterPageProtocol {
    public func viewController() -> UIViewController {
        return self
    }

    public func pageConfig(param: [String: Any]?, callback: (Error?) -> Void) {
        callback(nil)
    }
}
