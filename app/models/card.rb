#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-
class SootViolation < StandardError ; end

class Card
  extend ActiveModel::Naming
  attr_reader :soot ,:number,:name,:errors
  def initialize(arg)
    @errors = ActiveModel::Errors.new(self)
    @name = arg
    @soot = arg[0,1].upcase
    @number = arg[1..-1].to_i
    raise SootViolation,  "#{@soot}はCHDS 以外です"   unless "CHDS".include?(@soot)
    raise SootViolation,  "#{number}が1～13 以外です"  unless (1..13).include?(@number)
  end
  def <=> other
    ret = self.soot <=> other.soot
    ret == 0 ? self.number <=> other.number : ret
  end
  def self.human_attribute_name(a,b)
    ""
  end
end
