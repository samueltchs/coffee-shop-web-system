require 'uri'

module UrlHelpers
  
  #view product details
  def mngr_product_details_url(product, params)
    link = {
      id: product[:product_id],
      sort: params[:sort],
      order: params[:order],
      lastsort: params[:lastsort],
      column_to_search: params[:column_to_search],
      search_input: params[:search_input]
    }
    link.compact!
    "/manager/products/details?" + URI.encode_www_form(link)
  end

  #cancel button from product details
  def mngr_products_back_url(params, type = nil, id = nil)
    link = {
      sort: params[:sort],
      order: params[:order],
      lastsort: params[:lastsort],
      column_to_search: params[:column_to_search],
      search_input: params[:search_input]
    }
    
    case id
    when nil
      direct_to = "/manager/products/#{type}?"
    else
      direct_to = "/manager/products/details?"
      link[:id] = id
    end

    link.compact!
    direct_to + URI.encode_www_form(link)
  end

  def mngr_add_products_url(params, type, current_page)
    link = {
      type: type,
      lastpage: current_page,
      sort: params[:sort],
      order: params[:order],
      lastsort: params[:lastsort],
      column_to_search: params[:column_to_search],
      search_input: params[:search_input]
    }
    link.compact!
    "/manager/products/add-#{type}?" + URI.encode_www_form(link)
  end

  def mngr_update_products_url(id, type, params)
    link = {
      id: id,
      sort: params[:sort],
      order: params[:order],
      lastsort: params[:lastsort],
      column_to_search: params[:column_to_search],
      search_input: params[:search_input]
    }
    link.compact!
    "/manager/products/update-#{type}?" + URI.encode_www_form(link)
  end

  #view details of customer
  def mngr_cdetails_url(customer, params)
    link = {
      loyal_num: customer.loyalty_number,
      sort: params[:sort],
      order: params[:order],
      from: params[:from],
      to: params[:to],
      select_filter: params[:select_filter]
    }
    link.compact!
    "/manager/customers/details?" + URI.encode_www_form(link)
  end

  #back button in customer details
  def mngr_customer_url(params)
    link = {
      sort: params[:sort],
      order: params[:order],
      from: params[:from],
      to: params[:to],
      select_filter: params[:select_filter]
    }
    link.compact!
    "/manager/customers?" + URI.encode_www_form(link)
  end

end