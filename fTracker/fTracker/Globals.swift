//
//  Globals.swift
//  fTracker
//
//  Created by Afolabi Adekanle on 22/06/2025.
//

import Foundation
import SwiftUI
import KeychainAccess

let keychain = Keychain(service: "com.afolabi.fTracker")

var userId: Int = 1
var primaryColor: Color = Color.blue

class Globals {
    static var userId: Int = 1
    static var primaryColor: Color = Color.blue
    static var currencySymbol:String = "€"
    static var jsonToken: String {
        return keychain["jwt"] ?? ""
    }
    
    public static func signIn(email: String, password: String) async -> Bool{
        let token: String = await attemptLogIn(user: User(email: email, password: password))
        if token == "FAIL" {
            return false
        }
        
        try? keychain.set(token, key: "jwt")
    
        return true;
    }
    
    public static func logOut() {
        try? keychain.remove("jwt")
    }
    
    public static func signUp(email: String, password: String) async -> String?{
        let message: String? = await attemptSignUp(email: email, password: password)
        return message
    }
    
    
}
