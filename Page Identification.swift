//
// PPredictor
// iOS Version
// Founded and coded by @SoDisliked
//

import Foundation 

public struct Account {

    public let available: String
    public let balance: String
    public let currency: String
    public let hold: String
    public let id: String
    public let profileId: String

}

extension Account: Decodable { }
