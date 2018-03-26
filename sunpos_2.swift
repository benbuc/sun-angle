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

func calc_time(year: int, month: int, day: int, hour: int = 12, minute: int = 0, second: int = 0) {
    // Get day of the year, e.g. Feb 1 = 32, Mar 1 = 61 on leapyear
    let month_days: [int] = [0,31,28,31,30,31,30,31,31,30,31,30]
    day = day + arraySum(month_day)
}