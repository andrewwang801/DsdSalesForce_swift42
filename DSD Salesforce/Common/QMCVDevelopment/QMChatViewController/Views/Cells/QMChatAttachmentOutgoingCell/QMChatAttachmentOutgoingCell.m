//
//  QMChatAttachmentOutgoingCell.m
//  QMChatViewController
//
//  Created by Injoit on 7/1/15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatAttachmentOutgoingCell.h"

@interface QMChatAttachmentOutgoingCell()

@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

@implementation QMChatAttachmentOutgoingCell
@synthesize attachmentID = _attachmentID;

+ (QMChatCellLayoutModel)layoutModel {
    
    QMChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = defaultLayoutModel.containerInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    defaultLayoutModel.topLabelHeight = 0;
    defaultLayoutModel.bottomLabelHeight = 14;
    
    return defaultLayoutModel;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.attachmentImageView.image = nil;
}

- (void)setAttachmentImage:(UIImage *)attachmentImage isCenter:(BOOL)center{
    
    self.progressLabel.hidden = YES;
    self.attachmentImageView.image = attachmentImage;
    if (center == YES) {
        self.attachmentImageView.contentMode = UIViewContentModeCenter;
    }
    else {
        self.attachmentImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
}

- (void)updateLoadingProgress:(CGFloat)progress {
    
    if (progress > 0.0) {
        self.progressLabel.hidden = NO;
    }
    
    self.progressLabel.text = [NSString stringWithFormat:@"%2.0f %%", progress * 100.0f];
}

@end
