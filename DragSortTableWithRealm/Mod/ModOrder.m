
#import "ModOrder.h"

#import <YYModel/YYModel.h>

//格式化字符串的简写方式
#define StrFMT(fmt, ...) [NSString stringWithFormat:(fmt),##__VA_ARGS__]


@implementation ModOrder

#pragma mark - YYModel  -


#pragma mark - Public  -

+(void)makeMockData{
    for(int i=100;i>0;i--){
        ModOrder *mod = [ModOrder new];
        mod.orderId = [NSString stringWithFormat:@"%05d",i];
        [self saveData:mod];
    }
}

+(void)saveData:(ModOrder*)mod{
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults *results = [ModOrder allObjectsInRealm:realm];
    
    
    //新来的默认排到最前面，
    //下面的处理主要是避免数据库数据sortIndex依次加一的问题。
    //虽然顶部元素不是从0开始了，但是插到最前面的效率比较高。
    //sortIndex为负数的情况已测试过，没有问题。
    NSInteger sortIndex = 900;
    if(results.count>0){
        NSNumber *numSortIndex = [results minOfProperty:@"sortIndex"];
        if([numSortIndex isKindOfClass:[NSNumber class]]){
            sortIndex = [numSortIndex integerValue];
        }
    }
    
    [realm beginWriteTransaction];
    
    mod.sortIndex = sortIndex - 1;
    
    [realm addObject:mod];
    [realm commitWriteTransaction];
}

+(NSArray*)allOrders{
    RLMRealm *realm =  [RLMRealm defaultRealm];
    RLMResults *results = [ModOrder allObjectsInRealm:realm];
    
    RLMSortDescriptor *sortor = [RLMSortDescriptor sortDescriptorWithKeyPath:@"sortIndex"
                                                                           ascending:YES];
    
    RLMResults* sortedResults = [results sortedResultsUsingDescriptors:@[sortor]];
    
    return  [self getArrayFromRLMResluts:sortedResults];
}


+(NSArray*)modMoved:(ModOrder*)modMoved to:(ModOrder*)modTo{
    RLMRealm *realm =  [RLMRealm defaultRealm];
    
    BOOL isMoveUp = modMoved.sortIndex>modTo.sortIndex;
    
    RLMResults *results = nil;
    {
        NSString *where = @"";
        
        if(isMoveUp){
            //向上拖动，将拖动项移动到modTo的上面，则modTo也要移动。
            where = StrFMT(@"sortIndex >= %ld AND sortIndex < %ld"
                           ,(long)modTo.sortIndex
                           ,(long)modMoved.sortIndex);
        }else{
            //向下拖动，将拖动项移动到modTo的下面，modTo不需移动。
            where = StrFMT(@"sortIndex > %ld AND sortIndex <= %ld"
                           ,(long)modMoved.sortIndex
                           ,(long)modTo.sortIndex);
        }
        
        results = [ModOrder objectsInRealm:realm
                                        where:where];
    }
    
    RLMSortDescriptor *sortor = [RLMSortDescriptor sortDescriptorWithKeyPath:@"sortIndex"
                                                                   ascending:YES];
    RLMResults *sortedResults = [results sortedResultsUsingDescriptors:@[sortor]];
    /*
     Realm的RLMResults是随数据库变化实时更新的。就是说，在查询出结果后编辑数据，
     使此数据符合查询条件，则RLMResults中会增加此条数据。
     排序也是同样情况。
     */
    NSMutableArray *arrSorted = [self getArrayFromRLMResluts:sortedResults].mutableCopy;
    
    NSInteger sortIndex;
    if(isMoveUp){
        sortIndex = modTo.sortIndex + 1;
    }else{
        sortIndex = modMoved.sortIndex;
    }
    for(ModOrder *mod in arrSorted){
        mod.sortIndex = sortIndex;
        sortIndex += 1;
    }
    
    modMoved.sortIndex = modTo.sortIndex;
    [arrSorted addObject:modMoved];
    
    [realm beginWriteTransaction];
    
    for(ModOrder *mod in arrSorted){
        RLMResults *results = [ModOrder objectsInRealm:realm
                                                    where:@"orderId = %@"
                               ,mod.orderId];
        ModOrder *modInDb = results.firstObject;
        if(modInDb){
            modInDb.sortIndex = mod.sortIndex;
        }
    }
    
    [realm commitWriteTransaction];
    
    return arrSorted;
}

+(NSArray*)getArrayFromRLMResluts:(RLMResults*)results{
    NSMutableArray *arrReturn = @[].mutableCopy;
    for(ModOrder *mod in results){
        //对RLMObject进行copy，拷贝的对象切断了和数据库的关联。
        ModOrder *copiedMod = mod.copy;
        [arrReturn addObject:copiedMod];
    }
    
    return arrReturn;
}

#pragma mark- Copy && Encode -

-(id)copyWithZone:(NSZone *)zone{
    return [self yy_modelCopy];
}

- (instancetype)initWithCoder:(NSCoder*)decoder{
    return [self yy_modelInitWithCoder:decoder];
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    return [self yy_modelEncodeWithCoder:encoder];
}

@end

