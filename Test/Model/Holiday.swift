//
//  Holiday.swift
//  Test
//
//  Created by Ahmad Mohammadi on 7/29/21.
//

import Foundation

struct Holiday: Codable {
    let date: Int
    let holidayName, information: String
    let moreInformation: String
    let jurisdiction: Jurisdiction

    enum CodingKeys: String, CodingKey {
        case date = "Date"
        case holidayName = "Holiday Name"
        case information = "Information"
        case moreInformation = "More Information"
        case jurisdiction = "Jurisdiction"
    }
}

enum Jurisdiction: String, Codable {
    case act = "act"
    case nsw = "nsw"
    case nt = "nt"
    case qld = "qld"
    case sa = "sa"
    case tas = "tas"
    case vic = "vic"
    case wa = "wa"
}

typealias Holidays = [Holiday]
