//
// NSDate+Helper.h
//
// Created by Billy Gray on 2/26/09.
// Copyright (c) 2009–2012, ZETETIC LLC
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the ZETETIC LLC nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY ZETETIC LLC ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL ZETETIC LLC BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "NSDate+Helper.h"

#define NSDateTimeAgoLocalizedStrings(key) \
NSLocalizedStringFromTableInBundle(key, @"NSDateTimeAgo", [NSBundle mainBundle], nil)


@implementation NSDate (Helper)


- (NSString *)lastTimeConnected;
{
    NSDate* now = [NSDate date];
    NSTimeInterval duration = [now timeIntervalSinceDate:self];
    
    if (duration < 60)
        return [NSString stringWithFormat:@"Last seen: just now"];
    else if (duration<120)
        return [NSString stringWithFormat:@"Last seen: %d minute ago", 1];
    else if (duration<3600)
        return [NSString stringWithFormat:@"Last seen: %d minutes ago",(int)(duration/60)];
    else if (duration<7200)
        return [NSString stringWithFormat:@"Last seen: %d hour ago", 1];
    else if (duration<3600*24)
        return [NSString stringWithFormat:@"Last seen: %d hours ago", (int)(duration/3600)];
    else if (duration<3600*48)
        return [NSString stringWithFormat:@"Last seen: %d day ago", 1];
    else if (duration<3600*24*30)
        return [NSString stringWithFormat:@"Last seen: %d days ago", (int)(duration/3600/24)];
    else if (duration<3600*24*60)
        return [NSString stringWithFormat:@"Last seen: %d month ago", 1];
    else
        return [NSString stringWithFormat:@"Last seen: %d months ago", (int)(duration/3600/24/30)];
}

/*
 * This guy can be a little unreliable and produce unexpected results,
 * you're better off using daysAgoAgainstMidnight
 */
- (NSUInteger)daysAgo {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit) 
											   fromDate:self
												 toDate:[NSDate date]
												options:0];
	return [components day];
    
    
    
}
+ (NSUInteger)daysAgoAgainstMidnightForDate:(NSDate *)date {
	// get a midnight version of ourself:
	NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
	[mdf setDateFormat:@"yyyy-MM-dd"];
	NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:date]];
	
	return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

- (NSUInteger)daysAgoAgainstMidnight {
	// get a midnight version of ourself:
	NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
	[mdf setDateFormat:@"yyyy-MM-dd"];
	NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];
	
	return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

- (NSString *)stringDaysAgo {
	return [self stringDaysAgoAgainstMidnight:YES];
}

- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag {
	NSUInteger daysAgo = (flag) ? [self daysAgoAgainstMidnight] : [self daysAgo];
	NSString *text = nil;
	switch (daysAgo) {
		case 0:
			text = NSDateTimeAgoLocalizedStrings(@"Today");
			break;
		case 1:
			text = NSDateTimeAgoLocalizedStrings(@"Yesterday");
			break;
            
		default:
			text = [NSString stringWithFormat:NSDateTimeAgoLocalizedStrings(@"%d days ago"), daysAgo];
	}
	return text;
}

- (NSUInteger)weekday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [calendar components:(NSWeekdayCalendarUnit) fromDate:self];
	return [weekdayComponents weekday];
}

+ (NSString *)testStringForLocalization
{
    return NSDateTimeAgoLocalizedStrings(@"Today");
}

+ (NSDate *)dateFromString:(NSString *)string {
	return [NSDate dateFromString:string withFormat:[NSDate dbFormatString]];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:format];
	NSDate *date = [inputFormatter dateFromString:string];
	return date;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
	return [date stringWithFormat:format];
}

