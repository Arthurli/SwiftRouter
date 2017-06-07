//
//  Middleware.swift
//  FBSnapshotTestCase
//
//  Created by lichen on 2017/6/6.
//

import Foundation

public typealias MiddlewareBlock = (_ req: RouterRequest, _ err: Error?, _ callback: (RouterRequest, Error?) -> Void) -> Void
public typealias Middleware = (handleBefore: MiddlewareBlock?, handleAfter: MiddlewareBlock?)
