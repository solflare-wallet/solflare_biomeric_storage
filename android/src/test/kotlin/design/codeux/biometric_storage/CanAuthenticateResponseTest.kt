package design.codeux.biometric_storage

import org.junit.Assert.assertEquals
import org.junit.Test

/**
 * `BiometricManager.canAuthenticate()` returns an int status code. Before this test existed,
 * [CanAuthenticateResponse.fromCode] threw for every code the enum did not declare, and
 * Android 16 (API 36) added two new codes.
 *
 * https://github.com/authpass/biometric_storage/issues/148
 */
class CanAuthenticateResponseTest {

    @Test
    fun `maps every declared status code`() {
        val expected = mapOf(
            0 to CanAuthenticateResponse.Success,
            1 to CanAuthenticateResponse.ErrorHwUnavailable,
            11 to CanAuthenticateResponse.ErrorNoBiometricEnrolled,
            12 to CanAuthenticateResponse.ErrorNoHardware,
            7 to CanAuthenticateResponse.ErrorLockout,
            15 to CanAuthenticateResponse.ErrorSecurityUpdateRequired,
            -2 to CanAuthenticateResponse.ErrorUnsupported,
            -1 to CanAuthenticateResponse.ErrorStatusUnknown,
            -99 to CanAuthenticateResponse.ErrorPasscodeNotSet,
            20 to CanAuthenticateResponse.ErrorIdentityCheckNotActive,
            21 to CanAuthenticateResponse.ErrorNotEnabledForApps,
        )

        expected.forEach { (code, response) ->
            assertEquals("code $code", response, CanAuthenticateResponse.fromCode(code))
        }
    }

    /**
     * Android 16 returns `BIOMETRIC_ERROR_NOT_ENABLED_FOR_APPS` when the user turns off
     * biometric verification for apps. That code crashed the capability check.
     */
    @Test
    fun `maps BIOMETRIC_ERROR_NOT_ENABLED_FOR_APPS`() {
        assertEquals(
            CanAuthenticateResponse.ErrorNotEnabledForApps,
            CanAuthenticateResponse.fromCode(21),
        )
    }

    /**
     * `BiometricManager` does not declare a lockout code, but `canAuthenticate()` can still
     * return the sensor error code 7. androidx 1.4.0 converts it, which shows it does occur.
     */
    @Test
    fun `maps the sensor lockout code`() {
        assertEquals(CanAuthenticateResponse.ErrorLockout, CanAuthenticateResponse.fromCode(7))
    }

    @Test
    fun `an undeclared status code does not throw`() {
        listOf(22, 99, Int.MAX_VALUE, Int.MIN_VALUE).forEach { code ->
            assertEquals(
                "code $code",
                CanAuthenticateResponse.ErrorStatusUnknown,
                CanAuthenticateResponse.fromCode(code),
            )
        }
    }

    @Test
    fun `every enum value maps back to itself`() {
        CanAuthenticateResponse.values().forEach { response ->
            assertEquals(response, CanAuthenticateResponse.fromCode(response.code))
        }
    }

    @Test
    fun `status codes are unique`() {
        val codes = CanAuthenticateResponse.values().map { it.code }
        assertEquals(codes.size, codes.toSet().size)
    }
}
