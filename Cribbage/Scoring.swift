//
//  Scoring.swift
//  Cribbage
//
//  Created by Connor Fitzpatrick on 5/1/16.
//  Copyright © 2016 Connor Fitzpatrick. All rights reserved.
//

import Foundation

// MARK: - Ordering

struct Order {
    var historylist = History().showPlayHistory()
    
    func orderByValue() -> [Card] {
        let valueorderlist = historylist.sort { $0.rank.rawValue < $1.rank.rawValue }
        return valueorderlist
    }
    
    func getHistory() -> [Card] {
        return historylist
    }
}

class ScoringRun {
    
    private struct Constants {
        static var boolpoints = false
        static var someruncount = 0
    }
    
    func updateruncount(somecard: Card) {
        Constants.someruncount += somecard.rank.rawValue
    }
    
    // MARK: - Run Scoring
    
    func straight() -> Int {
        var i = 0
        let orderlist = Order().orderByValue()
        if orderlist.count >= 3 {
            while (i + 1) < orderlist.count {
                if orderlist[i].rank.ordinal() == (orderlist[i + 1].rank.ordinal() + 1) {
                    Constants.boolpoints = true
                    i += 1
                } else {
                    Constants.boolpoints = false
                    i = orderlist.count
                }
            }
        }
        if Constants.boolpoints {
            Constants.boolpoints = false
            return orderlist.count
        } else {
            return 0
        }
    }
    
    func fifteencount() -> Int {
        let orderlist = Order().orderByValue()
        var count = 0
        for acard in orderlist {
            count += acard.rank.rawValue
        }
        if count == 15 || count == 31 {
            return 2
        } else {
            return 0
        }
    }
    
    func SomeOfAKind() -> Int {
        var historylist = Order().getHistory()
        let temp0 = historylist.removeFirst()
        let temp1 = historylist.removeFirst()
        let temp2 = historylist.removeFirst()
        let temp3 = historylist.removeFirst()
        var count = 0
        
        if temp3.rank.description() == temp2.rank.description() && temp2.rank.description() == temp1.rank.description() && temp1.rank.description() == temp0.rank.description() {
            count = 12
        } else if temp2.rank.description() == temp1.rank.description() && temp1.rank.description() == temp0.rank.description() {
            count = 6
        } else if temp1.rank.description() == temp0.rank.description() {
            count = 2
        } else {
            count = 0
        }
        return count
    }
    
    func getruncount() -> Int {
        return Constants.someruncount
    }
    
    //returns 1 if the player cannot play, 0 otherwise
    //points should be given to the next player, not the current player (unlike the other functions)
    
    func go(runtotal: Int) -> Int {
        if History().mostRecentPlayer().cannotPlay(runtotal) {
            return 1
        } else {
            return 0
        }
    }
    
    func lastcard() -> Int {
        if Order().getHistory().count == 8 {
            return 1
        } else {
            return 0
        }
    }
    
    func jackflip() -> Int {
        if CribbageDeck().cutcard().rank.description() == "jack" {
            return 2
        } else {
            return 0
        }
    }
    
}

class ScoringHand {
    
    // MARK: - SubDecks
    
    func makeSubDecksOf2From5(somehand: [Card]) -> [String:[Card]] {
        var subdeckdict2 = ["twodeck1": [somehand[0],somehand[1]]]
        subdeckdict2["twodeck2"] = [somehand[0],somehand[2]]
        subdeckdict2["twodeck3"] = [somehand[0],somehand[3]]
        subdeckdict2["twodeck4"] = [somehand[0],somehand[4]]
        subdeckdict2["twodeck5"] = [somehand[1],somehand[2]]
        subdeckdict2["twodeck6"] = [somehand[1],somehand[3]]
        subdeckdict2["twodeck7"] = [somehand[1],somehand[4]]
        subdeckdict2["twodeck8"] = [somehand[2],somehand[3]]
        subdeckdict2["twodeck9"] = [somehand[2],somehand[4]]
        subdeckdict2["twodeck10"] = [somehand[3],somehand[4]]
        
        return subdeckdict2
    }
    
    func makeSubDecksOf3From5(somehand: [Card]) -> [String:[Card]] {
        var subdeckdict3 = ["threedeck1": [somehand[0],somehand[1],somehand[2]]]
        subdeckdict3["threedeck2"] = [somehand[0],somehand[1],somehand[3]]
        subdeckdict3["threedeck5"] = [somehand[0],somehand[1],somehand[4]]
        subdeckdict3["threedeck3"] = [somehand[0],somehand[2],somehand[3]]
        subdeckdict3["threedeck6"] = [somehand[0],somehand[2],somehand[4]]
        subdeckdict3["threedeck8"] = [somehand[0],somehand[3],somehand[4]]
        subdeckdict3["threedeck4"] = [somehand[1],somehand[2],somehand[3]]
        subdeckdict3["threedeck7"] = [somehand[1],somehand[2],somehand[4]]
        subdeckdict3["threedeck9"] = [somehand[1],somehand[3],somehand[4]]
        subdeckdict3["threedeck10"] = [somehand[2],somehand[3],somehand[4]]
        
        return subdeckdict3
    }
    
