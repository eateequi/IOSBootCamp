//
//  HelloWorldScene.m
//  Breakout
//
//  Created by Ray Wenderlich on 2/17/10.
//  Copyright 2011 Razeware LLC. All rights reserved.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "HelloWorldScene.h"
#import "GameOverScene.h"
#import "SimpleAudioEngine.h"

#define PTM_RATIO 32

@implementation HelloWorld
{
	b2World *_world;
	b2Body *_groundBody;
	b2Body *_paddleBody;    
	b2Fixture *_paddleFixture;
	b2Fixture *_ballFixture;
	b2Fixture *_bottomFixture;
	b2MouseJoint *_mouseJoint;
	MyContactListener *_contactListener;
}

+ (id)scene
{
	CCScene *scene = [CCScene node];
	HelloWorld *layer = [HelloWorld node];
	[scene addChild:layer];
	return scene;
}

- (id)init
{
	if ((self = [super init]))
	{
		CGSize winSize = [CCDirector sharedDirector].winSize;

		self.isTouchEnabled = YES;

		// Create a world
		b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
		bool doSleep = true;
		_world = new b2World(gravity, doSleep);

		// Create edges around the entire screen
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0,0);
		_groundBody = _world->CreateBody(&groundBodyDef);
		b2PolygonShape groundBox;
		b2FixtureDef groundBoxDef;
		groundBoxDef.shape = &groundBox;
		groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(winSize.width/PTM_RATIO, 0));
		_bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
		groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
		_groundBody->CreateFixture(&groundBoxDef);
		groundBox.SetAsEdge(b2Vec2(0, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
		_groundBody->CreateFixture(&groundBoxDef);
		groundBox.SetAsEdge(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, 0));
		_groundBody->CreateFixture(&groundBoxDef);

		// Create sprite and add it to the layer
		CCSprite *ball = [CCSprite spriteWithFile:@"Ball.png" rect:CGRectMake(0, 0, 52, 52)];
		ball.position = ccp(100, 100);
		ball.tag = 1;
		[self addChild:ball]; 

		// Create ball body 
		b2BodyDef ballBodyDef;
		ballBodyDef.type = b2_dynamicBody;
		ballBodyDef.position.Set(100/PTM_RATIO, 100/PTM_RATIO);
		ballBodyDef.userData = (__bridge void *)ball;
		b2Body * ballBody = _world->CreateBody(&ballBodyDef);

		// Create circle shape
		b2CircleShape circle;
		circle.m_radius = 26.0/PTM_RATIO;

		// Create shape definition and add to body
		b2FixtureDef ballShapeDef;
		ballShapeDef.shape = &circle;
		ballShapeDef.density = 1.0f;
		ballShapeDef.friction = 0.0f; // We don't want the ball to have friction!
		ballShapeDef.restitution = 1.0f;
		_ballFixture = ballBody->CreateFixture(&ballShapeDef);

		// Give shape initial impulse...
		b2Vec2 force = b2Vec2(10, 10);
		ballBody->ApplyLinearImpulse(force, ballBodyDef.position);

		// Create paddle and add it to the layer
		CCSprite *paddle = [CCSprite spriteWithFile:@"Paddle.png"];
		paddle.position = ccp(winSize.width/2, 50);
		[self addChild:paddle];

		// Create paddle body
		b2BodyDef paddleBodyDef;
		paddleBodyDef.type = b2_dynamicBody;
		paddleBodyDef.position.Set(winSize.width/2/PTM_RATIO, 50/PTM_RATIO);
		paddleBodyDef.userData = (__bridge void*)paddle;
		_paddleBody = _world->CreateBody(&paddleBodyDef);

		// Create paddle shape
		b2PolygonShape paddleShape;
		paddleShape.SetAsBox(paddle.contentSize.width/PTM_RATIO/2, 
		 paddle.contentSize.height/PTM_RATIO/2);

		// Create shape definition and add to body
		b2FixtureDef paddleShapeDef;
		paddleShapeDef.shape = &paddleShape;
		paddleShapeDef.density = 10.0f;
		paddleShapeDef.friction = 0.4f;
		paddleShapeDef.restitution = 0.1f;
		_paddleFixture = _paddleBody->CreateFixture(&paddleShapeDef);

		// Restrict paddle along the x axis
		b2PrismaticJointDef jointDef;
		b2Vec2 worldAxis(1.0f, 0.0f);
		jointDef.collideConnected = true;
		jointDef.Initialize(_paddleBody, _groundBody, _paddleBody->GetWorldCenter(), worldAxis);
		_world->CreateJoint(&jointDef);

		for(int i = 0; i < 4; i++)
		{
			static int padding = 20;

			// Create block and add it to the layer
			CCSprite *block = [CCSprite spriteWithFile:@"Block.png"];
			int xOffset = padding+block.contentSize.width/2+((block.contentSize.width+padding)*i);
			block.position = ccp(xOffset, 250);
			block.tag = 2;
			[self addChild:block];

			// Create block body
			b2BodyDef blockBodyDef;
			blockBodyDef.type = b2_dynamicBody;
			blockBodyDef.position.Set(xOffset/PTM_RATIO, 250/PTM_RATIO);
			blockBodyDef.userData = (__bridge void*)block;
			b2Body *blockBody = _world->CreateBody(&blockBodyDef);

			// Create block shape
			b2PolygonShape blockShape;
			blockShape.SetAsBox(block.contentSize.width/PTM_RATIO/2, block.contentSize.height/PTM_RATIO/2);

			// Create shape definition and add to body
			b2FixtureDef blockShapeDef;
			blockShapeDef.shape = &blockShape;
			blockShapeDef.density = 10.0;
			blockShapeDef.friction = 0.0;
			blockShapeDef.restitution = 0.1f;
			blockBody->CreateFixture(&blockShapeDef);
		}

		// Create contact listener
		_contactListener = new MyContactListener();
		_world->SetContactListener(_contactListener);

		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];

		[self schedule:@selector(tick:)];
	}
	return self;
}

