//
//  MelodyTableViewCell.m
//  PianoHelp
//
//  Created by Jobs on 14-5-19.
//  Copyright (c) 2014年 FlintInfo. All rights reserved.
//

#import "MelodyTableViewCell.h"
#import "Users.h"
#import "Melody.h"
#import "MelodyFavorite.h"
#import "MelodyCategory.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "MessageBox.h"

@implementation MelodyTableViewCell

-(MelodyFavorite*)getFavoriteByMelody
{
    NSManagedObjectContext *moc = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MelodyFavorite" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSManagedObjectResultType];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user.userName == %@ and melody.filePath = %@", [UserInfo sharedUserInfo].userName, self.melody.filePath];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *objects = [moc executeFetchRequest:fetchRequest error:&error];
    if([objects count]>0)
    {
        return [objects firstObject];
    }
    return nil;
}

-(void) updateContent:(id)obj
{
    self.melody = (Melody*)obj;
    self.labTitle.text = self.melody.name;
    self.btnView.fileName = self.melody.filePath;
    self.btnView.melody = self.melody;
    
    MelodyFavorite *favo = [self getFavoriteByMelody];
    
    if(favo)
    {
        self.btnView.type = [favo.sort intValue];
        if([favo.sort intValue] == 1)
        {
            [self.btnFavorite setSelected:YES];
            [self.btnTask setSelected:NO];
        }
        else if([favo.sort intValue] == 2)
        {
            [self.btnFavorite setSelected:NO];
            [self.btnTask setSelected:YES];
        }
        else if([favo.sort intValue] == 3)
        {
            [self.btnFavorite setSelected:YES];
            [self.btnTask setSelected:YES];
        }
    }
    else
    {
        self.btnView.type = 0;
        [self.btnFavorite setSelected:NO];
        [self.btnTask setSelected:NO];
    }
    
    if(self.isInSearch)
    {
        if([self.melody.buy intValue] == 1  || [self.melody.category.parentCategory.buy intValue] ==1)
        {
            [self.btnBuy setSelected:YES];
            self.labBuy.text = @"已购买";
        }
        else
        {
            [self.btnBuy setSelected:NO];
            self.labBuy.text = @"未购买";
        }
        self.btnBuy.hidden = NO;
        self.labBuy.hidden = NO;
    }
    else
    {
        self.btnBuy.hidden = YES;
        self.labBuy.hidden = YES;
    }
}
- (IBAction)btnFavorite_click:(id)sender
{
    if([self.melody.category.parentCategory.buy intValue] == 2)
    {
        [MessageBox showMsg:[NSString stringWithFormat:@"该乐曲所在专辑(%@)还未购买.", self.melody.category.parentCategory.name]];
        return;
    }
    NSManagedObjectContext *moc = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    MelodyFavorite *favo = [self getFavoriteByMelody];
    if (favo == nil)
    {
        MelodyFavorite *favo = (MelodyFavorite*)[NSEntityDescription insertNewObjectForEntityForName:@"MelodyFavorite" inManagedObjectContext:moc];
        favo.user = [UserInfo sharedUserInfo].dbUser;
        favo.melody = self.melody;
        favo.sort = [NSNumber numberWithInt:1];
    }
    else
    {
        if([favo.sort intValue] == 1)
        {
            [moc deleteObject:favo];
        }
        else if([favo.sort intValue] == 2)
        {
            favo.sort = [NSNumber numberWithInt:3];
        }
        else if([favo.sort intValue] == 3)
        {
            favo.sort = [NSNumber numberWithInt:2];
        }
    }
    
    NSError *error;
    if(![moc save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
//    if([self.updateDelegate conformsToProtocol:@protocol(MelodyTableViewCellDelegate) ])
//    {
//        [self.updateDelegate updateMelodyState];
//    }
//    if ([self.updateDelegate respondsToSelector:@selector(updateMelodyState)]) //刷新列表中的 图标状态
//    {
//        [self.updateDelegate updateMelodyState];
//    }
    [self updateContent:self.melody];
}

- (IBAction)btnTask_click:(id)sender
{
    if([self.melody.category.parentCategory.buy intValue] == 2)
    {
        [MessageBox showMsg:[NSString stringWithFormat:@"该乐曲所在专辑(%@)还未购买.", self.melody.category.parentCategory.name]];
        return;
    }
    NSManagedObjectContext *moc = ((AppDelegate*)[UIApplication sharedApplication].delegate).managedObjectContext;
    MelodyFavorite *favo = [self getFavoriteByMelody];
    if (favo == nil)
    {
        MelodyFavorite *favo = (MelodyFavorite*)[NSEntityDescription insertNewObjectForEntityForName:@"MelodyFavorite" inManagedObjectContext:moc];
        favo.user = [UserInfo sharedUserInfo].dbUser;
        favo.melody = self.melody;
        favo.sort = [NSNumber numberWithInt:2];
    }
    else
    {
        if([favo.sort intValue] == 1)
        {
            favo.sort = [NSNumber numberWithInt:3];
        }
        else if([favo.sort intValue] == 2)
        {
            [moc deleteObject:favo];
        }
        else if([favo.sort intValue] == 3)
        {
            favo.sort = [NSNumber numberWithInt:1];
        }
    }
    
    NSError *error;
    if(![moc save:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    //    if([self.updateDelegate conformsToProtocol:@protocol(MelodyTableViewCellDelegate) ])
    //    {
    //        [self.updateDelegate updateMelodyState];
    //    }
//    if ([self.updateDelegate respondsToSelector:@selector(updateMelodyState)])
//    {
//        [self.updateDelegate updateMelodyState];
//    }
    [self updateContent:self.melody];
}

- (IBAction)btnBuy_click:(id)sender
{
}

- (IBAction)btnView_click:(id)sender
{
    for (UITableViewCell *cell in self.tableView.visibleCells)
    {
        cell.selected = NO;
        ((MelodyTableViewCell*)cell).btnView.highlighted = NO;
    }
    self.selected = YES;
}
@end
