// sunpos_2.swift
// translated from python by Benito Buchheim

// header of sunpos_2.py:
/*
# Taken from the code on stackexchange here:
# - http://stackoverflow.com/questions/8708048/position-of-the-sun-given-time-of-day-latitude-and-longitude
# converted into Python and extensively tested.

# It is critical to note the following:
# Latitude is defined as +-90 degrees where 0 is the equator and +90 is the North Pole.
# Longitude is +- 180 degrees about the GMT line, but has two representations:
#  - Either a map based mode where +ve values lie to the East,
#  - or a satellite based mode where +ve refers to the West.
# The NOAA site - where you can validate this code output - uses the satellite basis.
#   - http://www.esrl.noaa.gov/gmd/grad/solcalc/azel.html
# Most maps, and this code, use the Map basis.

#  A latitude or longitude with 8 decimal places pinpoints a location to within 1 millimeter,( 1/16 inch).
#   Precede South latitudes and West longitudes with a minus sign.

# This can be overcome by entering Lat/Long in the NSEW notation instead of as floating point numbers.
# Samples site:
#    - http://www.findlatitudeandlongitude.com/
# E.g. These are equivalent - for Lisbon in Portugal.
#   Latitude:N 38° 43' 26.7257"
#   Longitude:W 9° 8' 26.25"
#   Latitude:N 38° 43.445428'
#   Longitude:W 9° 8.4375'
#   Latitude:38.72409°
#   Longitude:-9.140625°
#
# for Lima Peru
#   Latitude:S 11° 57' 12.0578"
#   Longitude:W 76° 59' 31.875"
#   Latitude:S 11° 57.200964'
#   Longitude:W 76° 59.53125'
#   Latitude:-11.953349°
#   Longitude:-76.992187°
 */

import Foundation

fileprivate extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

fileprivate func arraySumWithCount(_ array: [Int], num: Int) -> Int {
    // calculates the sum of the specified number of integers
    var sum = 0
    for i in 0..<num {
        sum += array[i]
    }
    return sum
}

fileprivate func leapyear(_ year: Int) -> Bool {
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

fileprivate func calc_time(year: Int, month: Int, day: Int, hour: Int = 12, minute: Int = 0, second: Int = 0) -> Double {
    // Get day of the year, e.g. Feb 1 = 32, Mar 1 = 61 on leap years
    let month_days: [Int] = [0,31,28,31,30,31,30,31,31,30,31,30]
    var dayOfYear: Int = day + arraySumWithCount(month_days, num: month)
    let leapdays = leapyear(year) && day >= 60 && !(month==2 && day==60)
    if leapdays {
        dayOfYear += 1
    }
    
    // Get Julian date - 2400000
    let totalHour = Double(hour) + Double(minute) / 60.0 + Double(second) / 3600.0 // hour plus fraction
    let delta = year - 1949
    let leap = delta / 4 // former leapyears
    let jd = 32916.5 + Double(delta) * 365 + Double(leap) + Double(dayOfYear) + totalHour / 24.0
    // The input to the Astronomer's almanac is the difference between
    // the Julian date and JD 2451545.0 (noon, 1 January 2000)
    let time = jd - 51545
    return time
}

fileprivate func meanLongitudeDegrees(time: Double) -> Double {
    return (280.460 + 0.9856474 * time).truncatingRemainder(dividingBy: 360)
}

fileprivate func meanAnomalyRadians(time: Double) -> Double {
    return (357.528 + 0.9856003 * time).truncatingRemainder(dividingBy: 360).degreesToRadians
}

fileprivate func eclipticLongitudeRadians(mnlong: Double, mnanomaly: Double) -> Double {
    return (mnlong + 1.916 * sin(mnanomaly) + 0.020 * sin(2 * mnanomaly)).truncatingRemainder(dividingBy: 360).degreesToRadians
}

fileprivate func eclipticObliquityRadians(time: Double) -> Double {
    return (23.439 - 0.0000004 * time).degreesToRadians
}

fileprivate func rightAscensionRadians(oblqec: Double, eclong: Double) -> Double {
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

fileprivate func rightDeclinationRadians(oblqec: Double, eclong: Double) -> Double {
    return asin(sin(oblqec) * sin(eclong))
}

fileprivate func greenwichMeanSiderealTimeHours(time: Double, hour: Double) -> Double {
    return (6.697375 + 0.0657098242 * time + hour).truncatingRemainder(dividingBy: 24)
}

fileprivate func localMeanSiderealTimeRadians(gmst: Double, longitude: Double) -> Double {
    return (15 * (gmst + longitude / 15.0).truncatingRemainder(dividingBy: 24)).degreesToRadians
}

fileprivate func hourAngleRadians(lmst: Double, ra: Double) -> Double {
    return ((lmst - ra + Double.pi).truncatingRemainder(dividingBy: 2*Double.pi)) - Double.pi
}

fileprivate func elevationRadians(lat: Double, dec: Double, ha: Double) -> Double {
    return asin(sin(dec) * sin(lat) + cos(dec) * cos(lat) * cos(ha))
}

fileprivate func solarAzimuthRadiansCharlie(lat: Double, dec: Double, ha: Double) -> Double {
    let zenithAngle = acos(sin(lat) * sin(dec) + cos(lat) * cos(dec) * cos(ha))
    var az = acos((sin(lat) * cos(zenithAngle) - sin(dec)) / (cos(lat) * sin(zenithAngle)))
    if ha > 0 {
        az = az + Double.pi
    } else {
        az = (3 * Double.pi - az).truncatingRemainder(dividingBy: 2 * Double.pi)
    }
    
    return az
}

public func sun_position(year: Int, month: Int, day: Int, hour: Int = 12, minute: Int = 0, second: Int = 0, latitude: Double = 46.5, longitude: Double = 6.5) -> (Double, Double) {
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

