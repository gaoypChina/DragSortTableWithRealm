
#import <UIKit/UIKit.h>

@class ModOrder;

@interface DragSortCell : UITableViewCell

-(void)setMod:(ModOrder*)mod;

- (void)prepareForMoveSnapshot;
- (void)prepareForMove;



@end
