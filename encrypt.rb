#!/usr/bin/env ruby

require "getoptlong"
require "openssl"
require "base64"
require "yaml"
require "json"

opts = GetoptLong.new(
                      [ "--help", "-h", GetoptLong::NO_ARGUMENT ],
                      [ "--file", "-f", GetoptLong::REQUIRED_ARGUMENT ],
                      [ "--secret", "-s", GetoptLong::REQUIRED_ARGUMENT ],
                      [ "--output", "-o", GetoptLong::OPTIONAL_ARGUMENT ],
                      )

help = <<-EOF
encrypt.rb --file=<PLAINTEXT FILE> --secret=<SECRET> --output=<OUTPUT FILE>

-h, --help:
  show help

-f, --file:
  plaintext file to encrypt (required)

-s, --secret:
  file containing encrypted data bag secret (required)

-o, --output:
  file to output to (defaults to STDOUT)
EOF

file = nil
secret = nil
out_file = nil

opts.each do |opt, arg|
  case opt
    when "--help"
    puts help
    exit 0
    when "--file"
    file = IO.read(arg).strip
    when "--secret"
    secret = IO.read(arg).strip
    when "--output"
    out_file = arg
  end
end

if file.nil?
  puts "Input file is required."
  puts help
  exit 0
end

if secret.nil?
  puts "Data bag secret file is required."
  puts help
  exit 0
end

contents = JSON.parse(file)
encrypted_contents = {}

contents.each do |k, v|
  if k == "id" || v.nil?
    encrypted_contents[k] = v
  else
    yaml = v.to_yaml

    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.encrypt
    cipher.pkcs5_keyivgen(secret)
    crypt = cipher.update(yaml) + cipher.final

    encrypted_contents[k] = Base64.encode64(crypt)
  end
end

if out_file.nil?
  print encrypted_contents.to_json
else
  IO.write(out_file, encrypted_contents.to_json)
end
