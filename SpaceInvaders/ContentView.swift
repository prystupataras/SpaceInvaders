//
//  ContentView.swift
//  SpaceInvaders
//
//  Created by Prystupa Taras on 03.09.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var playerPosition = CGPoint(x: UIScreen.main.bounds.width / 2 , y: UIScreen.main.bounds.height - 20)
    @State private var bullets = [Bullet]()
    @State private var invaders = [Invader]()
    @State private var invaderDirection: CGFloat = 1.0
    @State private var playerLives = 3
    @State private var gameOver = false
    @State private var timer: Timer?
    @State private var invaderBulletTimer: Timer?
    @State private var canShoot = true
    @State private var score = 0
    
    let playerSpeed: CGFloat = 10
    let invaderSpeed: CGFloat = 5
    
    var body: some View {
        ZStack {
            if gameOver {
                GameOverView(score: score, restartAction: restartGame)
            } else {
                Image(uiImage: UIImage(named: "space_ship")!)
                    .resizable()
                    .foregroundStyle(.blue)
                    .frame(width: 60, height: 60)
                    .position(playerPosition)
                    .gesture(
                        DragGesture()
                            .onChanged({ value in
                                movePlayer(to: value.location)
                            })
                    )
                ForEach(bullets, id: \.id) { bullet in
                    Rectangle()
                        .frame(width: 5, height: 10)
                        .position(bullet.position)
                        .foregroundStyle(bullet.isPlayerBullet ? Color.red : .green)
                }
                
                ForEach(invaders, id: \.id) { invader in
                    Image(invader.imageName)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .position(invader.position)
                }
                
                Text("Score: \(score)")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .position(x: 100, y: 50)
                
                Text("Lives: \(playerLives)")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .position(x: UIScreen.main.bounds.width - 100, y: 50)
            }
        }
        .background(.black)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            startGame()
        }
        .onTapGesture {
            if canShoot {
                shootBullet()
                canShoot = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    canShoot = true
                }
            }
        }
    }
    
    func startGame() {
        
        invaders = createInvaders()
        
        playerLives = 3
        gameOver = false
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            updateBullets()
            updateInvaders()
            checkCollisions()
            checkGameOver()
        }
        
        invaderBulletTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { _ in
            invaderShootBullet()
        }
    }
    
    func createInvaders() -> [Invader] {
        var invaders = [Invader]()
        
        let rows = 3
        let columns = 5
        
        let spacing: CGFloat = 60.0
        
        for row in 0..<rows {
            for column in 0..<columns {
                let x = spacing * CGFloat(column) + spacing / 2
                let y = spacing * CGFloat(row) + 100
                
                invaders.append(Invader(id: UUID(), position: CGPoint(x: x, y: y), imageName: "invader_image_name"))
            }
        }
        
        return invaders
    }
    
    func shootBullet() {
        let bulletStart = CGPoint(x: playerPosition.x, y: playerPosition.y - 30)
        let bulletEnd = CGPoint(x: playerPosition.x, y: 0)
        
        let angle = atan2(bulletEnd.y - bulletStart.y, bulletEnd.x - bulletStart.x)
        
        let bulletVelocityX = cos(angle) * 10
        let bulletVelocityY = sin(angle) * 10
        
        bullets.append(Bullet(id: UUID(), position: bulletStart, velocity: CGVector(dx: bulletVelocityX, dy: bulletVelocityY), isPlayerBullet: true))
    }
    
    func movePlayer(to location: CGPoint) {
        let newX = min(max(location.x, 0),UIScreen.main.bounds.width)
        playerPosition.x = newX
    }
    
    func updateBullets() {
        for i in 0..<bullets.count {
            bullets[i].position.x += bullets[i].velocity.dx
            bullets[i].position.y += bullets[i].velocity.dy
        }
        
        bullets = bullets.filter { $0.position.y > 0 && $0.position.y < UIScreen.main.bounds.height }
    }
    
    func updateInvaders() {
        
        for i in 0..<invaders.count {
            invaders[i].position.x += invaderSpeed * invaderDirection
        }
        
        if invaders.contains(where: { $0.position.x > UIScreen.main.bounds.width - 20 || $0.position.x < 20}) {
            
            invaderDirection *= -1
            
            for i in 0..<invaders.count {
                invaders[i].position.y += 10
            }
        }
    }
    
    func invaderShootBullet() {
        if !invaders.isEmpty {
            
            let randomInvaderIndex = Int.random(in: 0..<invaders.count)
            let invaderPosition = invaders[randomInvaderIndex].position
            let bulletStart = CGPoint(x: invaderPosition.x, y: invaderPosition.y + 20)
            let bulletEnd = playerPosition
            let angle = atan2(bulletEnd.y - bulletStart.y, bulletEnd.x - bulletStart.x)
            
            let bulletVelocityX = cos(angle) * 10
            let bulletVelocityY = sin(angle) * 10
            
            bullets.append(Bullet(id: UUID(), position: bulletStart, velocity: CGVector(dx: bulletVelocityX, dy: bulletVelocityY), isPlayerBullet: false))
        }
    }
    
    func checkCollisions() {
        
        for bullet in bullets {
            for invader in invaders {
                if abs(bullet.position.x - invader.position.x) < 20
                    && abs(bullet.position.y - invader.position.y) < 20
                    && bullet.isPlayerBullet  {
                    
                    if let bulletIndex = bullets.firstIndex(where: { $0.id == bullet.id }) {
                        bullets.remove(at: bulletIndex)
                    }
                    
                    if let invaderIndex = invaders.firstIndex(where: { $0.id == invader.id }) {
                        invaders.remove(at: invaderIndex)
                        
                        score += 1
                        break
                    }
                }
            }
        }
        
        for bullet in bullets {
            if abs(bullet.position.x - playerPosition.x) < 20
                && abs(bullet.position.y - playerPosition.y) < 20
                && !bullet.isPlayerBullet  {
                
                if let bulletIndex = bullets.firstIndex(where: { $0.id == bullet.id }) {
                    bullets.remove(at: bulletIndex)
                }
                
                playerLives -= 1
                
                if playerLives <= 0 {
                    gameOver = true
                    
                    timer?.invalidate()
                    invaderBulletTimer?.invalidate()
                }
                break
            }
        }
    }
    
    func checkGameOver() {
        
        if invaders.isEmpty {
            gameOver = true
            
            timer?.invalidate()
            invaderBulletTimer?.invalidate()
        }
    }
    
    func restartGame() {
        bullets.removeAll()
        invaders.removeAll()
        
        playerLives = 3
        gameOver = false
        score = 0
        invaderDirection = 1.0
        
        timer?.invalidate()
        invaderBulletTimer?.invalidate()
        
        startGame()
    }
}

#Preview {
    ContentView()
}