+ (NSString *)stringFromDate:(NSDate *)date {
	return [date string];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime {
    /* 
	 * if the date is in today, display 12-hour time with meridian,
	 * if it is within the last 7 days, display weekday name (Friday)
	 * if within the calendar year, display as Jan 23
	 * else display as Nov 11, 2008
	 */
            
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];

    //Set the current language locale
    NSString *languageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSLocale *newLocale = [[NSLocale alloc] initWithLocaleIdentifier:languageCode];
    [displayFormatter setLocale:newLocale];

	NSDate *today = [NSDate date];
    NSDateComponents *offsetComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
													 fromDate:today];
	
	NSDate *midnight = [calendar dateFromComponents:offsetComponents];
	NSString *displayString = nil;
	
	// comparing against midnight
    NSComparisonResult midnight_result = [date compare:midnight];
	if (midnight_result == NSOrderedDescending) {
        
        NSString *format = @"h:mm a";
        
		if (prefixed) {            
			format = NSDateTimeAgoLocalizedStrings(@"at_given_time"); // at 11:30 am
		}
        
        [displayFormatter setDateFormat:format]; // 11:30 am
		
	} else {
        
        if ([self daysAgoAgainstMidnightForDate:date] == 1) {
            
            if (!displayTime) {
                return NSDateTimeAgoLocalizedStrings(@"Yesterday");
            } else {
                NSString *format = NSDateTimeAgoLocalizedStrings(@"yesterday_at_given_time"); // at 11:30 am
                [displayFormatter setDateFormat:format]; // 11:30 am
            }
            
        } else {
            // check if date is within last 7 days
            NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
            [componentsToSubtract setDay:-7];
            NSDate *lastweek = [calendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
            NSComparisonResult lastweek_result = [date compare:lastweek];
            if (lastweek_result == NSOrderedDescending) {
                if (displayTime) {
                    [displayFormatter setDateFormat:@"EEEE h:mm a"];    //Tuesday 5:13 PM
                    
                    if (prefixed) {
                        [displayFormatter setDateFormat:NSDateTimeAgoLocalizedStrings(@"day_hour_prefixed")]; // on Tuesday at 5:13 PM
                    }
                    
                } else {
                    [displayFormatter setDateFormat:@"EEEE"]; // Tuesday
                    
                    if (prefixed) {
                        [displayFormatter setDateFormat:NSDateTimeAgoLocalizedStrings(@"day_prefixed")]; // on Tuesday
                    }
                    
                }
            }
            else {
                // check if same calendar year
                NSInteger thisYear = [offsetComponents year];
                
                NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                               fromDate:date];
                NSInteger thatYear = [dateComponents year];
                if (thatYear >= thisYear) {
                    if (displayTime) {
                        [displayFormatter setDateFormat:@"MMM d h:mm a"]; //May 23 5:08 PM
                        
                        if (prefixed) {
                            [displayFormatter setDateFormat:NSDateTimeAgoLocalizedStrings(@"month_day_time_prefixed")]; // May 23 at 5:08 PM
                        }
                    }
                    else {
                        [displayFormatter setDateFormat:@"MMM d"]; //May 23
                        
                        if (prefixed) {
                            [displayFormatter setDateFormat:NSDateTimeAgoLocalizedStrings(@"month_day_prefixed")]; // on May 23
                        }
                        
                    }
                } else {
                    if (displayTime) {
                        [displayFormatter setDateFormat:@"MMM d, yyyy h:mm a"]; //May 23, 2012 5:08 PM
                        
                        if (prefixed) {
                            [displayFormatter setDateFormat:NSDateTimeAgoLocalizedStrings(@"month_day_year_time_prefixed")]; //May 23 of 2012 at 5:08 PM
                        }
                    }
                    else {
                        [displayFormatter setDateFormat:@"MMM d, yyyy"]; //May 23, 2012
                        
                        if (prefixed) {
                            [displayFormatter setDateFormat:NSDateTimeAgoLocalizedStrings(@"month_day_year_prefixed")]; //May 23 of 2012
                        }
                    }
                }
            }
        }
        
	}
	
	// use display formatter to return formatted date string
	displayString = [displayFormatter stringFromDate:date];
        
	return displayString;
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed {
	return [[self class] stringForDisplayFromDate:date prefixed:prefixed alwaysDisplayTime:NO];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date {
	return [self stringForDisplayFromDate:date prefixed:NO];
}

- (NSString *)stringWithFormat:(NSString *)format {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:format];
	NSString *timestamp_str = [outputFormatter stringFromDate:self];
	return timestamp_str;
}

- (NSString *)string {
	return [self stringWithFormat:[NSDate dbFormatString]];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateStyle:dateStyle];
	[outputFormatter setTimeStyle:timeStyle];
	NSString *outputString = [outputFormatter stringFromDate:self];
	return outputString;
}

- (NSDate *)beginningOfWeek {
	// largely borrowed from "Date and Time Programming Guide for Cocoa"
	// we'll use the default calendar and hope for the best
	NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *beginningOfWeek = nil;
	BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginningOfWeek
						   interval:NULL forDate:self];
	if (ok) {
		return beginningOfWeek;
	} 
	
	// couldn't calc via range, so try to grab Sunday, assuming gregorian style
	// Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
	
	/*
	 Create a date components to represent the number of days to subtract from the current date.
	 The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question.  (If today's Sunday, subtract 0 days.)
	 */
	NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
	[componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
	beginningOfWeek = nil;
	beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
	
	//normalize to midnight, extract the year, month, and day components and create a new date from those components.
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
											   fromDate:beginningOfWeek];
	return [calendar dateFromComponents:components];
}

- (NSDate *)beginningOfDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // Get the weekday component of the current date
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) 
											   fromDate:self];
	return [calendar dateFromComponents:components];
}

- (NSDate *)endOfWeek {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
	NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
	// to get the end of week for a particular date, add (7 - weekday) days
	[componentsToAdd setDay:(7 - [weekdayComponents weekday])];
	NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
	
	return endOfWeek;
}

+ (NSString *)dateFormatString {
	return @"yyyy-MM-dd";
}

+ (NSString *)timeFormatString {
	return @"HH:mm:ss";
}

+ (NSString *)timestampFormatString {
	return @"yyyy-MM-dd HH:mm:ss";
}

// preserving for compatibility
+ (NSString *)dbFormatString {	
	return [NSDate timestampFormatString];
}

@end
