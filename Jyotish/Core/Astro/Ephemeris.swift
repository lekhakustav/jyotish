import Foundation

// Real geocentric astronomy per docs/03-ASTROLOGY-ENGINE.md.
// Sun: Meeus solar theory. Moon: truncated ELP (15 largest terms). Planets: JPL
// mean Keplerian elements. Sidereal via Lahiri ayanamsa. Pure math, no UI.

enum Rashi: Int, CaseIterable, Codable, Identifiable {
    case mesh, vrish, mithun, karkat, simha, kanya, tula, vrischik, dhanu, makar, kumbha, meen
    var id: Int { rawValue }
    /// Legacy monogram retained for text-only contexts; live UI uses path-drawn rashi marks.
    var glyph: String { ["मे", "वृ", "मि", "क", "सिं", "कन्", "तु", "वृश्", "ध", "म", "कु", "मी"][rawValue] }
    var symbolName: String {
        ["aries", "taurus", "gemini", "cancer", "leo", "virgo",
         "libra", "scorpio", "sagittarius", "capricorn", "aquarius", "pisces"][rawValue]
    }
    var nameEN: String { ["Mesh (Aries)", "Vrish (Taurus)", "Mithun (Gemini)", "Karkat (Cancer)", "Simha (Leo)", "Kanya (Virgo)", "Tula (Libra)", "Vrischik (Scorpio)", "Dhanu (Sagittarius)", "Makar (Capricorn)", "Kumbha (Aquarius)", "Meen (Pisces)"][rawValue] }
    var nameNE: String { ["मेष", "वृष", "मिथुन", "कर्कट", "सिंह", "कन्या", "तुला", "वृश्चिक", "धनु", "मकर", "कुम्भ", "मीन"][rawValue] }
    var shortEN: String { ["Mesh", "Vrish", "Mithun", "Karkat", "Simha", "Kanya", "Tula", "Vrischik", "Dhanu", "Makar", "Kumbha", "Meen"][rawValue] }
    var lord: Planet { [.mars, .venus, .mercury, .moon, .sun, .mercury, .venus, .mars, .jupiter, .saturn, .saturn, .jupiter][rawValue] }
}

enum Planet: Int, CaseIterable, Codable, Identifiable {
    case sun, moon, mars, mercury, jupiter, venus, saturn, rahu, ketu
    var id: Int { rawValue }
    var abbrev: String { ["Su", "Mo", "Ma", "Me", "Ju", "Ve", "Sa", "Ra", "Ke"][rawValue] }
    var nameEN: String { ["Surya", "Chandra", "Mangal", "Budha", "Brihaspati", "Shukra", "Shani", "Rahu", "Ketu"][rawValue] }
    var nameNE: String { ["सूर्य", "चन्द्र", "मंगल", "बुध", "बृहस्पति", "शुक्र", "शनि", "राहु", "केतु"][rawValue] }
}

enum Nakshatra: Int, CaseIterable, Codable {
    case ashwini, bharani, krittika, rohini, mrigashira, ardra, punarvasu, pushya, ashlesha,
         magha, purvaPhalguni, uttaraPhalguni, hasta, chitra, swati, vishakha, anuradha, jyeshtha,
         mula, purvaAshadha, uttaraAshadha, shravana, dhanishta, shatabhisha, purvaBhadrapada,
         uttaraBhadrapada, revati
    var nameEN: String {
        ["Ashwini", "Bharani", "Krittika", "Rohini", "Mrigashira", "Ardra", "Punarvasu", "Pushya",
         "Ashlesha", "Magha", "Purva Phalguni", "Uttara Phalguni", "Hasta", "Chitra", "Swati",
         "Vishakha", "Anuradha", "Jyeshtha", "Mula", "Purva Ashadha", "Uttara Ashadha", "Shravana",
         "Dhanishta", "Shatabhisha", "Purva Bhadrapada", "Uttara Bhadrapada", "Revati"][rawValue]
    }
    var nameNE: String {
        ["अश्विनी", "भरणी", "कृत्तिका", "रोहिणी", "मृगशिरा", "आर्द्रा", "पुनर्वसु", "पुष्य", "आश्लेषा",
         "मघा", "पूर्वफाल्गुनी", "उत्तरफाल्गुनी", "हस्त", "चित्रा", "स्वाति", "विशाखा", "अनुराधा", "ज्येष्ठा",
         "मूल", "पूर्वाषाढा", "उत्तराषाढा", "श्रवण", "धनिष्ठा", "शतभिषा", "पूर्वभाद्रपदा", "उत्तरभाद्रपदा", "रेवती"][rawValue]
    }
    /// Vimshottari lord: Ashwini starts with Ketu, cycle of 9.
    var lord: Planet {
        [Planet.ketu, .venus, .sun, .moon, .mars, .rahu, .jupiter, .saturn, .mercury][rawValue % 9]
    }
}

