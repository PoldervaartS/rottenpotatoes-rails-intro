class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    
    # get list of all ratings, then list of all checked ratings
    @all_ratings = Movie.order(:rating).select(:rating).map(&:rating).uniq
    @selected_ratings = checkSelected
    @selected_ratings.each do |rating|
      params[rating] = true
    end
    
    # if no parameters for sorting use the session
    if (not params[:sort]) and session[:sort]
      params[:sort] = session[:sort]
    end
    
    
    if params[:sort]
        @movies = Movie.order(params[:sort]).where(:rating => @selected_ratings)
        session[:sort] = params[:sort]
      else
        @movies = Movie.where(:rating => @selected_ratings)
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
  
  def checkSelected
    #if no ratings, check if the session has old ratings, otherwise return all
    if params[:ratings]
      session[:ratings] = params[:ratings]
      return params[:ratings].keys
    else
      if session[:ratings]
        return session[:ratings].keys
      end
      return @all_ratings
    end
  end
  

end
