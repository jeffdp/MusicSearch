//
//  Data.swift
//  MusicSearch
//
//  Created by Jeffrey Porter on 11/13/21.
//

import Foundation

public enum MusicError: Error {
    case searchFailed(Error)
    case lookupFailed(Error)
    case noSearchData
    case noLookupData
    case decodingSearch
    case decodingLookup
    case noAlbumFound
}

public struct CollectionSearch: Codable {
    public let results: [Collection]
    
    public static func searchUrl(for artist: String) -> URL {
        URL(string: "https://itunes.apple.com/search?term=\(artist)&entity=album")!
    }
}

public struct Collection: Codable, Hashable, Identifiable {
    public var id: Int {
        collectionId
    }

    public let collectionId: Int
    public let collectionName: String
    public let collectionPrice: Double
    public let artistName: String
}

public struct AlbumLookup: Codable {
    public let results: [Album]
    
    public static func lookupUrl(for albumId: Int) -> URL {
        URL(string: "https://itunes.apple.com/lookup?id=\(albumId)")!
    }
}

public struct Album: Codable, Hashable, Identifiable {
    public var id: Int {
        collectionId
    }

    public let collectionId: Int
    public let artistId: Int
    public let artistName: String
    public let collectionName: String
    public let artworkUrl100: String
}
