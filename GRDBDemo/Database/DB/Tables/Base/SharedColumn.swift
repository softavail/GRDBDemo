
import GRDB

extension Column {
    // swiftformat:disable consecutiveSpaces
    static let id                   = Column("id")
    static let phoneId              = Column("phoneId")
    static let rosterId             = Column("rosterId")
    static let roomId               = Column("roomId")
    static let messageId            = Column("messageId")
    static let deliveredMessageId   = Column("deliveredMessageId")
    static let serverId             = Column("serverId")
    static let localId              = Column("localId")
    static let starId               = Column("starId")
    static let feedId               = Column("feedId")
    
    static let feedType             = Column("feedType")
    
    static let avatar               = Column("avatar")
    static let names                = Column("names")
    static let surnames             = Column("surnames")
    
    static let container            = Column("container")
    static let action               = Column("action")
    static let reader               = Column("reader")
    static let unread               = Column("unread")
    static let update               = Column("update")
    static let created              = Column("created")
    static let time                 = Column("time")
    
    static let presence             = Column("presence")
    static let status               = Column("status")
    static let type                 = Column("type")
    
    static let prev                 = Column("prev")
    static let next                 = Column("next")
    
    static let from                 = Column("from")
    static let to                   = Column("to")
    
    static let editMessage          = Column("editMessage") // link
    static let seenBy               = Column("seenBy")
    static let repliedBy            = Column("repliedBy")
    static let mentioned            = Column("mentioned")
    
    static let showInTimeline       = Column("showInTimeline") // timeline
    static let draft                = Column("draft") // draft
    static let draftUpdated         = Column("draftUpdated") // draft

    // swiftformat:enable consecutiveSpaces
}
