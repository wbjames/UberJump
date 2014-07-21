import SpriteKit

class StarNode: GameObjectNode{
    
    override func collisionWithPlayer(player: SKNode) -> Bool {
        player.physicsBody.velocity = CGVectorMake(player.physicsBody.velocity.dx, 400)
        
        self.removeFromParent()
        
        return true
    }
}