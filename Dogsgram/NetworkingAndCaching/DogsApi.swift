//
//  DogsApi.swift
//  Dogsgram
//
//  Created by Pawel Masiewicz on 2/21/22.
//

import Foundation

struct DogDataModel {
    let imageURL: String
    let likesCount: Int
    let isLiked: Bool
}

struct DogsResponse: Decodable {
    let message: [String]
    let status: String
    
    private func getDogDataModels() -> [DogDataModel] {
        return message.map { DogDataModel(imageURL: $0, likesCount: Int.random(in: 1...100), isLiked: false) }
    }
    
    func getDogsCellViewModels() -> [[FeedCellType]] {
        let data = getDogDataModels()
        
        return data.compactMap {
            if let url = URL(string: $0.imageURL) {
                return [.image(viewModel: ImageCollectionViewCellViewModel(imageURL: url)),
                        .likes(viewModel: LikesCollectionViewCellViewModel(likesCount: $0.likesCount,
                                                                           isLiked: $0.isLiked,
                                                                           imageUrlString: url.absoluteString))]
            } else { return nil }
        }
    }
}

enum DogsError: Error {
    case noDataAvailable
    case canNotProcessData
}

class DogsAPI {
    static var shared = DogsAPI()
    
    public var isFetchingData = false
    
    /*
    func getDogs(breed: DogsBreed, pageSize: Int, completion: @escaping(Result<[[FeedCellType]], DogsError>) -> Void) {
        
        self.isFetchingData = true
        
        let dataTask = URLSession.shared.dataTask(with: Endpoint.randomDogs(breed: breed, pageSize: pageSize).url) {[weak self] data, _, error in
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                self?.isFetchingData = false
                return
            }
            do {
                let dogs = try JSONDecoder().decode(DogsResponse.self, from: jsonData)
                completion(.success(dogs.getDogsCellViewModels()))
                self?.isFetchingData = false
            } catch {
                completion(.failure(.canNotProcessData))
                self?.isFetchingData = false
            }
        }
        dataTask.resume()
    }
     */
    
    func getDogs(breed: DogsBreed, pageSize: Int) async -> Result<[[FeedCellType]], DogsError> {
        self.isFetchingData = true
        
        let url = Endpoint.randomDogs(breed: breed, pageSize: pageSize).url
        
        defer {
            self.isFetchingData = false
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let dogsResponse = try JSONDecoder().decode(DogsResponse.self, from: data)
            return .success(dogsResponse.getDogsCellViewModels())
        }
        catch {
            return .failure(.canNotProcessData)
        }
    }
}
