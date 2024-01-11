//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by Leo  on 11.01.24.
//

import Foundation
import SwiftUI

extension EditView {
    @Observable
    class ViewModel {
        enum LoadingState {
            case loading, loaded, failed
        }
        
        private(set) var location: Location
        
        var name: String
        var description: String
        
        var loadingState = LoadingState.loading
        var pages = [Page]()
        
        var onSave: (Location) -> Void
        
        init(location: Location, onSave: @escaping (Location) -> Void) {
            self.location = location
            self.onSave = onSave
            
            _name = location.name // geht auch mit State(initialValue: location.name).wrappedValue
            _description = location.description
        }
        
        func fetchNearbyPlaces() async {
            let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.latitude)%7C\(location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
            
            guard let url = URL(string: urlString) else {
                print("Bad URL: \(urlString)")
                return
            }
            
            do {
                    let (data, _) = try await URLSession.shared.data(from: url)

                    // we got some data back!
                    let items = try JSONDecoder().decode(Result.self, from: data)

                    // success – convert the array values to our pages array
                    pages = items.query.pages.values.sorted()
                    loadingState = .loaded
                } catch {
                    // if we're still here it means the request failed somehow
                    loadingState = .failed
                }
        }
    }
}
