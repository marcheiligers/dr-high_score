require 'lib/high_score.rb'

PURPLE_TOKEN_KEY = 'enpmlnnlpl$snkplpcnadohpdt?dnnht!scdt!k!'
PURPLE_TOKEN_SECRET = 'RopUH1PPpz[}]#9s+N#'

def tick(args)
  # Create a Purple Token instance
  #   Note that the token and secret are "encrypted". Really any player of your game can easily discover
  #   this key in the DragonRuby console, or in memory. With v3 the requests are cryptogrraphically signed
  #   so your keys aren't just showing up in the browser console for web builds anymore, but this is still
  #   just obfuscation. The "encryption" just ensures that your key and secret aren't in plain text in your repo.
  #
  #   You can save `#scores` locally and pass that hash in as a second parameter so you have
  #   local scores as soon as the game starts.
  #     `args.state.purple_token ||= HighScore::PurpleToken.new(PURPLE_TOKEN_KEY, PURPLE_TOKEN_SECRET, scores)`
  args.state.purple_token ||= HighScore::PurpleTokenV3.new(PURPLE_TOKEN_KEY, PURPLE_TOKEN_SECRET)

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
