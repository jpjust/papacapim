class RepliesController < ApplicationController

  before_action :authorize
  before_action :set_post, only: %i[ index create ]

  # GET /posts/:post_id/replies
  def index
    page = params[:page].to_i || 0
    offset = ENV['POSTS_FEED_PAGELIMIT'] * page
    render json: @post.replies
                      .order(created_at: :asc)
                      .includes([:user])
                      .limit(ENV['POSTS_FEED_PAGELIMIT'].to_i)
                      .offset(offset)
                      .each{ |p| p.you_liked = p.likes.where(user_id: @current_user.id).count > 0 },
           only: [:id, :message, :created_at, :post_id, :likes_number, :replies_number, :you_liked],
           include: [
             user: {only: [:login, :name, :profile_image]}
           ]
  end

  # POST /posts/:post_id/replies
  def create
    @reply = Post.new(reply_params)
    @reply.post_id = @post.id
    @reply.user_id = current_user.id

    if @reply.save
      render json: @reply, only: [:user_login, :message, :created_at, :post_id], status: :created, location: @reply
    else
      render json: @reply.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find_by(id: params[:post_id])
      render json: {}, status: 404 if @post.nil?
    end

    # Only allow a list of trusted parameters through.
    def reply_params
      params.require(:reply).permit([:message])
    end

end
