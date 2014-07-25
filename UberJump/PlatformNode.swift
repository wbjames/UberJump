import SpriteKit

enum PlatfromType:Int {
    case PLATFORM_NORMAL = 0, PLATFORM_BREAK
}

class PlatformNode:GameObjectNode {
    
    var platformType:PlatfromType?
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        if player.physicsBody.velocity.dy < 0 {
            player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 250)
            
            if platformType == PlatfromType.PLATFORM_BREAK {
                self.removeFromParent()
            }
        }
        
        return false
    }
}