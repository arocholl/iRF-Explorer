//
//  StringScaleDefinition.m
//  iScope
//
//  Created by Dirk-Willem van Gulik on 03/11/2010.
//  Copyright 2010 webweaving.org. All rights reserved.
//

#import "StringScaleDefinition.h"
#import "NumericScaleDefinition.h"

@implementation StringScaleDefinition
@synthesize ticks, def, commonSIprefix, individualSIprefix;
@synthesize dataMin, dataMax;

-(id)initWithNumericScaleDefinition:(NumericScaleDefinition *)_def 
						withDataMin:(double)aDataMin
						withDataMax:(double)aDataMax
						   withUnit:(NSString *)siUnit;
{
	self = [super init];
	if (!self)
		return nil;

	dataMin = aDataMin;
	dataMax = aDataMax;
	
	NSMutableArray * tmpTicks = [NSMutableArray arrayWithCapacity:_def.nbrOfTicks];
	double cc = _def.min;
	
	for(int i = 0; i < _def.nbrOfTicks; i++) {
		double c = fabs(cc);
        double sgn = signbit(cc) ? -1 : 1;
		
		NSString * siPrefix = @"";
		if (c == 0) {
			// skip.
		} else if (c <= 1E-24) {
			c *= 1E24; siPrefix = @"y";
		} else if (c <= 1E-21) {
			c *= 1E21; siPrefix = @"z";
		} else if (c <= 1E-18) {
			c *= 1E18; siPrefix = @"a";
		} else if (c <= 1E-15) {
			c *= 1E15; siPrefix = @"f";
		} else if (c <= 1E-12) {
			c *= 1E12; siPrefix = @"p";
		} else if (c <= 1E-9) {
			c *= 1E9; siPrefix = @"n";
		} else if (c <= 1E-6) {
			c *= 1E6; siPrefix = @"µ";
		} else if (c <= 1E-3) {
			c *= 1E3; siPrefix = @"m";
		} else if (c >= 1E24) {
			c *= 1E-24; siPrefix = @"Y";
		} else if (c >= 1E21) {
			c *= 1E-21; siPrefix = @"Z";
		} else if (c >= 1E18) {
			c *= 1E-18; siPrefix = @"E";
		} else if (c >= 1E15) {
			c *= 1E-15; siPrefix = @"P";
		} else if (c >= 1E12) {
			c *= 1E-12; siPrefix = @"T";
		} else if (c >= 1E9) {
			c *= 1E-9; siPrefix = @"G";
		} else if (c >= 1E6) {
			c *= 1E-6; siPrefix = @"M";
		} else if (c >= 1E3) {
			c *= 1E-3; siPrefix = @"k";
		};

		NSString * label = nil;
		
        c = sgn * c;
		if (c == floor(c)) {
			label = [NSString stringWithFormat:@"%.0f", c];
		} else if (c*10 == floor(10*c)) {
			label = [NSString stringWithFormat:@"%.01f", c];
		} else if (c*100 == floor(100*c)) {
			label = [NSString stringWithFormat:@"%.02f", c];
		} else if (c*3 == floor(3*c)) {
			label = [NSString stringWithFormat:@"%.02f", c];
		} else if (c*6 == floor(6*c)) {
			label = [NSString stringWithFormat:@"%.02f", c];
		} else {
			label = [NSString stringWithFormat:@"%.3f", c];
		}

		TickMark * tick = [[TickMark alloc] initWithLabelStr:label 
												  withSiUnit:siUnit
												withSiPrefix:siPrefix
												   withValue:cc];

		[tmpTicks addObject:tick];
		cc += _def.diff;
	};

	// find the first valid label - and check if it is equal to the
	// very last one - in which case we have just one multiplier
	// siPrefixs - otherwise each label will nead a multiplier postfix.
	//
	int i = 0;
	while(i < tmpTicks.count && [((TickMark *)[tmpTicks objectAtIndex:i]).siUnit isEqual:@""]) 
		i++;
	
	if (i == tmpTicks.count) {
		// nothing has a siPrefix
		individualSIprefix = NO;
		self.commonSIprefix = siUnit;
	} else if (i == 1 && [((TickMark*)[tmpTicks objectAtIndex:i]).siPrefix isEqual:((TickMark*)[tmpTicks objectAtIndex:tmpTicks.count-1]).siPrefix]) {
		self.commonSIprefix = [NSString stringWithFormat:@"%@%@",((TickMark*)[tmpTicks objectAtIndex:i]).siPrefix, siUnit];
		individualSIprefix = NO;
	} else {
		self.commonSIprefix = siUnit;
		individualSIprefix = YES;
	}
	
	if (individualSIprefix) {
		for (i = 0; i < tmpTicks.count; i++) {
			TickMark * t = [tmpTicks objectAtIndex:i];
			t.labelStr = [NSString stringWithFormat:@"%@%@", t.labelStr, t.siPrefix];
		};
	};
	
	ticks = [[NSArray arrayWithArray:tmpTicks] retain];
	def = [_def retain];
	
	return self;
}

-(BOOL)hasCommonSIprefix {
	return (commonSIprefix != nil) ? YES: NO;
}

@end
