module HandCalculator

=begin
These helper methods isolate the cards' "rank" (integer properties) and "suit" (letter 
properties) by mapping them onto a new array. They are crucial to the control flow of this 
module as they are used in virtually all hand strength and hand comparison methods.
=end

  def self.r(cards)
    cards.map { |card| card.to_i }.sort
  end


  def self.s(cards)
    cards.map { |card| card[-1] }
  end

  def self.which_rank_occurs_n_times?(cards, n)
    
    arr = []

    n_occurrences_hash = Hash.new(0)
    cards.each do |rank|
      n_occurrences_hash[rank] += 1
    end

    n_occurrences_hash.each do |rank, occurrence_number|
      if occurrence_number == n
        arr << rank
      end
    end
    
    arr.length == 1 ? arr[0] : arr
  end

  #which_rank_occurs_n_times?([3,6,6,7], 2)

  def self.isolate_kickers(cards, n)
      
    kickers = []
    
    cards.each do |rank|
      kickers << rank if rank != which_rank_occurs_n_times?(cards, n)
    end
     
    kickers
  end

  def self.assess_kickers(hands, i, n)
          
    best_hand = []
    kicker = 0
        
    hands.each do |this_hand_unrefined|
      nonpair_cards = isolate_kickers(r(this_hand_unrefined), n)
          
      if nonpair_cards[i] > kicker
        kicker = nonpair_cards[i]
        best_hand = [this_hand_unrefined]
          
      elsif nonpair_cards[i] == kicker
        best_hand << this_hand_unrefined
      end
    end
        
    return best_hand if best_hand.length == 1 || i == 0 
    
    assess_kickers(best_hand, i -= 1, n)
  end

=begin
This method takes a parameter of an array containing either 6 or 7 cards (meant to represent
the number of cards available to a player at the "turn" or the "river") and returns all possible 
hands. Used in tandem with the :best_hand method to find the best hand a player 
holds at any given point of the game.
=end

  def self.all_hands_from_cards(cards)

    all_hands = []
    
    if cards.length == 7

      until all_hands.length == 21
        cards = cards.shuffle
        random_hand = cards[0..4]
        all_hands << random_hand.sort
        all_hands = all_hands.uniq
      end
            
    elsif cards.length == 6
        
      until all_hands.length == 6
        cards = cards.shuffle
        random_hand = cards[0..4]
        all_hands << random_hand.sort
        all_hands = all_hands.uniq
      end
        
    else return [cards]
    
    end
    all_hands
  end

  #all_hands_from_cards(["2a","4b","5c","6d","7a","4d","5d"])