    func makeSubDecksOf4From5(somehand: [Card]) -> [String:[Card]] {
        var subdeckdict4 = ["fourdeck1": [somehand[0],somehand[1],somehand[2],somehand[3]]]
        subdeckdict4["fourdeck2"] = [somehand[0],somehand[1],somehand[2],somehand[4]]
        subdeckdict4["fourdeck3"] = [somehand[0],somehand[1],somehand[3],somehand[4]]
        subdeckdict4["fourdeck4"] = [somehand[0],somehand[2],somehand[3],somehand[4]]
        subdeckdict4["fourdeck5"] = [somehand[1],somehand[2],somehand[3],somehand[4]]

        return subdeckdict4
    }
    
    func makeSubDecksOf4From6(somehand: [Card]) -> [String: [Card]] {
        
        //should be 15 combinations
        //14 so far
        var subdeckdict4to6 = ["sixdeck1": [somehand[0],somehand[1],somehand[2],somehand[3]]]
        subdeckdict4to6["sixdeck2"] = [somehand[0],somehand[1],somehand[2],somehand[4]]
        subdeckdict4to6["sixdeck3"] = [somehand[0],somehand[1],somehand[2],somehand[5]]
        subdeckdict4to6["sixdeck4"] = [somehand[0],somehand[1],somehand[3],somehand[4]]
        subdeckdict4to6["sixdeck5"] = [somehand[0],somehand[1],somehand[3],somehand[5]]
        subdeckdict4to6["sixdeck6"] = [somehand[0],somehand[1],somehand[4],somehand[5]]
        subdeckdict4to6["sixdeck7"] = [somehand[0],somehand[2],somehand[3],somehand[4]]
        subdeckdict4to6["sixdeck8"] = [somehand[0],somehand[2],somehand[3],somehand[5]]
        subdeckdict4to6["sixdeck9"] = [somehand[0],somehand[2],somehand[4],somehand[5]]
        subdeckdict4to6["sixdeck10"] = [somehand[0],somehand[3],somehand[4],somehand[5]]
        subdeckdict4to6["sixdeck11"] = [somehand[1],somehand[2],somehand[3],somehand[4]]
        subdeckdict4to6["sixdeck12"] = [somehand[1],somehand[2],somehand[3],somehand[5]]
        subdeckdict4to6["sixdeck13"] = [somehand[1],somehand[2],somehand[4],somehand[5]]
        subdeckdict4to6["sixdeck14"] = [somehand[1],somehand[3],somehand[4],somehand[5]]
        subdeckdict4to6["sixdeck15"] = [somehand[2],somehand[3],somehand[4],somehand[5]]
        
        return subdeckdict4to6
    }
    
    // MARK: - Hand Scoring
    
    func jackinhand(somehand: [Card]) -> Int {
        var count = 0
        for acard in somehand {
            if acard.rank.description() == "jack" && acard.suit.description() == CribbageDeck().cutcard().suit.description() {
                count += 1
            }
        }
        return count
    }
    
    func SomeOfAKind(ahand: [Card]) -> Int {
        var count = 0
        let twodict = makeSubDecksOf2From5(ahand)
        let threedict = makeSubDecksOf3From5(ahand)
        let fourdict = makeSubDecksOf4From5(ahand)
        
        for (_, value) in twodict {
            if value[0].rank.rawValue == value[1].rank.rawValue {
                count += 2
            }
        }
        
        for (_, value) in threedict {
            if value[0].rank.rawValue == value[1].rank.rawValue && value[1].rank.rawValue == value[2].rank.rawValue {
                count += 4
            }
        }

        for (_, value) in fourdict {
            if value[0].rank.rawValue == value[1].rank.rawValue && value[1].rank.rawValue == value[2].rank.rawValue && value[2].rank.rawValue == value[3].rank.rawValue {
                count += 6
            }
        }

        return count
    }
    
    func fifteencount(ahand: [Card]) -> Int {
        var count = 0
        let twodict = makeSubDecksOf2From5(ahand)
        let threedict = makeSubDecksOf3From5(ahand)
        let fourdict = makeSubDecksOf4From5(ahand)
        
        for (_, value) in twodict {
            if value[0].rank.rawValue + value[1].rank.rawValue == 15 {
                count += 2
            }
        }
        
        for (_, value) in threedict {
            if value[0].rank.rawValue + value[1].rank.rawValue + value[2].rank.rawValue == 15 {
                count += 2
            }
        }
        
        for (_, value) in fourdict {
            if value[0].rank.rawValue + value[1].rank.rawValue + value[2].rank.rawValue + value[3].rank.rawValue == 15 {
                count += 2
            }
        }
        
        return count
    }
    