- (void)tick:(ccTime)dt
{
	bool blockFound = false;
	_world->Step(dt, 10, 10);

	for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext())
	{    
		if (b->GetUserData() != NULL)
		{
			CCSprite *sprite = (__bridge CCSprite *)b->GetUserData();
			if (sprite.tag == 2)
			{
				blockFound = true;
			}

			if (sprite.tag == 1)
			{
				static int maxSpeed = 10;

				b2Vec2 velocity = b->GetLinearVelocity();
				float32 speed = velocity.Length();

				// When the ball is greater than max speed, slow it down by
				// applying linear damping.  This is better for the simulation
				// than raw adjustment of the velocity.
				if (speed > maxSpeed)
					b->SetLinearDamping(0.5);
				else if (speed < maxSpeed)
					b->SetLinearDamping(0.0);
			}

			sprite.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}        
	}

	if (!blockFound)
	{
		GameOverScene *gameOverScene = [GameOverScene node];
		[gameOverScene.layer.label setString:@"You Win!"];
		[[CCDirector sharedDirector] replaceScene:gameOverScene];
	}

	std::vector<b2Body *>toDestroy;
	std::vector<MyContact>::iterator pos;
	for(pos = _contactListener->_contacts.begin(); pos != _contactListener->_contacts.end(); ++pos)
	{
		MyContact contact = *pos;

		if ((contact.fixtureA == _bottomFixture && contact.fixtureB == _ballFixture) ||
			(contact.fixtureA == _ballFixture && contact.fixtureB == _bottomFixture))
		{
			GameOverScene *gameOverScene = [GameOverScene node];
			[gameOverScene.layer.label setString:@"You Lose :["];
			[[CCDirector sharedDirector] replaceScene:gameOverScene];
		} 

		b2Body *bodyA = contact.fixtureA->GetBody();
		b2Body *bodyB = contact.fixtureB->GetBody();
		if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL)
		{
			CCSprite *spriteA = (__bridge CCSprite *) bodyA->GetUserData();
			CCSprite *spriteB = (__bridge CCSprite *) bodyB->GetUserData();

			// Sprite A = ball, Sprite B = Block
			if (spriteA.tag == 1 && spriteB.tag == 2)
			{
				if (std::find(toDestroy.begin(), toDestroy.end(), bodyB) == toDestroy.end())
				{
					toDestroy.push_back(bodyB);
				}
			}
			// Sprite B = block, Sprite A = ball
			else if (spriteA.tag == 2 && spriteB.tag == 1)
			{
				if (std::find(toDestroy.begin(), toDestroy.end(), bodyA) == toDestroy.end())
				{
					toDestroy.push_back(bodyA);
				}
			}        
		}
	}

	std::vector<b2Body *>::iterator pos2;
	for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2)
	{
		b2Body *body = *pos2;     
		if (body->GetUserData() != NULL)
		{
			CCSprite *sprite = (__bridge CCSprite *) body->GetUserData();
			[self removeChild:sprite cleanup:YES];
		}
		_world->DestroyBody(body);
	}

	if (toDestroy.size() > 0)
	{
		[[SimpleAudioEngine sharedEngine] playEffect:@"blip.caf"];   
	}
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_mouseJoint != NULL) return;

	UITouch *myTouch = [touches anyObject];
	CGPoint location = [myTouch locationInView:[myTouch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);

	if (_paddleFixture->TestPoint(locationWorld))
	{
		b2MouseJointDef md;
		md.bodyA = _groundBody;
		md.bodyB = _paddleBody;
		md.target = locationWorld;
		md.collideConnected = true;
		md.maxForce = 1000.0f * _paddleBody->GetMass();

		_mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
		_paddleBody->SetAwake(true);
	}
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_mouseJoint == NULL) return;

	UITouch *myTouch = [touches anyObject];
	CGPoint location = [myTouch locationInView:[myTouch view]];
	location = [[CCDirector sharedDirector] convertToGL:location];
	b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);

	_mouseJoint->SetTarget(locationWorld);
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_mouseJoint)
	{
		_world->DestroyJoint(_mouseJoint);
		_mouseJoint = NULL;
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (_mouseJoint)
	{
		_world->DestroyJoint(_mouseJoint);
		_mouseJoint = NULL;
	}  
}

- (void)dealloc
{
	delete _contactListener;
	delete _world;
	_groundBody = NULL;
}

@end
