import Foundation
import secp256k1
import CryptoSwift
import BigInt

public protocol PrivateChildKeyDerivating {
    func privateKey(privateParentKey: ExtendedKeyable, index: UInt32) throws -> ExtendedKeyable
}

public struct PrivateChildKeyDerivator {
    private static let keyLength = 32
    private static let keyPrefix = UInt8(0)

    public init() {}
}

// MARK: - PrivateChildKeyDerivating
extension PrivateChildKeyDerivator: PrivateChildKeyDerivating {
    public func privateKey(privateParentKey: ExtendedKeyable, index: UInt32) throws -> ExtendedKeyable {
        let keyBytes: [UInt8]
        if KeyIndexRange.hardened.contains(index) {
            keyBytes = Self.keyPrefix.bytes + privateParentKey.key.bytes
        } else {
            keyBytes = try secp256k1.serializedPoint(data: privateParentKey.key).bytes
        }

        let hmacSHA512 = HMAC(
            key: privateParentKey.chainCode.bytes,
            variant: .sha2(.sha512)
        )
        do {
            let bytes = keyBytes + index.bytes
            let hmacSHA512Bytes = try hmacSHA512.authenticate(bytes)
            let key = Data(hmacSHA512Bytes[HMACSHA512ByteRange.left])
            let chainCode = Data(hmacSHA512Bytes[HMACSHA512ByteRange.right])

            let bigIntegerKey = BigUInt(key)
            let bigIntegerParentKey = BigUInt(privateParentKey.key)
            let computedChildKey = (bigIntegerKey + bigIntegerParentKey) % .secp256k1CurveOrder
            guard !computedChildKey.isZero, bigIntegerKey < .secp256k1CurveOrder else {
                throw KeyDerivatorError.invalidKey
            }

            let serializedChildKey = computedChildKey.serialize()
            let privatekey: Data
            if serializedChildKey.count == Self.keyLength {
                privatekey = serializedChildKey
            } else {
                // Pad with leading zeros to make exactly 32 bytes (BIP32 compliant)
                let paddingCount = Self.keyLength - serializedChildKey.count
                let padding = Data(repeating: 0, count: paddingCount)
                privatekey = padding + serializedChildKey
            }

            return ExtendedKey(key: privatekey, chainCode: chainCode)
        } catch {
            throw KeyDerivatorError.invalidKey
        }
    }
}
