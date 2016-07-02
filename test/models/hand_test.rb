#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-
require "test_helper"

=begin
=end
class SootViolation < StandardError ; end

class HandTest <  ActiveSupport::TestCase
   must "cardに分解されるか" do
     assert_equal  [["D",1],["D",10],["S",9],["C",5],["C",4]],
       Hand.new("d1 D10 S9 C5 C4").cards.map{|card| [card.soot,card.number]}
   end

   must "royal strate flush" do
     assert_equal "ストレートフラッシュ",Hand::Yaku[Hand.new("D11 D12 D13 D10 D1").point]
   end
   must "strate flush" do
     assert_equal "ストレートフラッシュ",Hand::Yaku[Hand.new("D11 D12 D13 D10 D1").point]
   end
   must "four cards" do
     assert_equal "フォー・オブ・ア・カインド",Hand::Yaku[Hand.new("D1 D10 S1 C1 H1").point]
   end
   must "full_house" do
     assert_equal "フルハウス",Hand::Yaku[Hand.new("D1 D10 S1 C1 H10").point]
   end
   must "flush" do
     assert_equal "フラッシュ", Hand::Yaku[Hand.new("D1 D10 D9 D5 D4").point]
   end
   must "hi-card " do
     assert_equal "ハイカード",Hand::Yaku[Hand.new("D1 D10 S9 C5 C4").point]
   end
   must "one-pair " do
     assert_equal "ワンペア",Hand::Yaku[Hand.new("D1 D10 S1 C5 C4").point]
   end
   must "two_pair " do
     assert_equal "ツーペア",Hand::Yaku[Hand.new("D1 D10 S1 C10 C4").point]
   end
   must "three cxards " do
     assert_equal "スリー・オブ・ア・カインド",Hand::Yaku[Hand.new("D1 D10 S1 C1 C4").point]
   end
   must "strate " do
     assert_equal "ストレート",Hand::Yaku[Hand.new("D1 D2 S3 C5 C4").point]
   end
   must "roial strate " do
     assert_equal "ストレート",Hand.new("D1 D12 S13 C10 C11").view["hand"]
   end

   must "複数" do
     jsonstr =
       '{"cards": ["H1 H13 H12 H11 H10","H9 C9 S9 H2 C2","C13 D12 C11 H8 H7"]}'
     game = Game.new(jsonstr)
     assert_equal [{"card"=>"H1 H13 H12 H11 H10", "hand"=>"ストレートフラッシュ"},
                   {"card"=>"H9 C9 S9 H2 C2", "hand"=>"フルハウス"},
                   {"card"=>"C13 D12 C11 H8 H7", "hand"=>"ハイカード"}],
       game.hands.map(&:view)
   end
   must "一番は？" do
     jsonstr =
       '{"cards": ["H1 H13 H12 H11 H10","H9 C9 S9 H2 C2","C13 D12 C11 H8 H7"]}'
     game = Game.new(jsonstr)
     assert_equal [{"card"=>"H1 H13 H12 H11 H10", "hand"=>"ストレートフラッシュ","best"=>true},
                   {"card"=>"H9 C9 S9 H2 C2", "hand"=>"フルハウス"},
                   {"card"=>"C13 D12 C11 H8 H7", "hand"=>"ハイカード"}],
       game.order
   end
   must "JSON" do
     jsonstr =
       '{"cards": ["H1 H13 H12 H11 H10","H9 C9 S9 H2 C2","C13 D12 C11 H8 H7"]}'
     game = Game.new(jsonstr)
     assert_equal '{"result":[{"card":"H1 H13 H12 H11 H10","hand":"ストレートフラッシュ",'+
       '"best":true},{"card":"H9 C9 S9 H2 C2","hand":"フルハウス"},'+
       '{"card":"C13 D12 C11 H8 H7","hand":"ハイカード"}]}',
       game.json
   end

  ################
   must "スーツ違いはcardになるか" do
     violation = assert_raise(SootViolation){Card.new("P1")}
     assert_equal "PはCHDS 以外です", violation.message
   end

   must "cardデータなし" do
     violation = assert_raise(SootViolation){ Hand.new("").cards}
     assert_equal "カードデータが空です", violation.message
   end
   
   must "スーツ違いはcardに分解されるか" do
     violation = assert_raise(SootViolation){ Hand.new("P1 D10 S9 C5 C4").cards}
     assert_equal "PはCHDS 以外です", violation.message
   end
   
   must "数字違いはcardに分解されるか" do
     violation = assert_raise(SootViolation){Hand.new("D21 D10 S9 C5 C4").cards}
     assert_equal "21が1～13 以外です",violation.message
   end
   must "同じカードがある！" do
     violation = assert_raise(SootViolation){ Hand.new("D10 D10 S9 C5 C4").cards}
     assert_equal "イカサマだ！ D10 D10 S9 C5 C4には同じカードが2枚以上ある",
       violation.message
   end
   must "同じカードがある。create なら 例外出ない" do
     hand = Hand.create("D10 D10 S9 C5 C4")
     assert_equal [" イカサマだ！ D10 D10 S9 C5 C4には同じカードが2枚以上ある"],
       hand.errors.full_messages
   end
   must "複数で、同じカードあり" do
     jsonstr =
       '{"cards": ["H1 H13 H12 H11 H10","H9 C9 S9 H12 C2","C13 D12 C11 H8 H7"]}'
     assert_equal [" イカサマだ！ H1 H13 H12 H11 H10,H9 C9 S9 H12 C2,C13 D12"+
       " C11 H8 H7には同じカードが2枚以上ある"], Game.new(jsonstr).errors.full_messages
     
   end
   must "複数で、同じカードあり-2" do
     jsonstr =
       '{"cards": ["H1 H13 H13 H11 H10","H9 C9 S9 H12 C2","C13 D12 C11 H8 H7"]}'
     assert_equal [" イカサマだ！ H1 H13 H13 H11 H10には同じカードが2枚以上ある"],
       Game.new(jsonstr).errors.full_messages
   end
   must "複数で、スーツ違いあり" do
     jsonstr =
       '{"cards": ["H1 H13 P3 H11 H10","H9 C9 S9 H12 C2","C13 D12 C11 H8 H7"]}'
      assert_equal  [" PはCHDS 以外です"], Game.new(jsonstr) .errors.full_messages
   end
  must "JSONが空" do
    assert_equal  [" カードが配られていない"], Game.new('{"cards": []}').errors.full_messages
  end
  must "一部カード不足" do
    jsonstr =
      '{"cards": ["H1 H13 H12 H11","H9 C9 S9 H2 C2","C13 D12 C11 H8 H7"]}'
    assert_equal [" 手札が5枚じゃない"],  Game.new(jsonstr) .errors.full_messages
  end
  JsonTest = Game.new  '{"cards": ["H1 H13 H12 H11 H10","H9 C9 S9 H2 C2","C13 D12 C11 H8 H7"]}'
  must "keyが違う" do
    violation =  assert_raise(SootViolation) { JsonTest.vlidate  '{cards: '}
    assert_equal "key は 文字列 \"cards\" です。", violation.message
  end
  must "json形式が違う" do
    violation =  assert_raise(SootViolation) { JsonTest.vlidate  '{"cards": [ '}
    assert_equal '{ "cards" : [ ,,,,,] } という形式です', violation.message
  end
  must "[ ]内はカード" do
    violation =  assert_raise(SootViolation) { JsonTest.vlidate  '{"cards": [  ] }' }
    assert_equal '[ ] 内はカード5枚を表す文字列形式です', violation.message
  end
end
