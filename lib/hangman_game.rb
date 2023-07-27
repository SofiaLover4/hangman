def random_word
  words = File.readlines('alot_of_words.txt')
  possible_words = []
  words.each do |word|
    word = word.chomp
    possible_words.push(word) if word.length >= 5 && word.length <= 12 # Criteria
  end
  possible_words.sample # This will return one word from the list of possible words
end

# Hangman game
class Hangman
  attr_reader :word

  def initialize
    @word = random_word
  end
end

game = Hangman.new
