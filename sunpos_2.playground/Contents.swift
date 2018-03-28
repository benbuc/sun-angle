//: Playground - noun: a place where people can play

import UIKit
import Foundation

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

func arraySumWithCount(_ array: [Int], num: Int) -> Int {
    // calculates the sum of the specified number of integers
    var sum = 0
    for i in 0..<num {
        sum += array[i]
    }
    return sum
}

func leapyear(_ year: Int) -> Bool {
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

func calc_time(year: Int, month: Int, day: Int, hour: Int = 12, minute: Int = 0, second: Int = 0) -> Double {
    // Get day of the year, e.g. Feb 1 = 32, Mar 1 = 61 on leap years
    let month_days: [Int] = [0,31,28,31,30,31,30,31,31,30,31,30]
    var dayOfYear: Int = day + arraySumWithCount(month_days, num: month)
    let leapdays = leapyear(year) && day >= 60 && !(month==2 && day==60)
    if leapdays {
        dayOfYear += 1
    }
    
    // Get Julian date - 2400000
    let totalHour = Double(hour + minute) / 60.0 + Double(second) / 3600.0 // hour plus fraction
    let delta = year - 1949
    let leap = delta / 4 // former leapyears
    let jd = 32916.5 + Double(delta) * 365 + Double(leap) + Double(day) + totalHour / 24.0
    // The input to the Astronomer's almanac is the difference between
    // the Julian date and JD 2451545.0 (noon, 1 January 2000)
    let time = jd - 51545
    return time
}

func meanLongitudeDegrees(time: Double) -> Double {
    return (280.460 + 0.9856474 * time).truncatingRemainder(dividingBy: 360)
}

func meanAnomalyRadians(time: Double) -> Double {
    return (357.528 + 0.9856003 * time).truncatingRemainder(dividingBy: 360).degreesToRadians
}

func eclipticLongitudeRadians(mnlong: Double, mnanomaly: Double) -> Double {
    return (mnlong + 1.916 * sin(mnanomaly) + 0.020 * sin(2 * mnanomaly)).truncatingRemainder(dividingBy: 360).degreesToRadians
}

func eclipticObliquityRadians(time: Double) -> Double {
    return (23.439 - 0.0000004 * time).degreesToRadians
}

func rightAscensionRadians(oblqec: Double, eclong: Double) -> Double {
    let num = cos(oblqec) * sin(eclong)
    let den = cos(eclong)
    var ra = atan(num / den)
    if den < 0 {
        ra += Double.pi
    }
    if (den >= 0 && num < 0) {
        ra += 2 * Double.pi
    }
    
    return ra
}

func rightDeclinationRadians(oblqec: Double, eclong: Double) -> Double {
    return asin(sin(oblqec) * sin(eclong))
}

func greenwichMeanSiderealTimeHours(time: Double, hour: Double) -> Double {
    return (6.697375 + 0.0657098242 * time + hour).truncatingRemainder(dividingBy: 24)
}

func localMeanSiderealTimeRadians(gmst: Double, longitude: Double) -> Double {
    return (15 * (gmst + longitude / 15.0).truncatingRemainder(dividingBy: 24)).degreesToRadians
}

func hourAngleRadians(lmst: Double, ra: Double) -> Double {
    return ((lmst - ra + Double.pi).truncatingRemainder(dividingBy: 2*Double.pi)) - Double.pi
}

func elevationRadians(lat: Double, dec: Double, ha: Double) -> Double {
    return asin(sin(dec) * sin(lat) + cos(dec) * cos(lat) * cos(ha))
}

func solarAzimuthRadiansCharlie(lat: Double, dec: Double, ha: Double) -> Double {
    let zenithAngle = acos(sin(lat) * sin(dec) + cos(lat) * cos(dec) * cos(ha))
    var az = acos((sin(lat) * cos(zenithAngle) - sin(dec)) / (cos(lat) * sin(zenithAngle)))
    if ha > 0 {
        az = az + Double.pi
    } else {
        az = (3 * Double.pi - az).truncatingRemainder(dividingBy: 2 * Double.pi)
    }
    
    return az
}

func sun_position(year: Int, month: Int, day: Int, hour: Int = 12, minute: Int = 0, second: Int = 0, latitude: Double = 46.5, longitude: Double = 6.5) -> (Double, Double) {
    let time = calc_time(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
    let hourMinuteSecond = Double(hour) + Double(minute) / 60.0 + Double(second) / 3600.0
    // Ecliptic coordinates
    let mnlong = meanLongitudeDegrees(time: time)
    let mnanom = meanAnomalyRadians(time: time)
    let eclong = eclipticLongitudeRadians(mnlong: mnlong, mnanomaly: mnanom)
    let oblqec = eclipticObliquityRadians(time: time)
    // Celestial coordinates
    let ra = rightAscensionRadians(oblqec: oblqec, eclong: eclong)
    let dec = rightDeclinationRadians(oblqec: oblqec, eclong: eclong)
    // Local coordinates
    let gmst = greenwichMeanSiderealTimeHours(time: time, hour: hourMinuteSecond)
    let lmst = localMeanSiderealTimeRadians(gmst: gmst, longitude: longitude)
    // Hour angle
    let ha = hourAngleRadians(lmst: lmst, ra: ra)
    // Latitude to radians
    let lat = latitude.degreesToRadians
    // Azimuth and elevation
    let el = elevationRadians(lat: lat, dec: dec, ha: ha)
    let azC = solarAzimuthRadiansCharlie(lat: lat, dec: dec, ha: ha)
    
    let elevation = el.radiansToDegrees
    let azimuth = azC.radiansToDegrees
    return (azimuth, elevation)
}
