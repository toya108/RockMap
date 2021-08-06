//
//  File.swift
//  
//
//  Created by TOUYA KAWANO on 2021/08/06.
//

import Foundation

protocol LocalRequest: RequestProtocol {}

extension LocalRequest {
    public var parameters: Parameters { fatalError() }
    public var testDataPath: URL? { nil }
}
