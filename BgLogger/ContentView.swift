//
//  ContentView.swift
//  BgLogger
//
//  Created by Arsh Sharma on 30/09/25.
//

import SwiftUI

struct ContentView: View {
    @State private var username: String = ""
    
    
    var body: some View {
        VStack {
            Text("Welcome to BGLogger").font(Font.largeTitle)
            TextField("Enter your name", text: $username)
                .disableAutocorrection(true)
                .onSubmit(handleSubmit)
                .padding()
            Button("Submit", action: handleSubmit)
        }
        .padding()
    }
    
    private func validate(name: String) -> Bool {
        // Basic validation: ensure the name is not empty or whitespace
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            // You could display an alert or error message here
            print("Name cannot be empty.")
            return false
        }
        return true
    }
    
    private func handleSubmit() {
        guard validate(name: username) else {
            print("Enter a valid name.")
            return
        }
        print("Submitted text: \(username)")
    }
}

#Preview {
    ContentView()
}
