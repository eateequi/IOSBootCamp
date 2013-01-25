//
//  AnimatedView.h
//  Artists
//
//  Created by Matthijs Hollemans.
//  Copyright 2011-2012 Razeware LLC. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <UIKit/UIKit.h>

typedef void (^AnimatedViewBlock)(CGContextRef context, CGRect rect, CFTimeInterval totalTime, CFTimeInterval deltaTime);

@interface AnimatedView : UIView

@property (nonatomic, copy) AnimatedViewBlock block;

- (void)stopAnimation;

@end
