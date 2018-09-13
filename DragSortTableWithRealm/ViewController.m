#import "ViewController.h"

#import "FMMoveTableView.h"
#import "DragSortCell.h"

#import "ModOrder.h"

#define SCR_W [UIScreen mainScreen].bounds.size.width

@interface ViewController ()
<UITableViewDelegate
,UITableViewDataSource
,FMMoveTableViewDataSource
,FMMoveTableViewDelegate
>

{
    NSMutableArray *_showMods;
    
    UITableView *_table;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _table = [[FMMoveTableView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_table];
    [_table registerClass:[DragSortCell class] forCellReuseIdentifier:@"CellIdent"];
    _table.showsVerticalScrollIndicator = NO;
    _table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _table.delegate = self;
    _table.dataSource = self;
    
    NSArray *orders = [ModOrder allOrders];
    if(orders.count == 0){
        [ModOrder makeMockData];
        orders = [ModOrder allOrders];
    }
    _showMods = orders.mutableCopy;
    
    [_table reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _showMods.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DragSortCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdent"];
    if (!cell) {
        cell = [[DragSortCell alloc]initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"CellIdent"];
    }
   
    [cell setMod:[_showMods objectAtIndex:indexPath.row]];
    return cell;
}


#pragma mark - 长按拖动排序相关  -

- (void)moveTableView:(FMMoveTableView *)tableView
 moveRowFromIndexPath:(NSIndexPath *)fromIndexPath
          toIndexPath:(NSIndexPath *)toIndexPath
{
    NSInteger fromRow = fromIndexPath.row;
    NSInteger toRow = toIndexPath.row;
    
    ModOrder *modMoved = _showMods[fromRow];
    ModOrder *modTo = _showMods[toRow];
    
    NSArray *arrResorted = [ModOrder modMoved:modMoved to:modTo];
    
    //以数据库中数据的sortIndex为准,更新显示的内容。因为显示的可能非全部数据，中间会有间断。
    for(NSUInteger i = 0 ;i<arrResorted.count;i++){
        
        ModOrder *modResorted = arrResorted[i];
        
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"orderId=%@", modResorted.orderId];
        NSArray *arrFiltered = [_showMods filteredArrayUsingPredicate:pre];
        if(arrFiltered.count>0){
            ModOrder *modToShow = arrFiltered.firstObject;
            modToShow.sortIndex = modResorted.sortIndex;
        }
    }
    
    NSSortDescriptor *sortor = [NSSortDescriptor sortDescriptorWithKey:@"sortIndex"ascending:YES];
    [_showMods sortUsingDescriptors:@[sortor]];
}



@end
