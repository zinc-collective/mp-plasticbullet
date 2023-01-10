//
//  TestVM.swift
//  PlasticBullet
//
//  Created by Cricket on 1/8/23.
//

import SwiftUI


class TestVM: ObservableObject {
    typealias DataType = TestImageVM
    @Published var chosenViewModel = DataType(rawImage: testImages[1]!)
    
    @Published private(set) var data: [DataType] = []
    @Published private(set) var isLoading: Bool = false
        
    func buildList(from newElement: DataType, count: Int) throws {
        guard let img = newElement.rawImage as? UIImage else { return }
        
        self.data.removeAll()
        for _ in 0..<count {
            self.data.append(DataType(rawImage: img))
        }
        Task {
            do {
                print("###----> from viewModel internally - Data Count: \(data.count)")
//                try await self.reloadAllFilters()
            } catch {
                throw error
            }
        }
    }
    
    func replaceFirst(_ newElement: DataType) {
        self.data.removeFirst(1)
        self.data.insert(newElement, at: 0)
    }
    
    func reloadAllFilters() {
        for model in data {
            Task { [weak self] in
                guard let self = self else {
                    print("###---> SELF NOT FOUND")
                    return }
                let newFilteredModel = await self.processFilter(on: model)
                DispatchQueue.main.sync {
                    _ = self.replaceViewModel(existingModel: model, newElement: newFilteredModel)
                }
            }
        }
    }
    
    func replaceViewModel(existingModel: DataType, newElement: DataType) -> Int? {
        let newIndex = self.data.firstIndex(where: { $0.id == existingModel.id })
        let newIndex2 = self.data.firstIndex(of: existingModel)
        print("### index comparision: \(newIndex == newIndex2 ? "SAME" : "DIFFERENT") -- \(newIndex!) : \(newIndex2!)")
        
        self.data.remove(at: newIndex ?? 0)
        self.data.insert(newElement, at: newIndex ?? 0)
        
        if newIndex == nil {
            print("###----> ORIGINAL MODEL NOT FOUND -- FIRST DATA ITEM WAS REPLACED")
        }
        return newIndex
    }
    
    func replaceSelectedViewModel(_ newElement: DataType) {
        _ = replaceViewModel(existingModel: self.chosenViewModel, newElement: newElement)
        self.chosenViewModel = newElement
    }
    
    func processSelectedViewModel() {
        Task {
            let newFilteredModel = await self.processFilter(on: self.chosenViewModel)
            
            DispatchQueue.main.sync { [weak self, newFilteredModel] in
                self?.replaceSelectedViewModel(newFilteredModel)
            }
        }
    }
    
    private func processFilter(on model: DataType) async -> DataType {
        // need a spec test to ensure preservation of "rawImage"
        do {
            let newImage = try? await model.processImage()
            return TestImageVM(rawImage: model.rawImage, processedImage: newImage!)
        } catch {
            
        }
    }
//    func reloadAllFilters() async throws {
//        isLoading = true
////        sleep(2)
//        defer { isLoading = false }
//        for model in data { await model.processImage() }
//    }
}
