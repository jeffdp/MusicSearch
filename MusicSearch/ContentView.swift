//
//  ContentView.swift
//  MusicSearch
//
//  Created by Jeffrey Porter on 11/13/21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var completionSeach = CompletionSearch()
    @State var searchTerm = "Knopfler"
    
    var body: some View {
        VStack {
            Form {
                Section("Search") {
                    TextField("Artist", text: $searchTerm)
                }
                
                Section("Results") {
                    Text(completionSeach.foundAlbum?.collectionName ?? "")
                }
            }
            .padding()
            
            Spacer()
            
            HStack {
                Button("Completion") {
                    completionSeach.runCompletionSearch(for: searchTerm)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
