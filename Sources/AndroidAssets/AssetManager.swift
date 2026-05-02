import Android

public struct AssetManager: @unchecked Sendable {
    internal let pointer: OpaquePointer?
    
    public init(_ pointer: OpaquePointer?) {
        self.pointer = pointer
    }
    
    public func contents(at path: String = "") throws(AssetError) -> [String] {
        guard let directory = AAssetManager_openDir(pointer, path) else {
            throw .notFound(path: path)
        }
        defer {
            AAssetDir_close(directory)
        }
        AAssetDir_rewind(directory)
        var result: [String] = []
        while let string = AAssetDir_getNextFileName(directory) {
            let name = String(cString: string)
            result.append(name)
        }
        return result
    }
    
    public func assets(at path: String = "") throws(AssetError) -> [Asset] {
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
