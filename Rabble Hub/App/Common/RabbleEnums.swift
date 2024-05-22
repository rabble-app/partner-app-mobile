//
//  RabbleEnums.swift
//  Rabble Hub
//
//  Created by aljon antiola on 4/18/24.
//

import Foundation

/// SignUp enums
enum CellIndexDay: String {
    case mon = "Monday"
    case tue = "Tuesday"
    case wed = "Wednesday"
    case thu = "Thursday"
    case fri = "Friday"
    case sat = "Saturday"
    case sun = "Sunday"
}

enum StoreHoursType: String {
    case allTheTime = "ALL_THE_TIME"
    case monToFri = "MON_TO_FRI"
    case custom = "CUSTOM"
}

enum Step {
  case one, two, three, four
}

enum CellMode {
  case monFri, custom
}


enum ProfileMenuCellMode {
    case headerUI, textUI, switchUI, buttonUI, infoUI, sectionUI
}
