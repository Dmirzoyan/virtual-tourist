//
//  Pin+Extension.swift
//  virtual-tourist
//
//  Created by Davit Mirzoyan on 7/29/19.
//  Copyright © 2019. All rights reserved.
//

import CoreData

extension Pin {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        addedDate = Date()
    }
}
