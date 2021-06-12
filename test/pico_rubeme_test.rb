# frozen_string_literal: true

require "test_helper"

class PicoRubemeTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::PicoRubeme::VERSION
  end
end
