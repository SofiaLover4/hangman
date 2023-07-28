require 'yaml'

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
  guess = guess.chomp.downcase

  while guess != 'save' && guess.length != 1
    print 'Sorry that guess wasn\'t valid, try again: '
    guess = gets
    guess = guess.chomp
  end

  guess
end

# Hangman game
class Hangman
  attr_accessor :word, :screen, :turns, :guesses, :guessed_letters, :status
  @@saved_games = []

  def create_screen
    @screen = ''
    word.length.times do
      @screen += ' _ '
    end
  end

  def show_information
    puts screen
    puts "Your guessed letters are: #{guessed_letters}" if guessed_letters != ''
    puts "You have #{7 - turns} incorrect guesses left"
  end

  def initialize
    # The default stats
    @word = random_word
    @turns = 0
    @guessed_letters = ''
    @status = 'playing'
    create_screen
    show_information
  end

  def check_status
    if @screen.split(' ').join('') == @word
      puts "Congratulations, the word was #{@word}! You win!"
      @status = 'win'
    elsif @turns == 7
      puts "I'm sorry but you have run out of turns, the word was #{@word}"
      @status = 'loss'
    end
  end

  def check_word(guess)
    old_screen = @screen.split(' ') # We are going to use to keep old letters
    @screen = '' # Here were are resetting the screen
    # Only add to the turn if the letter is not in the word or guessed already
    @turns += 1 unless word.include?(guess) || @guessed_letters.include?(guess) 
    @guessed_letters += " #{guess} " unless @guessed_letters.include?(guess) # Stop repeated letters from showing up

    i = 0
    while i < word.length
      @screen += word[i] == guess ? " #{guess} " : " #{old_screen[i]} "
      i += 1
    end

    show_information
  end

  def decide_action
    print 'Type in your letter here:' # Place holder
    guess = ask_guess
    puts ' '
    if guess == 'save'
      puts 'The game will be saved'
      @status = 'save'
    else
      check_word(guess)
    end
  end

  def save_game

    data = YAML.dump({ # The data that will go into the file
      :word => @word,
      :turns => @turns,
      :guessed_letters => @guessed_letters
    })

    print 'What would you like to name this save? '
    name = gets
    @@saved_games.push(name.chomp)
    File.open("#{name.chomp}.txt", 'w') do |file|
      file.puts data
    end
  end

  # Get the name of the file from the user
  def find_game
    loop do
      puts 'Sorry, that\'s not a valid answer, try again'
      puts 'Saved Games:'
      puts @@saved_games
      print 'What save would you like to load? '
      name = gets
      puts "\n"
      return name if @@saved_games.include?(name.chomp)
    end
  end

  def load_game
    name = find_game
    p name
    game_data = YAML.load File.read("#{name.chomp}.txt")
    @word = game_data[:word]
    @turns = game_data[:turns]
    @guessed_letters = game_data[:guessed_letters]
    puts screen
  end
end

def play_game
  game = Hangman.new
  while game.status == 'playing'
    game.decide_action
    game.check_status
  end
end

play_game


