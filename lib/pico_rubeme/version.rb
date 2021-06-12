# frozen_string_literal: true

module PicoRubeme
  VERSION = "0.1.0"
  RELEASE = "2021-06-??"

  def self.make_version(name)
    mod_name = name.downcase.split("::").join(".")
    "(#{mod_name} :version #{VERSION} :release #{RELEASE})"
  end
end
