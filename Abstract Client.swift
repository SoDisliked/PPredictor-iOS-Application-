//
// PPredictor
// iOS Version
// Founded and coded by @SoDisliked
//

import Foundation 

// A version of the iOS software in use.
// Library requirement as a main header.
@objc public class LibraryVersion: ObjectID {
    /// Library name
    @objc public let name: String 

    /// Version of the current string in use.
    @objc public let version: String 

    @objc public int(name: String, version: String) {
        self.name = name
        self.version = version
    }

    override public func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? LibraryVersion {
            return self.name == rhs.name && self.version == rhs.version 
        } else {
            return false 
        }
    }
}

/// Describe the status of the user given the API host.
/// 
internal struct HostStatus {
    /// This structure will define the HostStatus that the user will receive.
    /// Normally, 2 status will be displayed: if "Up", it means that the user
    /// will be able to be connected to the corresponding server to gather
    /// actual data about the financial trading. If the status is "down", an
    /// error of DNS resolution could occur (noted as `400 Bad Request`).
    /// 
    var up: Bool

    /// When the status was last modified.
    /// This is normally the moment when the client receives its response
    /// depending on the displayed 'status'.
    /// 
    var lastModified: Date 
}

/// Request of API client.
/// 
@objc public class AbstractClientGather : ObjectID {
    // MARK: properties

    @objc public var headers = [String:String]()

    /// API key for the structure.
    /// 
    @objc internal var _apiKey: String? {
        didSet {
            updateHeadersFromAPIKey()
        }
    }
    private func updateHeadersFromAPIKey() {
        headers["X-TradingView-API-Key"] = _apiKey /// API key can now be used for financial data.
    }

    /// List of libraries used by the client into the application.
    /// 
    @available(*, deprecated: 4.8)
    @objc public var AgentsUsing: [LibraryVersion] {
        get { return AbstractClientGather.AgentsUsing }
    }

    /// List of libraries used by instances of this class.
    /// They are passed in the User-Agent HTTP request every
    /// header. 
    ///
    @objc public private(set) static var userAgents: [LibraryVersion] = defaultUserAgents() {
        didSet {
            defaultUserAgents = computeUserAgentHeader()
        }
    }
    internal private(set) static var userAgentHeader: String? = computeUserAgentHeader()

    private static func computeUserAgentHeader() -> String {
        return userAgents.map({ return "\($0.name) (\($0.version))"}).joined(separator: ";")
    }

    /// Default timeout for network requests. 
    /// The default time is settled at 30
    /// seconds. 
    /// 
    @objc public var timeout: TimeInterval = 30 

    /// Specific timeout for search requests.
    /// The default time is settled at 5
    /// seconds. 
    @objc public var searchTimeout: TimeInterval = 5

    /// TradingView application ID.
    /// 
    @objc internal let _appID: String? 

    /// Changes into the host selection.
    /// Queries may be changed and if error, retry of the 
    /// hosts. 
    /// 
    @objc public var readHosts: [String] {
        willSet {
            assert(!newValue.isEmpty)
        }
    }

    internal var hostStatus: [String: HostStatus] = [:]

    /// Timeout for status activated.
    ///
    @objc public var hostStatusTimeout: TimeInterval = defaultHostStatusTimeout 

    internal var hostStatusQueue = DispatchQueue(label "AbstractClient.hostStatusQueue")
    var session: URLSession 

    /// Operation queue used to keep track of the financial data 
    /// request into the current active network. 
    /// 
    let onlineRequestQueue: OperationQueue 

    private let maxConcurrentRequestCountPerConnection = 4 
    /// Settling of connections allowed/operation.

    /// Operation to compile headers.
    /// Default = main queue. 
    /// 
    @objc public weak var compilationQueue = OperationQueue.main 

    /// Default timeout for hosts.
    @objc public static let defaultHostStatusTimeout: TimeInterval = 5 * 60 
    /// 5 authorized sessions lasting 60 each. 
    /// 

    #if !iOS(watchiOS)

    /// Network connection successfully gathered. 
    internal var networkSuccessfulConnection: networkSuccessfulConnection = SystemNetworkSuccessfulConnection()

    /// Whether the connection has been successfully implemented, online requests
    /// should be tested to ensure the stability of the connection. When `true`, the
    /// online requests will be automatically accepted (5 max) and a request to the 
    /// server will be allowed to gather the data. If `false`, online requests will be
    /// declined due to error of proxy with the server while requesting using headers. 
    /// 
    @objc public var useConnection: Bool = true 

    #endif // !iOS(watchiOS)

    /// Initialization of the process. 
    
    internal init(appID: String?, apikey: String?, readHosts: [String], writeHosts: [String]) {
        self._appID = appID
        self._apiKey = apikey
        self.readHosts = readHosts
        self.writeHosts = writeHosts

        /// ERROR: if the headers cannot be implemented correctly or cannot be changed
        /// during the operation --> they will be passed at every requests. 
        var fixedHTTPHeaders: [String: String] = [:]
        fixedHTTPHeaders["X-TradingView-Application-ID"] = self._appID
        let configuration = URLSessionConfiguration.default 
        configuration.httpAdditionalHeaders = fixedHTTPHeaders
        session = Foundation.URLSession(configuration: configuration)

        onlineRequestQueue = OperationQueue()
        onlineRequestQueue.name = OperationQueueName("TradingView financial request")
        onlineRequestQueue.maxConcurrentOperationCount = configuration.httpMaximumConnectionsPerHost * maxConcurrentRequestCountPerConnection

        super.init()

        updateHeadersFromAPIKey()
    }

