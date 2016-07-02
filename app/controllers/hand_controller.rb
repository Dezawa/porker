# -*- coding: utf-8 -*-
class SootViolation < StandardError ; end
class HandController < ApplicationController
  def index
  end
    
  def hand
    @hand = Hand.create(params[:cards])
   # if @hand.errors.empty?
      render action: :index
    #else SootViolation
   #   redirect_to :index
   # end
  end

  def game
    @game = Game.new(params[:card_json])
      render action: :index
  #rescue SootViolation
  #  redirect_to :index
  end
end
