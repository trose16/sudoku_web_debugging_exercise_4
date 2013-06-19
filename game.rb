require_relative './lib/sudoku'
require 'sinatra'
require 'sinatra/flash'
require_relative './lib/helper_methods'

configure do
  use Rack::Session::Cookie, :key => 'rack.session',
                              :path => '/',
                              :expire_after => 2592000, # In seconds
                              :secret => 'I am the secret code to encrypt the cookie'  
end

class SudokuWeb < Sinatra::Application

include HelperMethods

  post '/' do  
    puzzle_string = convert_values_array_to_string(params[:cells])
    flash[:info] = problem_solved?(puzzle_string) ? "Perfect. Well done. Click new game to play again." : ["Keep trying.", "You're nearly there", "Almost, but not quite.", "Nah. You're just guessing now."].sample
    session[:current_sudoku] = puzzle_string
    redirect to('/')
  end

  get '/' do
    set_session_cookies
    @solved_cells = get_solved_sudoku_cells(session[:sudoku_string])
    @cells = Sudoku.new(session[:current_sudoku]).cells
    erb :home
  end

  get '/new' do
    session.clear
    redirect to('/')
  end

  get '/solution' do
    session[:current_sudoku] = get_solved_sudoku_cells(session[:sudoku_string])
    redirect to('/')  
  end


  def set_session_cookies
    if session[:current_sudoku]
      sudoku_puzzle = Sudoku.new(session[:current_sudoku])
    else
      sudoku_puzzle = Sudoku.generate
      session[:sudoku_string] = sudoku_puzzle.to_s
      session[:current_sudoku] = sudoku_puzzle.to_s
    end
  end



end