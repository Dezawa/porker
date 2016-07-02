#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-
class SootViolation < StandardError ; end

require "pp"
require "json"
class Game
  extend ActiveModel::Naming

  attr_reader :hands,:errors
  # {cards: [ "H1 H13 H12 H11 H10”, "H9 C9 S9 H2 C2”, "C13 D12 C11 H8 H7 ]} 
  def initialize(hands_json)
    @errors = ActiveModel::Errors.new(self)
    @hands = JSON.parse(hands_json)["cards"].map{|card_str| Hand.new(card_str)}
    
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
  def json
    JSON.dump({ result: order })
  end
  def order
    return errors.full_messages.join("\n") unless errors.empty?
    orders = @hands.map(&:view)
    orders.first["best"] = true unless orders.empty?
    orders
  end
  def self.human_attribute_name(a,b)
    ""
  end
end
