//
//  AsyncSearch.swift
//  MusicSearch
//
//  Created by Jeffrey Porter on 11/13/21.
//

import Foundation

class AsyncSearch: ObservableObject {
    @Published var foundAlbum: Album?

    func collections(for artist: String) async throws -> [Collection] {
        let url = CollectionSearch.searchUrl(for: artist)
        let (data, _) = try await URLSession.shared.data(from: url)
        return (try JSONDecoder().decode(CollectionSearch.self, from: data)).results
    }
    
    func lookup(albumId: Int) async throws -> Album? {
        let url = AlbumLookup.lookupUrl(for: albumId)
        let (data, _) = try await URLSession.shared.data(from: url)

        return (try JSONDecoder().decode(AlbumLookup.self, from: data)).results.first
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
