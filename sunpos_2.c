// sunpos_2.c
// translated from Swift by Benito Buchheim

// header of original sunpos_2.py:
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

#include <stdlib.h>
#include <math.h>
#include <stdio.h>

// select datatype for fractions
#define frac double
// modulo operation for double
#define modulo fmod
#define sine sin
#define cosine cos
#define atangent atan
#define asine asin
#define acosine acos

frac degreesToRadians(frac deg) {
    return deg * M_PI / 180;
}

frac radiansToDegrees(frac rad) {
    return rad * 180 / M_PI;
}

struct HorizontalCoordinates {
    frac azimuth;
    frac elevation;
};

int arraySumWithCount(int* array, int num) {
    // calculates the sum of the specifiec number of integers
    int sum = 0;
    int i;
    for (i=0; i < num; i++) {
        sum += array[i];
    }

    return sum;
}

int leapyear(int year) {
    if (year % 400 == 0) {
        return 1;
    } else if (year % 100 == 0) {
        return 0;
    } else if (year % 4 == 0) {
        return 1;
    } else {
        return 0;
    }
}

frac calc_time(int year, int month, int day, int hour, int minute, int second) {
    // Get day of the year, e.g. Feb 1 = 32, Mar 1 = 61 on leap years
    int month_days[] = {0,31,28,31,30,31,30,31,31,30,31,30};
    int dayOfYear = day + arraySumWithCount(month_days, month);
    int leapdays = leapyear(year) && day >= 60 && !(month==2 && day==60);
    if (leapdays) {
        dayOfYear += 1;
    }

    // Get Julian date - 2400000
    frac totalHour = (frac)hour + (frac)minute / 60.0 + (frac)second / 3600.0; // hour plus fraction
    int delta = year - 1949;
    int leap = delta / 4; // former leapyears
    frac jd = 32916.5 + (frac)delta * 365 + (frac)leap + (frac)dayOfYear + totalHour / 24.0;
    // The input to the Astronomer's almanac is the difference between
    // the Julian date and JD 2451545.0 (noon, 1 January 2000)
    frac time = jd - 51545;
    return time;
}

frac meanLongitudeDegrees(frac time) {
    return modulo((280.460 + 0.9856474 * time), 360);
}

frac meanAnomalyRadians(frac time) {
    return degreesToRadians(modulo((357.528 + 0.9856003 * time), 360));
}

frac eclipticLongitudeRadians(frac mnlong, frac mnanomaly) {
    return degreesToRadians(modulo((mnlong + 1.916 * sine(mnanomaly) + 0.020 * sine(2 * mnanomaly)), 360));
}

frac eclipticObliquityRadians(frac time) {
    return degreesToRadians(23.439 - 0.0000004 * time);
}

frac rightAscensionRadians(frac oblqec, frac eclong) {
    frac num = cosine(oblqec) * sine(eclong);
    frac den = cosine(eclong);
    frac ra = atangent(num / den);
    if (den < 0) {
        ra += M_PI;
    }
    if (den >= 0 && num < 0) {
        ra += 2 * M_PI;
    }

    return ra;
}

frac rightDeclinationRadians(frac oblqec, frac eclong) {
    return asine(sine(oblqec) * sine(eclong));
}

frac greenwichMeanSiderealTimeHours(frac time, frac hour) {
    return modulo(6.697375 + 0.0657098242 * time + hour, 24);
}

frac localMeanSiderealTimeRadians(frac gmst, frac longitude) {
    return degreesToRadians(modulo(15 * (gmst + longitude / 15.0), 24));
}

frac hourAngleRadians(frac lmst, frac ra) {
    return (modulo(lmst - ra * M_PI, 2*M_PI) - M_PI);
}

frac elevationRadians(frac lat, frac dec, frac ha) {
    return asine(sine(dec) * sine(lat) + cosine(dec) * cosine(lat) * cosine(ha));
}

frac solarAzimuthRadiansCharlie(frac lat, frac dec, frac ha) {
    frac zenithAngle = acosine(sine(lat) * sine(dec) + cosine(lat) * cosine(dec) * cosine(ha));
    frac az = acosine((sine(lat) * cosine(zenithAngle) - sine(dec)) / (cosine(lat) * sine(zenithAngle)));
    if (ha > 0) {
        az = az + M_PI;
    } else {
        az = modulo(3 * M_PI - az, 2 * M_PI); 
    }

    return az;
}

struct HorizontalCoordinates sun_position(int year, int month, int day, int hour, int minute, int second, frac latitude, frac longitude) {
    frac time = calc_time(year, month, day, hour, minute, second);
    frac hourMinuteSecond = (frac)hour + (frac)minute / 60.0 + (frac)second / 3600.0;
    // Ecliptic coordinates
    frac mnlong = meanLongitudeDegrees(time);
    frac mnanom = meanAnomalyRadians(time);
    frac eclong = eclipticLongitudeRadians(mnlong, mnanom);
    frac oblqec = eclipticObliquityRadians(time);
    // Celestial coordinates
    frac ra = rightAscensionRadians(oblqec, eclong);
    frac dec = rightDeclinationRadians(oblqec, eclong);
    // Local coordinates
    frac gmst = greenwichMeanSiderealTimeHours(time, hourMinuteSecond);
    frac lmst = localMeanSiderealTimeRadians(time, longitude);
    // Hour angle
    frac ha = hourAngleRadians(lmst, ra);
    // Latitude to radians
    frac lat = degreesToRadians(latitude);
    // Azimuth and elevation
    frac el = elevationRadians(lat, dec, ha);
    frac azC = solarAzimuthRadiansCharlie(lat, dec, ha);

    frac elevation = radiansToDegrees(el);
    frac azimuth = radiansToDegrees(azC);
    struct HorizontalCoordinates coords = { azimuth, elevation };
    return coords;
}

int main(int argc, char* argv[]) {

    return 0;
}