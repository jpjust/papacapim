class LikesController < ApplicationController

  before_action :authorize
  before_action :set_post, only: %i[ index create ]
  before_action :set_like, only: %i[ destroy ]

  # GET /posts/:post_id/likes
  def index
    render json: @post.likes, :except => [:user_id]
  end

  # POST /posts/:post_id/likes
  def create
    @like = @post.likes.new
    @like.user_id = current_user.id

    if @like.save
      render json: @like, :except => [:user_id], status: :created, location: post_like_url(@post.id, @like.id)
    else
      render json: @like.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:post_id/likes/1
  def destroy
    render json: {}, status: 401 unless @like.user_id == current_user.id
    @like.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_like
      set_post
      @like = @post.likes.find_by(user_id: current_user.id)
      render json: {}, status: 404 if @like.nil?
    end

    def set_post
      @post = Post.find(params[:post_id])
      render json: {}, status: 404 if @post.nil?
    end

    # Only allow a list of trusted parameters through.
    def like_params
      params.fetch(:like, {})
    end
end
