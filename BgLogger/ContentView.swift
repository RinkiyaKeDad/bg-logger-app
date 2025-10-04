//
//  ContentView.swift
//  BgLogger
//
//  Created by Arsh Sharma on 30/09/25.
//

import SwiftUI

struct ContentView: View {
    @State private var username: String = ""
    @State private var navigateToMenu = false
    
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
            .navigationDestination(isPresented: $navigateToMenu) {
                MenuView()
            }
    }
    
    private func sendNameToAPI(name: String) async {
        guard let url = URL(string: "http://localhost:3000/api/players") else {
            print("Invalid URL")
            return
        }
        
        let body: [String: Any] = ["name": name, "is_owner": true]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            print("Error encoding JSON")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (data, reponse) = try await URLSession.shared.data(for: request)
            if let httpResponse = reponse as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }
            if let responseBody = String(data: data, encoding: .utf8) {
                print("Response: \(responseBody)")
            }
        } catch {
            print("Request failed: \(error)")
        }
        
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
        Task {
            await sendNameToAPI(name: username)
            navigateToMenu = true
        }
    }
}

#Preview {
    NavigationStack{
        ContentView()
    }
}
