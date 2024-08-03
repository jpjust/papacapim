class RepliesController < ApplicationController

  before_action :authorize
  before_action :set_post, only: %i[ index create ]

  # GET /posts/:post_id/replies
  def index
    page = params[:page].to_i || 0
    offset = ENV['POSTS_FEED_PAGELIMIT'] * page
    render json: @post.replies.limit(ENV['POSTS_FEED_PAGELIMIT']).offset(offset), :except => [:user_id]
  end

  # POST /posts/:post_id/replies
  def create
    @reply = Post.new(reply_params)
    @reply.post_id = @post.id
    @reply.user_id = current_user.id

    if @reply.save
      render json: @reply, :except => [:user_id], status: :created, location: @reply
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
