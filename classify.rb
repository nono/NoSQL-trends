require "classifier"


# Classify is a small wrapper around Classifier::Bayes,
# so we can have several results for a provided text.
#
# It works by creating a classifier per keyword, with
# two possibilities: the keyword and its negation.
# When a text is provided, it iterates on the classifiers,
# and return only the choosed keywords, not the negations.
#
class Classify

  # Create a Classify with several keywords.
  #
  # Example:
  #   Classify.new %w(foo bar baz)
  #
  def initialize(keywords)
    @classifiers = {}
    keywords.each do |kw|
      @classifiers[kw] = Classifier::Bayes.new(kw, negate(kw))
    end
  end

  # Train it with some corpus in the given directory.
  # It'll load txt files in this directory that are
  # named according to the keywords, plus a garbage one.
  #
  # Example:
  #   Classify.new(%w(foo bar baz)).train
  #   # Load data/foo.txt, data/bar.txt, data/baz.txt
  #   # and data/garbage.txt
  #
  def train(directory="data")
    keys.each do |corpus|
      File.read("data/#{corpus}.txt").each_line do |line|
        @classifiers.each { |k,v| v.train((k == corpus ? k : negate(k)), line) }
      end
    end
  end

  # Returns the keywords for the provided text
  #
  # Example:
  #   c = Classify.new %w(foo bar baz)
  #   c.train
  #   c.results "Lorem ipsum ackbar"  # => ['foo', 'bar']
  #
  def results(text)
    @classifiers.keys.reject do |k|
      @classifiers[k].classify(text)[0...3] == "Not"
    end
  end

protected

  def negate(keyword)
    "Not #{keyword}"
  end

  def keys
    @keys ||= @classifiers.keys + ['garbage']
  end
end
