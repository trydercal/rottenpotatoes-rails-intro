class MoviesController < ApplicationController
  
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    if params[:ratings].nil? and params[:sort].nil?
      if not session[:ratings].nil? or not session[:sort].nil?
        params[:ratings] = session[:ratings]
        params[:sort] = session[:sort]
        session.clear
        redirect_to movies_path(:sort => params[:sort], 
          :ratings => params[:ratings])
      end
    end
    if params[:ratings].nil?
      params[:ratings] = {'G': '1', 'PG': '1', 'PG-13': '1', 'R': '2'}
    end
    @sort_title = false
    @sort_date = false
    @ratings_to_pass = params[:ratings]
    @ratings_to_show = params[:ratings].keys
    @movies = Movie.with_ratings(params[:ratings].keys)
    if @movies.nil?
      @movies=[]
    end
    session.clear
    session[:ratings] = params[:ratings]
    session[:sort] = params[:sort]
    if params[:sort].nil?
      return
    end
    if params[:sort].empty?
      return
    end
    unless params[:sort].is_a?Hash
      return
    end
    
    type_sort = params[:sort].keys[0]
    @sort_type = type_sort
    if type_sort.eql? ("title")
      @movies = @movies.order(:title)
      @sort_title = true
    end
    if type_sort.eql? ("date")
      @movies = @movies.order(:release_date)
      @sort_date = true
    end
  end
  

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
