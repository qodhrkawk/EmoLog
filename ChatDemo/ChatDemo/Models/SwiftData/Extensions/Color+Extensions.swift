internal import SwiftUI

extension Color {
    init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Remove the leading '#' if it exists
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        // The string must be either 6 or 8 characters long
        guard hexString.count == 6 || hexString.count == 8 else {
            return nil
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        let red, green, blue, alpha: Double
        
        if hexString.count == 6 {
            red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
            green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
            blue = Double(rgbValue & 0x0000FF) / 255.0
            alpha = 1.0
        } else {
            red = Double((rgbValue & 0xFF000000) >> 24) / 255.0
            green = Double((rgbValue & 0x00FF0000) >> 16) / 255.0
            blue = Double((rgbValue & 0x0000FF00) >> 8) / 255.0
            alpha = Double(rgbValue & 0x000000FF) / 255.0
        }
        
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

