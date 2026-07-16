## [Unreleased]

## [0.3.1] - 2026-07-16

- Remove `data/ngram_probs.json` from the gem
- Eager load model in Rails

## [0.3.0] - 2026-07-16

- Use binary model format: Reduce memory by searching a packed binary model instead of parsing JSON into hashes. Slower throughput though.

## [0.2.0] - 2026-07-15

- Train bundled model from German Wiktionary nouns (~95% head-detection accuracy on GermaNet compounds)
- Add Ruby training pipeline (`bin/train.rb`) and third-party notices

## [0.1.0] - 2026-07-14

- Initial release
