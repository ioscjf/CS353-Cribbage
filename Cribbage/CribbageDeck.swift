//
//  CribbageDeck.swift
//  Cribbage
//
//  Created by Connor Fitzpatrick on 3/16/16.
//  Copyright © 2016 Connor Fitzpatrick. All rights reserved.
//

import Foundation
import UIKit

class CribbageDeck {

    private struct Constants {
        
        static var rankDict: [String: Rank] = [:]
        static var suitDict: [String: Suit] = [:]
        
        static var playerDict: [String: Player] = [:]
        
        static var someshuffleddeck: [Card] = []
        
        static var count = 0
        
        static var scoreDict: [String: Int] = ["":0]
        
        static var tempcpuhand: [Card] = []
        
        static var cribcards: [Card] = []
    }

    func rankFromDescription(cardname: String) -> Rank {
        return Constants.rankDict[cardname]!
    }
    
    func suitFromDescription(cardname: String) -> Suit {
        return Constants.suitDict[cardname]!
    }
    
    func playerFromName(playername: String) -> Player {
        return Constants.playerDict[playername]!
    }
    
    func whoDealtIt() -> String {
        var temp = ""
        for (_, value) in Constants.playerDict {
            if value.whoDealt() {
                temp = value.name
            }
        }
        return temp
    }
    
    class Crib {
        
        var crib: [Card] = []
        
        func makeTheCrib(card: Card) {
            self.crib.append(card)
        }
        
        func showcrib() -> [Card] {
            return crib
        }
    }
    
    func addToCrib(cardname: String) {
        let suit = suitFromDescription(cardname)
        let rank = rankFromDescription(cardname)
        let cribcard = Card(rank: rank, suit: suit)
        CribbageDeck.Crib().makeTheCrib(cribcard)
    }
    
    func createDeck() -> [Card] {
        var n = 1
        var deck = [Card]()
        while let rank = Rank(rawValue: n) {
            var m = 1
            while let suit = Suit(rawValue: m) {
                let newcard = Card(rank: rank, suit: suit)
                deck.append(newcard)
                
                let descrip = newcard.description()
                Constants.suitDict[descrip] = suit
                Constants.rankDict[descrip] = rank
                
                m += 1
            }
            n += 1
        }
        return deck
    }
    
    func deal(shuffleddeck: [Card]) -> [Card] {
        var ahand = [Card]()
        for _ in 0...5 {
            ahand.append(Constants.someshuffleddeck.popLast()!)
        }
        return ahand
    }
    
    func shuffle(somedeck: [Card]) -> [Card] {
        var adeck = somedeck
        while adeck.count != 0 {
            let pop = adeck.removeAtIndex(Int(arc4random_uniform(UInt32(adeck.count))))
            Constants.someshuffleddeck.append(pop)
        }
        return Constants.someshuffleddeck
    }
    
    func makeDealer() -> Bool {
        let ran = Int(arc4random_uniform(100))
        if ran >= 50 {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - TBC
    
    func play(player: String, cardname: String) -> [String: Int] {
        
        var man = Constants.playerDict[player]
        var cpu = Constants.playerDict["Computer"]
        
        let rank = rankFromDescription(cardname)
        let suit = suitFromDescription(cardname)
        let playcard = Card(rank: rank, suit: suit)
        
        History().playHistory(playcard)
        History().playerHistory(man!)
        
        //Scoring

        if Constants.count == 0 {
            ScoringRun().jackflip()
            Constants.count += 1
        }
        
        ScoringRun().updateruncount(playcard)
        let runtotal = ScoringRun().getruncount()
        
        let scored = cpu!.score
        cpu!.score += ScoringRun().go(runtotal)
        Constants.scoreDict["Computer"] = cpu!.score
        
        if scored != cpu!.score {
            
            return Constants.scoreDict
        } else {
            man!.score += ScoringRun().fifteencount()
            man!.score += ScoringRun().SomeOfAKind()
            man!.score += ScoringRun().straight()
            man!.score += ScoringRun().lastcard()
            
            Constants.scoreDict[player] = man!.score
        
            return Constants.scoreDict
        }

    }
    
    func createPlayer(hand: [Card], score: Int, deals: Bool, name: String) -> Player {
        return Player(hand: hand, shorthand: hand, score: score, isDealer: deals, name: name)
    }
    
    // MARK: - TBC
    
    func computerPlay(cpu: String) -> String{

        // get the computer to pick the card it plays
        
        if var computer = Constants.playerDict[cpu] {
            
            if computer.shorthand.count != 4 {
                let newcpuhand = BestPlay().createAHand(computer.hand)
                
                computer.somenewhand(newcpuhand["Computer Hand"]!)
                computer.somenewshorthand(newcpuhand["Computer Hand"]!)
                
                for acard in newcpuhand["Crib Cards"]! {
                    Constants.cribcards.append(acard)
                }
                
            }
            
            let selectedcard = BestPlay().pickACard(computer)
                        
            var counter = 0
            for acard in computer.hand {
                if acard.description() == selectedcard.description() {
                    computer.deletecardfromhand(counter)
                }
                counter += 1
            }
                    
            History().playHistory(selectedcard)
            History().playerHistory(computer)
                    
            return selectedcard.description()
        } else {
            print("COMPUTER NAMING ERROR")
            return ""
        }
    }
    
    func cutcard() -> Card {
        let cutcard = Constants.someshuffleddeck.removeLast()
        return cutcard
    }
    
    func start() {
        let HVC = HandViewController()
        
        let theDeck = createDeck()
        let shuf = shuffle(theDeck)
        let hand1 = deal(shuf)
        let hand2 = deal(shuf)

        let dealer: Bool = makeDealer()
        
        let human = createPlayer(hand1, score: 0, deals: dealer, name: "Player")
        Constants.playerDict["Player"] = human
        let computer = createPlayer(hand2, score: 0, deals: !dealer, name: "Computer")
        Constants.playerDict["Computer"] = computer

        HVC.c1Display(human.hand[0].description())
        HVC.c2Display(human.hand[1].description())
        HVC.c3Display(human.hand[2].description())
        HVC.c4Display(human.hand[3].description())
        HVC.c5Display(human.hand[4].description())
        HVC.c6Display(human.hand[5].description())
        
        // MARK: - TBC
        
        if !computer.isDealer {
            HVC.switchturn()
        }
    }
}
