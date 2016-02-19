class GamesController < ApplicationController
	before_action :find_game, only: [:show, :edit, :update, :destroy]

	def index
		if Game.all.count >= 1
			@games = Game.all
			@decks = Game.select('deck').all.order("created_at DESC")
		end
	end

	def new
		@game = Game.new 
		@game.update_attribute(:deck, (2..14).flat_map { |rank| ("a".."d").map { |suit| (rank.to_s + suit) } }.shuffle)
		redirect_to root_path
	end

	def create
   	@game = Game.new(params[:id])
   	@game.update_attribute(:deck, (2..14).flat_map { |rank| ("a".."d").map { |suit| (rank.to_s + suit) } }.shuffle)
    if @game.save
			redirect_to @game
		end
	end

	def give_me_chips
		@user = current_user
		@user.chips.nil? ? @user.update_attribute(:chips, 500) : @user.update_attribute(:chips, @user.chips + 500)
		redirect_to root_url
	end

	def output
		
	end

	def edit
	end

	def update
	end

	def show
		@deck = @game.deck
	end

	def destroy
		@game.destroy
		redirect_to root_path
	end

	private
		def deck_params
			params.require(:game).permit(:deck, :pot, :community_cards)
		end

		def find_game
			@game = Game.find(params[:id])
		end
end
