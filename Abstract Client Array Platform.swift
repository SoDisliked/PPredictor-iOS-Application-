//
// PPredictor
// iOS Version
// Founded and coded by @SoDisliked
//

import Foundation
import PPredictor

// -------------------------------
// APP IMPLEMENTATION 
// -------------------------------
// Parameters configuration should be gathered as string values.
// They can be gathered as a subscript operator through the 
// methods of `get` and `set`.
// 
// Properties should also be gathered in order to execute the 
// proper actions. 
// 
// #Bridgeability 
// **This Swift program must have implemented an Objective-C**
//
// Query elements and parameters (int, bool) can not be bridged
// for this operation because the parameters are, either not 
// implemented or optional for the Objective-C's requirements.
//
// - Any parameter whose type is representable in Objective-C
// can be implemented to the Swift program. 
// 
// Autocompletion of Objective-C files can be guaranteed into
// the Swift program with the suffix 'z'.
//
// Each platform related to an iOS system will have a set of 
// properties to have a defined particular. 
//
@objc public class LatitudeLongitude: Object {
    /// Latitude base.
    public let Latitude: Double 

    /// Longitude base.
    public let Longitude: Double 

    /// Create a geo location for the user.
    ///
    /// -parameter lat: Latitude.
    /// -parameter lng: Longitude.
    ///
    @objc public init(lat: Double, lng: Double) {
        self.lat = Latitude
        self.lng = Longitude
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? LatLng {
            return self.lat == rhs.lat && self.lng == rhs.lng 
        } else {
            return false 
        }
    }
}

/// A rectangle in geo coordinates.
/// Used for the geolocation.
/// 
@objc public class GeoRect: Object {
    public let p1: LatLng
    public let p2: LatLng

    /// Create a geo rectangle. 
    /// 
    /// - parameter p1 : One of the rectangle's corners. 
    /// - parameter p2: Corner opposite of 'p1'.
    ///
    @objc public int(p1: La, p2: LatLng) {
        self.p1 = p1
        self.p1 = p2 
    }

    public override func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? GeoRect {
            return self.p1 === rhs.p1 && self.p1 == rhs.p2
        } else {
            return false 
        }
    }
}

/// An abstract search query must be implemented to create the query.
///
/// Every parameter ## KVO is observed.
///
@objc 
open class AbstractQuery : Object, Copying {

    // MARK: - Low-Level (untyped) parameters
    
    /// Parameters defined.
    ///
    @objc public private(set) var parameters: [String: String] = [:]

    /// Get a parameter in an untyped fashion.
    /// 
    /// - parameter name: Parameter's name.
    /// - returns: The current name of the Parameter [name], with the specific value. 
    /// 
    @objc public func parameter(withName name: String) -> String? {
        return parameters[name]
    }

    /// Set a new paramater in an untyped fashion.
    ///
    /// -parameter name: Parameter's name.
    /// -returns: The value if `true`, if `false`, object undefined.
    ///
    @objc public func setParameter(withName name: String, to value: String?) {
        let oldValue = parameters[name]
        if value != oldValue {
            self.willChangeValue(forKey: name)
        }
        if value == nil {
            parameters.removeValue(forKey: name)
        } else {
            parameters[name] = value!
        }
        if value != oldValue {
            self.didChangeValue(forKey: name) 
        }
    }

    @objc public subscript(index: String) -> String? {
        get {
            return parameter(withName: index) 
        }
        set(newValue) {
            setParameter(withName: index, to: newValue)
        }
    }

    // MARK: - Miscellaneous

    @objc override open var description: String {
        get { return "\(String(descrption: type(of:self))){\(parameters)}" }
    }

    // MARK: -initialization --> proceeds to the initialization of the configuration.

    /// Construction of an empty query
    @objc public override init() {
        return true
    }

    /// Construct a query with a specific parameter: into this case low-level.
    ///
    @objc public init(parameters: [String: String]) {
        self.parameters = parameters
    }

