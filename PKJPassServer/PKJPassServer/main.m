/*
 <codex><abstract>signpass</abstract></codex>
 */

/*
 Copyright (c) 2012, Praveen K Jha, Research2Development Inc..
 All rights reserved.

 Redistribution and use in source or in binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 Redistributions in source or binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 Neither the name of the Research2Development. nor the names of its contributors may be
 used to endorse or promote products derived from this software without specific
 prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 OF THE POSSIBILITY OF SUCH DAMAGE."
 */

#import <Foundation/Foundation.h>
#import "PassSigner.h"

int main (int argc, const char * argv[])
{
    @autoreleasepool {
                
        NSString *passPath = nil;
        NSString *certSuffix = nil;
        NSString *outputPath = nil;
        NSString *verifyPath = nil;
        
        NSArray *args = [[NSProcessInfo processInfo] arguments];
        
        if ([args containsObject:@"-p"] && ![args containsObject:@"-v"]) {
            NSUInteger index = [args indexOfObject:@"-p"];
            if ((index + 1) < [args count]) { 
                passPath = [args objectAtIndex:index + 1];
            }
        }

        if ([args containsObject:@"-c"]) {
            NSUInteger index = [args indexOfObject:@"-c"];
            if ((index + 1) < [args count]) { 
                certSuffix = [args objectAtIndex:index + 1];
            }
        }

        if ([args containsObject:@"-o"]) {
            NSUInteger index = [args indexOfObject:@"-o"];
            if ((index + 1) < [args count]) { 
                outputPath = [args objectAtIndex:index + 1];
            }
        }
        
        if ([args containsObject:@"-v"] && ![args containsObject:@"-p"]) {
            NSUInteger index = [args indexOfObject:@"-v"];
            if ((index + 1) < [args count]) {
                verifyPath = [args objectAtIndex:index + 1];
            }
        }
        
        if (!passPath && !verifyPath) {
            PSPrintLine(@"usage:\tsignpass -p <rawpass> [-o <path>] [-c <certSuffix>]");
            PSPrintLine(@"\tsignpass -v <signedpass>");
            PSPrintLine(@"\n\t -p Sign and zip a raw pass directory");
            PSPrintLine(@"\t -v Unzip and verify a signed pass's signature and manifest. This DOES NOT validate pass content.");
        } else {
            
            if (passPath) {
                NSURL *outputURL;
                
                if (outputPath == nil) {
                    outputPath = [[passPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"pkpass"];
                }
                
                outputURL = [NSURL fileURLWithPath:outputPath];
                NSURL *passURL = [NSURL fileURLWithPath:passPath];
                [PassSigner signPassWithURL:passURL certSuffix:certSuffix outputURL:outputURL zip:YES];
            } else if (verifyPath) {
                NSURL *verifyURL = [NSURL fileURLWithPath:verifyPath];
                [PassSigner verifyPassSignatureWithURL:verifyURL];
            }
        }
    }
    return 0;
}

