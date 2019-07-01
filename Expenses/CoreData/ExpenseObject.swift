//
//  ExpenseObject.swift
//  Expenses
//
//  Created by Agterra on 01/07/2019.
//  Copyright © 2019 Agterra. All rights reserved.
//

import Foundation
import CoreData

class ExpenseObject: NSManagedObject {
    @NSManaged var amount: Float
    @NSManaged var date: NSDate?
    @NSManaged var title: String?
}
