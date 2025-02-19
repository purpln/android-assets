import Android
import ndk.asset_manager

public func asset(from assetManager: OpaquePointer, named name: String) -> String? {
    let file: OpaquePointer = AAssetManager_open(assetManager, name, CInt(AASSET_MODE_BUFFER))
    let length: Int64 = AAsset_getLength(file)
    let capacity = Int(length)
    guard let buffer: UnsafeMutableRawPointer = malloc(capacity) else { return nil }
    memcpy(buffer, AAsset_getBuffer(file), capacity)
    
    let pointer = buffer.assumingMemoryBound(to: UInt8.self)
    
    defer {
        free(buffer)
    }
    
    return String(decoding: UnsafeMutableBufferPointer(start: pointer, count: capacity), as: UTF8.self)
}
