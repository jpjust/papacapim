class PostsController < ApplicationController

  before_action :authorize
  before_action :set_post, only: %i[ show update destroy ]

  # GET /posts
  def index
    page = params[:page].to_i || 0
    offset = ENV['POSTS_FEED_PAGELIMIT'].to_i * page
    @posts = Post.order(created_at: :desc)

    if params[:user_id].present?
      @posts = @posts.where(user_id: User.find_by(login: params[:user_id]))
    elsif params[:feed].to_i == 1
      @posts = Post.where(user_id: current_user.following.map(&:followed_id))
    elsif params[:search].present?
      search_query = ''
      first_word = true;
      params[:search].to_s.gsub(/@+/, ' ').strip.split.each do |word|
        search_query += ',' unless first_word
        search_query += word + '*'
      first_word = false
    end
      @posts = @posts.select("posts.*, MATCH(message) AGAINST('#{search_query}' IN BOOLEAN MODE) AS score")
                     .where('MATCH(message) AGAINST(? IN BOOLEAN MODE)', search_query)
    end

    if params[:search].present?
      @posts = @posts.order(score: :desc)
    else
      @posts = @posts.order(created_at: :desc)
    end

    render json: @posts.includes([:user, :likes])
                       .limit(ENV['POSTS_FEED_PAGELIMIT'].to_i)
                       .offset(offset)
                       .each{ |p| p.you_liked = p.likes.where(user_id: @current_user.id).count > 0 },
           only: [:id, :message, :created_at, :post_id, :likes_number, :replies_number, :you_liked],
           include: [
             user: {only: [:login, :name, :profile_image]},
             media: {only: [:medium_type, :medium_url]}
           ]
  end

  # GET /posts/1
  def show
    render json: @post,
           only: [:id, :message, :created_at, :post_id, :likes_number, :replies_number, :you_liked],
           include: [
             user: {only: [:login, :name, :profile_image]},
             media: {only: [:medium_type, :medium_url]}
           ]
  end

  # POST /posts
  def create
    @post = Post.new(post_params)
    @post.user_id = current_user.id

    if @post.save
      # Salva as imagens associadas ao post, se houver
      max_file_size = 50.megabytes
      max_base64_size = ((max_file_size * 4.0) / 3).ceil

      params[:post][:media].each do |media_attr|
        next unless media_attr[:medium_type] == 'image'

        begin
          media = @post.media.build(medium_type: media_attr[:medium_type])
          medium_data = Base64.strict_decode64(media_attr[:medium_data])

          if medium_data.bytesize <= max_base64_size
            tmp_file = File.join(Rails.root, 'tmp', "#{media.uuid}.png")
            File.binwrite(tmp_file, medium_data)
            system('/usr/bin/convert', tmp_file, '-auto-orient', '-resize', '512x512', '-quality', '75', '-define', 'webp:method=6', media.medium_file)
            File.delete(tmp_file) if File.exist?(tmp_file)
            media.save
          else
            raise ArgumentError, "Media data exceeds maximum allowed size of #{max_file_size} bytes."
          end
        rescue ArgumentError => e
          puts e.message
        end
      end

      render json: @post, only: [:id, :message, :created_at, :post_id], status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    render json: {}, status: 401 unless @post.user_id == current_user.id
    @post.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
      render json: {}, status: 404 if @post.nil?
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit([:message, :post_id])
    end
end
