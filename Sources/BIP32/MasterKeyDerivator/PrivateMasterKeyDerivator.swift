import Foundation
import CryptoSwift
import BigInt

public protocol PrivateMasterKeyDerivating {
    func privateKey(seed: Data) throws -> ExtendedKeyable
}

public struct PrivateMasterKeyDerivator {
    private static let hmacSHA512Key = "Bitcoin seed"
    private static let keyLength = 32
    private static let keyPrefix = UInt8(0)

    public init() {}
}

// MARK: - PrivateMasterKeyDerivating
extension PrivateMasterKeyDerivator: PrivateMasterKeyDerivating {
    public func privateKey(seed: Data) throws -> ExtendedKeyable {
        let hmacSHA512 = HMAC(key: Self.hmacSHA512Key.bytes, variant: .sha2(.sha512))
        do {
            let hmacSHA512Bytes = try hmacSHA512.authenticate(seed.bytes)
            let key = Data(hmacSHA512Bytes[HMACSHA512ByteRange.left])
            let chainCode = Data(hmacSHA512Bytes[HMACSHA512ByteRange.right])

            let bigIntegerKey = BigUInt(key)
            guard !bigIntegerKey.isZero, bigIntegerKey < .secp256k1CurveOrder else {
                throw KeyDerivatorError.invalidKey
            }
            let serializedBigIntegerKey = bigIntegerKey.serialize()
            let privatekey: Data
            if serializedBigIntegerKey.count == Self.keyLength {
                privatekey = serializedBigIntegerKey
            } else {
                // Pad with leading zeros to make exactly 32 bytes (BIP32 compliant)
                let paddingCount = Self.keyLength - serializedBigIntegerKey.count
                let padding = Data(repeating: 0, count: paddingCount)
                privatekey = padding + serializedBigIntegerKey
            }

            return ExtendedKey(key: privatekey, chainCode: chainCode)
        } catch {
            throw KeyDerivatorError.invalidKey
        }
    }
}
