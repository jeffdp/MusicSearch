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

    func lookup(artist: String, completion: @escaping (Album?) -> Void) {
        Future<[Collection], Error> { promise in
            self.collections(for: artist, completion: promise)
        }
        .flatMap { collections in
            Future<Album?, Error> { promise in
                if let collectionId = collections.randomElement()?.collectionId {
                    self.lookup(albumId: collectionId, completion: promise)
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { result in
            if case let .failure(error) = result {
                print(error.localizedDescription)
                completion(nil)
            }
        }, receiveValue: { album in
            completion(album)
        })
        .store(in: &observers)
    }
    
    func find(artist: String) {
        foundAlbum = nil
        
        lookup(artist: artist) { album in
            self.foundAlbum = album
        }
    }
}
