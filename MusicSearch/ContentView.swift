//
//  ContentView.swift
//  MusicSearch
//
//  Created by Jeffrey Porter on 11/13/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var completionSeach = CompletionSearch()
    @ObservedObject var combineSearch = CombineSearch()
    @ObservedObject var asyncSearch = AsyncSearch()
    @State var searchTerm = "Mark Knopfler"
    
    var body: some View {
        VStack {
            Form {
                Section("Search Terms") {
                    TextField("Artist", text: $searchTerm)
                }
                
                Section("completion") {
                    AlbumView(album: completionSeach.foundAlbum)
                }
                
                Section("Combine") {
                    AlbumView(album: combineSearch.foundAlbum)
                }
                
                Section("Async") {
                    AlbumView(album: asyncSearch.foundAlbum)
                }
            }
            .padding()
            
            Spacer()
            
            HStack {
                Button("Search") {
                    completionSeach.find(artist: searchTerm)
                    combineSearch.find(artist: searchTerm)
                    asyncSearch.find(artist: searchTerm)
                }
            }
        }
        .task {
            asyncSearch.find(artist: searchTerm)
        }
        .onAppear {
            completionSeach.find(artist: searchTerm)
            combineSearch.find(artist: searchTerm)
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
