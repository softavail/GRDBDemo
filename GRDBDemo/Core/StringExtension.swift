import Foundation

extension String {
    
    public static func label(withSuffix suffix: String, bundle: Bundle = .main) -> String {
        return bundle.bundleIdentifier!.appending(suffix)
    }
}
