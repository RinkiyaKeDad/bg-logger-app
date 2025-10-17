//
//  AddGameView.swift
//  BgLogger
//
//  Created by Arsh Sharma on 03/10/25.
//


import SwiftUI

struct AddGameView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var newGameName: String = ""
    @State private var newGameCreatorName: String = ""
    @State private var showSuccess: Bool = false
    @State private var isSubmitting = false
    
    
    var body: some View {
            Form {
                Section(header: Text("Game Details")) {
                    TextField("Game name", text: $newGameName)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                    
                    TextField("Creator name", text: $newGameCreatorName)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                }
                
                // 👇 Buttons inline inside the form
                Section {
                    HStack(spacing: 16) {
                        Button(role: .cancel) {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.gray)
                        
                        Button {
                            Task {
                                isSubmitting = true
                                await addGame(name: newGameName, creator_name: newGameCreatorName)
                                isSubmitting = false
                                newGameName = ""
                                newGameCreatorName = ""
                            }
                        } label: {
                            if isSubmitting {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Add Game")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newGameName.trimmingCharacters(in: .whitespaces).isEmpty ||
                                  newGameCreatorName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .navigationTitle("Add Game")
            .alert("Game Added!", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            }
        }
    
    private func addGame(name: String, creator_name: String) async {
        guard let url = URL(string: "http://localhost:3000/api/games") else { return }
        
        let newGame: [String: Any] = ["name": name, "creator_name": creator_name]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: newGame, options: []) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("POST status: \(httpResponse.statusCode)")
            }
            showSuccess = true
        } catch {
            print("Failed to add game: \(error)")
        }
    }
}

