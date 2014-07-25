import SpriteKit
import CoreMotion


class GameScene: SKScene, SKPhysicsContactDelegate{
    
    
    var backgroundNode:SKNode?
    var midgroundNode:SKNode?
    var foregroundNode:SKNode = SKNode()
    
    var playerNode:SKNode?
    var hudNode:SKNode?
    
    var tapToStartNode:SKSpriteNode?
    // Height at which level ends
    var _endLevelY:CGFloat?
    
    var maxPlayerY:Int = 0
    
    let CollisionCategoryPlayer:UInt32   = 0x1 << 0
    let CollisionCategoryStar:UInt32     = 0x1 << 1
    let CollisionCategoryPlatform:UInt32 = 0x1 << 2
    let platformNormalTexture = SKTexture(imageNamed: "Platform.png")
    let platformBreakTexture = SKTexture(imageNamed: "PlatformBreak.png")
    let starTexture = SKTexture(imageNamed: "Star.png")
    let starSpecialTexture = SKTexture(imageNamed: "StarSpecial.png")
    
    var motionManager:CMMotionManager = CMMotionManager()
    var xAcceleration:CGFloat = 0
    
    let lblScore:SKLabelNode = SKLabelNode()
    let lblStars:SKLabelNode = SKLabelNode()
    
    var gameOver:Bool = false
    
    init(size :CGSize){
        super.init(size: size)
        self.backgroundColor = SKColor.blackColor()
        
        let levelPlist:NSString = NSBundle.mainBundle().pathForResource("Level01", ofType: "plist")
        let levelData:NSDictionary = NSDictionary(contentsOfFile: levelPlist)
        
        _endLevelY =  levelData["EndY"] as? CGFloat
        println("\(_endLevelY)")

        
        
        
        
        hudNode = SKNode()
        self.addChild(hudNode)
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -2.0)
        
        self.physicsWorld.contactDelegate = self
        
        backgroundNode = createBackgroundNode()
        self.addChild(backgroundNode)
        maxPlayerY = 80
        gameOver = false
        GameState.sharedInstance.score = 0
        GameState.sharedInstance.stars = 0
        
        
        midgroundNode = createMidgroundNode()
        self.addChild(midgroundNode)
        
//        let platform = createPlatformAtPosition(CGPointMake(160, 320), type: PlatfromType.PLATFORM_NORMAL)
//        foregroundNode.addChild(platform)
        foregroundNode = SKNode()
        let platforms:NSDictionary = levelData["Platforms"] as NSDictionary
        let platformsPatterns:NSDictionary = platforms["Patterns"] as NSDictionary
        println(platformsPatterns)
        let platformPositions:Array<NSDictionary> = platforms["Positions"] as Array<NSDictionary>
        println(platformPositions)
        for platformPosition: NSDictionary in platformPositions {
            let patternX:CGFloat = platformPosition["x"] as CGFloat
            let patternY:CGFloat = platformPosition["y"] as CGFloat
            let pattern:String = platformPosition["pattern"] as String;
            
            println(patternX)
            println(pattern)
            let platformPattern:Array<NSDictionary> = platformsPatterns[pattern] as Array<NSDictionary>
            for platformPoint:NSDictionary in platformPattern {
                let x:CGFloat = platformPoint["x"] as CGFloat
                let y:CGFloat = platformPoint["y"] as CGFloat
                
                let typeInt:Int = platformPoint["type"] as Int
                println(typeInt)
                let type:PlatfromType = PlatfromType.fromRaw(typeInt)!
                
                println(type.toRaw())
                let platformNode = createPlatformAtPosition(CGPointMake(x + patternX, y + patternY), type: type)
                println(platformNode)
                foregroundNode.addChild(platformNode)
            }
            
        }
        
        
        
//        let star = createStarAtPosition(CGPointMake(160, 220), type: StarType.STAR_SPECIAL)
//        foregroundNode.addChild(star)
        
        let stars:NSDictionary = levelData["Stars"] as NSDictionary
        let starPatterns:NSDictionary = stars["Patterns"] as NSDictionary
        let starPositions:Array<NSDictionary> = stars["Positions"] as Array<NSDictionary>
        
        for starPosition:NSDictionary in starPositions {
            let patternX:CGFloat = starPosition["x"] as CGFloat
            let patternY:CGFloat = starPosition["y"] as CGFloat
            let pattern:String = starPosition["pattern"] as String
            
            let starPattern:Array<NSDictionary> = starPatterns[pattern] as Array<NSDictionary>
            for starPoint:NSDictionary in starPattern{
                let x:CGFloat = starPoint["x"] as CGFloat
                let y:CGFloat = starPoint["y"] as CGFloat
                let typeInt:Int = starPoint["type"] as Int
                let type:StarType = StarType.fromRaw(typeInt)!
                
                let starNode = createStarAtPosition(CGPointMake(x + patternX, y + patternY), type: type)
                foregroundNode.addChild(starNode)
            }
            
        }
        
        
        
