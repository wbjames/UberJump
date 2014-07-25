import SpriteKit
import AVFoundation


enum StarType:Int{
    case STAR_NORMAL = 0,STAR_SPECIAL
}


class StarNode: GameObjectNode{
    var starSound:SKAction?
    var starType:StarType?
    init(){
        super.init()
        starSound = SKAction.playSoundFileNamed("StarPing.wav", waitForCompletion: false)
    }
    
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 400)
        
        self.parent.runAction(starSound)
        self.removeFromParent()
    
        GameState.sharedInstance.score += (starType == StarType.STAR_NORMAL ? 20 : 100)
        
        GameState.sharedInstance.stars += (starType == StarType.STAR_NORMAL ? 1 : 5)
        return true
    }
}