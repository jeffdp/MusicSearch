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
    var cancellable: Cancellable?
    
    func collections(for artist: String, completion: @escaping (Result<[Collection], MusicError>) -> Void) {
        let url = CollectionSearch.searchUrl(for: artist)
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .tryMap() { $0.data }
            .decode(type: CollectionSearch.self, decoder: JSONDecoder())
            .map { $0.results }
            .sink(receiveCompletion: { _ in
                completion(.failure(MusicError.noSearchData))
            }, receiveValue: { collections in
                completion(.success(collections))
            })
    }
    
    func lookup(albumId: Int, completion: @escaping (Result<Album, MusicError>) -> Void) {
        let url = AlbumLookup.lookupUrl(for: albumId)
        let searchRequest = URLRequest(url: url)
        cancellable = URLSession.shared.dataTaskPublisher(for: searchRequest)
            .tryMap() { $0.data }
            .decode(type: AlbumLookup.self, decoder: JSONDecoder())
            .map { $0.results }
            .sink(receiveCompletion: { _ in
                completion(.failure(MusicError.noLookupData))
            }, receiveValue: { albums in
                guard let album = albums.first else {
                    completion(.failure(.noLookupData))
                    return
                }
                completion(.success(album))
            })
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
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let album):
                            self.foundAlbum = album
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
