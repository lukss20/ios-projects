//
//  Contact.swift
//  luchit22Contacts
//
//  Created by lukss on 22.12.25.
//
import Foundation

struct Contact {
    var name: String
    var phone: String
}

struct ContactSection {
    let letter: String
    var contacts: [Contact]
    var isCollapsed: Bool
}

