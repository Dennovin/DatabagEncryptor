require "getoptlong"
require "openssl"
require "base64"
require "yaml"
require "json"

opts = GetoptLong.new(
                      [ "--file", "-f", GetoptLong::REQUIRED_ARGUMENT ],
                      [ "--secret", "-s", GetoptLong::REQUIRED_ARGUMENT ],
                      [ "--output", "-o", GetoptLong::OPTIONAL_ARGUMENT ],
                      )

file = nil
secret = nil
out_file = nil

opts.each do |opt, arg|
  case opt
    when "--file"
    file = IO.read(arg).strip
    when "--secret"
    secret = IO.read(arg).strip
    when "--output"
    out_file = arg
  end
end

encrypted_contents = JSON.parse(file)
contents = {}

encrypted_contents.each do |k, v|
  if k == "id" || v.nil?
    contents[k] = v
  else
    crypt = Base64.decode64(v)

    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.decrypt
    cipher.pkcs5_keyivgen(secret)
    yaml = cipher.update(crypt) + cipher.final

    contents[k] = YAML.load(yaml)
  end
end

if out_file.nil?
  print contents.to_json
else
  IO.write(out_file, contents.to_json)
end
