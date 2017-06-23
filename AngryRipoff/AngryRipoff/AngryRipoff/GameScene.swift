import SpriteKit

func clamp<T: Comparable>(value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}

class GameScene: SKScene {
    
    /* Game object connections */
    var catapultArm: SKSpriteNode!
    
    var catapult: SKSpriteNode!
    
    var cantileverNode: SKSpriteNode!
    
    var touchNode: SKSpriteNode!
    /* Define a var to hold the camera */
    var cameraNode:SKCameraNode!
    
    /* Add an optional camera target */
    var cameraTarget: SKSpriteNode?
    
    /* UI Connections */
    var buttonRestart: MSButtonNode!
    
    /* Physics helpers */
    var touchJoint: SKPhysicsJointSpring?
    
    var penguinJoint: SKPhysicsJointPin?
    
    func moveCamera() {
        guard let cameraTarget = cameraTarget else {
            return
        }
        let targetX = cameraTarget.position.x
        let x = clamp(value: targetX, lower: 0, upper: 392)
        cameraNode.position.x = x
    }
    
    /* Make a Class method to load levels */
    class func level(_ levelNumber: Int) -> GameScene? {
        guard let scene = GameScene(fileNamed: "Level_\(levelNumber)") else {
            return nil
        }
        scene.scaleMode = .aspectFill
        return scene
    }
    
    override func didMove(to view: SKView) {
        /* Set reference to catapultArm node */
        catapultArm = childNode(withName: "catapultArm") as! SKSpriteNode
        catapult = childNode(withName: "catapult") as! SKSpriteNode
        cantileverNode = childNode(withName: "cantileverNode") as! SKSpriteNode
        touchNode = childNode(withName: "touchNode") as! SKSpriteNode
        
        /* Create a new Camera */
        cameraNode = childNode(withName: "cameraNode") as! SKCameraNode
        self.camera = cameraNode
        
        /* Set UI connections */
        buttonRestart = childNode(withName: "//buttonRestart") as! MSButtonNode
        
        /* Reset the game when the reset button is tapped */
        buttonRestart.selectedHandler = {
            guard let scene = GameScene.level(1) else {
                print("Level 1 is missing?")
                return
            }
            
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
        }
        setupCatapult()
        
    }
    
    func setupCatapult() {
        /* Pin joint */
        var pinLocation = catapultArm.position
        pinLocation.x += -10
        pinLocation.y += -70
        let catapultJoint = SKPhysicsJointPin.joint(
            withBodyA:catapult.physicsBody!,
            bodyB: catapultArm.physicsBody!,
            anchor: pinLocation)
        physicsWorld.add(catapultJoint)
        
        /* Spring joint catapult arm and cantilever node */
        var anchorAPosition = catapultArm.position
        anchorAPosition.x += 0
        anchorAPosition.y += 50
        let catapultSpringJoint = SKPhysicsJointSpring.joint(withBodyA: catapultArm.physicsBody!, bodyB: cantileverNode.physicsBody!, anchorA: anchorAPosition, anchorB: cantileverNode.position)
        physicsWorld.add(catapultSpringJoint)
        catapultSpringJoint.frequency = 6
        catapultSpringJoint.damping = 0.5
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        let touch = touches.first!              // Get the first touch
        let location = touch.location(in: self) // Find the location of that touch in this view
        let nodeAtPoint = atPoint(location)     // Find the node at that location
        if nodeAtPoint.name == "catapultArm" {  // If the touched node is named "catapultArm" do...
            touchNode.position = location
            touchJoint = SKPhysicsJointSpring.joint(withBodyA: touchNode.physicsBody!, bodyB: catapultArm.physicsBody!, anchorA: location, anchorB: location)
            physicsWorld.add(touchJoint!)
        }
        
        let penguin = Penguin()
        addChild(penguin)
        penguin.position.x += catapultArm.position.x + 20
        penguin.position.y += catapultArm.position.y + 50
        penguin.physicsBody?.usesPreciseCollisionDetection = true
        penguinJoint = SKPhysicsJointPin.joint(withBodyA: catapultArm.physicsBody!,
                                               bodyB: penguin.physicsBody!,
                                               anchor: penguin.position)
        physicsWorld.add(penguinJoint!)
        cameraTarget = penguin
        
        
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        // Make a Penguin
//        let penguin = Penguin()
//        
//        // Add the penguin to this scene
//        addChild(penguin)
//        
//        /* Move penguin to the catapult bucket area */
//        penguin.position.x = catapultArm.position.x + 32
//        penguin.position.y = catapultArm.position.y + 50
//        
//        /* Impulse vector */
//        let launchImpulse = CGVector(dx: 200, dy: 0)
//        
//        /* Apply impulse to penguin */
//        penguin.physicsBody?.applyImpulse(launchImpulse)
//
//        cameraTarget = penguin
//        
//    }
//    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        touchNode.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchJoint = touchJoint {
            physicsWorld.remove(touchJoint)
        }
        
        // Check for a touchJoint then remove it.
        if let touchJoint = touchJoint {
            physicsWorld.remove(touchJoint)
        }
        // Check for a penguin joint then remove it.
        if let penguinJoint = penguinJoint {
            physicsWorld.remove(penguinJoint)
        }
        // Check if there is a penuin assigned to the cameraTarget
        guard let penguin = cameraTarget else {
            return
        }
        // Generate a vector and a force based on the angle of the arm.
        let force: CGFloat = 350
        let r = catapultArm.zRotation
        let dx = cos(r) * force
        let dy = sin(r) * force
        // Apply an impulse at the vector. 
        let v = CGVector(dx: dx, dy: dy)
        penguin.physicsBody?.applyImpulse(v)
    }
    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        moveCamera()
    }
}
