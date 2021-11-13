//
//  CompletionSearch.swift
//  MusicSearch
//
//  Created by Jeffrey Porter on 11/13/21.
//

import Foundation

class CompletionSearch {
    var searchTerm = "knopfler"
    var foundAlbum: Album?
    
    func searchCompletion(for artist: String, completion: @escaping (Result<[Collection], MusicError>) -> Void) {
        let url = CollectionSearch.searchUrl(for: artist)
        let searchRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: searchRequest) { data, response, error in
            guard error == nil else {
                completion(.failure(MusicError.searchFailed(error!)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noSearchData))
                return
            }
            
            do {
                let collections = try JSONDecoder().decode(CollectionSearch.self, from: data)
                completion(.success(collections.results))
            } catch {
                completion(.failure(.decodingSearch))
            }
        }
        .resume()
    }

    func albumCompletion(albumId: Int, completion: @escaping (Result<Album, MusicError>) -> Void) {
        let url = AlbumLookup.lookupUrl(for: albumId)
        let searchRequest = URLRequest(url: url)
        URLSession.shared.dataTask(with: searchRequest) { data, response, error in
            guard error == nil else {
                completion(.failure(MusicError.lookupFailed(error!)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noLookupData))
                return
            }
            
            do {
                let albums = try JSONDecoder().decode(AlbumLookup.self, from: data)
                guard let album = albums.results.first else {
                    completion(.failure(.noAlbumFound))
                    return
                }
                
                completion(.success(album))
            } catch {
                completion(.failure(.decodingLookup))
            }
        }
        .resume()
    }

    func runCompletionSearch() {
        do {
            searchCompletion(for: searchTerm) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let collections):
                    print("Found \(collections.count) albums")
                    let collectionId = collections.randomElement()?.collectionId ?? 0
                    self.albumCompletion(albumId: collectionId) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let album):
                                print(album.collectionName)
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

}
