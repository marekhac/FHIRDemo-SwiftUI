//
//  FHIRNetworkService.swift
//  FHIRDemo
//
//  Created by Marek Hac on 23/04/2026.
//

import Foundation

final class FHIRNetworkService {

    let baseURL = URL(string: "https://r4.smarthealthit.org")!
    let session: URLSession
    let decoder: JSONDecoder
    let encoder: JSONEncoder

    init(session: URLSession = .shared,
         decoder: JSONDecoder = JSONDecoder(),
         encoder: JSONEncoder = JSONEncoder()) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }
}
