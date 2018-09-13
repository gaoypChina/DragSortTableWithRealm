
#import <Realm/Realm.h>

#import <Foundation/Foundation.h>

@interface ModOrder : RLMObject<NSCopying,NSCoding>


//订单号,主键。
@property(nonatomic,copy)NSString* orderId;

//排序字段,只在客户端有,用于支持用户拖动排序.
@property(nonatomic,assign)NSInteger sortIndex;

+(void)makeMockData;
+(NSArray*)allOrders;

/**
 用于拖动重排序,将modMoved排到modTo的位置.
 如果是向上拖动，则是拖动到modTo的上面。如果是向下拖动，则是拖动到modTo的下面。
 返回重新排序后的数据。
 */
+(NSArray*)modMoved:(ModOrder*)modMoved to:(ModOrder*)modTo;

@end
