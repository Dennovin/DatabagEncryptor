DatabagEncryptor
================

Scripts for encrypting and decrypting Chef data bags.

This is intended for use with Chef Solo and data bag format version 0. **Files created with these scripts will NOT work with Chef 11 or above.**

## Use
```
encrypt.rb --file=<PLAINTEXT FILE> --secret=<SECRET> --output=<OUTPUT FILE>
decrypt.rb --file=<ENCRYPTED FILE> --secret=<SECRET> --output=<OUTPUT FILE>
```

If `--output` is omitted, the script will output to `STDOUT`.
