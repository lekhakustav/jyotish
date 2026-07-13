import Foundation

struct PanchangaWindow: Equatable {
    var start: Date
    var end: Date
}

struct PanchangaDayDetails: Equatable {
    var sunrise: Date
    var sunset: Date
    var moonrise: Date
    var moonset: Date
    var rahuKaal: PanchangaWindow
    var gulikaKaal: PanchangaWindow
    var yamaganda: PanchangaWindow
    var abhijitMuhurat: PanchangaWindow
    var observances: [String]
    var moonTimesAreApproximate: Bool
}

/// Location-aware civil-day utilities around the existing Panchanga engine.
/// Solar rise/set uses the NOAA fractional-year approximation. Rahu Kaal,
/// Gulika, Yamaganda and Abhijit divide the actual sunrise-to-sunset interval.
/// The current ephemeris does not include lunar latitude, so Moon rise/set is
/// explicitly marked approximate rather than presented as almanac-grade data.
enum PanchangaDayCalculator {
    static func details(for date: Date,
                        place: BirthPlace = .kathmandu,
                        language: Language = .en) -> PanchangaDayDetails {
        let calendar = localCalendar(place)
        let day = calendar.startOfDay(for: date)
        let solar = solarTimes(for: day, place: place, calendar: calendar)
        let weekday = calendar.component(.weekday, from: day)
        let rahu = daylightSegment(index: rahuSegment[weekday - 1], sunrise: solar.sunrise, sunset: solar.sunset)
        let gulika = daylightSegment(index: gulikaSegment[weekday - 1], sunrise: solar.sunrise, sunset: solar.sunset)
        let yama = daylightSegment(index: yamagandaSegment[weekday - 1], sunrise: solar.sunrise, sunset: solar.sunset)
        let daylight = solar.sunset.timeIntervalSince(solar.sunrise)
        let noon = solar.sunrise.addingTimeInterval(daylight / 2)
        let abhijitHalf = daylight / 30
        let abhijit = PanchangaWindow(start: noon.addingTimeInterval(-abhijitHalf),
                                      end: noon.addingTimeInterval(abhijitHalf))
        let moon = approximateMoonTimes(for: day, sunrise: solar.sunrise, place: place, calendar: calendar)
        let pan = Panchanga.forDay(day, place: place, calendar: calendar)
        return PanchangaDayDetails(sunrise: solar.sunrise, sunset: solar.sunset,
                                   moonrise: moon.rise, moonset: moon.set,
                                   rahuKaal: rahu, gulikaKaal: gulika,
                                   yamaganda: yama, abhijitMuhurat: abhijit,
                                   observances: observances(for: pan, language: language),
                                   moonTimesAreApproximate: true)
    }

    /// Segment numbers are 1...8 from sunrise, indexed Sunday...Saturday.
    private static let rahuSegment = [8, 2, 7, 5, 6, 4, 3]
    private static let gulikaSegment = [7, 6, 5, 4, 3, 2, 1]
    private static let yamagandaSegment = [5, 4, 3, 2, 1, 7, 6]

    private static func daylightSegment(index: Int, sunrise: Date, sunset: Date) -> PanchangaWindow {
        let segment = sunset.timeIntervalSince(sunrise) / 8
        return PanchangaWindow(start: sunrise.addingTimeInterval(segment * Double(index - 1)),
                               end: sunrise.addingTimeInterval(segment * Double(index)))
    }

    private static func solarTimes(for day: Date,
                                   place: BirthPlace,
                                   calendar: Calendar) -> (sunrise: Date, sunset: Date) {
        let ordinal = max(1, calendar.ordinality(of: .day, in: .year, for: day) ?? 1)
        let gamma = 2 * Double.pi / 365 * (Double(ordinal) - 1)
        let equation = 229.18 * (0.000075
            + 0.001868 * cos(gamma) - 0.032077 * sin(gamma)
            - 0.014615 * cos(2 * gamma) - 0.040849 * sin(2 * gamma))
        let declination = 0.006918 - 0.399912 * cos(gamma) + 0.070257 * sin(gamma)
            - 0.006758 * cos(2 * gamma) + 0.000907 * sin(2 * gamma)
            - 0.002697 * cos(3 * gamma) + 0.00148 * sin(3 * gamma)
        let latitude = Ephemeris.deg2rad(place.latitude)
        let zenith = Ephemeris.deg2rad(90.833)
        let cosHour = (cos(zenith) / (cos(latitude) * cos(declination))
            - tan(latitude) * tan(declination)).clamped(to: -1...1)
        let hourDegrees = acos(cosHour) * 180 / Double.pi
        let zoneMinutes = place.utcOffsetHours * 60
        let solarNoon = 720 - 4 * place.longitude - equation + zoneMinutes
        let sunriseMinutes = solarNoon - 4 * hourDegrees
        let sunsetMinutes = solarNoon + 4 * hourDegrees
        return (day.addingTimeInterval(sunriseMinutes * 60),
                day.addingTimeInterval(sunsetMinutes * 60))
    }

    private static func approximateMoonTimes(for day: Date,
                                             sunrise: Date,
                                             place: BirthPlace,
                                             calendar: Calendar) -> (rise: Date, set: Date) {
        let localNoon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: day) ?? day
        let jd = Ephemeris.julianDay(localNoon)
        let elongation = Ephemeris.norm360(Ephemeris.moonTropical(jd: jd) - Ephemeris.sunTropical(jd: jd))
        let lunarDayHours = 24.84
        let rise = sunrise.addingTimeInterval(elongation / 360 * lunarDayHours * 3600)
        let set = rise.addingTimeInterval(lunarDayHours / 2 * 3600)
        return (rise, set)
    }

    private static func observances(for panchanga: Panchanga, language: Language) -> [String] {
        let ne = language == .ne
        switch panchanga.tithiInPaksha {
        case 4:
            return [ne ? "चतुर्थी · गणेश आराधना" : "Chaturthi · Ganesha observance"]
        case 8:
            return [ne ? "अष्टमी · देवी आराधना" : "Ashtami · Devi observance"]
        case 11:
            return [ne ? "एकादशी व्रत" : "Ekadashi Vrat"]
        case 13:
            return [ne ? "त्रयोदशी · प्रदोष साधना" : "Trayodashi · Pradosh observance"]
        case 15:
            return [panchanga.isShukla ? (ne ? "पूर्णिमा" : "Purnima") : (ne ? "औंसी" : "Aunsi")]
        default:
            return []
        }
    }

    private static func localCalendar(_ place: BirthPlace) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: Int(place.utcOffsetHours * 3600)) ?? .current
        return calendar
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
