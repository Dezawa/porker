#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-
class SootViolation < StandardError ; end

class Hand
  extend ActiveModel::Naming
  Yaku = %w(ハイカード ワンペア ツーペア スリー・オブ・ア・カインド
            ストレート フラッシュ フルハウス フォー・オブ・ア・カインド
            ストレートフラッシュ データエラー)
  attr_accessor :cards,:card,:errors
  
  def initialize( cards_string )
    @errors = ActiveModel::Errors.new(self)
    @card = cards_string
    @cards = cards_string.split.map{|str| Card.new str }
    if @cards.group_by{|card| [card.soot,card.number]}.values.map(&:size).max>1
      # raise SootViolation,"イカサマだ！ #{@card}には同じカードが2枚以上ある"
      errors.add( :nil, "イカサマだ！ #{@card}には同じカードが2枚以上ある")
    end
    if cards.size != 5
      errors.add( :nil, "手札が5枚じゃない")
    end
  rescue SootViolation  => e
    errors.add( :nil, e.message )
    @cards = nil
  end

  def inspect
    {"card" => @card ,"hand" => Yaku[point||-1]}
  end
  
  def point
    return  nil unless cards
      
    @group_number = cards.group_by{|card| card.number}
    @group_soot   = cards.group_by{|card| card.soot}
    #return "ロイヤルストレートフラッシュ" if royal_straight_flush?
    straight_flush? || four_cards? || full_house? ||
      flush? || straight? || three_cards? || two_pair? ||
      one_pair? || 0
  end
  def royal_straight_flush?
    straight_flush? &&  @cards.map(&:number).sort == [1, 10,11,12,13] && 9
  end
  def straight_flush?
    straight? && flush? && 8
  end
  
  def four_cards?
    @group_number.values.map(&:size).sort == [1,4] && 7
  end
  def full_house?
    @group_number.values.map(&:size).sort == [2,3] && 6
  end
  def flush?
    @group_soot.size == 1 && 5
  end
  def straight?
    sorted = @cards.map(&:number).sort
    ((sorted[0] .. sorted[4]).to_a == sorted || sorted == [1,10,11,12,13]) && 4
  end
  def three_cards?
    @group_number.values.map(&:size).sort == [1,1,3] && 3
  end
  def one_pair?
    @group_number.size == 4 && 1
  end

  # three cards を見てるから、これでOK
  def two_pair?
    @group_number.size == 3 && 2
  end
  def self.human_attribute_name(a,b)
    ""
  end
end

