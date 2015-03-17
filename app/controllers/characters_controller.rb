class CharactersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_user!

  after_action :verify_authorized, :except => :index
  after_action :verify_policy_scoped, :only => :index

  def index
    @characters = policy_scope(Character)
    session[:current_char_id] = nil
  end

  def new
    @character = @user.characters.new
    authorize @character
  end

  def show
    @character = Character.find_by id: params[:id]
    authorize @character
    session[:current_char_id] = params[:id]
  end

  def edit
    @character = Character.find_by id: params[:id]
    authorize @character
  end

  def create
    @character = @user.characters.new(character_params)
    authorize @character

    if @character.save
      redirect_to @character, notice: 'Character created successfully.'
    else
      render action: :new
    end
  end

  def update
    @character = Character.find_by id: params[:id]
    authorize @character

    if @character.update_attributes(character_params)
      redirect_to @character, notice: 'Character updated successfully.'
    else
      render action: :edit
    end
  end

  def destroy
    # Will actually be "retiring"
  end

  private

  def character_params
    params.require(:character).permit! #ahhhhhhhh
  end
end