=begin
Methods for determining the strength of hands. <r> stands for "rank" and is both 
invoked as a method and declared as a variable when we are concerned with the 
rank (or integer property) of the cards. <s> stands for "suit" and is both invoked 
as a method and declared as a variable when we are concerned with the suit (or
letter property) of the cards.
=end

  def self.straight_flush(cards)
      
    s = s(cards)
    r = r(cards)

    if s[0] == s[1] && s[1] == s[2] && s[2] == s[3] && s[3] == s[4]
      
      if r[4] - r[3] == 1 && r[3] - r[2] == 1 && r[2] - r[1] == 1 && r[1] - r[0] == 1 &&  r[3] == 13
        "royal flush"
      elsif r[4] - r[3] == 1 && r[3] - r[2] == 1 && r[2] - r[1] == 1 && r[1] - r[0] == 1
        true
      elsif r[3] - r[2] == 1 && r[2] - r[1] == 1 && r[1] - r[0] == 1 && r[4] - r[0] == 12 && r[4] == 14
        true
      else false
      end
    else false
    end
  end


  def self.quads(cards)
      
    r = r(cards)
    
    if (r[0] == r[1] && r[1] == r[2] && r[2] == r[3]) || (r[1] == r[2] && r[2] == r[3] && r[3] == r[4])
      true
    else false
    end
  end


  def self.full_house(cards)
      
    r = r(cards)

    if ((r[0] == r[1] && r[1] == r[2]) && r[3] == r[4]) || (r[0] == r[1] && (r[2] == r[3] && r[3] == r[4]))
      true
    else false
    end
  end


  def self.flush(cards)
      
    s = s(cards)
    
    if s[0] == s[1] && s[1] == s[2] && s[2] == s[3] && s[3] == s[4]
      true
    else false
    end
  end


  def self.straight(cards)

    r = r(cards)
    
    if r[4] - r[3] == 1 && r[3] - r[2] == 1 && r[2] - r[1] == 1 && r[1] - r[0] == 1
      true
    elsif r[3] - r[2] == 1 && r[2] - r[1] == 1 && r[1] - r[0] == 1 && r[4] - r[0] == 12 && r[4] == 14
      true
    else false
    end
  end


  def self.trips(cards)
      
    r = r(cards)
    
    if (r[0] == r[1] && r[1] == r[2]) || (r[1] == r[2] && r[2] == r[3]) || (r[2] == r[3] && r[3] == r[4])
      true
    else false
    end
  end


  def self.two_pair(cards)
      
    r = r(cards)
    
    if (r[0] == r[1] && r[2] == r[3]) || (r[1] == r[2] && r[3] == r[4]) || (r[0] == r[1] && r[3] == r[4])
      true
    else false
    end
  end


  def self.pair(cards)
      
    r = r(cards)
    
    if r[0] == r[1] || r[1] == r[2] || r[2] == r[3] || r[3] == r[4]
      true
    else false
    end
  end

  # When any 2 or more hands result in the same type of hand (e.g. both are full houses), we must
  # use tie-breaker methods to deduce which hand/s is/are best.

  def self.best_quads(hands)

    best_hand = []
    highest_rank = 0

    hands.each do |this_hand_unrefined|
      this_hand = r(this_hand_unrefined)

      if which_rank_occurs_n_times?(this_hand, 4) > highest_rank
        best_hand = [this_hand_unrefined]
        highest_rank = which_rank_occurs_n_times?(this_hand, 4)
      
      elsif which_rank_occurs_n_times?(this_hand, 4) == highest_rank
        best_hand << this_hand_unrefined
      end
    end

    return best_hand if best_hand.length == 1
    
    assess_kickers(best_hand, 4, 0)
  end

  #best_quads([["5a","5b","5c","5d","10a"],["5a","5b","5c","5d","12a"],["5a","5b","5c","5d","11a"]])

  def self.best_full_house(hands)

    best_hand = []
    highest_rank = 0

    hands.each do |this_hand_unrefined|
      this_hand = r(this_hand_unrefined)
      
      if which_rank_occurs_n_times?(this_hand, 3) > highest_rank
        best_hand = [this_hand_unrefined]
        highest_rank = which_rank_occurs_n_times?(this_hand, 3)
      
      elsif which_rank_occurs_n_times?(this_hand, 3) == highest_rank
        best_hand << this_hand_unrefined
      end
    end

    if best_hand.length > 1

      highest_rank = 0

      best_hand.each do |this_hand_unrefined|
        this_hand = r(this_hand_unrefined)

        if which_rank_occurs_n_times?(this_hand, 2) > highest_rank
          best_hand = [this_hand_unrefined]
          highest_rank = which_rank_occurs_n_times?(this_hand, 2)
        
        elsif which_rank_occurs_n_times?(this_hand, 2) == highest_rank
          best_hand << this_hand_unrefined
        end
      end
      best_hand
    else best_hand
    end
  end

  #best_full_house([["13a","12b","13c","12a","7d"],["13a","12c","13a","12b","8d"]])
  #best_full_house([["13a","11b","13c","11a","8d"],["13a","12c","13a","12b","8d"]])

  def self.best_flush(hands)
    assess_kickers(hands, 4, 1)
  end
  #best_flush([["13a","11a","10a","9a","8a"],["13a","11a","10a","9a","7a"]])

  def self.best_straight(hands)
      
    highest_rank_sum = 0
    best_hand = []
    
    hands.each do |this_hand|

      ## Reassign the rank value of the ace when it is part of the low straight.

      r = r(this_hand) 

      if r == [2,3,4,5,14]
        r = [1,2,3,4,5]
      end

      #                     #                           #
  
      rank_sum = r.inject(:+)
  
      if rank_sum > highest_rank_sum
        highest_rank_sum = rank_sum
        best_hand = [this_hand]
  
      elsif rank_sum == highest_rank_sum
        best_hand << this_hand
      end
    end
    best_hand
  end

  #best_straight(["18a","4a","12b","13a","9d"], ["29a","8c","8b","9a","2d"]) #returns both
  #best_straight(["2a","3a","4a","5a","14a"], ["2a","3a","4a","5a","6a"]) #returns the second arr

  def self.best_trips(hands)

    best_hand = []
    highest_rank = 0
    
    hands.each do |this_hand_unrefined|
      this_hand = r(this_hand_unrefined)
      
      if which_rank_occurs_n_times?(this_hand, 3) > highest_rank
        best_hand = [this_hand_unrefined]
        highest_rank = which_rank_occurs_n_times?(this_hand, 3)
      
      elsif which_rank_occurs_n_times?(this_hand, 3) == highest_rank
        best_hand << this_hand_unrefined
      end
    end

    return best_hand if best_hand.length == 1
    
    assess_kickers(best_hand, 1, 3)
  end

  #best_trips([["11a","11b","11c","12a","10b"], ["11d","11b","11c","10b","12a"]]) #returns both
  #best_trips([["11a","11b","11c","9a","12b"],["11d","11b","11c","10b","12a"]]) #returns the second arr

  def self.best_two_pair(hands)
    
    best_hand = []
    top_pair_rank = 0
    bottom_pair_rank = 0
    kicker = 0
    
    hands.each do |this_hand_unrefined|
      this_hand = r(this_hand_unrefined)
      
      if (which_rank_occurs_n_times?(this_hand, 2)).max > top_pair_rank
        top_pair_rank = (which_rank_occurs_n_times?(this_hand, 2)).max
        best_hand = [this_hand_unrefined]
      
      elsif (which_rank_occurs_n_times?(this_hand, 2)).max == top_pair_rank
        best_hand << this_hand_unrefined
      end
    end
            
    if best_hand.length > 1
      
      best_hand.each do |this_hand_unrefined|
        this_hand = r(this_hand_unrefined)
    
        if (which_rank_occurs_n_times?(this_hand, 2)).min > bottom_pair_rank
          bottom_pair_rank = (which_rank_occurs_n_times?(this_hand, 2)).min
          best_hand = [this_hand_unrefined]
        
        elsif (which_rank_occurs_n_times?(this_hand, 2)).min == bottom_pair_rank
          best_hand << this_hand_unrefined
        end
      end
    
      if best_hand.length > 1
          
        best_hand.each do |this_hand_unrefined|
          this_hand = r(this_hand_unrefined)
          
          this_hand.each do |rank|
              
            if rank > kicker && !(which_rank_occurs_n_times?(this_hand, 2).include?(rank))
              kicker = rank
              best_hand = [this_hand_unrefined]
                  
            elsif rank > kicker && !(which_rank_occurs_n_times?(this_hand, 2).include?(rank))
              best_hand << this_hand_unrefined
            end
          end
        end
        best_hand
      else best_hand
      end
    else best_hand
    end
  end

  #which_rank_occurs_n_times?([2,3,3,2,5], 2).min
  #best_two_pair([["13a","13b","10a","10b","14a"],["10a","10b","13b","13c","9a"]]) #returns the first arr

  def self.best_pair(hands)
    
    best_hand = []
    top_pair = 0
    
    hands.each do |this_hand_unrefined|
      this_hand = r(this_hand_unrefined)
      
      if which_rank_occurs_n_times?(this_hand, 2) > top_pair
        top_pair = which_rank_occurs_n_times?(this_hand, 2)
        best_hand = [this_hand_unrefined]
      
      elsif which_rank_occurs_n_times?(this_hand, 2) == top_pair
        best_hand << this_hand_unrefined
      end
    end
    
    return best_hand if best_hand.length == 1
     
    assess_kickers(best_hand, 2, 2)
  end

  #best_pair([["14a","14b","11a","10b","6a"],["14a","12b","14b","10c","13a"]]) #returns the second arr

  def self.best_air(hands)
      assess_kickers(hands, 4, 1)
  end

  #best_air([["4a","13b","12a","11b","10a"],["7a","13b","12b","11c","10a"],["3a","13b","12b","11b","10a"]]) #returns second arr

  def self.winning_hand(hand)
    
    hand = hand.length == 1 ? hand.flatten : hand[0]

    return "ROYAL FLUSH!" if straight_flush(hand) == "royal flush"
    return "STRAIGHT FLUSH!" if straight_flush(hand)
    return "FOUR OF A KIND!" if quads(hand)
    return "FULL HOUSE!" if full_house(hand)
    return "FLUSH!" if flush(hand)
    return "STRAIGHT!" if straight(hand)
    return "THREE OF A KIND!" if trips(hand)
    return "TWO PAIR!" if two_pair(hand)
    return "PAIR!" if pair(hand)
    return "COMPLETE AIR"
  end


  def self.evaluate_hand(cards)
    return 10 if straight_flush(cards) == "royal flush"
    return 9 if straight_flush(cards)
    return 8 if quads(cards)
    return 7 if full_house(cards)
    return 6 if flush(cards)
    return 5 if straight(cards)
    return 4 if trips(cards)
    return 3 if two_pair(cards)
    return 2 if pair(cards)
    return 1
  end


  def self.best_hand(hands)

    best_hand = []
    best_hand_score = 0

    hands.each do |this_hand|
      if evaluate_hand(this_hand) > best_hand_score
        best_hand = [this_hand]
        best_hand_score = evaluate_hand(this_hand)
      elsif evaluate_hand(this_hand) == best_hand_score
        best_hand << this_hand
      end
    end
    if best_hand.length > 1
      if best_hand_score == 1
        best_air(best_hand)
      elsif best_hand_score == 2
        best_pair(best_hand)
      elsif best_hand_score == 3
        best_two_pair(best_hand)
      elsif best_hand_score == 4
        best_trips(best_hand)
      elsif best_hand_score == 5 || best_hand_score == 9
        best_straight(best_hand)
      elsif best_hand_score == 6
        best_flush(best_hand)
      elsif best_hand_score == 7
        best_full_house(best_hand)
      elsif best_hand_score == 8
        best_quads(best_hand)
      else best_hand
      end
    else best_hand
    end
  end
#winning_hand(best_hand(all_hands_from_cards(["10b","12d","10d","10c","9b","9c","10a"])))
end