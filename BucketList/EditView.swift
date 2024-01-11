//
//  EditView.swift
//  BucketList
//
//  Created by Leo  on 08.01.24.
//

import SwiftUI

struct EditView: View {
    @State private var viewModel: ViewModel
    
    @Environment(\.dismiss) var dismiss
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
            // Create a State instance for viewModel
            _viewModel = State(initialValue: ViewModel(location: location, onSave: onSave))
        }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place name", text: $viewModel.name)
                    TextField("Description", text: $viewModel.description)
                }
                
                Section("Nearby…") {
                    switch viewModel.loadingState {
                    case .loading:
                        Text("Loading…")
                    case .loaded:
                        ForEach(viewModel.pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            
                            + Text(": ") +
                            
                            Text(page.description)
                                .italic()
                            
                        }
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place Details")
            .toolbar {
                Button("save") {
                    var newLocation = viewModel.location
                    newLocation.id = UUID()
                    newLocation.name = viewModel.name
                    newLocation.description = viewModel.description
                    
                    viewModel.onSave(newLocation)
                    dismiss()
                }
            }
            .task {
                await viewModel.fetchNearbyPlaces()
            }
        }
    }
    
    
    
    
}

#Preview {
    EditView(location: .example) { _ in }
}
