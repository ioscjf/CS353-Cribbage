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
            if value.isDealer {
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
    
    func addToCrib(acard: Card) {
        Constants.cribcards.append(acard)
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
            print("PLAYERS HAND \(Constants.playerDict["Player"]!.shorthand)")
            
            return ((Constants.playerDict["Player"]!.shorthand[0]),(Constants.playerDict["Player"]!.shorthand[1]),(Constants.playerDict["Player"]!.shorthand[2]),(Constants.playerDict["Player"]!.shorthand[3]))
        } else if playername == "Computer" {
            print("COMPUTERS HAND \(Constants.playerDict["Computer"]!.shorthand)")

            return ((Constants.playerDict["Computer"]!.shorthand[0]),(Constants.playerDict["Computer"]!.shorthand[1]),(Constants.playerDict["Computer"]!.shorthand[2]),(Constants.playerDict["Computer"]!.shorthand[3]))
        } else {
            print("ERROR NAMING THE PLAYER")
            var templist: [Card] = []
            for acard in (Constants.playerDict["Player"]!.hand) {
                templist.append(acard)
            }
            return (templist[0], templist[1], templist[2], templist[3])
        }
    }
    
    func play(cardname: String) {
        
        let rank = rankFromDescription(cardname)
        let suit = suitFromDescription(cardname)
        
        let playcard = Card(rank: rank, suit: suit)
        var score = 0

        var loop = 0
        for acard in Constants.playerDict["Player"]!.hand {
            if acard.description() == playcard.description() {
                Constants.playerDict["Player"]!.deletecardfromhand(loop)
            }
            loop += 1
        }

        if Constants.count == 0 {
            score += ScoringRun().jackflip("Player")
            Constants.count += 1
        }
        
        History().playHistory(playcard)
        History().playerHistory(Constants.playerDict["Player"]!)
        
        ScoringRun().updateruncount(playcard)
        score += ScoringRun().fifteencount("Player")
        score += ScoringRun().SomeOfAKind("Player")
        score += ScoringRun().straight("Player")
        
        PlayerScores().addScore("Player", newpoints: score)
    }
    
    func computerPlay() -> String {
        
        var score = 0
        if Constants.starthand == 0 {
            Constants.starthand += 1
            let newcpuhand = BestPlay().createAHand(Constants.playerDict["Computer"]!.hand)
            
            Constants.playerDict["Computer"]!.somenewhand(newcpuhand["Computer Hand"]!)
            Constants.playerDict["Computer"]!.somenewshorthand(newcpuhand["Computer Hand"]!)
            print("NEW SHORTHAND \(Constants.playerDict["Computer"]!.shorthand)")
            
            for acard in newcpuhand["Crib Cards"]! {
                Constants.cribcards.append(acard)
            }
        }
        
        if Constants.count == 0 {
            score += ScoringRun().jackflip("Computer")
            Constants.count += 1
        }
        
        print("\n THISHAND \n \(Constants.playerDict["Computer"]!.hand) \n")
        let (selectedcard, newhand) = BestPlay().pickACard(Constants.playerDict["Computer"]!.hand)!
        
        print("SELECTEDCARD\(selectedcard.description())")
        
        History().playHistory(selectedcard)
        History().playerHistory(Constants.playerDict["Computer"]!)
        
        Constants.playerDict["Computer"]!.somenewhand(newhand)
        
        ScoringRun().updateruncount(selectedcard)
        score += ScoringRun().fifteencount("Computer")
        score += ScoringRun().SomeOfAKind("Computer")
        score += ScoringRun().straight("Computer")
        
        PlayerScores().addScore("Computer", newpoints: score)
        
        return selectedcard.description()
    }
    
    func getTheCrib() -> ([Card]) {
        return Constants.cribcards
    }
    
    func createPlayer(hand: [Card], deals: Bool, name: String) -> Player {
        return Player(hand: hand, shorthand: hand, isDealer: deals, name: name)
    }
    
    func showPlayerHand() -> [Card] {
        return Constants.playerDict["Player"]!.hand
    }
    
    func scoreCrib(name: String) {
        let S = ScoringHand()

        var cribCardsWithCut = Constants.cribcards
        cribCardsWithCut.append(Constants.cutcard[0])
        var score = 0
        
        score += S.fifteencount(name, ahand: cribCardsWithCut)
        score += S.jackinhand(name, somehand: Constants.cribcards)
        score += S.fiveflush(name, handandcutcardORcrib: cribCardsWithCut)
        score += S.straight(name, ahand: cribCardsWithCut)
        score += S.SomeOfAKind(name, ahand: cribCardsWithCut)
        
        PlayerScores().addScore(name, newpoints: score)
    }
    
    func scoreShortHand(name: String) {
        let S = ScoringHand()
        var handWithCut = Constants.playerDict[name]!.shorthand
        print("Computer hand \(handWithCut)")
        handWithCut.append(Constants.cutcard[0])
        var score = 0
        score += S.fifteencount(name, ahand: handWithCut)
        score += S.fourflush(name, justplayerhand: Constants.playerDict[name]!.shorthand)
        score += S.jackinhand(name, somehand: Constants.playerDict[name]!.shorthand)
        score += S.fiveflush(name, handandcutcardORcrib: handWithCut)
        score += S.straight(name, ahand: handWithCut)
        score += S.SomeOfAKind(name, ahand: handWithCut)
        
        PlayerScores().addScore(name, newpoints: score)
    }
    
    func canPlay(name: String) -> Bool {
        var value = 15
        for acard in Constants.playerDict[name]!.hand {
            if acard.rank.value() < value {
                value = acard.rank.value()
            }
        }
        print("VALUE \(value)")
        print("RUN COUNT \(ScoringRun().getruncount())")
        if value + ScoringRun().getruncount() <= 31 {
            return true
        } else {
            return false
        }
    }
    
    func cutcard() -> Card {
        Constants.cutcard.removeAll()
        Constants.cutcard.append(Constants.someshuffleddeck.removeLast())
        return Constants.cutcard[0]
    }
    
    func removeCardFromPlayer(cardname: String) {
        Constants.playerDict["Player"]!.deletecardfromhandbystring(cardname)
    }
    
    func removeCardFromPlayerShortHand(cardname: String) {
        let newcribcard = Constants.playerDict["Player"]!.deletecardfromshorthandbystring(cardname)
        addToCrib(newcribcard)
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
        
        Constants.someshuffleddeck = shuf
        cutcard()
        
        let hand1 = deal()
        let hand2 = deal()

        let dealer: Bool = makeDealer()
        
        Constants.playerDict["Player"] = createPlayer(hand1, deals: dealer, name: "Player")
        Constants.playerDict["Computer"] = createPlayer(hand2, deals: !dealer, name: "Computer")
        PlayerScores().addPlayers("Player")
        PlayerScores().addPlayers("Computer")

        HVC.c1Display(Constants.playerDict["Player"]!.hand[0].description())
        HVC.c2Display(Constants.playerDict["Player"]!.hand[1].description())
        HVC.c3Display(Constants.playerDict["Player"]!.hand[2].description())
        HVC.c4Display(Constants.playerDict["Player"]!.hand[3].description())
        HVC.c5Display(Constants.playerDict["Player"]!.hand[4].description())
        HVC.c6Display(Constants.playerDict["Player"]!.hand[5].description())
        
        Constants.count = 0
        if Constants.playerDict["Computer"]!.isDealer {
            HVC.switchturn()
            print("TURN 6 playerturn")
        }
    }
    
    func restart() {
        let HVC = HandViewController()
        
        let theDeck = createDeck()
        let shuf = shuffle(theDeck)
        clearTheCrib()
        
        Constants.someshuffleddeck = shuf
        cutcard()
        
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
        Constants.count = 0
        
        if Constants.playerDict["Computer"]!.isDealer {
            HVC.switchturn()
            print("TURN 7 playerturn")

        }
    }

}
