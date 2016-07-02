# -*- coding: utf-8 -*-
class HandController < ApplicationController
  def index
  end
    
  def hand
    unless params[:cards].blank?
      @hand = Hand.new(params[:cards])
      render action: :index
    else
      redirect_to :index
    end
  end

  def game
    unless params[:card_json].blank?
      @game = Game.new(params[:card_json])
      render action: :index
    else
      redirect_to :index
    end
  end
end
