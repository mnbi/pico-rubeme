# coding: utf-8
# frozen_string_literal: true

require "test_helper"

class PicoRubemeLexerTest < Minitest::Test
  def test_it_can_instantiate
    lexer = PicoRubeme.lexer("")
    refute_nil lexer
  end

  def test_it_can_tokenize_identifier
    tcs = [
      "foo",
      "cons", "car", "cdr", "eq?", "pair?",
      "if", "quote", "lambda", "define"
    ]
    assert_simple_tokens(tcs, "identifier")
  end

  def test_it_can_tokenize_boolean
    tcs = [
      "#f", "#false",
      "#t", "#true",
    ]
    assert_simple_tokens(tcs, "boolean")
  end

  def test_it_can_tokenize_number
    tcs = [
      "0", "123", "+4", "-56", "+0", "-0",
      "12.3", "-456.7", "+8.901",
      "1/2", "-3/5",
      "1+2i", "-3.4+5.67i", "+8.9-0.12i", "+i", "-3.0i",
      "2/3+6/7i",
    ]
    assert_simple_tokens(tcs, "number")
  end

  def test_it_can_tokenize_character
    tcs = [
      "#\\a", "#\\B", "#\\1", "#\\純", "#\\#",
    ]
    assert_simple_tokens(tcs, "character")
  end

  def test_it_can_tokenize_string
    tcs = [
      "\"foo\"", "\"hoge\"", "\"あいうえお\"",
    ]
    assert_simple_tokens(tcs, "string")
  end

  def test_it_can_tokenize_an_empty_list
    tc = "()"
    expected = ["lparen", "rparen",]
    assert_compound_tokens(tc, expected)
  end

  def test_it_can_tokenize_a_lambda_expression
    tc = "(lambda (n) (+ n 1))"
    expected = [
      "lparen",                 # (
      "identifier",             # lambda
      "lparen",                 # (
      "identifier",             # n
      "rparen",                 # )
      "lparen",                 # (
      "identifier",             # +
      "identifier",             # n
      "number",                 # 1
      "rparen",                 # )
      "rparen",                 # )
    ]
    assert_compound_tokens(tc, expected)
  end

  def test_it_can_tokenize_quotation
    tc = "'123"
    expected = ["quotation", "number"]
    assert_compound_tokens(tc, expected)
  end

  def test_it_can_skip_lparen
    tc = "(123)"
    lexer = PicoRubeme.lexer(tc)
    lexer.skip_lparen
    assert_type("number", lexer.peek)
  end

  def test_it_can_skip_rparen
    tc = ")("
    lexer = PicoRubeme.lexer(tc)
    lexer.skip_rparen
    assert_type("lparen", lexer.peek)
  end

  private

  include PicoRubeme::Object

  def assert_compound_tokens(tc, expected)
    lexer = PicoRubeme.lexer(tc)
    loop {
      assert_equal expected.shift, token_type(lexer.next)
    }
  end

  def assert_simple_tokens(tcs, type)
    tcs.each { |tc|
      lexer = PicoRubeme.lexer(tc)
      token = lexer.next
      assert_type(type, token)
    }
  end

  def assert_type(type, token)
    assert_equal type, token_type(token)
  end
end
