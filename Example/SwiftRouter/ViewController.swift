//
//  ViewController.swift
//  SwiftRouter
//
//  Created by lichen on 06/06/2017.
//  Copyright (c) 2017 lichen. All rights reserved.
//

import UIKit
import SwiftRouter

class ViewController: UIViewController, UIViewControllerPreviewingDelegate {

    var req: RouterPageRequest = {
        return RouterPageRequest(key: "123")
    }()

    var handler: RouterPageHandler = {
        var handle: RouterPageHandler = RouterPageHandler()
        handle.register(key: "123", page: SecondViewController.self)
        return handle
    }()

    var router: Router = Router()
    var btn: UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        router.register(request: type(of: req), handler: handler)

        let m1: Middleware = (handleBefore: { (req: RouterRequest, error: Error?, callback: (RouterRequest, Error?) -> Void) -> Void in
            print("before 1")
            callback(req, nil)
        }, handleAfter: { (req: RouterRequest, error: Error?, callback: (RouterRequest, Error?) -> Void) -> Void in
            print("after 1")
            callback(req, nil)
        })

        let m11: Middleware = (handleBefore: { (req: RouterRequest, error: Error?, callback: (RouterRequest, Error?) -> Void) -> Void in
            print("before 11")
            callback(req, nil)
        }, handleAfter: nil)

        let m2: Middleware = (handleBefore: { (req: RouterRequest, error: Error?, callback: (RouterRequest, Error?) -> Void) -> Void in
            print("before 2")
            callback(req, nil)
        }, handleAfter: { (req: RouterRequest, error: Error?, callback: (RouterRequest, Error?) -> Void) -> Void in
            print("after 2")
            callback(req, nil)
        })

        let m22: Middleware = (handleBefore: nil,
                               handleAfter: { (req: RouterRequest, error: Error?, callback: (RouterRequest, Error?) -> Void) -> Void in
            print("after 22")
            callback(req, nil)
        })


        router.use(middleware: m1)
        router.use(middleware: m11)
        router.use(middleware: m2)
        router.use(middleware: m22)


        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.go()
        }

        let btn = UIButton(type: .custom)
        btn.backgroundColor = UIColor.red
        btn.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        btn.addTarget(self, action: #selector(go), for: .touchUpInside)
        self.view.addSubview(btn)
        self.btn = btn

        if #available(iOS 9.0, *) {
            self.registerForPreviewing(with: self, sourceView: btn)
        }
    }

    @objc
    func go() {
        self.router.send(req: self.req)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        if #available(iOS 9.0, *) {
            if previewingContext.sourceView == self.btn {
                var viewController: UIViewController? = nil
                let r = RouterPageRequest(key: "123", type: .touch(callback: { (vc) in
                    viewController = vc
                }))
                self.router.send(req: r)

                return viewController
            }
        }

        return nil
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

