import SpriteKit


class GameObjectNode: SKNode{
    
    
    func collisionWithPlayer(player:SKNode) -> Bool {
        return false
    }
    
    func checkNodeRemoval(playerY: CGFloat) {
        if playerY > self.position.y + 300 {
            self.removeFromParent()
        }
    }
}