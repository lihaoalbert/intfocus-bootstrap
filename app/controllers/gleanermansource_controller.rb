class GleanermansourceController < EntitiesController
  def index
    @gmsources = Gmsource.all
  end
  
  def new
    respond_to do |format|
      format.html{ render :layout => true }
    end
  end
  
  def create
    @gmsource = Gmsource.new(params[:gmsource])
    @gmsource.save
    redirect_to :action=>'index'
  end
  
  def edit
    @gmsourceid = params[:id]
    @gmsource = Gmsource.find(@gmsourceid)
    respond_to do |format|
      format.html{ render :layout => false }
    end
  end
  
  def update
    @gmsource = Gmsource.find(params[:id])
    @gmsource.update_attributes(params[:gmsource])
    redirect_to :action=>'index'
  end
  
  def delete
    @gmsource = Gmsource.find(params[:id])
    @gmsource.destroy
    redirect_to :action=>'index'
  end
  
end