        self.addChild(foregroundNode)
        
        playerNode = createPlayer()
        foregroundNode.addChild(playerNode)
        
        tapToStartNode = SKSpriteNode(imageNamed: "TapToStart")
        tapToStartNode!.position = CGPointMake(160, 180)
        if hudNode {
            hudNode!.addChild(tapToStartNode)
        }
        
        
        let star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPointMake(25, self.size.height - 30)
        hudNode!.addChild(star)
        
        lblStars = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblStars.fontSize = 30;
        lblStars.fontColor = SKColor.whiteColor()
        lblStars.position = CGPointMake(50, self.size.height - 40)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        lblStars.text = String(format: "X %D", GameState.sharedInstance.stars)
        hudNode!.addChild(lblStars)
        
        lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 30
        lblScore.fontColor = SKColor.whiteColor()
        lblScore.position = CGPointMake(self.size.width - 20, self.size.height - 40)
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        lblScore.text = "0"
        hudNode!.addChild(lblScore)
        
        
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler:
            {(accelerometerData:CMAccelerometerData!, error:NSError!) -> Void in
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            })
        
        
        
        
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
    
    func createMidgroundNode() -> SKNode{
        var midgroundNode:SKNode = SKNode()
        for i in 0..<10 {
            var spriteName:String
            let r = arc4random() % 2
            if r > 0{
                spriteName = "BranchRight"
            } else {
                spriteName = "BranchLeft"
            }
            
            let branchNode = SKSpriteNode(imageNamed: spriteName)
            branchNode.position = CGPointMake(160.0, 500*CGFloat(i))
            midgroundNode.addChild(branchNode)
        }
        
        return midgroundNode
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
        node.starType = type
        var sprite:SKSpriteNode = SKSpriteNode(texture: starTexture)
        println("starType = \(type.toRaw())")
        
        if type == StarType.STAR_SPECIAL {
            sprite = SKSpriteNode(texture: starSpecialTexture)
        } else if type == StarType.STAR_NORMAL{
            sprite = SKSpriteNode(texture: starTexture)
        }
        node.addChild(sprite)
        
        println(sprite)
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
        
        node.physicsBody.dynamic = false
        
        node.physicsBody.categoryBitMask  = CollisionCategoryStar
        node.physicsBody.collisionBitMask = 0
        
        
        return node
    }
    
    func createPlatformAtPosition(position:CGPoint, type:PlatfromType) -> PlatformNode {
        println("type = \(type)")
        var node = PlatformNode()
        node.position = position
        node.name = "NODE_PLATFORM"
        node.platformType = type
        
        
        
        println(platformNormalTexture)
        
        var sprite:SKSpriteNode?
        if type == PlatfromType.PLATFORM_BREAK {
            sprite = SKSpriteNode(texture: platformBreakTexture )
        }else if type == PlatfromType.PLATFORM_NORMAL {
            sprite = SKSpriteNode(texture: platformNormalTexture)
        }
        println(sprite)
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
            lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
            lblScore.text = String(format: "%d", GameState.sharedInstance.score)
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
//        foregroundNode.enumerateChildNodesWithName("NODE_PLATFORM", usingBlock:
//          )
        if gameOver {
            return
        }
        
        if playerNode!.position.y > 200 {
            backgroundNode!.position = CGPointMake(0.0, -(playerNode!.position.y - 200)/10)
            midgroundNode!.position = CGPointMake(0.0, -(playerNode!.position.y - 200)/4)
            foregroundNode.position = CGPointMake(0.0, -(playerNode!.position.y - 200))
        }
        if Int(playerNode!.position.y) > maxPlayerY {
            GameState.sharedInstance.score += Int(playerNode!.position.y) - maxPlayerY
            maxPlayerY = Int(playerNode!.position.y)
            lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        }
        
        if playerNode!.position.y > _endLevelY {
            endGame()
        }
        
        if playerNode!.position.y < -20 {
            endGame()
        }
        
    }
    
    override func didSimulatePhysics() {
        playerNode!.physicsBody.velocity  = CGVectorMake(xAcceleration * 400, playerNode!.physicsBody.velocity.dy)
        
        if playerNode!.position.x < -20 {
            playerNode!.position = CGPointMake(340, playerNode!.position.y)
        } else if playerNode!.position.x > 340 {
            playerNode!.position = CGPointMake(-20, playerNode!.position.y)
        }
    }
    
    func endGame(){
        gameOver = true;
        
        GameState.sharedInstance.saveState()
        
        let endGameScene = EndGameScene(size: self.size)
        let reveal = SKTransition.fadeWithDuration(NSTimeInterval(0.5))
        self.view.presentScene(endGameScene, transition: reveal)
    }
}
