
import Foundation

enum KeychainKeys {
    
    static let `class` = kSecClass as String
    
    enum Data {
        static let value = kSecValueData as String
        static let `return` = kSecReturnData as String
    }
    
    enum Attributes {
        static let label = kSecAttrLabel as String
        static let accessible = kSecAttrAccessible as String
        static let account = kSecAttrAccount as String
    }
    
}

enum KeychainKeyValues {
    
    enum Class {
        static let genericPassword = kSecClassGenericPassword as String
        static let certificate = kSecClassCertificate
    }
    
}
