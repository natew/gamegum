class PagesController < ApplicationController

  def show
    @page = Page.find_by_slug(params[:slug])
    @page.update_attribute(:views, @page.views.next)
  end

end
