require_relative './lib/sudoku'
require 'sinatra'
require 'sinatra/flash'
require_relative 'lib/sudoku_helpers'

class SudokuWeb < Sinatra::Application

  configure do
    use Rack::Session::Cookie, :key => 'rack.session',
                                :path => '/',
                                :expire_after => 2592000, # In seconds
                                :secret => 'I am the secret code to encrypt the cookie'  
  end

  helpers do
    def generate_new_game(difficulty=Sudoku::EASY)
      if session[:current_sudoku]
        sudoku_puzzle = Sudoku.new(session[:current_sudoku])
      else
        sudoku_puzzle = Sudoku.generate(difficulty)
        session[:sudoku_string] = sudoku_puzzle.to_s
        session[:current_sudoku] = sudoku_puzzle.to_s
      end
    end
  end

  post '/' do  
    puzzle_string = convert_values_array_to_string(params[:cells])    
    flash[:info] = problem_solved?(puzzle_string, session[:sudoku_string]) ? "Perfect. Well done. Click new game to play again." : ["Keep trying.", "You're nearly there", "Almost, but not quite.", "Nah. You're just guessing now."].sample
    session[:current_sudoku] = puzzle_string
    redirect to('/')
  end

  get '/new' do
    session.clear
    redirect to('/')
  end

  get '/hard' do
    session.clear
    generate_new_game(Sudoku::HARD)
    cells_criteria
    erb :home
  end  

  get '/solution' do
    cells_array = get_solved_sudoku_cells(session[:sudoku_string])
    session[:current_sudoku] = convert_values_array_to_string(cells_array)
    redirect to('/')  
  end

  get '/' do
    generate_new_game
    cells_criteria
    erb :home
  end

end