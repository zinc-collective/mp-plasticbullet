//
//  ObservableAnimatedViewModel.swift
//  PlasticBullet
//
//  Created by Cricket on 1/4/23.
//  Copyright © 2023 Zinc Collective, LLC. All rights reserved.
//

import SwiftUI

enum Sheet: Identifiable {
    var id: Int {
        switch self {
        case .info:
            return 0
        case .detail:
            return 1
        }
    }
    
    case info
    case detail(data:FilterableImageViewModel)
    
    var model: FilterableImageViewModel? {
        switch self {
        case .info:
            return nil
        case .detail(let data):
            return data
        }
    }
}


@MainActor
class ObservableAnimatedViewModel: ObservableObject {
    typealias DataType = FilterableImageViewModel
//    @EnvironmentObject var chosenTileModel: FilterableImageViewModel
//    @EnvironmentObject var selectedImage: ObservableUIImage
    @Published var chosenViewModel = FilterableImageViewModel(image: FilterableImage(rawImage: testImages[1]!))
    
    @Published private(set) var data: [DataType] = []
    @Published private(set) var isLoading: Bool = false
    var count: Int {
        data.count
    }
    
    func updateData(_ data: [DataType] = []) async {
        defer { print("###----> updated from view model") }
        do {
            self.data.removeAll()
            for model in data {
                self.data.append(model)
            }
            try await self.reloadAllFilters()
        } catch {
            print(error)
        }
    }
    
    func buildList(from newElement: FilterableImage, count: Int) throws {
        guard let img = newElement.rawImage as? UIImage else { return }
        
        self.data.removeAll()
        for _ in 0..<count {
            self.data.append(DataType(image: FilterableImage(rawImage: img)))
        }
        Task {
            do {
                print("###----> from viewModel internally")
                try await self.reloadAllFilters()
            } catch {
                throw error
            }
        }
    }
    
    func removeAll() {
        data.removeAll()
    }
    
    func append(_ newElement: DataType) {
        self.data.append(newElement)
    }
    
    func reloadAllFilters() async throws {
        isLoading = true
//        sleep(2)
        defer { isLoading = false }
        for model in data { await model.processImage() }
    }
    
    func setAsSelectedModel(_ newElement: DataType? = nil) {
        for model in self.data {
            if model == newElement {
                model.showFullscreen = true
            } else {
                model.showFullscreen = false
            }
        }
    }
    
    func getSelectedModel() -> DataType? {
        return self.data.first(where: { $0.showFullscreen == true })
    }
}
