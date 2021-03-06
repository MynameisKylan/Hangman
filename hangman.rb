
class Game
  attr_reader :computer, :player, :wordlist, :guesses
  
  def initialize(computer, player, wordfile, guesses=6)
    @computer = computer
    @player = player
    @wordfile = wordfile
    @wordlist = nil
    @guesses = guesses
  end

  def load_words
    if !wordlist
      @wordlist = []
      file = File.open(@wordfile, 'r')
      while !file.eof?
        word = file.readline
        @wordlist.push(word.chomp.downcase) if word.chomp.length > 4 && word.chomp.length < 13
      end
    end
    puts 'Wordlist loaded.'
  end

  def start_game
    load_answer = prompt('load')
    if load_answer
      filename = prompt_load
      begin
        puts "Loading #{filename}..."
        sleep(1)
        load_game(filename)
        puts 'Loading Success!'
      rescue
        puts "#{filename} save file not found. Starting new game."
        load_words
        computer.select_word(wordlist)
      end
    else
      load_words
      computer.select_word(wordlist)
    end
    play
  end

  def play
    computer.update_display
    while guesses > 0 && !computer.win?
      guess = player.get_guess
      until !computer.guessed.include?(guess)
        puts 'You already guessed that!'
        computer.update_display
        guess = player.get_guess
      end
      eval = computer.evaluate_guess(guess)
      if eval 
        puts "Correct!"
      else
        puts "-------------------"
        puts "Sorry, no #{guess} in this word."
        puts "-------------------"
        @guesses -= 1
        puts "#{@guesses} guesses remaining."
        break if @guesses == 0
      end
      computer.update_display
      save_answer = prompt('save')
      save_game if save_answer
    end
    computer.update_display
    
    if guesses < 1
      puts "Out of guesses! The word was #{computer.word}"
    else
      puts "You win!"
    end
  end

  def prompt(action)
    answer = ''
    until answer == 'n' || answer == 'y'
      print "Would you like to #{action} a save file? y/n: "
      answer = gets.chomp.downcase
    end
    return true if answer == 'y'
    return false
  end

  def save_game
    Dir.mkdir('saves') unless Dir.exists?('saves')
    filename = 'saves/' + player.name + '_save.txt'
    save_file = File.open(filename, 'w') { |file| file.puts Marshal.dump(self) }
    puts 'Game successfully saved.'
  end

  def prompt_load
    name = player.name
    filename = 'saves/' + name + '_save.txt'
  end

  def load_game(save_file)
    save = File.open(save_file)
    game = Marshal.load(save)
    @computer = game.computer
    @player = game.player
    @guesses = game.guesses
  end

end

class Computer
  attr_reader :word, :guessed
  def initialize()
    @word = nil
    @guessed = []
  end

  def select_word(wordlist)
    @word = wordlist.sample
  end

  #evaluate_guess(guess)
  def evaluate_guess(guess)

    @guessed.push(guess)
    return true if @word.split('').include?(guess)
    false
  end

  def update_display
    puts display_word
    puts display_guessed
  end
  
  #display word
  def display_word
    @word.split('').map { |char| guessed.include?(char) ? char : '_' }.join(' ')
  end

  #display available letters
  def display_guessed
    'Guessed: ' + @guessed.join
  end

  #win?
  def win?
    @word.split('').all? { |char| guessed.include?(char) }
  end

end

class Player
  attr_reader :name
  def initialize(name)
    @name = name
  end

  #get guess
  def get_guess
    puts '>>>Guess a letter: '
    guess = gets.chomp.downcase
    while guess.length > 1 || !('a'..'z').include?(guess)
      puts '>>> Invalid guess. Please enter a letter from a to z: '
      guess = gets.chomp.downcase
    end
    guess
  end

end

puts 'Enter player name: '
name = gets.chomp.downcase

player = Player.new(name)
computer = Computer.new
game = Game.new(computer, player, '5desk.txt')
game.start_game