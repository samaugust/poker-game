class GamesController < ApplicationController
  before_action :find_game, only: [:show, :edit, :update, :destroy]

  def index
    if Game.all.count >= 1
      @games = Game.all.order("created_at DESC")
      @decks = @games.map { |x| x.deck }
    end
  end

  def create
    @game = Game.new({deck: ("2".."14").flat_map { |rank| ("a".."d").map { |suit| (rank + suit) } }.shuffle}, params[:id])
    @game.save
    Game.first.destroy if Game.all.count > 1
    redirect_to root_path
  end

  def give_me_chips
    current_player.chips.nil? ? current_player.update_attribute(:chips, 500) : current_player.update_attribute(:chips, current_player.chips + 500)
    redirect_to root_url
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
    def game_params
      params.require(:game).permit(:deck, :pot, :community_cards)
    end

    def find_game
      @game = Game.find(params[:id])
    end
end
