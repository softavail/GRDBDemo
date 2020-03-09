import Foundation

protocol IdentityDAOProtocol: class {
    func fetchIdentity(by identityId: String) -> DBIdentity?
    func fetchIdentity(by rowID: Int64) -> DBIdentity?
    
    func fetchAuthProvider(by rowID: Int64) -> DBAuthProvider?
    func fetchAuthProviders(by identityId: String) -> [DBAuthProvider]?
}