enum Ephemeris {
    static func deg2rad(_ d: Double) -> Double { d * .pi / 180 }
    static func norm360(_ d: Double) -> Double { var x = d.truncatingRemainder(dividingBy: 360); if x < 0 { x += 360 }; return x }

    /// Julian Day from UT calendar components (Meeus 7.1).
    static func julianDay(year: Int, month: Int, day: Int, hourUT: Double) -> Double {
        var y = Double(year), m = Double(month)
        if m <= 2 { y -= 1; m += 12 }
        let a = floor(y / 100)
        let b = 2 - a + floor(a / 4)
        return floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + Double(day) + b - 1524.5 + hourUT / 24
    }

    static func julianDay(_ date: Date) -> Double {
        // Date is an absolute instant; convert via UTC components.
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let c = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let hour = Double(c.hour!) + Double(c.minute!) / 60 + Double(c.second!) / 3600
        return julianDay(year: c.year!, month: c.month!, day: c.day!, hourUT: hour)
    }

    /// Lahiri (Chitrapaksha) ayanamsa, degrees.
    static func ayanamsa(jd: Double) -> Double {
        let t = (jd - 2451545.0) / 36525
        return 23.85236 + 1.39697 * t
    }

    /// Tropical geocentric solar longitude (degrees).
    static func sunTropical(jd: Double) -> Double {
        let t = (jd - 2451545.0) / 36525
        let l0 = 280.46646 + 36000.76983 * t + 0.0003032 * t * t
        let m = deg2rad(357.52911 + 35999.05029 * t - 0.0001537 * t * t)
        let c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * sin(m)
              + (0.019993 - 0.000101 * t) * sin(2 * m)
              + 0.000289 * sin(3 * m)
        return norm360(l0 + c)
    }

    /// Tropical geocentric lunar longitude (degrees), truncated ELP (Meeus ch.47).
    static func moonTropical(jd: Double) -> Double {
        let t = (jd - 2451545.0) / 36525
        let lp = 218.3164477 + 481267.88123421 * t - 0.0015786 * t * t
        let d = deg2rad(297.8501921 + 445267.1114034 * t - 0.0018819 * t * t)
        let m = deg2rad(357.5291092 + 35999.0502909 * t)
        let mp = deg2rad(134.9633964 + 477198.8675055 * t + 0.0087414 * t * t)
        let f = deg2rad(93.2720950 + 483202.0175233 * t - 0.0036539 * t * t)
        var lon = lp
        lon += 6.288774 * sin(mp)
        lon += 1.274027 * sin(2 * d - mp)
        lon += 0.658314 * sin(2 * d)
        lon += 0.213618 * sin(2 * mp)
        lon -= 0.185116 * sin(m)
        lon -= 0.114332 * sin(2 * f)
        lon += 0.058793 * sin(2 * d - 2 * mp)
        lon += 0.057066 * sin(2 * d - m - mp)
        lon += 0.053322 * sin(2 * d + mp)
        lon += 0.045758 * sin(2 * d - m)
        lon -= 0.040923 * sin(m - mp)
        lon -= 0.034720 * sin(d)
        lon -= 0.030383 * sin(m + mp)
        lon += 0.015327 * sin(2 * d - 2 * f)
        lon -= 0.012528 * sin(2 * f + mp)
        return norm360(lon)
    }

    /// Mean lunar ascending node (Rahu), tropical.
    static func rahuTropical(jd: Double) -> Double {
        let t = (jd - 2451545.0) / 36525
        return norm360(125.0445479 - 1934.1362891 * t + 0.0020754 * t * t)
    }

    // JPL approximate Keplerian elements, J2000 + rates per Julian century.
    // [a, e, I, L, longPeri, longNode] + rates
    private struct Kepler { let e0: [Double]; let rate: [Double] }
    private static let kepler: [Planet: Kepler] = [
        .mercury: Kepler(e0: [0.38709927, 0.20563593, 7.00497902, 252.25032350, 77.45779628, 48.33076593],
                         rate: [0.00000037, 0.00001906, -0.00594749, 149472.67411175, 0.16047689, -0.12534081]),
        .venus: Kepler(e0: [0.72333566, 0.00677672, 3.39467605, 181.97909950, 131.60246718, 76.67984255],
                       rate: [0.00000390, -0.00004107, -0.00078890, 58517.81538729, 0.00268329, -0.27769418]),
        .mars: Kepler(e0: [1.52371034, 0.09339410, 1.84969142, -4.55343205, -23.94362959, 49.55953891],
                      rate: [0.00001847, 0.00007882, -0.00813131, 19140.30268499, 0.44441088, -0.29257343]),
        .jupiter: Kepler(e0: [5.20288700, 0.04838624, 1.30439695, 34.39644051, 14.72847983, 100.47390909],
                         rate: [-0.00011607, -0.00013253, -0.00183714, 3034.74612775, 0.21252668, 0.20469106]),
        .saturn: Kepler(e0: [9.53667594, 0.05386179, 2.48599187, 49.95424423, 92.59887831, 113.66242448],
                        rate: [-0.00125060, -0.00050991, 0.00193609, 1222.49362201, -0.41897216, -0.28867794]),
    ]
    private static let earthKepler = Kepler(
        e0: [1.00000261, 0.01671123, -0.00001531, 100.46457166, 102.93768193, 0.0],
        rate: [0.00000562, -0.00004392, -0.01294668, 35999.37244981, 0.32327364, 0.0])

