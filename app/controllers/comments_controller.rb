class CommentsController < ApplicationController
  before_action :authenticate_user!, only: %i[create edit update destroy]
  load_and_authorize_resource
  
  def create
    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id
    @comment.detail_id = params[:detail_id]
    
    @comment.save
    respond_to :js
  end
  
  def index
    respond_to do |format|
      if !params[:buscador].nil?
        if params[:buscador].blank?
          @comments = Comment.all.order('id DESC')
        elsif params[:buscador].length >= 1
          # @comments = Detail.where('product.title LIKE ?', "%#{params[:buscador]}%")
          @comments = Comment.where('description LIKE ?', "%#{params[:buscador]}%").order('id DESC')
        end
        format.js
      else
        @comments = Comment.all.order('id DESC')
        format.html
      end
    end
  end
  
  def new
    @detail = Detail.find(params[:detail_id])
    @comment = Comment.new
    respond_to :js
  end

  def edit
    @comment = Comment.find(params[:id])
    @detail = Detail.find(params[:detail_id])
    
    respond_to { |format| format.js }
  end

  def update
    @detail = Detail.find(params[:detail_id])
    @comment = Comment.find(params[:id])
  
    respond_to do |format|
      if @comment.update(comment_params)
        format.js
      else
        flash[:danger] = 'Error. Intente nuevamente'
        format.html { detail_path(params[:detail_id]) }
      end
    end
  end
  
  def destroy
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.destroy
        format.js
      else
        flash[:danger] = 'Error. Intente nuevamente'
        format.html { detail_path(params[:detail_id]) }
      end 
    end
  end

  def banned
    byebug
    @comment = Comment.find(params[:comment_id])
    @comment.banned = true
    respond_to do |format|
      if @comment.update(@comment.attributes)
        format.js
      else
        flash[:danger] = 'Error. Intente bannnear más tarde, nuevamente. '
        format.html { comments_path }
      end
    end
  end

  private
  def comment_params
    params.require(:comment).permit(:description, :banned, :user_id)
  end

end
