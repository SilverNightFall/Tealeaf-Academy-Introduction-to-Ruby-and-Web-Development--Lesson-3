  require 'rubygems'
  require 'sinatra'

  set :sessions, true
  set :public, Proc.new { root }


  helpers do

    BLACKJACK_AMOUNT = 21
    DEALER_MIN = 17
    ACE_VALUE = 11
    FACE_CARD_VALUE = 10

    def new_deck
      ranks = %w{ace 2 3 4 5 6 7 8 9 10 jack queen king}
      suits = %w{spades hearts diamonds clubs}
      session[:deck] = ranks.product(suits).each do |rank, suit|
      end
      session[:deck].shuffle!
    end

    def initialize_session
      @last_player = session[:name]
      session.clear
      session[:name] =  @last_player
      new_deck
      session[:player_cards] = nil
      session[:dealer_cards] = nil
      session[:player_cards] = []
      session[:dealer_cards] = []
      session[:player_cards] << session[:deck].pop
      session[:player_cards] << session[:deck].pop
      session[:dealer_cards] << session[:deck].pop
      session[:dealer_cards] << session[:deck].pop
    end

    def show_cards(card)
      rank = card[0]
      suit = card[1]
      "<img class='cards' src='public/images/cards/#{suit}_#{rank}.jpg' />"
    end

    def player_card_value(blackjack_players)
      card_values = 0
      players_cards = blackjack_players.map { |cards| cards[0]}
      players_cards.each do |card|
        if card == "Ace"
          card_values += ACE_VALUE
        elsif card.to_i == 0
          card_values += FACE_CARD_VALUE
        else
          card_values += card.to_i
        end
      end
      players_cards.select { |cards| cards == "Ace" }.count.times do
        if card_values > BLACKJACK_AMOUNT
          card_values -= FACE_CARD_VALUE
        end
      end
      card_values
    end

    def dealer_winner?
      @dealer_winner = "<h1 class='hit'>#{session[:name]}, you lose! <br /> Dealer won!<br /></h1>"
      if player_card_value(session[:dealer_cards]) == BLACKJACK_AMOUNT
       @dealer_winner
     elsif player_card_value(session[:dealer_cards]) > player_card_value(session[:player_cards]) && player_card_value(session[:dealer_cards]) < BLACKJACK_AMOUNT && session[:hit_or_stay] == "Stay"
       @dealer_winner
     end
   end

   def player_winner?
    @player_winner =  "<h1 class='hit'> #{session[:name]}, you won!<br /> </h1>"
    if player_card_value(session[:player_cards]) == BLACKJACK_AMOUNT
      @player_winner
    elsif player_card_value(session[:player_cards]) > player_card_value(session[:dealer_cards]) && player_card_value(session[:player_cards]) <= BLACKJACK_AMOUNT && session[:hit_or_stay] == "Stay" || player_card_value(session[:player_cards]) < player_card_value(session[:dealer_cards]) && player_card_value(session[:dealer_cards]) > BLACKJACK_AMOUNT
      @player_winner
    elsif player_card_value(session[:dealer_cards]) > BLACKJACK_AMOUNT  && player_card_value(session[:player_cards]) <= BLACKJACK_AMOUNT
      @player_winner
    end
  end

  def tie?
    @tie = "<h1 class='hit'>Its a tie</h1>"
    if player_card_value(session[:player_cards]) == BLACKJACK_AMOUNT &&  player_card_value(session[:player_cards]) == player_card_value(session[:dealer_cards])
      @tie
    elsif player_card_value(session[:player_cards]) == player_card_value(session[:dealer_cards]) && session[:hit_or_stay] == "Stay" && player_card_value(session[:dealer_cards]) >= 17
      @tie
    end
  end

  def no_winner?
    @no_winner = "<h1 class='hit'>No Winner!</h1>"
    if player_card_value(session[:player_cards]) == BLACKJACK_AMOUNT &&  player_card_value(session[:player_cards]) == player_card_value(session[:dealer_cards])
      @no_winner
    end
  end

  def dealer_busted?
    @dealer_busted = "<h1 class='hit'>Dealer busted!<br /></h1>"
    if player_card_value(session[:dealer_cards]) > BLACKJACK_AMOUNT
      @dealer_busted
    end
  end

  def player_busted?
    @player_busted = "<h1 class='hit'> #{session[:name]}, you busted!<br /></h1>"
    if player_card_value(session[:player_cards]) > BLACKJACK_AMOUNT
      @player_busted
    end
  end
  end

  get '/' do
    erb :play_round
  end

  get '/play_round' do
    erb :play_round
  end

  post '/play_round' do
    session[:play_round] = params[:play_round]
    if session[:play_round]  == "no"
      redirect '/goodbye'
    else
     session.clear
     initialize_session
     redirect '/get_name'
   end
  end

  get '/get_name' do
    erb :get_name
  end

  post '/get_name' do
   session[:name] = params[:name]
   @last_player = session[:name]
   if session[:name] == nil
    session[:name] = @last_player
    session[:name] = params[:name]
  end
  redirect '/start_game'
  end

  get '/start_game' do
    erb :start_game
  end

  get '/hit_or_stay' do
    erb :hit_or_stay
  end

  post '/hit_or_stay' do
    session[:hit_or_stay] = params[:hit_or_stay]
    if session[:hit_or_stay] == "hit"
      session[:player_cards] << session[:deck].pop
      if player_card_value( session[:player_cards]) == 21 || player_card_value( session[:player_cards]) > 21
        redirect '/winner'
      else
        redirect '/hit'
      end
    else
      redirect '/dealer_turn'
    end
  end

  get '/dealer_turn' do
    erb :dealer_turn
  end

  post '/dealer_turn' do
    begin
      if player_card_value(session[:dealer_cards]) < 17
        @dealer_card  = session[:dealer_cards] << session[:deck].pop
        redirect '/dealer_turn'
      end
    end until player_card_value(session[:dealer_cards]) >= 17
    redirect '/winner'
  end

  get '/hit' do
    erb :hit
  end

  get '/winner' do
    erb :winner
  end

  post '/winner' do
   session[:play_round] = params[:play_round]
   if session[:play_round] == "no"
    redirect '/goodbye'
  else
    initialize_session
    redirect '/start_game'
  end
  end

  get '/goodbye' do
    erb :goodbye
  end