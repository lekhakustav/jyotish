# Privacy Policy

**Jyotish baje (ज्योतिष बाजे)**
**Effective Date:** July 8, 2026
**Last Updated:** July 8, 2026

Sodhera ("**we**," "**us**," or "**our**") operates the Jyotish baje mobile application (the "**App**"). This Privacy Policy explains how we collect, use, store, share, and protect your information when you use the App. By using Jyotish baje, you agree to the practices described in this Privacy Policy.

We are committed to transparency and to safeguarding your personal data. Please read this Privacy Policy carefully. If you do not agree with any part of it, please do not use the App.

---

## 1. Information We Collect

### 1.1 Information You Provide Directly

When you use Jyotish baje, you may voluntarily provide the following information:

| Data Category | Specific Data | Purpose |
|---|---|---|
| **Personal Profile** | Full name, gender (male / female / other) | Identify you within the app and generate personalized astrological readings |
| **Birth Details** | Date of birth, time of birth (optional), birthplace (selected from a preset list of cities) | Compute your Vedic kundali (birth chart), dasha periods, panchanga, and rashifal |
| **Family Member Profiles** | Name, gender, family relation, date of birth, time of birth, birthplace — for each family member you add | Generate astrological readings for your family members |
| **Chat Messages** | Questions you type or dictate to "Pandit-ji" (the AI assistant), along with Pandit-ji's replies | Provide personalized astrological guidance; maintain conversational context |
| **Calendar Events** | Event titles, optional notes, Bikram Sambat dates, yearly-repeat preferences | Display your personal events on the Nepali patro (calendar) |
| **Preferences** | Language choice (English or Nepali), theme choice (light, dark, or system) | Customize your app experience |

### 1.2 Information Generated Automatically

| Data Category | Specific Data | Purpose |
|---|---|---|
| **Anonymous User ID** | A universally unique identifier (UUID) generated when you first open the App | Securely link your data to your account without requiring an email or phone number |
| **Authentication Tokens** | Session access token and refresh token | Maintain your signed-in session and sync data to the cloud |
| **Computed Astrological Data** | Kundali (lagna, moon rashi, sun rashi, moon nakshatra, planetary positions), dasha periods, rashifal text, personality readings | These are derived from your birth details using on-device Vedic astronomical calculations |

### 1.3 Information We Do NOT Collect

We want to be explicit about what Jyotish baje **does not** collect:

- ❌ **Email address** — not required for any feature
- ❌ **Phone number** — not required for any feature
- ❌ **Password** — authentication is anonymous; no password is created
- ❌ **GPS location or precise location data** — birthplace is selected from a preset list; we never access your device's location services
- ❌ **Photos or camera data** — the App does not access your camera or photo library
- ❌ **Contacts** — the App does not access your address book
- ❌ **Financial or payment information** — the App has no in-app purchases or subscriptions
- ❌ **Device identifiers or advertising IDs (IDFA)** — we do not collect or use any device advertising identifiers
- ❌ **Analytics or usage data** — we do not use any analytics SDKs, tracking pixels, or behavioral tracking tools
- ❌ **Browsing history** — the App does not track your activity outside the App
- ❌ **Health or biometric data** — voice input is processed entirely on your device (see Section 3)

---

## 2. How We Use Your Information

We use the information we collect for the following purposes:

1. **Astrological Computations:** Your birth details are used to compute your Vedic kundali, planetary positions, dasha cycles, panchanga, and rashifal — all calculated on your device using genuine sidereal astronomical algorithms.

2. **AI-Powered Guidance:** When you ask Pandit-ji a question, your query, relevant family birth data, computed kundali, current dasha, daily rashifal, saved calendar events, and recent chat history (up to the last 16 messages) are sent to our server-side backend to generate a personalized response.

3. **Family Astrology:** Family member profiles you add are used to generate kundalis and readings for your entire family, enabling family-centric astrological features.

4. **Calendar & Events:** Calendar events you create are stored to display personalized reminders on the Bikram Sambat calendar.

5. **Cloud Sync:** Your household data (profiles, family, events, chat history, and preferences) is synced to our cloud database so your data persists if you reinstall the App.

6. **Language & Theme:** Your preference choices are stored to deliver the App in your chosen language (English or Nepali) and visual theme.

We do **not** use your data for advertising, marketing, profiling, sale to third parties, or any purpose other than providing and improving the Jyotish baje experience.

---

## 3. Voice Input and Speech Recognition

Jyotish baje offers an optional voice input feature that lets you speak questions to Pandit-ji instead of typing.

- **Microphone Access:** When you tap the microphone button, the App requests your permission to access the device microphone. You may decline, and the App will continue to work with text input only.

- **On-Device Processing Only:** All speech recognition is performed **entirely on your device** using Apple's built-in Speech framework. **No audio recordings are sent to our servers, to any third party, or over the internet.** The audio is converted to text on your device, and only the resulting text is used.

- **Text-to-Speech:** Pandit-ji's replies can optionally be spoken aloud using your device's built-in text-to-speech engine (Apple AVSpeechSynthesizer). This is also fully on-device. This feature is off by default.

