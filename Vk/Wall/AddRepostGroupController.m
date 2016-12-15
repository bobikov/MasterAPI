//
//  AddRepostGroupController.m
//  MasterAPI
//
//  Created by sim on 09.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "AddRepostGroupController.h"

@interface AddRepostGroupController ()

@end

@implementation AddRepostGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"%@", _receivedData);
//    [self removeAllGroups];
}
- (IBAction)saveGroup:(id)sender {
    [self addGroup];
}
-(void)removeAllGroups{
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext=moc;
//    NSEntityDescription *entityDesc1 = [NSEntityDescription entityForName:@"VKUserRepostGroupsNames" inManagedObjectContext:moc];
    NSFetchRequest *request = [ NSFetchRequest fetchRequestWithEntityName:@"VKUserRepostGroupsNames"];
    NSError *readError;
    NSError *saveError;
//    [request setResultType:NSDictionaryResultType];
    [request setReturnsObjectsAsFaults:NO];
    NSArray *data = [temporaryContext executeFetchRequest:request error:&readError];
    for(NSManagedObject *object in data){
        [temporaryContext deleteObject:object];
        if(![temporaryContext save:&saveError]){
            NSLog(@"Error has occuring while removing repost group name object.");
            
        }else{
            NSLog(@"Repost group name object has removed successfully.");
            
        }
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadListUserRepostGroups" object:nil];
  
    
}
-(void)addGroup{
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext=moc;
    [temporaryContext performBlock:^{
    
        
        NSEntityDescription *entityDesc1 = [NSEntityDescription entityForName:@"VKUserRepostGroupsNames" inManagedObjectContext:moc];
        //    NSError *saveError;
        //    NSError *saveError2;
        NSError *saveError3;
        NSMutableArray *objects = [[NSMutableArray alloc]init];
        
        NSManagedObject *object = [[NSManagedObject alloc]initWithEntity:entityDesc1 insertIntoManagedObjectContext:temporaryContext];
        [object setValue:groupName.stringValue forKey:@"name"];
        //    if(![moc save:&saveError]){
        //        NSLog(@"Error save name of repost group.");
        //    }else{
        //        NSLog(@"Repost name of group successfully saved.");
        
        
        for(NSDictionary *i in _receivedData){
            NSEntityDescription *entityDesc2 = [NSEntityDescription entityForName:@"VKUserRepostGroups" inManagedObjectContext:temporaryContext];
            NSManagedObject *object2 = [[NSManagedObject alloc] initWithEntity:entityDesc2 insertIntoManagedObjectContext:temporaryContext];
            [object2 setValue:i[@"id"] forKey:@"id"];
            [object2 setValue:i[@"photo"] forKey:@"photo"];
            [object2 setValue:i[@"deactivated"] forKey:@"deactivated"];
            [object2 setValue:i[@"desc"] forKey:@"desc"];
            [object2 setValue:i[@"name"] forKey:@"name"];
            //            NSLog(@"%@",i[@"name"]);
            //            [seet addObject:object2];
            
            [objects addObject:object2];
            
        }
        
        [object setValue:[NSSet setWithArray:objects] forKey:@"userRepostGroups"];
        if(![temporaryContext save:&saveError3]){
            NSLog(@"Error save items in group.");
        }
            
            
        
        [moc performBlockAndWait:^{
            NSError *error=nil;
            if (![moc save:&error]) {
                NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
                abort();
            }else{
                NSLog(@"Items in group successfully saved.");
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadListUserRepostGroups" object:nil];
            }
        }];
        
        
    }];
}

@end
