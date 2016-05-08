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
        
        static var scoreDict: [String: Int] = ["Player":0]
        
        static var tempcpuhand: [Card] = []
        
        static var cribcards: [Card] = []
        
        static var starthand = 0
        
        static var cutcard: [Card] = []
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
    
    func whoDidntDealIt() -> String {
        var temp = ""
        for (_, value) in Constants.playerDict {
            if !value.whoDealt() {
                temp = value.name
            }
        }
        return temp
    }
    
    func addToCrib(cardname: String) {
        let suit = suitFromDescription(cardname)
        let rank = rankFromDescription(cardname)
        let cribcard = Card(rank: rank, suit: suit)
        Constants.cribcards.append(cribcard)
    }
    
    func clearTheCrib() {
        Constants.cribcards.removeAll()
    }
    
    func createDeck() -> [Card] {
        let suits = [Suit.spades, Suit.hearts, Suit.clubs, Suit.diamonds]
        var deck = [Card]()
        
        for theSuit in suits {
            for theRank in Rank.one.rawValue...Rank.king.rawValue {
                let thecard = Card(rank: Rank(rawValue: theRank)!, suit: theSuit)
                let descrip = thecard.description()
                Constants.suitDict[descrip] = thecard.suit
                Constants.rankDict[descrip] = thecard.rank
                deck.append(thecard)
            }
        }
        for acard in deck {
            print(acard.description())
        }
        return deck
    }
    
    func deal() -> [Card] {
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
    
    func cpuHandLength() -> Int {
        print("COUNT \(Constants.playerDict["Computer"]!.hand.count)")
        print("HAND \(Constants.playerDict["Computer"]!.hand)")

        return Constants.playerDict["Computer"]!.hand.count
    }
    
    func hand(playername: String) -> (Card, Card, Card, Card) {
        if playername == "Player" {
            print("PLAYERS HAND \(Constants.playerDict["Player"]!.hand)")
            
            return ((Constants.playerDict["Player"]?.hand[0])!,(Constants.playerDict["Player"]?.hand[1])!,(Constants.playerDict["Player"]?.hand[2])!,(Constants.playerDict["Player"]?.hand[3])!)
        } else if playername == "Computer" {
            print("COMPUTERS HAND \(Constants.playerDict["Computer"]!.shorthand)")

            return ((Constants.playerDict["Computer"]?.shorthand[0])!,(Constants.playerDict["Computer"]?.shorthand[1])!,(Constants.playerDict["Computer"]?.shorthand[2])!,(Constants.playerDict["Computer"]?.shorthand[3])!)
        } else {
            print("ERROR NAMING THE PLAYER")
            var templist: [Card] = []
            for acard in (Constants.playerDict["Player"]?.hand)! {
                templist.append(acard)
            }
            return (templist[0], templist[1], templist[2], templist[3])
        }
    }
    
    func play(cardname: String) -> [String: Int] {
        
        var man = Constants.playerDict["Player"]
        var cpu = Constants.playerDict["Computer"]
        
        let rank = rankFromDescription(cardname)
        let suit = suitFromDescription(cardname)
        
        let playcard = Card(rank: rank, suit: suit)
        
        History().playHistory(playcard)
        History().playerHistory(man!)
        
        //Scoring

        if Constants.count == 0 {
            ScoringRun().jackflip("Player")
            Constants.count += 1
        }
        
        ScoringRun().updateruncount(playcard)
        let runtotal = ScoringRun().getruncount()
        
        let scored = cpu!.score
        cpu!.score += ScoringRun().go("Computer", runtotal: runtotal)
        Constants.scoreDict["Computer"] = cpu!.score
                
        if scored != cpu!.score {
            
            return Constants.scoreDict
        } else {
            man!.score += ScoringRun().fifteencount("Player")
            man!.score += ScoringRun().SomeOfAKind("Player")
            man!.score += ScoringRun().straight("Player")
            man!.score += ScoringRun().lastcard("Player")
            
            Constants.scoreDict["Player"] = man!.score
            
            print("PLAYER SCORE \(Constants.scoreDict["Player"])")
            print("COMPUTER SCORE \(Constants.scoreDict["Computer"])")

        
            return Constants.scoreDict
        }

    }
    
    
    func getTheCrib() -> ([Card]) {
        return Constants.cribcards
    }
    
    func createPlayer(hand: [Card], score: Int, deals: Bool, name: String) -> Player {
        return Player(hand: hand, shorthand: hand, score: score, isDealer: deals, name: name)
    }
    
    func showPlayerHand() -> [Card] {
        return Constants.playerDict["Player"]!.hand
    }
    
    func scoreHand(name: String) -> Int {
        let S = ScoringHand()
        var handWithCut = Constants.playerDict[name]!.hand
        handWithCut.append(Constants.cutcard[0])
        var score = 0
        
        score += S.fifteencount(name, ahand: handWithCut)
        score += S.fourflush(name, justplayerhand: Constants.playerDict[name]!.hand)
        score += S.jackinhand(name, somehand: Constants.playerDict[name]!.hand)
        score += S.fiveflush(name, handandcutcardORcrib: handWithCut)
        score += S.straight(name, ahand: handWithCut)
        score += S.SomeOfAKind(name, ahand: handWithCut)
        
        Constants.scoreDict[name]! += score
        return Constants.scoreDict[name]!
    }
    
    func scoreShortHand(name: String) -> Int {
        let S = ScoringHand()
        var handWithCut = Constants.playerDict[name]!.shorthand
        handWithCut.append(Constants.cutcard[0])
        var score = 0
        
        score += S.fifteencount(name, ahand: handWithCut)
        score += S.fourflush(name, justplayerhand: Constants.playerDict[name]!.shorthand)
        score += S.jackinhand(name, somehand: Constants.playerDict[name]!.shorthand)
        score += S.fiveflush(name, handandcutcardORcrib: handWithCut)
        score += S.straight(name, ahand: handWithCut)
        score += S.SomeOfAKind(name, ahand: handWithCut)
        
        Constants.scoreDict[name]! += score
        return Constants.scoreDict[name]!
    }
    // MARK: - TBC
    
    func computerPlay() -> (String, [String: Int]) {
        
        // When the player is the dealer, computer plays a duplicate card (the first one)
        // The card isn't necessarily played immediately if the computer can score
        // Am I duplicating the computer or it's hand somewhere??!!!

        //need to fix Go!!! (how to end the run, as well as the points)
        //run scoring needs work!!!
        //crib scoring needs work!!!
        //hand scoring 15 needs work?!!!
        
        
        if Constants.starthand == 0 {
            Constants.starthand += 1
            let newcpuhand = BestPlay().createAHand(Constants.playerDict["Computer"]!.hand)
            
            Constants.playerDict["Computer"]!.somenewhand(newcpuhand["Computer Hand"]!)
            Constants.playerDict["Computer"]!.somenewshorthand(newcpuhand["Computer Hand"]!)
            
            for acard in newcpuhand["Crib Cards"]! {
                Constants.cribcards.append(acard)
            }
        }
            print("\n THISHAND \n \(Constants.playerDict["Computer"]!.hand) \n")
            let (selectedcard, newhand) = BestPlay().pickACard(Constants.playerDict["Computer"]!.hand)
        
            print("HAND LENGTH \(Constants.playerDict["Computer"]!.hand.count)")
                                  
            History().playHistory(selectedcard)
            History().playerHistory(Constants.playerDict["Computer"]!)
        
            Constants.playerDict["Computer"]!.somenewhand(newhand)
        
            Constants.playerDict["Computer"]!.score += ScoringRun().fifteencount("Computer")
            Constants.playerDict["Computer"]!.score += ScoringRun().SomeOfAKind("Computer")
            Constants.playerDict["Computer"]!.score += ScoringRun().straight("Computer")
            Constants.playerDict["Computer"]!.score += ScoringRun().lastcard("Computer")
            
            Constants.scoreDict["Computer"] = Constants.playerDict["Computer"]!.score
                
            print("SELECTEDCARD\(selectedcard.description())")
            return (selectedcard.description(), Constants.scoreDict)
    }
    
    func cutcard() -> Card {
        Constants.cutcard.removeAll()
        Constants.cutcard.append(Constants.someshuffleddeck.removeLast())
        return Constants.cutcard[0]
    }
    
    func removeCardFromPlayer(cardname: String) {
        Constants.playerDict["Player"]!.deletecardfromhandbystring(cardname)
    }
    
    func getCutCard() -> String {
        return Constants.cutcard[0].description()
    }
    
    func getCutCardCard() -> Card {
        return Constants.cutcard[0]
    }
    
    func start() {
        let HVC = HandViewController()
        
        let theDeck = createDeck()
        let shuf = shuffle(theDeck)
        
        print("HERE YA GO \(Constants.cutcard)")

        Constants.someshuffleddeck = shuf
        cutcard()
        print("HERE YA GO \(Constants.cutcard)")

        
        let hand1 = deal()
        let hand2 = deal()

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
    
    func restart() {
        let HVC = HandViewController()
        
        let theDeck = createDeck()
        let shuf = shuffle(theDeck)
        clearTheCrib()
        
        Constants.someshuffleddeck = shuf
        print("HERE YA GO \(Constants.cutcard)")
        cutcard()
        print("HERE YA GO \(Constants.cutcard)")
        
        let hand1 = deal()
        let hand2 = deal()
        
        if Constants.playerDict["Player"]!.isDealer {
            Constants.playerDict["Player"]!.isDealer = false
            Constants.playerDict["Computer"]!.isDealer = true
        } else if Constants.playerDict["Computer"]!.isDealer {
            Constants.playerDict["Player"]!.isDealer = true
            Constants.playerDict["Computer"]!.isDealer = false
        }
        
        Constants.playerDict["Player"]!.somenewhand(hand1)
        Constants.playerDict["Player"]!.somenewshorthand(hand1)
        
        Constants.playerDict["Computer"]!.somenewhand(hand2)
        Constants.playerDict["Computer"]!.somenewshorthand(hand2)
        
        HVC.c1Display(Constants.playerDict["Player"]!.hand[0].description())
        HVC.c2Display(Constants.playerDict["Player"]!.hand[1].description())
        HVC.c3Display(Constants.playerDict["Player"]!.hand[2].description())
        HVC.c4Display(Constants.playerDict["Player"]!.hand[3].description())
        HVC.c5Display(Constants.playerDict["Player"]!.hand[4].description())
        HVC.c6Display(Constants.playerDict["Player"]!.hand[5].description())
        HVC.cutCardDisplay()
        HVC.lastCardDisplay("bicycleback")
        
        Constants.starthand = 0
        
        // MARK: - TBC
        
        if !Constants.playerDict["Computer"]!.isDealer {
            HVC.switchturn()
        }
    }

}
