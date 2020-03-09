import UIKit

class ViewController: UIViewController {

    private var initialized = false
    private let accountId = "d6be2792-03eb-4e2d-8762-95569413aebd"
    private let identityId = "616dfbdb-34d0-4b59-98cf-5defe8a5a63c"

    private var subscribes: [SubscribeType]? {
        return [.account(accountId), .identity, .authProvider]
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        subscribes?.forEach({
            DBObserver.default.register(subscriber: self, type: $0)
        })
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)

        subscribes?.forEach({
            DBObserver.default.register(subscriber: self, type: $0)
        })
    }

    deinit {
        DBObserver.default.unregister(subscriber: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        initialize()
    }
    
    private func initialize() {
        if !initialized {
            let storage = StorageService.sharedInstance
            let phone = "+15555555555"
            let identity = DBIdentity(id: identityId,
                                      passcode: "8e82d6eb-ee7d-4aa6-8224-09cb9659d935",
                                      defaultAccountId: accountId,
                                      authProviders: getProvider(identity: identityId, phone: phone))
            let account = getAccount(identity: identityId, account: accountId, phone: phone)
            
            storage.setupDatabase(with: "11bd121c-359f-4878-ba22-4cfd3bb2665f", application: UIApplication.shared)

            do {
                try storage.perform(action: .save, with: identity)
                try storage.perform(action: .save, with: account)
            } catch {
            }

            initialized = true
        }
    }
    
    private func getProvider(identity:String, phone: String) -> [DBAuthProvider]
    {
        let provider = DBAuthProvider(identityId: identity,
                                      type: .phone,
                                      value: phone,
                                      isAvailableForSearch: true)
        return [provider]
    }
    
    private func getAccount(identity: String, account: String, phone: String) -> DBAccount {
        
        let acc = DBAccount(accountId: account,
                            identityId: identity,
                            authenticationIdentifier: phone,
                            authenticationType: "phone",
                            avatar: nil,
                            accountMark: nil,
                            accountName: "John Dow",
                            firstName: "John",
                            lastName: "Doe",
                            username: "john_doe",
                            status: 1,
                            qrCode: nil,
                            birthday: nil,
                            roles: [.user],
                            created: nil,
                            updated: nil)
        
        return acc
    }
}


extension ViewController: StorageSubscriber {
    func update(with changes: [StorageChange], type: SubscribeType)
    {
        
    }
}

