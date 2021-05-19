//
//  SignPhotoModel+CoreDataProperties.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 17.05.2021.
//
//

import Foundation
import CoreData


extension SignPhotoModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SignPhotoModel> {
        return NSFetchRequest<SignPhotoModel>(entityName: "SignPhotoModel")
    }

    @NSManaged public var filedata: Data?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var address: String?
    @NSManaged public var direction: Double

}

extension SignPhotoModel : Identifiable {

}