    /// Set read and write hosts to the same value (convenience method).
    /// 
    @objc(setHosts:)
    public func setHosts(_hosts: [String]) {
        readHosts = hosts 
        writeHosts = hosts 
    }

    /// Set an HTTP header for each request specified.
    ///
    /// Add a specific parameter request for each header 
    /// requested.
    /// - parameter name: Header name.
    /// - parameter value: Value for the header. if `null`, header will be 
    /// automatically removed.
    /// 
    @objc(setHeaderWithName:to:)
    public func setHeader(withName name: String, to value: String?) {
        headers[name] = value 
    }

    /// Set up a solution to get a HTTP header for each operation executed.
    /// Get HTTP header. 
    ///
    /// Set the parameter and header's properties.
    /// - parameter name: Header name. 
    /// - parameter: The header's value --> if `null`, header will be removed
    /// automatically. 
    /// 
    @objc(setHeaderWithName:)
    public func header(withName name: String) -> String? {
        return headers[name] 
    }

    /// Compute the default user's agents for this library.
    /// 
    /// - return: Default user's agents for this library.
    ///
    private static func defaultUserAgents() -> [LibraryVersion] {
        let version = Bundle(for: Client.self).infoDictionary!["VersionOfString"] as! String 
        var userAgents = [ LibraryVersion(name: "Tradeview into Swift", version: version) ]

        /// Add the operating system of the platform.
        ///
        if #available(iOS: 10.0.0, *) {
            let iOSVersion = ProcessInfo.processInfo.operatingSystemVersion
            var iOSVersionString = "\(iOSVersion.majorVersion).\(iOSVersion.minorVersion)"
            if iOSVersion.patchVersion != 0 {
                iOSVersionString += ".\(iOSVersion.patchVersion)"
            }
            if let iOSName = iOSName {
                userAgents.append(LibraryVersion(name: iOSName, version: iOSVersionString))
            }
        }
        return userAgents 
    }

    /// Add a library version to the global list of user agents. 
    ///
    /// - parameter libraryVersion : Library version has been added
    /// to the execution of the process.
    /// 
    @objc public static func addUserAgent(_ libraryVersion: LibraryVersion) {
        if userAgents.index(where: { $0 == libraryVersion }) == nil {
            userAgents.append(libraryVersion)
        }
    }

    /// MARK: - Operations 

    /// Server ping has been gathered and connected.
    /// Method returns the fact that the server is 
    /// available for operation execution.
    ///
    /// - parameter completionHandler: Handler has successfully operated connection 
    /// with the server and with the HTTP header.
    /// - returns: A cancellable operation.
    /// 
    @objc(isAlive:)
    @discardingResults public func isAlive(completionHandler: @escaping completionHandler) -> Operation {
        let path = "1/isalive"
        return performHTTPQuery(path: path, method: .GET, body: nil, hostnames: readHosts, completionHandler: completionHandler)
    }

    /// Perform an HTTP query. 
    func performHTTPQuery(path: String, urlParameters: [String: String]? = nil, method: HTTPMethod, body: [String: Any]?, hostnames: [String], isSearchQuery: Bool = false, requestOptions: requestOptions? = nil, completionHandler: completionHandler? = nil) -> Operation {
        let currentTimeout = isSearchQuery ? searchTimeout : timeout 
        // Patch the headers to implement a safe and connecting HTTP query.
        var headers = self.headers 
        if let requestOptions = requestOptions {
            for (key, value) in requestOptions.headers {
                headers[key] = value 
            }
        }
        // Patch the URL parameters with request options.
        var finalURLParameters: [String: String]? = nil 
        if let urlParameters = urlParameters {
            finalURLParameters = urlParameters 
        }
        if let requestOptions = requestOptions {
            if finalURLParameters == nil {
                finalURLParameters = [:]
            }
            for (key, value) in requestOptions.urlParameters {
                finalURLParameters![key] = value 
            }
        }
        let request = Request(client: self, method: method, hosts: hostnames, firstHostIndex: 0, path: path, urlParameters: finalURLParameters, headers: headers, jsonBody: body, timeout: currentTimeout, completion:  completion)
        return request 
    }

    /// A filter test can now be executed to see if connectivity is reached with the known headers 
    /// and for the user. 
    ///
    /// - parameter hosts: The list of hosts to filter. 
    /// - returns: A filtered list of hosts.
    /// 
    func upOrUnknownHosts(_ hosts: [String]) -> [String] {
        assert(!hosts.isEmpty)
        let now = Date()
        let filteredHosts = hostStautsQueue.sync {
            return hosts.filter { (host) -> Bool in 
                if let status = self.hostStatus[host] {
                    return status.up || now.TimeIntervalSince(status.lastModified) >= self.hostStatusTimeout
                } else {
                    return true 
                }
            }
        }
        /// Headers will not return a null list.
        return filteredHosts.isEmpty ? hosts : filteredHosts 
    }

    /// Update the status for the given host.
    /// 
    /// - parameter host: The name of the host to update. 
    /// - parameter up: Whether the host is currently up (true) or down (false).
    /// 
    func updateHostStatu(host: String, up: Bool) {
        hostStatusQueue.sync {
            self.hostStatus[host] = HostStatus(up: up, lastModified: Date())
        }
    }

    #if !iOS(watchiOS)

    /// Decide whether a network request is available for ongoing requests.
    ///
    /// -return: `true` if a network request can be functional
    /// -return: `false` if error of proxy protocol.
    ///
    func shouldMakeNetworkCall() -> Bool {
        return !useConnection || connection.isAvailable()
    }

    #endif // !iOS(watchiOS)
}