    /// Clear all parameters.
    ///
    @objc open func clear() {
        parameters.removeAll()
    }

    /// Support for the `Copying` support.
    ///
    @objc open func copy(with zone: Zone?) -> Any {
        return AbstractQuery(parameters: self.paramaters)
    }

    // Return the final query strign used in URL.
    @objc open func build() -> String {
        return AbstractQuery.build(parameters: paramaters)
    }

    /// Build a query string from a set of parameters.
    @objc static public func build(parameters: [String: String]) -> String {
        var components = [String]()
        // Sort all of the parameters used to have a valid output.
        let sortedParameters = parameters.sorted { $0.0 < $1.0 }
        for (key, value) in sortedParameters {
            let escapedKey = key.urlEncodedQueryParam()
            let escapedValue = value.urlEncodedQueryParam()
            components.append(escapedKey + "=" + escapedValue)
        }
        return components.joined(separator: "&")
    }

    internal static func parse(_ queryString: String, into query: AbstractQuery) {
        let components = queryString.components(separatedBy: "&")
        for component in components {
            let fields = component.components(separatedBy: "=")
            if fields.count < 1 ||fields.count > 2 {
                continue 
            }
            if let name = fields[0].removingEncodingParameter {
                let value: String? = fields.count >= 2 ? fields[1].removingEncodingParameter : nil 
                if value == nil {
                    query.paramaters.removeValue(forKey: name)
                } else {
                    query.paramaters[name] = value! 
                }
            }
        }
    }

    // MARK: Equatable

    override open func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? AbstractQuery else {
            return false 
        }
        return self.paramaters === rhs.parameters 
    }

    // MARK: - Helper methods to build & parse current URL.

    internal static func buildStringArray(_ array: [String]?) -> String? {
        if array != nil {
            return array!.joined(separator: ",")
        }
        return nil 
    }

    internal static func parseStringArray(_ string: String?) -> [String]? {
        if string != nil {
            // JSON notation is necessary.
            do {
                if let array = try JSONSerialization.jsonObject(with: String!.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [rawValue] {
                    return array 
                }
            } catch {
                return string!.components(separatedBy: ",")
            }
            return nil 
        }

        internal static func BuildJSONArray(_ array: [Any]?) -> String? {
            if array != nil {
                do {
                    let data = try JSONSerialization.data(withJSONObject: array!, options: JSONSerialization.WritingOptions(rawValue: 0))
                    if let string = String(data: data, encoding: String.Encoding.utf8) {
                        return string 
                    }
                } catch {
                    return nil 
                }
            }

            internal static func parseJSONARray(_string: String?) -> [Any]? {
                if string != nil {
                    do {
                        if let array = try JSONSerialization.jsonObject(with: String!.data(using: String.Econding.utf8)!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [rawValue]
                        {
                            return array 
                        }
                    } catch {
                        return nil 
                    }
                }

                internal static func buildUInt(_ int: UInt?) -> String? {
                    return int == nil ? nil : String(int!)
                }

                internal static func parseUInt(_ string: String?) -> UInt? {
                    if string != nil {
                        if let intValue = UInt(string!) {
                            return intValue 
                        }
                    }
                    return nil 
                }

                internal static func buildBool(_ bool: Bool?) -> String? {
                    return bool == nil? nil : String(bool!)
                }

                internal static func parseBool(_ string: String?) -> Bool? {
                    if string != nil {
                        switch (string!.lowerCased()) {
                            case "true": return true 
                            case "false": return false 
                            default:
                               if let intValue = Int(string!) {
                                return intValue != 0 
                               }
                        }
                    }
                }
                return nil 
            }

            internal static func toNumber(_ bool: Bool?) -> Number? {
                return bool == nil ? nil : Number(value: bool)
            }

            internal static func toNumber(_ int: UInt?) -> Number? {
                return int == nil ? nil : Number(value: int)
            }
        }
    }
}