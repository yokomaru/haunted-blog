# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show
    @blog = Blog.find(params[:id])
    return unless @blog.secret? && !@blog.owned_by?(current_user)

    raise ActiveRecord::RecordNotFound
  end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)
    @blog.random_eyecatch = filter_random_eyecatch(blog_params[:random_eyecatch])
    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    new_blog_params = blog_params.deep_dup
    new_blog_params[:random_eyecatch] = filter_random_eyecatch(blog_params[:random_eyecatch])
    if @blog.update(new_blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = current_user.blogs.find(params[:id])
  end

  def blog_params
    params.require(:blog).permit(:title, :content, :secret, :random_eyecatch)
  end

  def filter_random_eyecatch(random_eyecatch)
    current_user.premium ? random_eyecatch : '0'
  end
end
