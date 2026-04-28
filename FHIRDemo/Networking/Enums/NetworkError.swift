//
//  NetworkError.swift
//  FHIRDemo
//
//  Created by Marek Hac on 20/04/2026.
//

import Foundation

enum NetworkError: Error {
    case invalidStatusCode
    case invalidResponse(String)
}
