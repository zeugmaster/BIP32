import Base58Check

public protocol KeyEncoding {
    func encode(serializedKey: SerializedKeyable) -> String
}

public protocol KeyDecoding {
    func decode(string: String) throws -> SerializedKeyable
}

public struct KeyCoder {
    private let base58Check: Base58CheckCoding

    public init(base58Check: Base58CheckCoding = Base58Check()) {
        self.base58Check = base58Check
    }
}

// MARK: - KeyEncoding
extension KeyCoder: KeyEncoding {
    public func encode(serializedKey: SerializedKeyable) -> String {
        base58Check.encode(data: serializedKey.data)
    }
}

// MARK: - KeyDecoding
extension KeyCoder: KeyDecoding {
    public func decode(string: String) throws -> SerializedKeyable {
        do {
            let decodedData = try base58Check.decode(string: string)
            return try SerializedKey(data: decodedData)
        } catch {
            throw KeyDecodingError.invalidDecoding
        }
    }
}