- **Supported Languages:** Voice recognition supports Nepali (ne-NP), Hindi (hi-IN), English India (en-IN), and English US (en-US).

---

## 4. Data Sharing with Third Parties

We share your data only with the following service providers, strictly for the purposes described below. **We never sell, rent, trade, or otherwise commercially transfer your personal information to any third party.**

### 4.1 OpenAI (AI Response Generation)

| Detail | Description |
|---|---|
| **What is shared** | Your chat question, family members' birth data and computed astrological data, your current dasha and daily rashifal, saved calendar events, and recent chat history (up to 16 messages) |
| **Why** | To generate Pandit-ji's personalized astrological responses |
| **How** | Data is sent **from our server-side backend only** — never directly from your device. The OpenAI API key never leaves the server. |
| **OpenAI's data policy** | OpenAI processes data per their [API Data Usage Policy](https://openai.com/policies/api-data-usage-policies). As of our last review, OpenAI does not use API inputs/outputs to train its models. |

### 4.2 Supabase (Cloud Infrastructure)

| Detail | Description |
|---|---|
| **What is shared** | Your entire household data (profiles, family members, calendar events, chat history, and preferences), along with your anonymous user ID and authentication tokens |
| **Why** | To provide cloud storage, data synchronization, anonymous authentication, and to host the server-side backend (Edge Functions) |
| **How** | Data is transmitted over HTTPS (TLS encryption in transit). Data is stored in a PostgreSQL database protected by Row Level Security (RLS) — each user can only access their own data. |
| **Supabase's data policy** | Supabase processes data per their [Privacy Policy](https://supabase.com/privacy). |

### 4.3 No Other Third Parties

We do **not** integrate any of the following:
- Advertising networks or ad mediation platforms
- Analytics or crash reporting SDKs (e.g., Firebase Analytics, Crashlytics, Amplitude, Mixpanel)
- Social media SDKs (e.g., Facebook SDK, Google Sign-In)
- Attribution or tracking services
- Data brokers

---

## 5. Data Storage and Security

### 5.1 On-Device Storage

- Your household data (profiles, family members, kundalis, events, chat history, preferences) is stored locally on your device in a JSON file within the App's sandboxed Documents directory.
- Authentication session tokens are stored in the device's standard user defaults storage.
- Cached network responses are stored in an on-device URL cache (up to 64 MB in memory, 256 MB on disk).

### 5.2 Cloud Storage

- Your household data is synced to a Supabase-hosted PostgreSQL database as a single JSON payload.
- All data is associated with your anonymous user ID and protected by Row Level Security (RLS) policies — meaning only your authenticated session can read or modify your data.
- Data is encrypted in transit using HTTPS / TLS.
- Supabase's infrastructure uses encryption at rest for stored data.

### 5.3 API Key Security

- The OpenAI API key is stored exclusively on the server side (Supabase Edge Function environment). It is **never** included in the iOS app binary, configuration files, build settings, or transmitted to your device.

### 5.4 Security Measures

We implement the following security measures:
- **TLS encryption** for all data in transit between the App and our servers
- **Row Level Security (RLS)** ensuring data isolation between users at the database level
- **Anonymous authentication** minimizing the personal data footprint
- **Server-side API key management** preventing exposure of sensitive credentials
- **JWT verification** on production endpoints to prevent unauthorized access

While we take reasonable measures to protect your data, no method of electronic transmission or storage is 100% secure. We cannot guarantee absolute security.

### 5.5 Data Breach Notification

In the event of a data breach that poses a high risk to your rights and freedoms, we will:

1. Notify affected users without undue delay and, where feasible, within 72 hours of becoming aware of the breach
2. Describe the nature of the breach and the categories of data affected
3. Provide contact details for obtaining further information
4. Describe the measures taken or proposed to address the breach
5. Report the breach to the relevant supervisory authority where required by applicable law (including GDPR Article 33)

---

## 6. Data Retention

- **On-Device Data:** Your data remains on your device until you sign out (which clears all local data) or uninstall the App.

- **Cloud Data:** Your cloud-stored household data is retained as long as your anonymous account exists. If you sign out, local data is erased but cloud data remains associated with your anonymous user ID. Since accounts are anonymous and cannot be re-authenticated after sign-out, orphaned cloud data may persist until we perform periodic cleanup.

- **Chat History with OpenAI:** We do not independently store chat data on our servers beyond the Supabase database. Data sent to OpenAI for processing is handled per OpenAI's data retention policies — as of our last review, OpenAI retains API data for up to 30 days for abuse monitoring, then deletes it.

- **Account Deletion:** To request deletion of your cloud data, please contact us at **privacy@sodhera.com**. We will process deletion requests within 30 days.

---

## 7. Your Rights

Depending on your jurisdiction, you may have the following rights regarding your personal data:

### 7.1 All Users

