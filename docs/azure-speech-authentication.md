# Azure Speech credentials

`AzureStreamSynthesizerEngine` supports both subscription keys and short-lived
authorization tokens. The existing initializer remains available:

```swift
let engine = AzureStreamSynthesizerEngine(
    voiceId: voiceID, style: style, role: role,
    sub: subscriptionKey, region: region
)
```

For applications that obtain credentials from their backend, share
one token provider across engines:

```swift
let provider = AzureSpeechTokenProvider {
    let response = try await fetchSpeechTokenFromBackend()
    return AzureSpeechToken(
        token: response.token,
        region: response.region,
        expiresAt: response.expiresAt
    )
}

let engine = AzureStreamSynthesizerEngine(
    voiceId: voiceID, style: style, role: role,
    tokenProvider: provider
)
```

The provider caches credentials and coalesces concurrent requests. Before each
utterance, the engine obtains a credential from the provider, which reloads it
when it has at most one minute left. The engine updates the live SDK
`authorizationToken` so that its existing connection can be reused. If the region
changes, it creates an SDK configuration for the new region.

Refresh failures propagate to the caller; an expiring credential is not used as a
fallback. The backend must return a fresh credential with more than one minute of
validity. An explicit `try await provider.token(forceRefresh: true)` refreshes the
cache immediately; the engine applies it before the next utterance.

For a backend response containing `expiresInSeconds`, calculate `expiresAt` from
the time the request started to account conservatively for network latency. Keep
subscription keys on the backend and never log returned credentials.
