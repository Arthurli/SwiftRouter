//
//  RouterRequest.swift
//  FBSnapshotTestCase
//
//  Created by lichen on 2017/6/6.
//

import Foundation
import UIKit

public enum PageHandleError: Swift.Error, CustomDebugStringConvertible {
    case unknown
    case unregister(key: String)
    case noFoundVc
    case invalidRequest
}

extension PageHandleError {
    public var debugDescription: String {
        switch self {
        case .unknown:
            return "Unknown error occured."
        case .unregister(let key):
            return "Key: `\(key)` is not register."
        case .noFoundVc:
            return "找不到 viewController"
        case .invalidRequest:
            return "无效的 request"
        }
    }
}

public struct RouterPageRequest: RouterRequest {
    public enum ActionType {
        case push(animation: Bool)
        case present(animation: Bool, warp: Bool)
        case touch(callback: (UIViewController) -> Void)
    }

    public var key: String
    public var type: ActionType = .push(animation: true)
    public var params: [String: Any]?

    public init(key: String, params: [String: Any]? = nil, type: ActionType = .push(animation: true)) {
        self.key = key
        self.type = type
        self.params = params
    }
}

public protocol RouterPageProtocol: class {
    init()
    func pageConfig(param: [String: Any]?, callback: (Error?) -> Void)
    func viewController() -> UIViewController
}

public typealias RoutePageHandleBlock = (_ req: RouterPageRequest, _ callback: @escaping (Error?) -> Void) -> Void

public class RouterPageHandler: RouterHandler {
    var mapping: [String: (RoutePageHandleBlock?, RouterPageProtocol.Type?)] = [:]

    public init() {
        
    }

    public func register(key: String, page: RouterPageProtocol.Type) {
         self.mapping[key] = (nil, page)
    }

    public func register(key: String, handleBlock: @escaping RoutePageHandleBlock) {
        self.mapping[key] = (handleBlock, nil)
    }

    public func handle(request: RouterRequest, callback: @escaping (Error?) -> Void) {
        guard let root = UIApplication.shared.delegate?.window??.rootViewController,
            let vc = UIViewController.getVisibleViewController(vc: root) else {
                callback(PageHandleError.noFoundVc)
                return
        }

        guard let request = request as? RouterPageRequest else {
            callback(PageHandleError.invalidRequest)
            return
        }

        self.handle(request: request, origin: vc, callback: { (err) in
            callback(err)
        })
    }

    func handle(request: RouterPageRequest, origin: UIViewController, callback: @escaping (Error?) -> Void) {
        guard let handleObject = self.mapping[request.key] else {
            callback(PageHandleError.unregister(key: request.key))
            return
        }

        if let handleBlock = handleObject.0 {
            handleBlock(request, { (err) in
                callback(err)
            })
            return
        }

        guard let PageType = handleObject.1 else {
            callback(PageHandleError.unregister(key: request.key))
            return
        }

        let page = PageType.init()
        page.pageConfig(param: request.params) { (error) in
            if let error = error {
                callback(error)
                return
            }

            switch request.type {
            case let .push(animated):
                origin.navigationController?.pushViewController(page.viewController(), animated: animated)
                callback(nil)
            case let .present(animated, warp):
                var presented = page.viewController()
                if warp {
                    presented = UINavigationController(rootViewController: presented)
                }
                origin.present(presented, animated: animated, completion: {
                    callback(nil)
                })
            case let .touch(touchCb):
                touchCb(page.viewController())
                callback(nil)
            }
        }
    }
}

public extension UIViewController {
    class func getVisibleViewController(vc: UIViewController?, usePresentedVC: Bool = false) -> UIViewController? {
        guard let vc = vc else {
            return nil
        }
        if let nav = vc as? UINavigationController {
            return UIViewController.getVisibleViewController(vc: nav.visibleViewController)
        } else if let tabVc = vc as? UITabBarController {
            return UIViewController.getVisibleViewController(vc: tabVc.selectedViewController)
        } else {
            if usePresentedVC, let prensentedVc = vc.presentedViewController {
                return UIViewController.getVisibleViewController(vc: prensentedVc, usePresentedVC: usePresentedVC)
            } else {
                return vc
            }
        }
    }
}

