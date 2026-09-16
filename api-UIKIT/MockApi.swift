//
//  MockApi.swift
//  api-UIKIT
//
//  Created by Vokal-Ican on 16/09/26.
//

struct MockApi: Codable {
    let id: String
    let name: String
    let address: String
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case imageUrl
    }
}
