//
//  Router.swift
//  FBSnapshotTestCase
//
//  Created by lichen on 2017/6/6.
//

import Foundation

public enum RouterError: Swift.Error {
    case unknown
    case noHandler(requestType: String)
}

extension RouterError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .unknown:
            return "Unknown error occured."
        case .noHandler(let type):
            return "Request: `\(type)` not match handler."
        }
    }
}

public protocol RouterRequest {
    var key: String { get set }
    var params: [String: Any]? { get set }
}

public protocol RouterHandler {
    func handle(request: RouterRequest, callback: @escaping (Error?) -> Void)
}

public class Router {
    public var mapping: [String: RouterHandler] = [:]
    public var middlewares: [Middleware] = []

    public init() {
        
    }

    public func register(request: RouterRequest.Type, handler: RouterHandler) {
        self.mapping["\(request)"] = handler
    }

    // 注册全局的中间件
    public func use(middleware: Middleware) {
        middlewares.append(middleware)
    }

    // 包含默认全局中间件
    public func send(req: RouterRequest, extraMiddlewares middlewares: [Middleware]? = nil) {
        var allMiddlewares = self.middlewares
        if let middlewares = middlewares {
            allMiddlewares += middlewares
        }

        self.send(req: req, middlewares: allMiddlewares)
    }

    // 不通过任何中间件执行命令
    public func sendWithoutMiddlewares(req: RouterRequest) {
        self.send(req: req, middlewares: [])
    }

    // 只执行传进来的中间件
    public func send(req: RouterRequest, middlewares: [Middleware]?) {
        var allMiddlewares: [Middleware] = []
        if let middlewares = middlewares {
            allMiddlewares += middlewares
        }

        self.do(req: req, middlewares: allMiddlewares, error: nil) { (req, err) in
            if let err = err {
                print("Request: \(req) \nError: \(String(describing: err))\n")
            }
        }
    }

    // 递归执行中间件
    func `do`(req: RouterRequest, middlewares: [Middleware], error: Error?, callback: @escaping (RouterRequest, Error?) -> Void) {

        guard let middleware = middlewares.first else {
            if error == nil {
                self.execute(req: req, callback: { (req, err) in
                    callback(req, err)
                })
            }
            return
        }
        var otherMiddlewares = middlewares
        otherMiddlewares.removeFirst()

        let next = { [weak self] (req: RouterRequest, error: Error?) in
            self?.do(req: req, middlewares: otherMiddlewares, error: error, callback: { (req, err) in
                if let handleAfter = middleware.handleAfter {
                    handleAfter(req, err, { (req, err) in
                        callback(req, err)
                    })
                } else {
                    callback(req, err)
                }
            })
        }

        // 这里是递归执行中间件
        if let handleBefore = middleware.handleBefore {
            handleBefore(req, error) { (req, error) in
                next(req, error)
            }
        } else {
            next(req, error)
        }
    }

    func execute(req: RouterRequest, callback: @escaping (RouterRequest, Error?) -> Void) {
        if let handler = self.mapping["\(type(of: req))"] {
            handler.handle(request: req, callback: { (error) in
                callback(req, error)
            })
        } else {
            callback(req, RouterError.noHandler(requestType: "\(type(of: req))"))
        }
    }
}
