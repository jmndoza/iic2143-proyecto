class LocalsController < ApplicationController
  before_action :set_local, only: %i[show edit update destroy enviar_aceptar_local verificar_propietario_local comprobar_tuvo_cita]
  before_action :authenticate_admin_propietario_local!, only: %i[edit update destroy]
  before_action :verificar_propietario_local, only: %i[edit update destroy]
  before_action :authenticate_propietario_local!, only: %i[new create index_locals_de_propietario_local]
  before_action :set_comunas, only: %i[new create edit]
  before_action :authenticate_admin!, only: %i[index_no_aceptados enviar_aceptar_local]
  before_action :comprobar_tuvo_cita, only: %i[show]
  before_action :authenticate_todos!, only: %i[show index]

  # GET /locals
  # GET /locals.json
  def index
    @locals = Local.buscar(params[:busqueda])
  end

  def index_no_aceptados
    @locals_no_aceptados = Local.where(aceptado: false)
  end

  def index_locals_de_propietario_local
    @locals_de_propietario_local = Local.where(propietario_local: current_propietario_local)
  end

  # GET /locals/1
  # GET /locals/1.json
  def show
    @comentario = Comentario.new
    suma = 0
    cont = 0
    @local.comentarios.each do |comentario|
      if comentario.valoracion
        suma += comentario.valoracion
        cont += 1
      end
    end
    @promedio = if cont != 0
                  suma_f = suma.to_f
                  (suma_f / cont.to_f).round 1
                else
                  0
                end
  end

  # GET /locals/new
  def new
    @local = Local.new
  end

  # GET /locals/1/edit
  def edit
    @locals = Local.all
  end

  # POST /locals
  # POST /locals.json
  def create
    @local = current_propietario_local.locals.new(local_params)
    respond_to do |format|
      if @local.save
        format.html { redirect_to locals_mis_locales_path, notice: 'Tu local fue creado con éxito.' }
        format.json { render :show, status: :created, location: @local }
      else
        format.html { render :new }
        format.json { render json: @local.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /locals/1
  # PATCH/PUT /locals/1.json
  def update
    respond_to do |format|
      if @local.update(local_params)
        format.html { redirect_to @local, notice: 'Tu local fue editado.' }
        format.json { render :show, status: :ok, location: @local }
      else
        format.html { render :edit }
        format.json { render json: @local.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locals/1
  # DELETE /locals/1.json
  def destroy
    @local.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, notice: 'Se ha eliminado tu Local.' }
      format.json { head :no_content }
    end
  end

  def enviar_aceptar_local
    # indica al model aceptar el local
    @local.aceptar_local
    respond_to do |format|
      format.html { redirect_to locals_solicitudes_path, notice: 'Se ha aceptado el local.' }
      format.json { head :no_content }
    end
  end

  def verificar_propietario_local
    unless current_propietario_local == @local.propietario_local || admin_signed_in?
      redirect_to request.referrer, notice: 'No tienes permisos para realizar esta acción'
    end
  end

  private

  def comprobar_tuvo_cita
    @tuvo_cita = false
    if current_matcher
      current_matcher.matcher1_matches.each do |match_i|
        if @local.meetings.include? match_i.meeting
          @tuvo_cita = true
        end
      end
      current_matcher.matcher2_matches.each do |match_i|
        if @local.meetings.include? match_i.meeting
          @tuvo_cita = true
        end
      end
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_local
    @local = Local.find(params[:id])
  end

  def set_comunas
    @comunas = Comuna.all
  end

  # Only allow a list of trusted parameters through.
  def local_params
    params.require(:local).permit(:nombre, :comuna_id, :direccion, :descripcion, :imagen, :busqueda)
  end
end
