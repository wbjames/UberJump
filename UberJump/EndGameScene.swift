import SpriteKit

class EndGameScene:SKScene {
    
    init(size: CGSize) {
        super.init(size: size)
        
        let lblGameOver:SKLabelNode = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblGameOver.fontSize = 40
        lblGameOver.fontColor = SKColor.whiteColor()
        lblGameOver.position = CGPointMake(160, size.height - 200)
        lblGameOver.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblGameOver.text = "what you know?"
        self.addChild(lblGameOver)
        
        
        let star = SKSpriteNode(imageNamed: "Star")
        star.position = CGPointMake(25, self.size.height - 30)
        self.addChild(star)
        let lblStars = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblStars.fontSize = 30
        lblStars.fontColor = SKColor.whiteColor()
        lblStars.position = CGPointMake(50, self.size.height - 40)
        lblStars.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        lblStars.text = String(format: "X %d", GameState.sharedInstance.stars)
        self.addChild(lblStars)
        
        let lblScore = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblScore.fontSize = 60
        lblScore.fontColor = SKColor.whiteColor()
        lblScore.position = CGPointMake(160, 300)
        lblScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblScore.text = String(format: "%d", GameState.sharedInstance.score)
        self.addChild(lblScore)
        
        let highScore = SKLabelNode(fontNamed:"ChalkboardSE-Bold")
        highScore.fontSize = 30
        highScore.fontColor = SKColor.cyanColor()
        highScore.position = CGPointMake(160, 150)
        highScore.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        highScore.text = String(format: "High Score: %d", GameState.sharedInstance.highScore)
        self.addChild(highScore)
        
        let lblTryAgain = SKLabelNode(fontNamed: "ChalkboardSE-Bold")
        lblTryAgain.fontSize = 30
        lblTryAgain.fontColor = SKColor.whiteColor()
        lblTryAgain.position = CGPointMake(160, 50)
        lblTryAgain.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        lblTryAgain.text = "Tap To Try Again"
        self.addChild(lblTryAgain)
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let gameScene = GameScene(size: self.size)
        let reveal = SKTransition.fadeWithDuration(0.5)
        self.view.presentScene(gameScene, transition: reveal)
        
    }

}