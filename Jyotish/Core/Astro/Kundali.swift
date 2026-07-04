import Foundation

/// Birth details — the input to everything.
struct BirthData: Codable, Equatable {
    var year: Int, month: Int, day: Int      // Gregorian civil date at birthplace
    var hour: Int, minute: Int               // local time
    var timeKnown: Bool
    var place: BirthPlace

    /// Julian day of the birth instant (UT).
    var julianDay: Double {
        let localHour = Double(hour) + Double(minute) / 60
        let ut = localHour - place.utcOffsetHours
        return Ephemeris.julianDay(year: year, month: month, day: day, hourUT: ut)
    }
}

struct BirthPlace: Codable, Equatable, Hashable {
    var name: String
    var nameNE: String
    var latitude: Double
    var longitude: Double
    var utcOffsetHours: Double

    static let kathmandu = BirthPlace(name: "Kathmandu", nameNE: "काठमाडौं", latitude: 27.7172, longitude: 85.3240, utcOffsetHours: 5.75)

    static let presets: [BirthPlace] = [
        .kathmandu,
        BirthPlace(name: "Pokhara", nameNE: "पोखरा", latitude: 28.2096, longitude: 83.9856, utcOffsetHours: 5.75),
        BirthPlace(name: "Lalitpur", nameNE: "ललितपुर", latitude: 27.6588, longitude: 85.3247, utcOffsetHours: 5.75),
        BirthPlace(name: "Bhaktapur", nameNE: "भक्तपुर", latitude: 27.6710, longitude: 85.4298, utcOffsetHours: 5.75),
        BirthPlace(name: "Biratnagar", nameNE: "विराटनगर", latitude: 26.4525, longitude: 87.2718, utcOffsetHours: 5.75),
        BirthPlace(name: "Birgunj", nameNE: "वीरगन्ज", latitude: 27.0104, longitude: 84.8770, utcOffsetHours: 5.75),
        BirthPlace(name: "Bharatpur", nameNE: "भरतपुर", latitude: 27.6833, longitude: 84.4333, utcOffsetHours: 5.75),
        BirthPlace(name: "Butwal", nameNE: "बुटवल", latitude: 27.7006, longitude: 83.4484, utcOffsetHours: 5.75),
        BirthPlace(name: "Dharan", nameNE: "धरान", latitude: 26.8065, longitude: 87.2846, utcOffsetHours: 5.75),
        BirthPlace(name: "Hetauda", nameNE: "हेटौंडा", latitude: 27.4287, longitude: 85.0322, utcOffsetHours: 5.75),
        BirthPlace(name: "Janakpur", nameNE: "जनकपुर", latitude: 26.7288, longitude: 85.9263, utcOffsetHours: 5.75),
        BirthPlace(name: "Nepalgunj", nameNE: "नेपालगन्ज", latitude: 28.0500, longitude: 81.6167, utcOffsetHours: 5.75),
        BirthPlace(name: "Dhangadhi", nameNE: "धनगढी", latitude: 28.6833, longitude: 80.6000, utcOffsetHours: 5.75),
        BirthPlace(name: "Ilam", nameNE: "इलाम", latitude: 26.9094, longitude: 87.9282, utcOffsetHours: 5.75),
        BirthPlace(name: "Gorkha", nameNE: "गोरखा", latitude: 28.0000, longitude: 84.6333, utcOffsetHours: 5.75),
        BirthPlace(name: "Jumla", nameNE: "जुम्ला", latitude: 29.2742, longitude: 82.1838, utcOffsetHours: 5.75),
        BirthPlace(name: "Delhi, India", nameNE: "दिल्ली, भारत", latitude: 28.6139, longitude: 77.2090, utcOffsetHours: 5.5),
        BirthPlace(name: "Kolkata, India", nameNE: "कोलकाता, भारत", latitude: 22.5726, longitude: 88.3639, utcOffsetHours: 5.5),
        BirthPlace(name: "Sikkim, India", nameNE: "सिक्किम, भारत", latitude: 27.3389, longitude: 88.6065, utcOffsetHours: 5.5),
        BirthPlace(name: "London, UK", nameNE: "लन्डन, बेलायत", latitude: 51.5074, longitude: -0.1278, utcOffsetHours: 0),
        BirthPlace(name: "New York, USA", nameNE: "न्यूयोर्क, अमेरिका", latitude: 40.7128, longitude: -74.0060, utcOffsetHours: -5),
        BirthPlace(name: "Sydney, Australia", nameNE: "सिड्नी, अस्ट्रेलिया", latitude: -33.8688, longitude: 151.2093, utcOffsetHours: 10),
    ]
}

/// The computed natal chart.
struct Kundali: Codable, Equatable {
    var longitudes: [Int: Double]   // Planet.rawValue → sidereal longitude
    var lagna: Rashi
    var moonRashi: Rashi
    var sunRashi: Rashi
    var moonNakshatraIndex: Int
    var moonNakshatraPada: Int
    var moonNakshatraFraction: Double  // elapsed fraction — seeds the dasha balance
    var birthJD: Double

    var moonNakshatra: Nakshatra { Nakshatra(rawValue: moonNakshatraIndex)! }

    static func compute(from birth: BirthData) -> Kundali {
        let jd = birth.julianDay
        var lons: [Int: Double] = [:]
        for planet in Planet.allCases {
            lons[planet.rawValue] = Ephemeris.sidereal(planet, jd: jd)
        }
        let asc = Ephemeris.ascendantSidereal(jd: jd, latitude: birth.place.latitude, longitudeEast: birth.place.longitude)
        let moon = lons[Planet.moon.rawValue]!
        let nak = Ephemeris.nakshatra(of: moon)
        return Kundali(longitudes: lons,
                       lagna: Ephemeris.rashi(of: asc),
                       moonRashi: Ephemeris.rashi(of: moon),
                       sunRashi: Ephemeris.rashi(of: lons[Planet.sun.rawValue]!),
                       moonNakshatraIndex: nak.nakshatra.rawValue,
                       moonNakshatraPada: nak.pada,
                       moonNakshatraFraction: nak.fractionElapsed,
                       birthJD: jd)
    }

    func rashi(of planet: Planet) -> Rashi { Ephemeris.rashi(of: longitudes[planet.rawValue] ?? 0) }

    /// Whole-sign house (0-based) of a planet, counted from lagna.
    func house(of planet: Planet) -> Int {
        (rashi(of: planet).rawValue - lagna.rawValue + 12) % 12
    }

    func planetsInHouse(_ house: Int) -> [Planet] {
        Planet.allCases.filter { self.house(of: $0) == house }
    }
}
