//
//  ViewController.swift
//  SwiftRouter
//
//  Created by lichen on 06/06/2017.
//  Copyright (c) 2017 lichen. All rights reserved.
//

import UIKit
import SwiftRouter

enum PageType {
    case first(key: String)
    case second

    func inditify() -> String {
        switch self {
        case .first(key: _):
            return "first"
        case .second:
            return "second"
        }
    }

    func build(type: RouterPageRequest.ActionType = .push(animation: true)) -> RouterPageRequest {
        var params: [String: Any] = [:]

        switch self {
        case let .first(key: key):
            params["key"] = key
        case .second:
            break
        }

        let requst = RouterPageRequest(key: self.inditify(), params: params, type: type)
        return requst
    }

}

class ViewController: UIViewController, UIViewControllerPreviewingDelegate {

    var handler: RouterPageHandler = {
        var handle: RouterPageHandler = RouterPageHandler()
        return handle
    }()

    var router: Router = Router()
    var btn: UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // 注册 router 的 handler
        router.register(request: RouterPageRequest.self, handler: handler)

        // 注册 页面跳转
        handler.register(key: PageType.second.inditify(), page: SecondViewController.self)
        // 注册中间件
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
        self.router.send(req: PageType.second.build())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        if #available(iOS 9.0, *) {
            if previewingContext.sourceView == self.btn {
                var viewController: UIViewController? = nil
                let r = PageType.second.build(type: .touch(callback: { (vc) in
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