    /// Heliocentric ecliptic rectangular coords (AU) from Keplerian elements.
    private static func heliocentric(_ k: Kepler, t: Double) -> (x: Double, y: Double, z: Double) {
        let a = k.e0[0] + k.rate[0] * t
        let e = k.e0[1] + k.rate[1] * t
        let inc = deg2rad(k.e0[2] + k.rate[2] * t)
        let bigL = k.e0[3] + k.rate[3] * t
        let peri = k.e0[4] + k.rate[4] * t
        let node = k.e0[5] + k.rate[5] * t
        let m = deg2rad(norm360(bigL - peri))
        let w = deg2rad(peri - node)
        let omega = deg2rad(node)
        // Kepler's equation, Newton iteration.
        var eAnom = m + e * sin(m)
        for _ in 0..<8 {
            eAnom -= (eAnom - e * sin(eAnom) - m) / (1 - e * cos(eAnom))
        }
        let xp = a * (cos(eAnom) - e)
        let yp = a * sqrt(1 - e * e) * sin(eAnom)
        let x = (cos(w) * cos(omega) - sin(w) * sin(omega) * cos(inc)) * xp
              + (-sin(w) * cos(omega) - cos(w) * sin(omega) * cos(inc)) * yp
        let y = (cos(w) * sin(omega) + sin(w) * cos(omega) * cos(inc)) * xp
              + (-sin(w) * sin(omega) + cos(w) * cos(omega) * cos(inc)) * yp
        let z = sin(w) * sin(inc) * xp + cos(w) * sin(inc) * yp
        return (x, y, z)
    }

    /// Tropical geocentric longitude of a true planet (Mercury…Saturn).
    static func planetTropical(_ planet: Planet, jd: Double) -> Double {
        guard let k = kepler[planet] else { fatalError("not a Keplerian planet") }
        let t = (jd - 2451545.0) / 36525
        let p = heliocentric(k, t: t)
        let e = heliocentric(earthKepler, t: t)
        let gx = p.x - e.x, gy = p.y - e.y
        return norm360(atan2(gy, gx) * 180 / .pi)
    }

    /// Sidereal longitude for any graha.
    static func sidereal(_ planet: Planet, jd: Double) -> Double {
        let ayan = ayanamsa(jd: jd)
        let tropical: Double
        switch planet {
        case .sun: tropical = sunTropical(jd: jd)
        case .moon: tropical = moonTropical(jd: jd)
        case .rahu: tropical = rahuTropical(jd: jd)
        case .ketu: tropical = norm360(rahuTropical(jd: jd) + 180)
        default: tropical = planetTropical(planet, jd: jd)
        }
        return norm360(tropical - ayan)
    }

    /// Sidereal ascendant (lagna) longitude for time + place.
    static func ascendantSidereal(jd: Double, latitude: Double, longitudeEast: Double) -> Double {
        let t = (jd - 2451545.0) / 36525
        let gmst = norm360(280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * t * t)
        let ramc = deg2rad(norm360(gmst + longitudeEast))
        let eps = deg2rad(23.4392911 - 0.0130042 * t)
        let phi = deg2rad(latitude)
        let asc = atan2(cos(ramc), -(sin(ramc) * cos(eps) + tan(phi) * sin(eps))) * 180 / .pi
        return norm360(norm360(asc) - ayanamsa(jd: jd))
    }

    static func rashi(of longitude: Double) -> Rashi { Rashi(rawValue: Int(norm360(longitude) / 30))! }
    static func nakshatra(of longitude: Double) -> (nakshatra: Nakshatra, pada: Int, fractionElapsed: Double) {
        let span = 360.0 / 27.0
        let lon = norm360(longitude)
        let idx = min(26, Int(lon / span))
        let within = lon - Double(idx) * span
        return (Nakshatra(rawValue: idx)!, Int(within / (span / 4)) + 1, within / span)
    }
}
