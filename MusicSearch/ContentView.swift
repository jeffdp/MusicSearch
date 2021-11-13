//
//  ContentView.swift
//  MusicSearch
//
//  Created by Jeffrey Porter on 11/13/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var completionSeach = CompletionSearch()
    @ObservedObject var asyncSearch = AsyncSearch()
    @State var searchTerm = "Mark Knopfler"
    
    var body: some View {
        VStack {
            Form {
                Section("Search Terms") {
                    TextField("Artist", text: $searchTerm)
                }
                
                Section("Completion") {
                    if completionSeach.foundAlbum?.artworkUrl100 != nil {
                        HStack {
                            AsyncImage(url: URL(string: completionSeach.foundAlbum!.artworkUrl100)!)
                            Text(completionSeach.foundAlbum?.collectionName ?? "")
                        }
                    } else {
                        Text(completionSeach.foundAlbum?.collectionName ?? "")
                    }
                }
                
                Section("Async") {
                    if asyncSearch.foundAlbum?.artworkUrl100 != nil {
                        HStack {
                            AsyncImage(url: URL(string: asyncSearch.foundAlbum!.artworkUrl100)!)
                            Text(asyncSearch.foundAlbum?.collectionName ?? "")
                        }
                    } else {
                        Text(asyncSearch.foundAlbum?.collectionName ?? "")
                    }
                }
            }
            .padding()
            
            Spacer()
            
            HStack {
                Button("Search") {
                    completionSeach.find(artist: searchTerm)
                    asyncSearch.find(artist: searchTerm)
                }
            }
        }
        .task {
            asyncSearch.find(artist: searchTerm)
        }
        .onAppear {
            completionSeach.find(artist: searchTerm)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