    func straight(ahand: [Card]) -> Int{
        var count = 0
        let threedict = makeSubDecksOf3From5(ahand)
        let fourdict = makeSubDecksOf4From5(ahand)
        let sorthand = ahand.sort { $0.rank.rawValue < $1.rank.rawValue }
        
        if sorthand[0].rank.ordinal() == sorthand[1].rank.ordinal() + 1 && sorthand[1].rank.ordinal() == sorthand[2].rank.ordinal() + 1 && sorthand[2].rank.ordinal() == sorthand[3].rank.ordinal() + 1 && sorthand[3].rank.ordinal() == sorthand[4].rank.ordinal() + 1 {
            count += 5
            
            return count
        }
        
        for (_, value) in fourdict {
            if value[0].rank.ordinal() == value[1].rank.ordinal() + 1 && value[1].rank.ordinal() == value[2].rank.ordinal() + 1 && value[2].rank.ordinal() == value[3].rank.ordinal() + 1 {
                count += 4
                
                return count
            }
        }
        
        for (_, value) in threedict {
            if value[0].rank.ordinal() == value[1].rank.ordinal() + 1 && value[1].rank.ordinal() == value[2].rank.ordinal() + 1 {
                count += 3
                
                return count
            }
        }
        
        return count
    }
    
    func fourflush(justplayerhand: [Card]) -> Int {
        var count = 0
        let suitchecker = justplayerhand[0].suit.description()
        for acard in justplayerhand {
            if acard.suit.description() == suitchecker {
                count = justplayerhand.count
            } else {
                return 0
            }
        }
        
        return count
    }
    
    func fiveflush(handandcutcardORcrib: [Card]) -> Int {
        var count = 0
        let suitchecker = handandcutcardORcrib[0].suit.description()
        for acard in handandcutcardORcrib {
            if acard.suit.description() == suitchecker {
                count = handandcutcardORcrib.count
            } else {
                return 0
            }
        }
        
        return count
    }
    
}

// MARK: - Scoring Checks for computer cards
// make this work with BestPlay.PickACard
// add function calls to BestPlay.PickACard

struct CPUOrder {
    var historylist = History().showPlayHistory()
    
    func orderByValue() -> [Card] {
        let valueorderlist = historylist.sort { $0.rank.rawValue < $1.rank.rawValue }
        return valueorderlist
    }
    
    func getHistory() -> [Card] {
        return historylist
    }
}

class CPUScoringRun {
    
    private struct Constants {
        static var boolpoints = false
        static var someruncount = 0
    }
    
    func updateruncount(somecard: Card) {
        Constants.someruncount += somecard.rank.rawValue
    }
    
    // MARK: - Run Scoring
    
    func straight(cardone: Card) -> Int {
        var i = 0
        let orderlist = Order().orderByValue()
        if orderlist.count >= 3 {
            while (i + 1) < orderlist.count {
                if orderlist[i].rank.ordinal() == (orderlist[i + 1].rank.ordinal() + 1) {
                    Constants.boolpoints = true
                    i += 1
                } else {
                    Constants.boolpoints = false
                    i = orderlist.count
                }
            }
        }
        if Constants.boolpoints {
            Constants.boolpoints = false
            return orderlist.count
        } else {
            return 0
        }
    }
    
    func fifteencount(cardone: Card) -> Int {
        let orderlist = Order().orderByValue()
        var count = 0
        for acard in orderlist {
            count += acard.rank.rawValue
        }
        if count == 15 || count == 31 {
            return 2
        } else {
            return 0
        }
    }
    
    func SomeOfAKind(cardone: Card) -> Int {
        var historylist = Order().getHistory()
        let temp0 = historylist.removeFirst()
        let temp1 = historylist.removeFirst()
        let temp2 = historylist.removeFirst()
        let temp3 = historylist.removeFirst()
        var count = 0
        
        if temp3.rank.description() == temp2.rank.description() && temp2.rank.description() == temp1.rank.description() && temp1.rank.description() == temp0.rank.description() {
            count = 12
        } else if temp2.rank.description() == temp1.rank.description() && temp1.rank.description() == temp0.rank.description() {
            count = 6
        } else if temp1.rank.description() == temp0.rank.description() {
            count = 2
        } else {
            count = 0
        }
        return count
    }
    
    func getruncount(cardone: Card) -> Int {
        return Constants.someruncount
    }
    
    //returns 1 if the player cannot play, 0 otherwise
    //points should be given to the next player, not the current player (unlike the other functions)
    
    func go(runtotal: Int) -> Int {
        if History().mostRecentPlayer().cannotPlay(runtotal) {
            return 1
        } else {
            return 0
        }
    }
    
    func lastcard() -> Int {
        if Order().getHistory().count == 8 {
            return 1
        } else {
            return 0
        }
    }
    
    func jackflip() -> Int {
        if CribbageDeck().cutcard().rank.description() == "jack" {
            return 2
        } else {
            return 0
        }
    }
    
}
