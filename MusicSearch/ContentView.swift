//
//  ContentView.swift
//  MusicSearch
//
//  Created by Jeffrey Porter on 11/13/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var combineSearch = CombineSearch()
    @ObservedObject var asyncSearch = AsyncSearch()
    @ObservedObject var mixedSearch = MixedSearch()
    @State var searchTerm = "Mark Knopfler"
    
    var body: some View {
        VStack {
            Form {
                Section("Search Terms") {
                    TextField("Artist", text: $searchTerm)
                }
                
                Section("Combine") {
                    AlbumView(album: combineSearch.foundAlbum)
                }
                
                Section("Async") {
                    AlbumView(album: asyncSearch.foundAlbum)
                }
                
                Section("Mixed") {
                    AlbumView(album: mixedSearch.foundAlbum)
                }
            }
            .padding()
            
            Spacer()
            
            HStack {
                Button("Search") {
                    combineSearch.find(artist: searchTerm)
                    asyncSearch.find(artist: searchTerm)
                    mixedSearch.find(artist: searchTerm)
                }
            }
        }
        .task {
            asyncSearch.find(artist: searchTerm)
            mixedSearch.find(artist: searchTerm)
        }
        .onAppear {
            combineSearch.find(artist: searchTerm)
        }
        .refreshable {
            combineSearch.find(artist: searchTerm)
            asyncSearch.find(artist: searchTerm)
            mixedSearch.find(artist: searchTerm)
        }
    }
}

struct AlbumView: View {
    var album: Album?
    
    var body: some View {
        if album?.artworkUrl100 != nil {
            HStack {
                AsyncImage(url: URL(string: album!.artworkUrl100)!)
                Text(album?.collectionName ?? "")
            }
        } else {
            Text(album?.collectionName ?? "")
        }
    }
}
