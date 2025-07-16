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
        Globals.userId = extractUserId(from: token) ?? 0
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
    
    private static func extractUserId(from jwt: String) -> Int? {
        let segments = jwt.split(separator: ".")
        guard segments.count == 3 else { return nil }

        let payloadSegment = segments[1]
        
        
        var base64 = String(payloadSegment)
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        while base64.count % 4 != 0 {
            base64 += "="
        }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let sub = json["sub"] as? String,
              let userId = Int(sub)
        else {
            return nil
        }

        return userId
    }
    
    
}
