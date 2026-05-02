import Android

public struct Asset: Sendable {
    internal let manager: AssetManager
    public let name: String
    
    public init(_ manager: AssetManager, name: String) {
        self.manager = manager
        self.name = name
    }
    
    public init(_ manager: OpaquePointer?, name: String) {
        self.manager = AssetManager(manager)
        self.name = name
    }
}

private extension Asset {
    func withPointer<R>(_ body: (OpaquePointer) -> R) throws(AssetError) -> R {
        guard let pointer = AAssetManager_open(
            manager.pointer,
            name,
            AccessMode.random.rawValue
        ) else {
            throw .notFound(path: name)
        }
        defer {
            AAsset_close(pointer)
        }
        return body(pointer)
    }
}

public extension Asset {
    var bytes: [UInt8] {
        get throws(AssetError) {
            try withPointer({ pointer in
                var result = [UInt8]()
                
                while true {
                    let bytes = [UInt8](unsafeUninitializedCapacity: 4096, initializingWith: { buffer, count in
                        count = Int(AAsset_read(pointer, buffer.baseAddress, buffer.count))
                    })
                    if bytes.isEmpty { break }
                    result.append(contentsOf: bytes)
                }
                
                return result
            })
        }
    }
    
    var length: Int {
        get throws(AssetError) {
            try withPointer({ pointer in
                Int(AAsset_getLength(pointer))
            })
        }
    }
}

extension Asset: CustomStringConvertible {
    public var description: String {
        "Asset(name: \"\(name)\")"
    }
}

extension Asset: Equatable {
    public static func == (lhs: Asset, rhs: Asset) -> Bool {
        lhs.name == rhs.name
    }
}

extension Asset: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
/*
private extension Asset {
    func seek(position: off_t, offset: CInt = SEEK_SET) {
        AAsset_seek(asset, position, offset)
    }
    
    func seekToStart() {
        seek(position: 0, offset: SEEK_SET)
    }
    
    func seekToEnd() {
        seek(position: 0, offset: SEEK_END)
    }
    
    var position: off_t {
        length - AAsset_getRemainingLength(asset)
    }
}
*/
