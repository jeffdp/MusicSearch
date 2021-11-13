//
//  ContentView.swift
//  MusicSearch
//
//  Created by Jeffrey Porter on 11/13/21.
//

import SwiftUI

struct ContentView: View {
    let completionSeach = CompletionSearch()
    
    var body: some View {
        VStack {
            HStack {
                Button("Completion") {
                    completionSeach.runCompletionSearch()
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
