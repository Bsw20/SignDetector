//
//  CoreDataManager.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 17.05.2021.
//

import Foundation
import UIKit
import CoreData
import SwiftyBeaver

protocol CoreDataService {
    func addSignModel(fileData: Data, latitude: Double, longitude: Double, direction: Double)
    func startSendingDataToServer()
}

class CoreDataManager {
    static let MAX_ELEMENTS_COUNT = 250
    
    public static var shared = CoreDataManager()
    
    private var currentElementsCount = 0
    private var container: NSPersistentContainer
    private init() {
        container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer

        retrieveSignPhotoModels { result in
            switch result {
            
            case .success(let data):
                self.currentElementsCount = data.count
            case .failure(_):
                break
            }
        }
        
    }
    
    public func saveContext(completion: @escaping (Result<Void, Error>) -> Void = {_ in }) {
        DispatchQueue.global(qos: .default).async {
            if self.container.viewContext.hasChanges {
                do {
                    try self.container.viewContext.save()
                    completion(.success(Void()))
                } catch {
                    completion(.failure(error))
                }
            }
        }

    }
    
    public func getContext() -> NSManagedObjectContext {
        return container.viewContext
    }
    
    private func initNewSignPhotoModel() -> SignPhotoModel {
        return SignPhotoModel(context: container.viewContext)
    }
    
    public func deleteSignPhotoModel(model: SignPhotoModel, completion: @escaping (Result<Void, APIError>) -> Void) {
        getContext().delete(model)
        do{
            try getContext().save()
            completion(.success(Void()))
        } catch {
            completion(.failure(APIErrorFabrics.coreDataError()))
            SwiftyBeaver.error(APIErrorFabrics.coreDataError().message)
        }
    }
    
    
    public func retrieveSignPhotoModels(completion: @escaping (Result<[SignPhotoModel], APIError>) -> Void){
        let request: NSFetchRequest<SignPhotoModel> = SignPhotoModel.fetchRequest()
        
        do {
            let tasks = try container.viewContext.fetch(request)
            completion(.success(tasks))
        } catch {
            SwiftyBeaver.error(APIErrorFabrics.coreDataError().message)
            completion(.failure(APIErrorFabrics.coreDataError()))
        }
    }
}

//MARK: - CoreDataService
extension CoreDataManager: CoreDataService {
    func addSignModel(fileData: Data, latitude: Double, longitude: Double, direction: Double) {
        DispatchQueue.global(qos: .default).async {[weak self ]in
            guard let self = self else { return }
            if self.currentElementsCount < CoreDataManager.MAX_ELEMENTS_COUNT {
                let model = self.initNewSignPhotoModel()
                model.latitude = latitude
                model.longitude = longitude
                model.filedata = fileData
                model.direction = direction
                self.saveContext { [weak self] result in
                    switch result {
                    
                    case .success():
                        self?.currentElementsCount += 1
                    case .failure(let error):
                        SwiftyBeaver.error(APIErrorFabrics.coreDataError().message)
                        break
                    }
                }
            }
        }
    }
    
    func startSendingDataToServer() {
        DispatchQueue.global(qos: .background).async {
            self.retrieveSignPhotoModels { result in
                switch result {
                
                case .success(let models):
                    DispatchQueue.global(qos: .background).async {
                        for model in models {
                            if let fileData = model.filedata {
                                UserAPIService.shared.sendImageWithSign(model: .init(fileData: fileData, latitude: model.latitude, longitude: model.longitude, direction: model.direction)) { result in
                                    switch result {
                                    
                                    case .success():
                                        self.deleteSignPhotoModel(model: model) {[weak self]  result in
                                            switch result {
                                            
                                            case .success():
                                                self?.currentElementsCount -= 1;
                                            case .failure(_):
                                                break
                                            }
                                        }
                                    case .failure(_):
                                        break
                                    }
                                }
                            } else {
                                self.deleteSignPhotoModel(model: model) {[weak self]  result in
                                    switch result {
                                    
                                    case .success():
                                        self?.currentElementsCount -= 1;
                                    case .failure(_):
                                        break
                                    }
                                }
                            }

                        }
                    }
                case .failure(let error):
                    SwiftyBeaver.error(error.localizedDescription)
                }
            }
        }
    }
    
    
}
