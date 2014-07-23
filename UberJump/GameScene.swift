//
//  GameScene.swift
//  UberJump
//
//  Created by wubin on 7/21/14.
//  Copyright (c) 2014 wubin. All rights reserved.
//

import SpriteKit



class GameScene: SKScene, SKPhysicsContactDelegate{
    
    
    var backgroundNode:SKNode?
    var foregroundNode:SKNode = SKNode()
    var playerNode:SKNode?
    var hudNode:SKNode?
    
    var tapToStartNode:SKSpriteNode?
    // Height at which level ends
    var _endLevelY:Int?
    
    let CollisionCategoryPlayer:UInt32   = 0x1 << 0
    let CollisionCategoryStar:UInt32     = 0x1 << 1
    let CollisionCategoryPlatform:UInt32 = 0x1 << 2
    
    init(size :CGSize){
        super.init(size: size)
        self.backgroundColor = SKColor.blackColor()
        
        
        
        
        
        
        hudNode = SKNode()
        self.addChild(hudNode)
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -2.0)
        
        self.physicsWorld.contactDelegate = self
        
        backgroundNode = createBackgroundNode()
        self.addChild(backgroundNode)
        
        let platform = createPlatformAtPosition(CGPointMake(160, 320), type: PlatfromType.PLATFORM_NORMAL)
        foregroundNode.addChild(platform)
        
        let star = createStarAtPosition(CGPointMake(160, 220), type: StarType.STAR_SPECIAL)
        foregroundNode.addChild(star)
        self.addChild(foregroundNode)
        
        playerNode = createPlayer()
        self.addChild(playerNode)
        
        tapToStartNode = SKSpriteNode(imageNamed: "TapToStart")
        tapToStartNode!.position = CGPointMake(160, 180)
        if hudNode {
            hudNode!.addChild(tapToStartNode)
        }
        
        
        
        
        
        let levelPlist:NSString = NSBundle.mainBundle().pathForResource("Level01", ofType: "plist")
        let levelData:NSDictionary = NSDictionary(contentsOfFile: levelPlist)
        
        _endLevelY =  levelData["EndY"] as? Int
        println("\(_endLevelY)")
        
        
    }
    
    func createBackgroundNode() -> SKNode{
        var bgNode = SKNode()
        
        for i in 0..<20 {
            let imageNamed = String(format: "Background%02d", i+1)
            var node = SKSpriteNode(imageNamed: imageNamed)
            node.position = CGPointMake(160.0, CGFloat(i)*64.0)
            node.anchorPoint = CGPointMake(0.5, 0.0)
            
            bgNode.addChild(node)
        }
        
        return bgNode
    }
    
    
    func createPlayer() -> SKNode{
        var pNode = SKNode()
        let sprite = SKSpriteNode(imageNamed: "Player")
        pNode.addChild(sprite)
        pNode.position = CGPointMake(160, 80)
        
        pNode.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
        pNode.physicsBody.dynamic = false
        pNode.physicsBody.allowsRotation = false
        pNode.physicsBody.restitution = 1.0
        pNode.physicsBody.friction = 0.0
        pNode.physicsBody.angularDamping = 0.0
        pNode.physicsBody.linearDamping = 0.0
        
        pNode.physicsBody.usesPreciseCollisionDetection = true
        pNode.physicsBody.categoryBitMask = CollisionCategoryPlayer
        pNode.physicsBody.collisionBitMask = 0;
        pNode.physicsBody.contactTestBitMask = CollisionCategoryStar | CollisionCategoryPlatform
        
        
        return pNode
    }
    
    func createStarAtPosition(position:CGPoint, type:StarType) -> StarNode{
        var node = StarNode()
        node.position = position
        node.name = "NODE_STAR"
        var sprite:SKSpriteNode?
        
        if type == StarType.STAR_SPECIAL {
            sprite = SKSpriteNode(imageNamed: "StarSpecial")
        } else if type == StarType.STAR_NORMAL{
            sprite = SKSpriteNode(imageNamed: "Star")
        }
        node.addChild(sprite)
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite!.size.width/2)
        
        node.physicsBody.dynamic = false
        
        node.physicsBody.categoryBitMask  = CollisionCategoryStar
        node.physicsBody.collisionBitMask = 0
        
        
        return node
    }
    
    func createPlatformAtPosition(position:CGPoint, type:PlatfromType) -> PlatformNode {
        var node = PlatformNode()
        node.position = position
        node.name = "NODE_PLATFORM"
        node.platformType = type
        
        var sprite:SKSpriteNode?
        if type == PlatfromType.PLATFORM_BREAK {
            sprite = SKSpriteNode(imageNamed: "PlatformBreak")
        }else if type == PlatfromType.PLATFORM_NORMAL {
            sprite = SKSpriteNode(imageNamed: "Platform")
        }
        node.addChild(sprite)
        
        node.physicsBody = SKPhysicsBody(rectangleOfSize: sprite!.size)
        node.physicsBody.dynamic = false
        node.physicsBody.categoryBitMask = CollisionCategoryPlatform
        node.physicsBody.collisionBitMask = 0;
        
        return node
    }
    
    
    func didBeginContact(contact: SKPhysicsContact!) {
        var other:GameObjectNode
        let nodeA = contact.bodyA.node
        let nodeB = contact.bodyB.node
        if nodeA != playerNode {
            other = nodeA as GameObjectNode
        }else {
            other = nodeB as GameObjectNode
        }
        
        let updateHUD = other.collisionWithPlayer(playerNode!)
        
        if updateHUD {
            
        }
        
    }
    
    
    
    
    
    override func didMoveToView(view: SKView) {
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if playerNode!.physicsBody.dynamic{
            return
        }
        tapToStartNode!.removeFromParent()
        
        playerNode!.physicsBody.dynamic = true
        
        playerNode!.physicsBody.applyImpulse(CGVectorMake(0.0, 20.0))
        
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
