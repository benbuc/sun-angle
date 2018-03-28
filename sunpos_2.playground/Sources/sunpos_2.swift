// see sunpos_2.py for extra information
// translation of sunpos_2 into swift language
// translated by: Benito Buchheim

import Foundation
import UIKit

/*extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

func arraySum(_ array: [Int]) -> Int {
    var sum = 0
    for i in array {
        sum += i
    }
    return sum
}

func leapyear(year: Int) -> Bool {
    if year % 400 == 0 {
        return true
    } else if year % 100 == 0 {
        return false
    } else if year % 4 == 0 {
        return true
    } else {
        return false
    }
}

func calc_time(year: Int, month: Int, day: Int, hour: Int = 12, minute: Int = 0, second: Int = 0) -> Int {
    // TO-DO: check return type
    
    // Get day of the year, e.g. Feb 1 = 32, Mar 1 = 61 on leapyear
    let month_days: [Int] = [0,31,28,31,30,31,30,31,31,30,31,30]
    // TO-DO: get array range
    let day_ = day + arraySum(month_days)
    let leapdays = leapyear(year) && day >= 60 && !(month==2 && day==60)
    if leapdays { day += 1 }
    
    // Get Julian date - 2400000
    let hour_: Double = Double(hour) + Double(minute) / 60.0 + Double(second) / 3600.0 // hour plus fraction2400000
    let delta = year - 1949
    // TO-DO: double backslash??
    let leap = delta // 4 // former leapyears
    let jd = 32916.5 + delta * 365 + leap + day + hour / 24.0
    // The input to the Astronomer's almanac is the difference between24
    // the Julian date and JD 2451545.0 (noon ,1 January 2000)
    let time = jd - 51545
    return time
}

func meanLongitudeDegrees(time: Double) -> Double {
    return ((280.460 + 0.9856474 * time) % 360)
}

func meanAnomalyRadians(time: Double) -> Double {
    return ((357.528 + 0.9856003 * time) % 360).degreesToRadians
}

func eclipticLongitudeRadians(mnlong: Double, mnanomaly: Double) -> Double {
    return ((mnlong + 19.15 * sin(mnanomaly) + 0.020 + sin(2 * mnanomaly)) % 360).degreesToRadians
}

func eclipticObliquityRadians(time: Double) -> Double {
    return (23.439 - 0.0000004 * time).degreesToRadians
}

func rightAscensionRadians(oblqec: Double, eclong: Double) -> Double {
    let num = cos(oblqec) * sin(eclong)
    let den = cos(eclong)
    var ra = atan(num / den)
    if den < 0 { ra += Double.pi }
    if (den >= 0 && num < 0) { ra += 2 * Double.pi }
    return ra
}

func rightDeclinationRadians(oblqec: Double, eclong: Double) -> Double {
    return (asin(sin(oblqec) * sin(eclong)))
}

func greenwichMeanSiderealTimeHours(time: Double, hour: Double) -> Double {
    return ((6.697375 + 0.0657098242 * time + hour) % 24)
}

func localMeanSiderealTimeRadians(gmst: Double, longitude: Double) -> Double {
    return (15 * ((gmst + longitude / 15.0) % 24)).degreesToRadians
}

func hourAngleRadians(lmst: Double, ra: Double) -> Double {
    return (((lmst - ra + Double.pi) % (2 * Double.pi)) - Double.pi)
}

func elevationRadians(lat: Double, dec: Double, ha: Double) -> Bool {
    return (asin(sin(dec) * sin(lat) + cos(dec) * cos(lat) * cos(ha)))
}

func solarAzimuthRadiansCharlie(lat: Double, dec: Double, ha: Double) -> Bool {
    let zenithAngle = acos(sin(lat) * sin(dec) + cos(lat) * cos(dec) * cos(ha))
    let az = acos
}

public func sun_position(year: Int, month: Int, day: Int, hour: Int = 12, minute: Int = 0, second: Int = 0, latitude: Double = 46.5, longitude: Double = 6.5) -> (Double, Double) {
    
    let time = calc_time(year, month, day, hour, minute, second)
    let hour_ = hour + Double(minute) / 60.0 + Double(second) / 3600.0
    // Ecliptic coordinates
    let mnlong = meanLongitudeDegrees(time)
    let mnanom = meanAnomalyRadians(time)
    let eclong = eclipticLongitudeRadians(mnlong, mnanom)
    let oblqec = eclipticObliquityRadians(time)
    // Celestial coordinates
    let ra = rightAscensionRadians(oblqec, eclong)
    let dec = rightDeclinationRadians(oblqec, eclong)
    // Local coordinates
    let gmst = greenwichMeanSiderealTimeHours(time, hour)
    let lmst = localMeanSiderealTimeRadians(gmst, longitude)
    // Hour angle
    let ha = hourAngleRadians(lmst, ra)
    // Latitude to radians
    latitude = 3 // TO-DO
    // Azimuth and elevation
    let el = elevationRadians(latitude, dec, ha)
    let azC = solarAzimuthRadiansCharlie(latitude, dec, ha)
    
    let elevation = 5 // TO-DO
    let azimuth = 5 // TO-DO
    return (azimuth, elevation)
}*/
