
#import "DragSortCell.h"

#import "ModOrder.h"

@implementation DragSortCell
{
    ModOrder *_mod;
}

-(void)setMod:(ModOrder*)mod{
    _mod = mod;
    
    self.textLabel.text = mod.orderId;
}

#pragma mark - 拖动排序相关   -

- (void)prepareForMoveSnapshot
{
    // Should be implemented by subclasses if needed
}

- (void)prepareForMove
{

}

@end
