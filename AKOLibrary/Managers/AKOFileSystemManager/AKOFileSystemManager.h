//
//  AKOFileSystemManager.h
//  AKOLibrary
//
//  Created by Adrian on 4/15/11.
//  Copyright (c) 2009, 2010, 2011, Adrian Kosmaczewski & akosma software
//  All rights reserved.
//  
//  Use in source and/or binary forms without modification is permitted following the
//  instructions in the LICENSE file.
//  
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
//  OF THE POSSIBILITY OF SUCH DAMAGE.
//

/**
 @file AKOFileSystemManager.h
 Contains the definition of the AKOFileSystemManager class.
 */

#import <Foundation/Foundation.h>


/**
 Wraps all accesses to the file system.
 */
@interface AKOFileSystemManager : NSObject 

/**
 Contains the value of the application documents directory of the current app.
 */
@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

/**
 Contains the value of the application cache directory of the current app.
 */
@property (nonatomic, readonly) NSString *applicationCacheDirectory;

/**
 Contains the value of the application temp directory of the current app.
 */
@property (nonatomic, readonly) NSString *applicationTempDirectory;


/**
 Returns a pointer to the singleton instance of this class.
 @return A pointer to the singleton instance of this class.
 */
+ (AKOFileSystemManager *)sharedAKOFileSystemManager;

/**
 Removed the file with the path passed as parameter.
 @param path An NSString with the path of the file to remove.
 */
- (void)removeFile:(NSString *)path;

@end
