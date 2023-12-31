//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Bruce Lopez on 7/6/23.
//

import SwiftUI

struct FlagImage: View {
    var countryImage: String

    var body: some View {
        Image(countryImage)
            .renderingMode(.original)
            .clipShape(Capsule())
            .shadow(radius: 5)
    }
}

struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle.weight(.bold))
            .foregroundColor(.white)
            .padding()
    }
}

extension View {
    func titleStyle() -> some View {
        modifier(Title())
    }
}

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    
    @State private var showingScore = false
    @State private var gameOver = false
    @State private var scoreTitle = ""
    @State private var plays = 0
    @State private var scoretotal = 0
    
    @State private var animateCorrect = 0.0
    @State private var animateOpacity = 1.0
    @State private var besidesTheCorrect = false
    @State private var besidesTheWrong = false
    @State private var selectedFlag = 0
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3),
            ], center: .top, startRadius: 200, endRadius: 400)
                .ignoresSafeArea()
            VStack {
                Spacer()
                
                Text("Guess the Flag")
                    .titleStyle()
                
                VStack(spacing: 15){
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3) { number in
                        Button {
                            
                            self.selectedFlag = number
                            self.flagTapped(number)
                            
                        } label: {
                            FlagImage(countryImage: self.countries[number])
                        }
                        .rotation3DEffect(.degrees(number == self.correctAnswer ? self.animateCorrect : 0), axis: (x: 0, y: 1, z: 0))
                        .opacity(number != self.correctAnswer && self.besidesTheCorrect ? self.animateOpacity : 1)
                        .background(self.besidesTheWrong && self.selectedFlag == number ? Capsule(style: .circular).fill(Color.red).blur(radius: 30) : Capsule(style: .circular).fill(Color.clear).blur(radius: 0))
                        .opacity(self.besidesTheWrong && self.selectedFlag != number ? self.animateOpacity : 1)
                        
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Score: \(scoretotal)")
                    .foregroundColor(.white)
                    .font(.title.bold())
                
                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text("Your score is \(scoretotal)")
        }.alert("Gameover!", isPresented: $gameOver) {
            Button("Restart game?", action: restartGame)
        } message: {
            Text("Your final score is \(scoretotal)/800")
        }
    }
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct"
            scoretotal += 100
            plays += 1
            
            withAnimation {
                self.animateCorrect += 360
                self.animateOpacity = 0.25
                self.besidesTheCorrect = true
            }
        } else {
            scoreTitle = "Wrong! That's the flag of \(countries[correctAnswer])"
            scoretotal -= 100
            plays += 1
            withAnimation {
                self.animateOpacity = 0.25
                self.besidesTheWrong = true
            }
        }
        
        if plays == 8 {
            gameOver = true
        }else {
            showingScore = true
        }
    }
    
    func askQuestion() {
        besidesTheCorrect = false
        besidesTheWrong = false
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
    
    func restartGame() {
            gameOver = false
            plays = 0
            scoretotal = 0
            askQuestion()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
