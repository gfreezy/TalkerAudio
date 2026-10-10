// Keep cancellation throwable even when a legacy/rethrows iterator advertises
// Failure == Never. The typed next(isolation:) default force-casts errors to
// Failure, so it can abort before the surrounding task group catches them.
func nextLegacyStreamElement<Iterator: AsyncIteratorProtocol>(
    _ iterator: inout Iterator
) async throws -> Iterator.Element? {
    try await iterator.next()
}
