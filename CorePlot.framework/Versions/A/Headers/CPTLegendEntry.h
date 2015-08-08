#import "CPTDefinitions.h"

@class CPTPlot;
@class CPTTextStyle;

@interface CPTLegendEntry : NSObject<NSCoding>

/// @name Plot Info
/// @{
@property (nonatomic, readwrite, cpt_weak_property, nullable) cpt_weak CPTPlot *plot;
@property (nonatomic, readwrite, assign) NSUInteger index;
/// @}

/// @name Formatting
/// @{
@property (nonatomic, readwrite, strong, nullable) CPTTextStyle *textStyle;
/// @}

/// @name Layout
/// @{
@property (nonatomic, readwrite, assign) NSUInteger row;
@property (nonatomic, readwrite, assign) NSUInteger column;
@property (nonatomic, readonly) CGSize titleSize;
/// @}

/// @name Drawing
/// @{
-(void)drawTitleInRect:(CGRect)rect inContext:(nonnull CGContextRef)context scale:(CGFloat)scale;
/// @}

@end
