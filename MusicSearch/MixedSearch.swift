// Copyright © 2022 Streem, Inc. All rights reserved.

import Foundation
import Combine

class MixedSearch: ObservableObject {
    @Published var foundAlbum: Album?
    
    var observers = Set<AnyCancellable>()
    
    // async version of artist API
    func collections(for artist: String) async throws -> [Collection] {
        let url = CollectionSearch.searchUrl(for: artist)
        let (data, _) = try await URLSession.shared.data(from: url)
        return (try JSONDecoder().decode(CollectionSearch.self, from: data)).results
    }
    
    // combine version of album API
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
    
    // async adapter for combine album API
    func lookup(albumId: Int) async throws -> Album? {
        try await withCheckedThrowingContinuation { continuation in
            lookup(albumId: albumId) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func find(artist: String) {
        foundAlbum = nil

        Task { @MainActor in
            do {
                let collections = try await collections(for: artist)
                guard let collectionId = collections.randomElement()?.collectionId else {
                    foundAlbum = nil
                    return
                }
                
                self.foundAlbum = try await lookup(albumId: collectionId)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}
