class Local < ApplicationRecord
  has_one_attached :imagen
  belongs_to :comuna
  belongs_to :propietario_local
  has_many :comentarios
  has_many :meetings
  before_destroy :eliminar_relaciones
  after_create :set_aceptado

  def set_aceptado
    update_attributes(aceptado: false)
  end

  def eliminar_relaciones
    comentarios.destroy_all
    # self.meetings.destroy_all
  end

  def aceptar_local
    update_attributes(aceptado: true)
  end

  def self.buscar(busqueda)
    if busqueda
      Local.where('aceptado = ? AND nombre ILIKE ?', true, "%#{busqueda}%")
    else
      Local.where(aceptado: true)
    end
  end
end
