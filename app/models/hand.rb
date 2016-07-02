#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-
require "pp"
class SootViolation < StandardError ; end

class Hand
  extend ActiveModel::Naming
  Yaku = %w(ハイカード ワンペア ツーペア スリー・オブ・ア・カインド
            ストレート フラッシュ フルハウス フォー・オブ・ア・カインド
            ストレートフラッシュ データエラー)
  attr_accessor :cards,:card,:errors
  def self.create( cards_string )
    begin
      hand = new cards_string
      hand.cards
    rescue SootViolation => e
      #hand.errors.add :nil, e.message
    end
    hand
  end
  
  def initialize( cards_string )
    @errors = ActiveModel::Errors.new(self)
    @card = cards_string
  end

  def view
    {"card" => @card ,"hand" => Yaku[point||-1]}
  end

  def cards
    return @cards if @cards
pp  @card
    raise SootViolation,"カードデータが空です" if @card.blank?
    @cards = @card.split.map{|str| Card.new str }
    if @cards.group_by{|card| [card.soot,card.number]}.values.map(&:size).max>1
      raise SootViolation,"イカサマだ！ #{@card}には同じカードが2枚以上ある"
    end
    raise SootViolation, "手札が5枚じゃない" if cards.size != 5
    @cards
  rescue SootViolation  => e
    errors.add( :nil, e.message )
    @cards = nil
    raise
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

