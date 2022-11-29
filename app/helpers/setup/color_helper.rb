module Setup::ColorHelper

  def color( entity )
    c = Color.find_by_name(entity).value
    logger.info "color for #{entity} is #{c}"
    c
  rescue 
    Color.create :name => entity, :value => 'White'
  end

  def sample( color )
    p #{color}
    color
  end

end
