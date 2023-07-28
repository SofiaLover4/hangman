def random_word
  words = File.readlines('alot_of_words.txt')
  possible_words = []
  words.each do |word|
    word = word.chomp
    possible_words.push(word) if word.length >= 5 && word.length <= 12 # Criteria
  end
  possible_words.sample # This will return one word from the list of possible words
end

def ask_guess
  guess = gets
  guess = guess.chomp

  while guess.length != 1
    print 'Sorry that guess wasn\' valid, try again: '
    guess = gets
    guess = guess.chomp
  end

  guess
end

# Hangman game
class Hangman
  attr_accessor :word, :screen, :turns, :guesses, :guessed_letters

  def create_screen
    @screen = ''
    word.length.times do
      @screen += ' _ '
    end
  end

  def show_information
    puts screen
    puts "Your guessed letters are: #{guessed_letters}" if guessed_letters != ''
    puts "You have #{6 - turns} incorrect guesses left"
  end

  def initialize
    # The default stats
    @word = random_word
    @turns = 0
    @guessed_letters = ''
    create_screen
    show_information
  end

  def check_word
    old_screen = @screen.split(' ') # We are going to use to keep old letters
    @screen = '' # Here were are resetting the screen

    print 'type in your word here:' # Place holder

    guess = ask_guess

    i = 0
    while i < word.length
      @screen += word[i] == guess ? " #{guess} " : " #{old_screen[i]} "
      i += 1
    end

    show_information
  end
end

game = Hangman.new
game.check_word
game.check_word
