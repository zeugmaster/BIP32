import Foundation
import CryptoSwift
import BigInt

public protocol PrivateMasterKeyGenerating {
    func privateMasterKey(seed: Data) throws -> ExtendedKeyable
}

public struct PrivateMasterKeyGenerator {
    private static let hmacSHA512Key = "Bitcoin seed"

    public init() {}
}

// MARK: - PrivateMasterKeyGenerating
extension PrivateMasterKeyGenerator: PrivateMasterKeyGenerating {
    public func privateMasterKey(seed: Data) throws -> ExtendedKeyable {
        let hmacSHA512 = HMAC(
            key: Self.hmacSHA512Key.bytes,
            variant: .sha2(.sha512)
        )
        do {
            let hmacSHA512Bytes = try hmacSHA512.authenticate(seed.bytes)
            let key = Data(hmacSHA512Bytes[HMACSHA512ByteRange.left])
            let chainCode = Data(hmacSHA512Bytes[HMACSHA512ByteRange.right])

            let base256Key = BigUInt(key)
            guard !base256Key.isZero, base256Key < .secp256k1CurveOrder else {
                throw KeyError.invalidKey
            }

            return ExtendedKey(
                key: base256Key.serialize(),
                chainCode: chainCode
            )
        } catch {
            throw KeyError.invalidKey
        }
    }
}
