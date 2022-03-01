//
//  Endpoint.swift
//  Dogsgram
//
//  Created by Pawel Masiewicz on 2/21/22.
//

import Foundation

enum DogsBreed: CaseIterable {
    case hound
    case husky
    case pug
    case shibaInu
    case terrier
    
    func getApiName() -> String {
        switch self {
        case .hound:
            return "hound"
        case .husky:
            return "husky"
        case .pug:
            return "pug"
        case .shibaInu:
            return "shiba"
        case .terrier:
            return "terrier"
        }
    }
    
    func getTitle() -> String {
        switch self {
        case .hound:
            return "Hounds"
        case .husky:
            return "Husky"
        case .pug:
            return "Pugs"
        case .shibaInu:
            return "Shiba Inu"
        case .terrier:
            return "Terriers"
        }
    }
}

struct Endpoint {
    var path: String
    var queryItems: [URLQueryItem] = []
}

//https://dog.ceo/api/breed/pug/images/random/20
extension Endpoint {
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "dog.ceo"
        components.path = "/api/" + path
        components.queryItems = queryItems
        
        guard let url = components.url else {
            preconditionFailure("Invalid URL components: \(components)")
        }
        
        return url
    }
    
    static func randomDogs(breed: DogsBreed, pageSize: Int) -> Self {
        Endpoint(path: "breed/\(breed.getApiName())/images/random/\(pageSize)")
    }
}
