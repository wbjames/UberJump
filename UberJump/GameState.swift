import Foundation

class GameState: NSObject{
    var score:Int = 0
    var highScore:Int = 0
    var stars:Int = 0
    
    class var sharedInstance: GameState{
        struct Static{
            static let instance: GameState = GameState()
        }
        return Static.instance
    }
    
    init() {
        super.init()
        score = 0
        highScore = 0
        stars = 0
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let hscore:Int? = defaults.objectForKey("highScore") as? Int
        if hscore != nil{
            highScore = hscore!
        }
        let ss:Int? = defaults.objectForKey("stars") as? Int
        if ss != nil{
            stars = ss!
        }
    }
    
    func saveState() {
        highScore = max(score, highScore)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(highScore, forKey: "highScore")
        defaults.setInteger(stars, forKey: "stars")
        defaults.synchronize()
    
    }
    
}

