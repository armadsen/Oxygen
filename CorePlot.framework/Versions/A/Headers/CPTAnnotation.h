#import "CPTDefinitions.h"

@class CPTAnnotationHostLayer;
@class CPTLayer;

@interface CPTAnnotation : NSObject<NSCoding>

@property (nonatomic, readwrite, strong, nullable) CPTLayer *contentLayer;
@property (nonatomic, readwrite, cpt_weak_property, nullable) cpt_weak CPTAnnotationHostLayer *annotationHostLayer;
@property (nonatomic, readwrite, assign) CGPoint contentAnchorPoint;
@property (nonatomic, readwrite, assign) CGPoint displacement;
@property (nonatomic, readwrite, assign) CGFloat rotation;

@end

#pragma mark -

/** @category CPTAnnotation(AbstractMethods)
 *  @brief CPTAnnotation abstract methods—must be overridden by subclasses.
 **/
@interface CPTAnnotation(AbstractMethods)

/// @name Layout
/// @{
-(void)positionContentLayer;
/// @}

@end
