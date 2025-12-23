# v0.1.0 - 22 December 2025

* Add SHA256 DragonRuby (mRuby) implementation, see [the messy annotated version of the SHA256 code here](https://gist.github.com/marcheiligers/3868b8fe862ce6a166a9cb67d7b429fb)
* Add Base64 [cribbed from CRuby](https://github.com/ruby/base64/blob/master/lib/base64.rb)
* Extended `BadCrypto` to handle a full-ish US keyboard (for secrets)
* Introduced a `Response` class for easier management of API responses
* Implement PurpleToken v3 API in `PurpleTokenV3`. Same API for users except requires a secret on instantiation in addition to the key
* Added new basic and interactive samples for V3 and made them the default
* Updated [dr-input](https://github.com/marcheiligers/dr-input) used in the samples to the latest release
* Updated release workflow

# v0.0.2 - 24 November 2025

* Fix links in the sample app in Safari (thanks @KonnorRogers)
* Add a note about the "Legacy" mode on the keys (thanks `@`Xed on Discord)

# v0.0.1 - 6 January 2025

* First release
* Library extracted from 20sHarvest and generalized
* Added basic_sample.rb and interactive_sample.rb sample applications
* Published interactive_sample to Itch

# Known Issues and TODO

* At least one user is hitting a Cloudflare block when running locally, though it works correctly when published to Itch
