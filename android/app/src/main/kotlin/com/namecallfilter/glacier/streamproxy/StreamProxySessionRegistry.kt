package com.namecallfilter.glacier.streamproxy

import java.util.concurrent.ConcurrentHashMap

object StreamProxySessionRegistry {
    private val routers = ConcurrentHashMap<Long, StreamProxyRequestRouter>()
    private val clients = ConcurrentHashMap<Long, StreamProxyWebViewClient>()

    fun routerFor(webViewIdentifier: Long): StreamProxyRequestRouter? {
        return routers[webViewIdentifier]
    }

    fun getOrCreateRouter(webViewIdentifier: Long): StreamProxyRequestRouter {
        return routers.getOrPut(webViewIdentifier) {
            StreamProxyRequestRouter()
        }
    }

    fun clientFor(webViewIdentifier: Long): StreamProxyWebViewClient? {
        return clients[webViewIdentifier]
    }

    fun putClient(
        webViewIdentifier: Long,
        client: StreamProxyWebViewClient,
    ) {
        clients[webViewIdentifier] = client
    }

    fun removeClient(webViewIdentifier: Long): StreamProxyWebViewClient? {
        return clients.remove(webViewIdentifier)
    }

    fun removeRouter(webViewIdentifier: Long) {
        routers.remove(webViewIdentifier)
    }

    fun updateAllClients(config: StreamProxyConfig) {
        clients.values.forEach { client ->
            client.updateConfig(config)
        }
    }
}
