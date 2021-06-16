# frozen_string_literal: true

module PicoRubeme

  # Object of Pico-rubeme:
  #   [ <category>, <type>, <data>, ... ]
  #   category -> :token | :ast | :scmo
  #   type -> "*#{type_string}*"
  #
  #   Example:
  #   - [:token, "*lparen*", "("]
  #   - [:ast, "*boolean*", "#f"]

  module Object

    CATEGORIES = [:token, :ast, :scmo,]
    TAG = /\A\*(.+)\*\Z/

    def make_object(category, type_name, *data)
      if CATEGORIES.include?(category)
        tag = "*#{type_name}*"
        [category, tag, *data]
      end
    end

    def rubeme_object?(obj)
      obj.instance_of?(Array) && CATEGORIES.include?(obj[0]) && TAG.match?(obj[1])
    end

    def category(obj)
      obj[0]
    end

    def category?(obj, cat)
      category(obj) == cat
    end

    def token?(obj)
      category?(obj, :token)
    end

    def ast?(obj)
      category?(obj, :ast)
    end

    def scmo?(obj)
      category?(obj, :scmo)
    end

    def type(obj)
      TAG.match(obj[1])
      Regexp.last_match && Regexp.last_match(1)
    end

    def data(obj)
      obj[2..-1]
    end

    def make_token(type, literal)
      make_object(:token, type, literal)
    end

    def token_type(obj)
      type(obj)
    end

    def token_type?(obj, type)
      token_type(obj) == type
    end

    def token_literal(obj)
      data(obj)[0]
    end

    def make_ast_node(type, *data)
      make_object(:ast, type, *data)
    end

    def ast_type(obj)
      type(obj)
    end

    def ast_type?(obj, type)
      ast_type(obj) == type
    end

    def ast_literal(obj)
      data(obj)[0]
    end

  end
end