- **Access:** You can view all your data within the App at any time (profiles, family, events, chat history, preferences).
- **Correction:** You can edit your personal and family member profiles directly in the App.
- **Deletion (Local):** You can sign out of the App, which erases all local data from your device.
- **Deletion (Cloud):** You can request deletion of your cloud-stored data by contacting us at **privacy@sodhera.com**.
- **Withdraw Consent:** You can revoke microphone and speech recognition permissions at any time through your device's Settings → Jyotish baje.

### 7.2 European Economic Area (EEA), UK, and Switzerland Residents

If you are located in the EEA, UK, or Switzerland, you have additional rights under the General Data Protection Regulation (GDPR) or equivalent laws:

- **Right to Access** your personal data
- **Right to Rectification** of inaccurate data
- **Right to Erasure** ("right to be forgotten")
- **Right to Restrict Processing**
- **Right to Data Portability** — receive your data in a structured, commonly used format
- **Right to Object** to processing of your personal data
- **Right to Lodge a Complaint** with your local data protection authority

**Automated Decision-Making (GDPR Article 22):** Jyotish baje generates astrological readings and AI responses through automated processing. However, these outputs are provided for informational, cultural, spiritual, and entertainment purposes only and do not produce legal or similarly significant effects on you. You are never obligated to act on any automated output. If you have concerns about automated processing, please contact us at **privacy@sodhera.com**.

**Legal Basis for Processing:** We process your data based on:
- **Performance of a contract** — to provide the Jyotish baje service you use
- **Legitimate interests** — to improve and secure the App
- **Consent** — for optional features like voice input (which you can withdraw at any time)

### 7.3 California Residents (CCPA / CPRA)

If you are a California resident, you have rights under the California Consumer Privacy Act (CCPA) and California Privacy Rights Act (CPRA):

- **Right to Know** what personal information we collect, use, and share
- **Right to Delete** your personal information
- **Right to Opt-Out of Sale** — we do **not** sell your personal information
- **Right to Non-Discrimination** for exercising your privacy rights

To exercise any of these rights, contact us at **privacy@sodhera.com**.

### 7.4 Nepal Residents

If you are located in Nepal, your personal data is protected under Nepal’s Individual Privacy Act, 2075 (2018) and the Privacy Act, 2075. These laws establish your right to privacy and impose obligations on data controllers. We process your data in accordance with these laws. You may exercise your rights under Nepali law by contacting us at **privacy@sodhera.com**.

### 7.5 Data Portability

You can view all your personal data at any time within the App (profiles, family, events, chat history, preferences). To receive a machine-readable export of your data, contact us at **privacy@sodhera.com** and we will provide your data in JSON format within 30 days.

---

## 8. Children's Privacy

Jyotish baje is not directed at children under the age of 13 (or the applicable age in your jurisdiction). We do not knowingly collect personal information from children under 13. If you believe that a child under 13 has provided us with personal data, please contact us at **privacy@sodhera.com**, and we will take steps to delete such information promptly.

---

## 9. International Data Transfers

Your data may be transferred to and processed in countries other than your country of residence, including the United States (where OpenAI and Supabase infrastructure may be located). These countries may have data protection laws that differ from your jurisdiction.

When we transfer data internationally, we take steps to ensure that appropriate safeguards are in place, including:
- Using service providers that maintain robust data protection practices
- Relying on standard contractual clauses or other approved transfer mechanisms where required by law

---

## 10. Third-Party Links and Services

The App may display references to external content (such as temple information). If you navigate to any third-party website or service, that entity's own privacy policy governs the collection and use of your data. We are not responsible for the privacy practices of third parties.

---

## 11. Changes to This Privacy Policy

We may update this Privacy Policy from time to time to reflect changes in our practices, technology, legal requirements, or other factors. When we make material changes, we will:

1. Update the "Last Updated" date at the top of this policy
2. Notify you through the App or by other appropriate means

We encourage you to review this Privacy Policy periodically. Your continued use of the App after any changes constitutes acceptance of the updated policy.

---

## 12. Contact Us

If you have questions, concerns, or requests regarding this Privacy Policy or your personal data, please contact us:

- **Email:** privacy@sodhera.com
- **Developer:** Sodhera
- **App:** Jyotish baje (com.sodhera.jyotish)

We aim to respond to all inquiries within 30 days.

---

## 13. Apple App Store Privacy Disclosure Summary

The following summary aligns with Apple's App Store privacy label requirements:

### Data Used to Track You
- **None.** We do not track you across other companies' apps or websites.

### Data Linked to You
| Data Type | Purpose |
|---|---|
| Name | App Functionality |
| Other User Content (birth details, family profiles, chat messages, calendar events) | App Functionality |
| User ID (anonymous) | App Functionality |

### Data Not Linked to You
- **None.** All collected data is linked to your anonymous identity within the App.

### Data Not Collected
- Contact Info (email, phone, physical address)
- Health & Fitness
- Financial Info
- Location
- Sensitive Info
- Contacts
- Browsing History
- Search History
- Identifiers (device ID, advertising ID)
- Purchases
- Diagnostics
- Photos or Videos

---

*This Privacy Policy is governed by the laws of Nepal, without regard to conflict of law principles.*
