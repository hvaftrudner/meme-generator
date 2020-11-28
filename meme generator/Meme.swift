//
//  Meme.swift
//  meme generator
//
//  Created by Kristoffer Eriksson on 2020-11-26.
//

import UIKit

class Meme: NSObject, Codable {
    var name: String
    var topText: String?
    var bottomText: String?
    var image: String
    
    init(name: String, topText: String, bottomText: String?, image: String) {
        self.name = name
        self.topText = topText
        self.bottomText = bottomText
        self.image = image
    }
}
