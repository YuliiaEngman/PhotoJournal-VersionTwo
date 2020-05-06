//
//  ImageObject.swift
//  PhotoJournal
//
//  Created by Yuliia Engman on 4/30/20.
//  Copyright © 2020 Yuliia Engman. All rights reserved.
//

import Foundation

struct ImageObject: Codable & Equatable {
  let imageData: Data // we cannot use UIImage directly, we have to work through Data
  let date: Date
  let identifier = UUID().uuidString // this will help us to create a unique identifier, creates authomatically
    let imageDescription: String
}
