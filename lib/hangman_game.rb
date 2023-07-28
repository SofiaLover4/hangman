require 'yaml'

def introduction
  puts 'Welcome to Hangman'
  puts 'You will have to guess a word that is 5 to 12 characters long'
  puts 'You have seven incorrect guesses but aftet that you lose'
  puts 'Each game you play will be saved'
  puts 'You can also save in the middle of a game by typing \'save\' instead of a guess'
  puts 'Good luck!'
  puts ''
end

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
  attr_accessor :word, :screen, :turns, :guesses, :guessed_letters, :status, :saved_games

  def self.saved_games
    @saved_games
  end

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
    @saved_games = []
    #create_screen 
    #show_information

    Dir.foreach('saves') do |entry|
      next if entry == '.' || entry == '..'

      @saved_games.push(entry[0..(entry.length - 5)])
    end
  end

  def check_win
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
  end

  def decide_action
    print 'Type in your letter here:' # Place holder
    guess = ask_guess
    puts ' '
    if guess == 'save'
      puts 'The game will be saved'
      @status = 'saving'
      save_game
    else
      check_word(guess)
    end
  end

  def save_game
    puts @status
    data = YAML.dump({ # The data that will go into the file
      :word => @word,
      :turns => @turns,
      :guessed_letters => @guessed_letters,
      :screen => @screen,
      :status => @status == 'saving' ? 'playing' : 'done' # If a game is finished it will show
    })

    print 'What would you like to name this save? '
    name = gets
    file_path = File.join('saves', "#{name.chomp}.txt")
    File.open(file_path, 'w') { |file| file.puts data }
  end

  # Get the name of the file from the user
  def find_game
    loop do # This loop will continue until a valid name is found
      puts 'Saved Games:'
      puts @saved_games
      print 'What save would you like to load? '
      name = gets
      puts "\n"
      return name if @saved_games.include?(name.chomp) || name.chomp == 'n'
    end
  end

  def load_game
    name = find_game
    return if name.chomp == 'n'

    game_data = YAML.load File.read("saves/#{name.chomp}.txt")
    @word = game_data[:word]
    @turns = game_data[:turns]
    @guessed_letters = game_data[:guessed_letters]
    @screen = game_data[:screen]
    @status = game_data[:status]
    # Only show the status if the same is already done else the loop will show the status
    show_information if @status == 'done' 
  end
end

def play_game
  game = Hangman.new
  game.load_game unless game.saved_games.empty? # only prompt to load a game when there are saves
  while game.status == 'playing'
    game.show_information
    game.decide_action
    game.check_win
  end
  # The game status will be saving if it was saved in the middle of the game
  game.save_game unless game.status == 'done' || game.status == 'saving'

  # Prompt to end the game
  answer = ''
  until answer == 'y' || answer == 'n'
    print 'Would you like to continue? '
    answer = gets
    answer = answer.chomp
  end

  return if answer == 'n'

  play_game
end

introduction
play_game


