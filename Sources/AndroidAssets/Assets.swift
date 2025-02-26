import Android

public class Asset {
    private let assetManager: OpaquePointer
    private let asset: OpaquePointer
    private let path: String
    
    public init(with assetManager: OpaquePointer, path: String) throws(AssetError) {
        guard let asset = AAssetManager_open(assetManager, path, CInt(AASSET_MODE_RANDOM)) else { throw .notFound(path: path) }
        self.assetManager = assetManager
        self.asset = asset
        self.path = path
    }
    
    deinit {
        AAsset_close(asset)
    }
}

extension Asset: CustomStringConvertible {
    public var description: String {
        path
    }
}

public extension Asset {
    var bytes: [UInt8] {
        var result = [UInt8]()
        
        while true {
            let bytes = [UInt8](unsafeUninitializedCapacity: 4096, initializingWith: { buffer, count in
                count = read(into: UnsafeMutableRawBufferPointer(buffer))
            })
            if bytes.isEmpty { break }
            result.append(contentsOf: bytes)
        }
        
        return result
    }
}

public extension Asset {
    var length: off_t {
        AAsset_getLength(asset)
    }
    
    func read(into buffer: UnsafeMutableRawBufferPointer) -> Int {
        Int(AAsset_read(asset, buffer.baseAddress, buffer.count))
    }
    
    func seek(position: off_t, offset: CInt = SEEK_SET) {
        AAsset_seek(asset, position, offset)
    }
}

internal extension Asset {
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

public func assets(with assetManager: OpaquePointer, path: String = "") -> [Asset] {
    contents(with: assetManager, path: path).map({ try! Asset(with: assetManager, path: path == "" ? $0 : "\(path)/\($0)") })
}

public func contents(with assetManager: OpaquePointer, path: String = "") -> [String] {
    guard let directory: OpaquePointer = AAssetManager_openDir(assetManager, path) else { return [] }
    defer {
        AAssetDir_close(directory)
    }
    var result: [String] = []
    while let pointer: UnsafePointer<CChar> = AAssetDir_getNextFileName(directory) {
        result.append(String(cString: pointer))
    }
    return result
}

public enum AssetError: Error {
    case notFound(path: String)
}

extension AssetError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notFound(let path):
            return "asset not found: \(path)"
        }
    }
}
