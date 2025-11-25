# dr-high_score

A library for saving and retrieving high scores for DragonRuby.

## Usage

In order to use this library, you will need to sign up for an account at [Purple Token](https://purpletoken.com/), create a Game in the UI, and then create an API key. Ensure that you enable the "Legacy" mode (checkbox) once the key has been created.

Grab the latest single file release `high_score.rb` from the [Releases](https://github.com/marcheiligers/dr-high_score/releases) page and save it in your DragonRuby game folder (I'm assuming in a `lib` directory in the sample below).

Finally, you'll have to "encrypt" your API key. You can use the game console:

```
$gtk.ffi_misc.setclipboard(HighScore::BadCrypto.encrypt('YOUR_KEY_HERE'))
```

Or you can use the [sample app on Itch](https://fascinationworks.itch.io/dr-high-score?secret=h9NIxJGh6Isp10sy4s75xCAM).


```ruby
require 'lib/high_score.rb'

PURPLE_TOKEN_KEY = 'palhessam?!d?$ktom$tl$!m?c?heeld!ppsnnoo'

def tick(args)
  # Create a Purple Token instance
  #   Note that the token is "encrypted". Really any player of your game can easily discover
  #   this key in the DragonRuby console, the browser console in the case of a web build, or
  #   in memory. This just ensures that your key isn't in plain text in your repo.
  #
  #   You can save `#scores` locally and pass that hash in as a second parameter so you have
  #   local scores as soon as the game starts.
  #     `args.state.purple_token ||= HighScore::PurpleToken.new(PURPLE_TOKEN_KEY, scores)`
  args.state.purple_token ||= HighScore::PurpleToken.new(PURPLE_TOKEN_KEY)

  # Fetch scores
  #   This happens automatically on instantiation, after saving a score, and periodically,
  #   so you shouldn't ever have to call this method. Also only one request to fetch scores
  #   is allowed at a time. Purple Token saves the top 20 scores only.
  #     `args.state.purple_token.fetch_scores`

  # Save a score
  #   For this sample, we only do this once on tick zero, otherwise it will send a request to
  #   Purple Token every tick. This score will probably not be saved because it's too low,
  #   but feel free to edit this file with your name and a higher score to see how it works.
  #
  #   This automatically updates the local cache of scores so the score is immediately
  #   visible in the high scores table. If the call is successful, it will attempt to initiate
  #   a `#fetch_scores` immediately afterwards to get the latest scores (see above).
  args.state.purple_token.save_score('Marc', 1) if args.tick_count == 0

  # Tick
  #   The API calls happen asynchronously, and so the Purple Token instance need to be given
  #   time to check the state of the request. This is cheap when the request is in flight, and
  #   only slightly more expensive on a tick when the reponse is completed and needs to be parsed.
  args.state.purple_token.tick

  # Is it even a high_score?
  #   Since the Purple Token API only saves the top 20 scores, it might not even make sense to try
  #   to save this score. This method checks if the score would fall into the scores we are locally
  #   aware of. It's possilbe to pass a second paramter indicating the number of scores you're
  #   interested in, like in this example with only the top 10
  #     `args.state.purple_token.high_score?(1, 10)`
  if args.state.purple_token.high_score?(1)
    args.outputs.labels << { x: 20, y: 50, text: '1 is a high score!' }
  else
    args.outputs.labels << { x: 20, y: 50, text: '1 is NOT a high score!' }
  end

  # Format scores and display
  #    #scores is an array of hashes with name and score as keys. The instance will maintain a list
  #    of 20 high scores even Purple Token does not yet have 20 scores. The additional scores will
  #    have a name of '---' and a score of 0.
  args.outputs.labels << args.state.purple_token.scores.map_with_index do |score, i|
    {
      x: 20,
      y: 700 - i * 30,
      text: "#{(i + 1).to_s.rjust(2)}. #{score.name.to_s.ljust(10)} #{score.score.to_s.rjust(5, '0')}"
    }
  end
end
```

## Thanks

* [Zimnox](https://zimnox.com/) (@phaelax on Discord) for providing [Purple Token](https://purpletoken.com/), and working with me to figure out the various CORS incantations to make it work with DragonRuby web builds
* @virtualnomad on Discord for pointing me at Purple Token in the first place and connecting me with @phaelax
* @leviongit (@leviondiscord on Discord) for [dragonjson](https://github.com/leviongit/dragonjson) used in the samples
* @KonnorRogers for the [gist](https://gist.github.com/KonnorRogers/9ca86e4d055d81ee702fb79ceda5df20) to make links work in Safari again
* @Xed on Discord for trying things and making me realize I need to add the notes about the "Legacy" keys to this file
