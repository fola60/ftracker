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
    static var userId: Int = extractUserId(from: jsonToken) ?? 0
    static var primaryColor: Color = Color.blue
    static var currencySymbol:String = "€"
    static var jsonToken: String {
        return keychain["jwt"] ?? ""
    }
    static var backendUrl: String = "http://localhost:8080"
    static var userCategories: [Category] = []
    static var defaultCategory: Category = Category(id: 0, headCategory: .miscellaneous, name: "Miscellaneous")
    
    public static func signIn(email: String, password: String) async -> Bool{
        let token: String = await attemptLogIn(user: User(email: email, password: password))
        if token == "FAIL" {
            return false
        }
        Globals.userId = extractUserId(from: token) ?? 0
        try? keychain.set(token, key: "jwt")
        defaultCategory = await getDefaultCategory()
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
    
    public static func getDefaultCategory() async -> Category {
        let categories = await getCategories()
        return categories.first(where: { $0.name == "Miscellaneous" }) ?? Category(id: 0, headCategory: .miscellaneous, name: "Miscellaneous")
    }
    
    public static func isUserSignedIn() async -> Bool {

        guard let url = URL(string: "\(Globals.backendUrl)/user/auth/check-token") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(jsonToken)", forHTTPHeaderField: "Authorization")

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("SUCCESS \(httpResponse.statusCode)")
                return httpResponse.statusCode == 200
            }
        } catch {
            print("Error verifying token: \(error)")
        }

        return false
    }
}
