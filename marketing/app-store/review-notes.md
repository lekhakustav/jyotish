# App Review notes (Apple App Review / Google Play pre-launch notes)

Hello Review Team,

Jyotish Baje's primary experience is private Kundli sharing for Nepali Hindu families. The app
now opens directly to **My Kundli & QR**, where a user can keep their own Kundli, generate a QR
containing their name and birth details, and share it intentionally with a person they trust.
The receiver scans the QR, selects the real-world relationship and saves the profile to their
own private household without re-entering sensitive birth information.

The previous Home experience is now a separate **Religious** tab. It contains Nepal-specific
Bikram Sambat dates, Tithi, festivals, Temple of the Day, Rashifal, Patro and traditional Jyotish
guidance. This hierarchy makes the private Kundli exchange the primary product workflow rather
than presenting the app as a generic horoscope reader.

Suggested review path:

1. Open **My Kundli & QR**. This is the default first tab.
2. Tap **Share My Kundli** to view the private QR and the exact disclosure of what it contains.
3. From another device or the paste fallback, open **Scan Kundli QR**.
4. Scan the code, choose a relationship and add the profile.
5. Open a saved person to view the Kundli generated from the shared birth profile.
6. Open **Religious** to view Nepal-specific religious dates and guidance as supporting context.

Privacy boundary: the v1 QR includes the sharer's name and birth details. It does not include a
calculated Kundli, relationship label, chat history, account credentials or analytics identifier.
The app does not claim that the exchange creates a permanent mutual social connection.

Sign-in and demo account: the app requires an account (Sign in with Apple, Google, or email and
password). A working demo account **must** be entered in App Review Information before
submission:

- Email: `<fill in before submitting — create a dedicated review account>`
- Password: `<fill in before submitting>`

Permissions: camera is requested only when the user opens **Scan Kundli QR** and is used solely
for live QR detection — no photo or video is captured or stored. Microphone and speech
recognition are requested only when the user taps the voice-input button.

We respectfully ask that this private, culturally specific Kundli-sharing workflow be evaluated
as the app's primary experience under Guideline 4.3(b).
