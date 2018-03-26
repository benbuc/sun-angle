// see sunpos_2.py for extra information
// translation of sunpos_2 into swift language
// translated by: Benito Buchheim

func arraySum(_ array: [int]) -> int {
    var sum = 0
    for i in array {
        sum += i
    }
    return sum
}

func leapyear(year: int) -> Bool {
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

func calc_time(year: int, month: int, day: int, hour: int = 12, minute: int = 0, second: int = 0) -> Int {
    // TO-DO: check return type
    
    // Get day of the year, e.g. Feb 1 = 32, Mar 1 = 61 on leapyear
    let month_days: [int] = [0,31,28,31,30,31,30,31,31,30,31,30]
    // TO-DO: get array range
    let day_ = day + arraySum(month_day)
    let leapdays = leapyear(year) && day >= 60 && !(month==2 && day==60)
    if leapdays { day += 1 }
    
    // Get Julian date - 2400000
    let hour_: double = Double(hour) + Double(minute) / 60.0 + Double(second) / 3600.0 // hour plus fraction2400000
    let delta = year - 1949
    // TO-DO: double backslash??
    let leap = delta // 4 // former leapyears
    let jd = 32916.5 + delta * 365 + leap + day + hour / 24.0
    // The input to the Astronomer's almanac is the difference between24
    // the Julian date and JD 2451545.0 (noon ,1 January 2000)
    let time = jd - 51545
    return time
}

func 
