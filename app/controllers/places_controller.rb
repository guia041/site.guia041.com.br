class PlacesController < ApplicationController
  before_action :set_place, only: [:show, :edit, :update, :destroy]

  # GET /places
  # GET /places.json
  def index

    geo = request.location

    @latitude  = geo.latitude
    @longitude = geo.longitude

    @places = Place.take(10)

    @hash = Gmaps4rails.build_markers(@places) do |place, marker|
      marker.lat place.lat
      marker.lng place.lon
    end

  end

# Posts that match 'pizza' returning counts for each :author_id
=begin
search = Place.search do
  fulltext( 'pizza' , {:fields => :title} )
  facet :title, :neighborhood
end
search.facet(:neighborhood).rows.each do |facet|
  puts "neighborhood #{facet.value} has #{facet.count} pizza posts!"
end

search.facet(:title).rows.each do |facet|
  puts "neighborhood #{facet.value} has #{facet.count} pizza posts!"
end
=end

  def search

    search = Place.search do
      fulltext( params[:q] , {:fields => [ :title, :description] } ) if params[:q].present?
      fulltext( params[:w] , {:fields => :neighborhood} ) if params[:w].present?
      paginate( :page =>  params[:page], :per_page => 25 )
      order_by(:score, :desc)
      facet :neighborhood
    end

    @bairros = search.facet(:neighborhood).rows
    @places = search

    @hash = Gmaps4rails.build_markers(search.results) do |place, marker|
      marker.lat place.lat if place.lat.present?
      marker.lng place.lon if place.lon.present?
    end

    render 'index'
  end


  def nearby

    search = Place.search do
       keywords( params[:q] ) if params[:q].present?
       with(:location).near([ params[:lat], params[:lon] ], 5 ) if (params[:lat].present?) && (params[:lon].present?)
       order_by(:score, :asc)
       #with(:geohash).near( -25.480876, -49.304425, :precision => 1)
    end

    @places = search.results # Adiciona um lugar para traçar o trajeto # Adiciona um lugar para traçar o trajeto

    @distances = search

    @hash = Gmaps4rails.build_markers(@places) do |place, marker|
      marker.lat place.lat if place.lat.present?
      marker.lng place.lon if place.lon.present?
    end

    render 'index'
  end

  # GET /places/1
  # GET /places/1.json
  def show
  end

  # GET /places/new
  def new
    @place = Place.new
  end

  # GET /places/1/edit
  def edit
  end

  # POST /places
  # POST /places.json
  def create
    @place = Place.new(place_params)

    respond_to do |format|
      if @place.save
        format.html { redirect_to @place, notice: 'Place was successfully created.' }
        format.json { render action: 'show', status: :created, location: @place }
      else
        format.html { render action: 'new' }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /places/1
  # PATCH/PUT /places/1.json
  def update
    respond_to do |format|
      if @place.update(place_params)
        format.html { redirect_to @place, notice: 'Place was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    @place.destroy
    respond_to do |format|
      format.html { redirect_to places_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_place
      @place = Place.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def place_params
      params.require(:place).permit(:title, :description, :lat, :lon, :address)
    end
end
