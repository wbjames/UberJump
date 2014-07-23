import SpriteKit
import AVFoundation


enum StarType:Int32{
    case STAR_NORMAL = 0,STAR_SPECIAL
}


class StarNode: GameObjectNode{
    var starSound:SKAction?
    
    init(){
        super.init()
        starSound = SKAction.playSoundFileNamed("StarPing.wav", waitForCompletion: false)
    }
    
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 400)
        
        self.parent.runAction(starSound)
        self.removeFromParent()
       
        
        return true
    }
}