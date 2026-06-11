package com.namecallfilter.glacier.streamproxy

import java.net.Inet4Address
import java.net.InetAddress
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class CastRelayLanAddressSelectorTest {
    @Test
    fun selectsWifiLanAddressBeforeCellularAddress() {
        val selected = CastRelayLanAddressSelector.select(
            listOf(
                candidate("rmnet_data0", "mobile", "192.0.0.4"),
                candidate("wlan0", "wlan0", "192.168.5.145"),
            ),
        )

        assertEquals("192.168.5.145", selected?.address?.hostAddress)
    }

    @Test
    fun selectsPrivateLanAddressBeforePublicAddress() {
        val selected = CastRelayLanAddressSelector.select(
            listOf(
                candidate("unknown0", "unknown0", "192.0.0.4"),
                candidate("unknown1", "unknown1", "10.0.0.22"),
            ),
        )

        assertEquals("10.0.0.22", selected?.address?.hostAddress)
    }

    @Test
    fun ignoresUnusableAddresses() {
        val selected = CastRelayLanAddressSelector.select(
            listOf(
                candidate("lo", "lo", "127.0.0.1"),
                candidate("wlan0", "wlan0", "169.254.1.1"),
                candidate("wlan0", "wlan0", "0.0.0.0"),
            ),
        )

        assertNull(selected)
    }

    private fun candidate(
        interfaceName: String,
        displayName: String,
        address: String,
    ): CastRelayLanAddressSelector.Candidate {
        return CastRelayLanAddressSelector.Candidate(
            interfaceName = interfaceName,
            displayName = displayName,
            address = InetAddress.getByName(address) as Inet4Address,
        )
    }
}
