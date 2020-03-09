
import Foundation

protocol AccountDAOProtocol: class {
    func fetchAccount(byId accountId: String) -> DBAccount?
    func fetchAccount(byQRCode qrCode: String) -> DBAccount?
    func fetchAccount(by rowID: Int64) -> DBAccount?
}
