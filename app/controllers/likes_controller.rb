class LikesController < ApplicationController
  before_action :set_like, only: %i[show edit update destroy verificar_matcher]
  before_action :authenticate_matcher!, only: %i[new show create index destroy]
  before_action only: %i[edit destroy] do
    verificar_matcher(@like)
  end

  # GET /likes
  # GET /likes.json
  def index; end

  # GET /likes/1
  # GET /likes/1.json
  def show; end

  # GET /likes/new
  def new
    @like = Like.new
  end

  # GET /likes/1/edit
  def edit; end

  # POST /likes
  # POST /likes.json
  def create
    matcher2 = Matcher.find(params[:matcher])
    @like = Like.new(matcher1: current_matcher, matcher2: matcher2)

    respond_to do |format|
      if @like.save
        # find match
        find1 = Like.where('matcher1_id = (?) AND matcher2_id = (?)', current_matcher.id, matcher2.id).take
        find2 = Like.where('matcher1_id = (?) AND matcher2_id = (?)', matcher2.id, current_matcher.id).take

        if find1 && find2
          puts '**** MATCH! ****'
          @match = Match.new(matcher1: current_matcher, matcher2: matcher2)
          if @match.save
            redirect_to matches_path(@match.id)
            return
          else
            puts 'Uff'
          end
          # redirect_to url_for(:controller => :meetings, :action => :new)
        else
          prev = Rails.application.routes.recognize_path(request.referrer)
          redirect_to controller: prev[:controller], action: prev[:action]
          return
        end
        format.html { redirect_to @like, notice: 'Like creado exitosamente.' }
        format.json { render :show, status: :created, location: @like }
      else
        format.html { render :new }
        format.json { render json: @like.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /likes/1
  # PATCH/PUT /likes/1.json
  def update
    respond_to do |format|
      if @like.update(like_params)
        format.html { redirect_to @like, notice: 'Like editado exitosamente.' }
        format.json { render :show, status: :ok, location: @like }
      else
        format.html { render :edit }
        format.json { render json: @like.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /likes/1
  # DELETE /likes/1.json
  def destroy
    @like.destroy
    respond_to do |format|
      format.html { redirect_to likes_url, notice: 'Like eliminado exitosamente.' }
      format.json { head :no_content }
    end
  end

  def verificar_matcher(like)
    unless current_matcher == like.matcher1
      redirect_to request.referrer, notice: 'No tienes permisos para realizar esta acción'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_like
    @like = Like.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def like_params
    params.require(:matcher)
  end
end
