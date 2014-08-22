//
//  CheckNetwork.mm
//  ROBBMEET
//
//  Created by Iori on 12-3-30.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CheckNetwork.h"
#import "Reachability.h"
@implementation CheckNetwork

/*- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}*/

+(BOOL)isExistenceNetwork
{
	BOOL isExistenceNetwork;

    Reachability *HH = [Reachability reachabilityWithHostname:@""];
    switch ([HH currentReachabilityStatus]) {
        case NotReachable:
			isExistenceNetwork=FALSE;
			//   NSLog(@"娌℃湁缃戠粶");
            break;
        case ReachableViaWWAN:
			isExistenceNetwork=TRUE;
			//   NSLog(@"姝ｅ湪浣跨敤3G缃戠粶");
            break;
        case ReachableViaWiFi:
			isExistenceNetwork=TRUE;
			//  NSLog(@"姝ｅ湪浣跨敤wifi缃戠粶");        
            break;
    }
	if (!isExistenceNetwork) {
		UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"网络连接不可用" message:@"请重试..." delegate:self cancelButtonTitle:@"确认" 
                                                otherButtonTitles:nil,nil];
		[myalert show];
        
      /*  UIAlertView *theAlert = [[UIAlertView alloc] initWithTitle:@"Atention"
                                                            message: @"I'm a Chinese!"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Cancel" 
                                                  otherButtonTitles:@"Okay",nil];
        
        [theAlert show];
                
        
        UIImage *theImage = [UIImage imageNamed:@"loveChina.png"];    
        theImage = [theImage stretchableImageWithLeftCapWidth:0. topCapHeight:0.];
        CGSize theSize = [myalert frame].size;
        
        UIGraphicsBeginImageContext(theSize);    
        [theImage drawInRect:CGRectMake(0, 0, theSize.width, theSize.height)];    
        theImage = UIGraphicsGetImageFromCurrentImageContext();    
        UIGraphicsEndImageContext();
        myalert.layer.contents = (id)[theImage CGImage];*/

	}
	return isExistenceNetwork;
}

+(BOOL)isGoodNetwork
{
	Reachability *reach = [Reachability reachabilityForInternetConnection];	
    NetworkStatus netStatus = [reach currentReachabilityStatus];    
    return !(netStatus == NotReachable) ;
}




@end
