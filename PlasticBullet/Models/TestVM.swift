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
        self.replaceFirst(DataType(rawImage: testImages[2]!))
    }
    
    func replaceSelectedViewModel(_ newElement: DataType) {
        var newIndex = self.data.firstIndex(where: { $0.id == chosenViewModel.id })
        var newIndex2 = self.data.firstIndex(of: chosenViewModel)
        print("### index comparision: \(newIndex == newIndex2 ? "SAME" : "DIFFERENT") -- \(newIndex!) : \(newIndex2!)")
        self.data.remove(at: newIndex ?? 0)
        self.data.insert(newElement, at: newIndex ?? 0)
        self.chosenViewModel = newElement
    }
    
//    func reloadAllFilters() async throws {
//        isLoading = true
////        sleep(2)
//        defer { isLoading = false }
//        for model in data { await model.processImage() }
//    }
}
