//
//  CombineSearch.swift
//  MusicSearch
//
//  Created by Jeffrey Porter on 11/13/21.
//

import UIKit
import Combine

class CombineSearch: ObservableObject {
    @Published var foundAlbum: Album?
    var observers = Set<AnyCancellable>()
    
    func collections(for artist: String, completion: @escaping (Result<[Collection], Error>) -> Void) {
        let url = CollectionSearch.searchUrl(for: artist)
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap() { $0.data }
            .decode(type: CollectionSearch.self, decoder: JSONDecoder())
            .map { $0.results }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    completion(.failure(error))
                }
            }, receiveValue: { collections in
                completion(.success(collections))
            })
            .store(in: &observers)
    }
    
    func lookup(albumId: Int, completion: @escaping (Result<Album?, Error>) -> Void) {
        let url = AlbumLookup.lookupUrl(for: albumId)
        let searchRequest = URLRequest(url: url)
        URLSession.shared.dataTaskPublisher(for: searchRequest)
            .tryMap() { $0.data }
            .decode(type: AlbumLookup.self, decoder: JSONDecoder())
            .map { $0.results }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    completion(.failure(error))
                }
            }, receiveValue: { albums in
                completion(.success(albums.first))
            })
            .store(in: &observers)
    }
    
    func find(artist: String) {
        foundAlbum = nil
        
        collections(for: artist) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let collections):
                guard let collectionId = collections.randomElement()?.collectionId else {
                    self.foundAlbum = nil
                    return
                }
                self.lookup(albumId: collectionId) { result in
                    switch result {
                    case .success(let album):
                        self.foundAlbum = album
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
