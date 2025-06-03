import Android

public struct AssetManager: @unchecked Sendable {
    internal let pointer: OpaquePointer
    
    public init(_ pointer: OpaquePointer) {
        self.pointer = pointer
    }
    
    public func contents(at path: String = "") throws -> [String] {
        guard let pointer = AAssetManager_openDir(pointer, path) else {
            throw AssetError.notFound(path: path)
        }
        defer {
            AAssetDir_close(pointer)
        }
        AAssetDir_rewind(pointer)
        var result: [String] = []
        while let string = AAssetDir_getNextFileName(pointer) {
            let name = String(cString: string)
            result.append(name)
        }
        return result
    }
    
    public func assets(at path: String = "") throws -> [Asset] {
        try contents(at: path).map({ name in
            Asset(pointer, name: path == "" ? name : "\(path)/\(name)")
        })
    }
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
