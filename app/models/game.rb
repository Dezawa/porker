#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-
class SootViolation < StandardError ; end
class JasonViolation < StandardError ; end

require "pp"
require "json"
class Game
  extend ActiveModel::Naming

  attr_reader :hands,:errors
  # {cards: [ "H1 H13 H12 H11 H10”, "H9 C9 S9 H2 C2”, "C13 D12 C11 H8 H7 ]} 
  def initialize(hands_json)
    @errors = ActiveModel::Errors.new(self)
    @hands = JSON.parse(hands_json)["cards"].map{|card_str| Hand.new(card_str)}
    vlidate(hands_json)
    errors.add :nil,"カードが配られていない" if @hands.size == 0
    @hands.each{|hand|
      errors.add(:nil,hand.errors.full_messages.join("\n")) unless hand.errors.empty?
    }
    @cards = @hands.sort_by{|hand| -hand.point}.map{|hand| hand.cards.map(&:name)}.flatten
    if !@cards.empty? &&@cards.group_by{|name| name }.values.map(&:size).max>1
      raise SootViolation ,"イカサマだ！ #{@hands.map(&:card).join(',')}には同じカードが2枚以上ある"
    end
  rescue SootViolation  => e
    errors.add( :nil, e.message )
    @cards = nil
    #raise
  end
  card = "[CHDSchds]\\d\\d*"
  cards  ="\"\\s*#{card}\\s+#{card}\\s+#{card}\\s+#{card}\\s+#{card}\\s*\""
  Reg_form  = %r({\s*"cards"\s*:\s*\[.*\]\s*\})
  Reg_cards  = %r(\[\s*#{cards}.*\])
  cardss = "#{cards}(,\\s*#{cards})*"
  Reg   = %r(\s*\{\s*"cards"\s*:\s*\[\s*#{cardss}\s*\]\s*\})
  def vlidate(hands_json)
    raise SootViolation,'key は 文字列 "cards" です。' unless /"cards"\s*:/ =~ hands_json
    
    raise SootViolation,'{ "cards" : [ ,,,,,] } という形式です' unless Reg_form  =~ hands_json
    raise SootViolation,'[ ] 内はカード5枚を表す文字列形式です' unless Reg_cards  =~ hands_json

  end
  def json
    JSON.dump({ result: order })
  end
  def order
    return errors.full_messages.join("\n") unless errors.empty?
    orders = @hands.sort_by{|hand| - hand.point}.map(&:view)
    orders.first["best"] = true unless orders.empty?
    orders
  end
  def self.human_attribute_name(a,b)
    ""
  end
end
