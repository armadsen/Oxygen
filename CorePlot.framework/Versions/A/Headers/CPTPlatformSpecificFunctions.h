#import "CPTDefinitions.h"

/// @file

#if __cplusplus
extern "C" {
#endif

/// @name Graphics Context Save Stack
/// @{
void CPTPushCGContext(__nonnull CGContextRef context);
void CPTPopCGContext(void);

/// @}

/// @name Graphics Context
/// @{
__nonnull CGContextRef CPTGetCurrentContext(void);

/// @}

/// @name Color Conversion
/// @{
__nonnull CGColorRef CPTCreateCGColorFromNSColor(NSColor *__nonnull nsColor);
CPTRGBAColor CPTRGBAColorFromNSColor(NSColor *__nonnull nsColor);

/// @}

#if __cplusplus
}
#endif
