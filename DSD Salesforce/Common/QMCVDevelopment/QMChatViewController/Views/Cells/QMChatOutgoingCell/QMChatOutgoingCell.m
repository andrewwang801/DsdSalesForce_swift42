//
//  QMChatOutgoingCell.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 29.05.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatOutgoingCell.h"

@implementation QMChatOutgoingCell

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.spaceBetweenTextViewAndBottomLabel = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    
    return defaultLayoutModel;
}

@end
