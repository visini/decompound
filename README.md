# decompound

> [!IMPORTANT]
> This gem is in an early stage of development. The API may change in the future.

A Ruby gem for splitting German compound words into their constituent parts, based on [CharSplit](https://github.com/dtuggener/charsplit).

```rb
require "decompound"

word = "Bodenbelag"
parts = Decompound.split(word)
# => ["boden", "belag"]
```

The bundled model is trained on 127,106 German Wiktionary noun lemmas and their inflected forms, and achieves ~95% head-detection accuracy on GermaNet-derived compounds, matching CharSplit.

## Installation

```bash
bundle add decompound
```

Or without bundler:

```bash
gem install decompound
```

## Roadmap

- Provide different models (small, medium, large) (?)
- Recursive decompounding
  - `Fussbodenbelag` → `Fuss` + `Bodenbelag` → `Fuss` + `Boden` + `Belag`

## Development

After checking out the repo, run `bin/setup` to install dependencies, `rake test` to run the tests, and `bin/console` for an interactive prompt.

### Release process

For each release:

1. Update `lib/decompound/version.rb`
2. Update `CHANGELOG.md`
3. Run tests and RBS validation
4. Commit with message `Prepare x.x.x release` and push
5. Run `bundle exec rake release`

### Training CharSplit probabilities

The training pipeline reads the German noun CSV entirely in Ruby and defaults to one observation per unique word form across all case inflections:

```sh
ruby bin/train.rb \
  --input data/vendor/german-nouns/nouns.csv \
  --forms all \
  --output data/ngram_probs.json
```

`--forms lemmas` uses only lemmas, while `--forms nominative` uses lemmas plus nominative inflections. Inflected forms provide the linking-element evidence (e.g. the *-s* in *Einkaufsliste*), so the bundled model uses `all`. The generated JSON contains CharSplit-compatible `prefix`, `infix`, and `suffix` probabilities.

### Packing the runtime model

The gem ships the probabilities as a binary table (`data/model.bin`), searched in place:

```sh
ruby bin/pack.rb data/ngram_probs.json data/model.bin
```

## Provenance and credits

The noun corpus used to train the bundled probabilities is derived from [German Wiktionary](https://de.wiktionary.org/). It is extracted by [Wiktextract](https://github.com/tatuylonen/wiktextract) and distributed by [Kaikki.org](https://kaikki.org/). Wiktionary textual content is licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) and, where applicable, the GNU Free Documentation License. See [`data/vendor/german-nouns/SOURCE.md`](data/vendor/german-nouns/SOURCE.md) for the pinned source, extraction process, and reproducibility details.

The splitting and training algorithms are Ruby ports of [CharSplit](https://github.com/dtuggener/CharSplit), created by Don Tuggener and described in [Incremental Coreference Resolution for German](https://doi.org/10.5167/uzh-124915) (University of Zurich, 2016). CharSplit is MIT licensed; its copyright and license are reproduced in [`LICENSE-CharSplit.txt`](LICENSE-CharSplit.txt).

See [`NOTICE.md`](NOTICE.md) for consolidated third-party notices.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/visini/decompound>.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
