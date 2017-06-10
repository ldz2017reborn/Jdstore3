class ProductsController < ApplicationController
  before_action :validate_search_key, only: [:search]

  def index
     if params[:category].blank?
       @products = case params[:order]
       when 'by_product_price'
             Product.order('price DESC')
       when 'by_product_quantity'
             Product.order('quantity DESC')
       when 'by_product_like'
             Product.order('like DESC')
           else
             Product.order('created_at DESC')
           end
     else
       @category_id = Category.find_by(name: params[:category]).id
       @products = Product.where(:category_id => @category_id)
     end
   end

   def show
      @product = Product.find(params[:id])
      @reviews = @product.reviews
      @photos = @product.photos.all
      if @reviews.blank?
          @avg_review = 0
          @avg_look = 0
          @avg_price = 0
        else
          @avg_review = @reviews.average(:freshness).round(2)
          @avg_look = @reviews.average(:look).round(2)
          @avg_price = @reviews.average(:price).round(2)
        end
    end

 def add_to_cart
   @product = Product.find(params[:id])

      if !current_cart.products.include?(@product)
        current_cart.add_product_to_cart(@product)
        flash[:notice] = "你已成功将 #{@product.title} 加入购物车"
    else
      flash[:warning] = "你的购物车内已有此物品"
    end
   redirect_to :back
 end


 def search
    if @query_string.present?
      search_result = Product.ransack(@search_criteria).result(:distinct => true)
      @products = search_result.paginate(:page => params[:page], :per_page => 5 )
    end
  end

  protected

  def validate_search_key
    @query_string = params[:q].gsub(/\\|\'|\/|\?/, "") if params[:q].present?
    @search_criteria = search_criteria(@query_string)
  end

  def search_criteria(query_string)
    { :title_cont => query_string }
  end
end
