import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable {
  private(set) var cards: Array<Card>
  private(set) var score = 0
  
  private var indexOfTheOneAndOnlyFaceUpCard: Int? {
    get { cards.indices.filter { cards[$0].isFaceUp }.oneAndOnly }
    set { cards.indices.forEach{ cards[$0].isFaceUp = $0 == newValue }}
  }
  
  mutating func choose(_ card: Card) {
    if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }),
       !cards[chosenIndex].isFaceUp,
       !cards[chosenIndex].isMatched {
      if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
        if cards[chosenIndex].content == cards[potentialMatchIndex].content {
          cards[chosenIndex].isMatched = true
          cards[potentialMatchIndex].isMatched = true
          score += 2
        }
        // Mismatch
        else {
          if cards[chosenIndex].alreadyBeenSeen {
            score -= 1
          }
          if cards[potentialMatchIndex].alreadyBeenSeen {
            score -= 1
          }
        }
        
        cards[chosenIndex].isFaceUp = true
      } else {
          indexOfTheOneAndOnlyFaceUpCard = chosenIndex
      }
    }
  }
  
  mutating func shuffle() {
    cards.shuffle()
  }
  
  init(numberOfPairsOfCards: Int, createCardContent: (Int) -> CardContent) {
    cards = []
    
    for pairIndex in 0..<numberOfPairsOfCards {
      let content = createCardContent(pairIndex)
      cards.append(Card(content: content, id: pairIndex * 2))
      cards.append(Card(content: content, id: pairIndex * 2 + 1))
    }
    
    cards.shuffle()
  }
  
  struct Card: Identifiable {
    var isFaceUp = false {
      willSet {
        if !newValue && isFaceUp {
          alreadyBeenSeen = true
        }
      }
      didSet {
        if isFaceUp {
          startUsingBonusTime()
        } else {
          stopUsingBonusTime()
        }
      }
    }
    var isMatched = false {
      didSet {
        stopUsingBonusTime()
      }
    }
    var alreadyBeenSeen = false
    let content: CardContent
    let id: Int

    var bonusTimeLimit: TimeInterval = 6
    
    private var faceUpTime: TimeInterval {
      if let lastFaceUpDate = self.lastFaceUpDate {
        return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
      } else {
        return pastFaceUpTime
      }
    }
    
    var lastFaceUpDate: Date?
    var pastFaceUpTime: TimeInterval = 0
    
    var bonusTimeRemaining: TimeInterval {
      max(0, bonusTimeLimit - faceUpTime)
    }
    var bonusRemaining: Double {
      (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
    }
    var hasEarnedBonus: Bool {
      isMatched && bonusTimeRemaining > 0
    }
    var isConsumingBonusTime: Bool {
      isFaceUp && !isMatched && bonusTimeRemaining > 0
    }
    
    private mutating func startUsingBonusTime() {
      if isConsumingBonusTime, lastFaceUpDate == nil {
        lastFaceUpDate = Date()
      }
    }
    private mutating func stopUsingBonusTime() {
      pastFaceUpTime = faceUpTime
      self.lastFaceUpDate = nil
    }
  }
}

extension Array {
  var oneAndOnly: Element? {
    count == 1 ? first : nil
  }
}
