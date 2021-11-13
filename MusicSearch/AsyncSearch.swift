//
//  AsyncSearch.swift
//  MusicSearch
//
//  Created by Jeffrey Porter on 11/13/21.
//

import Foundation

class AsyncSearch: ObservableObject {
    @Published var foundAlbum: Album?

    func searchCompletion(for artist: String) async throws -> [Collection] {
        return []
    }
    
    func albumCompletion(albumId: Int) async throws -> Album? {
        return nil
    }
    
    func runCompletionSearch() {
        
    }
}
