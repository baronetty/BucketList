//
//  ContentView.swift
//  BucketList
//
//  Created by Leo  on 22.12.23.
//y

import MapKit
import SwiftUI


struct ContentView: View {
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 54.5, longitude: -3),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )
    
    @State private var viewModel = ViewModel()
    
    var body: some View {
//        if viewModel.isUnlocked {
            NavigationStack {
                MapReader { proxy in
                    Map(initialPosition: startPosition) {
                        ForEach(viewModel.locations) { location in
                            Annotation(location.name, coordinate: location.coordinate) {
                                Image(systemName: "star.circle")
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(.circle)
                                    .onLongPressGesture {
                                        viewModel.selectedPlace = location
                                    }
                            }
                        }
                    }
                    .mapStyle(viewModel.mapStyle ? .standard() : .hybrid(elevation: .realistic))
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            viewModel.addLocation(at: coordinate)
                        }
                    }
                    .sheet(item: $viewModel.selectedPlace) { place in
                        EditView(location: place) {
                            viewModel.update(location: $0)
                        }
                    }
                }
                HStack {
                    
                    Spacer()
                    
                    Button {
                        viewModel.mapStyle = true
                    } label: {
                        Image(systemName: "map.fill")
                        Text("Standard")
                    }
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
                    
                    Spacer()
                    
                    Button {
                        viewModel.mapStyle = false
                    } label: {
                        Image(systemName: "square.2.layers.3d.fill")
                        Text("Hybrid")
                    }
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
                    
                    Spacer()
                }
            }
            .alert("Error", isPresented: $viewModel.showAlert) {
                Button("Try again?", action: viewModel.authenticate)
                Button("Cancel", role: .cancel) { }
            }
            
//        } else {
//            Button("Unlock Places", action: viewModel.authenticate)
//                .padding()
//                .background(.blue)
//                .foregroundStyle(.white)
//                .clipShape(.capsule)
//        }
    }
    
}

#Preview {
    ContentView()
}
