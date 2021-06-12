# frozen_string_literal: true

module PicoRubeme
  VERSION = "0.1.0"
  RELEASE = "2021-06-??"

  def self.make_version(name, ver: nil, rel: nil)
    mod_name = name.downcase.split("::").join(".")
    mod_name.gsub!(/(pico)/, "\\1-")
    ver ||= VERSION
    rel ||= RELEASE
    [mod_name, ":version", ver, ":release", rel].join(" ")
  end
end
