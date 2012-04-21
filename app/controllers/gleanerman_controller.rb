#encoding:utf-8
require 'rss/1.0'         
require 'rss/2.0'         
require 'open-uri'
class GleanermanController < EntitiesController
  def index
    @gmall = Gleanerman.find(:all, :conditions => {})
  end
  
  def new
    @gms = Gmsource.find(:all, :conditions => {})
    @state = true
    respond_to do |format|
      format.html{ render :layout => true }
    end
  end
  
  def edit
    @id = params[:id]
    @gms = Gmsource.find(:all, :conditions => {})
    @gm = Gleanerman.find(params[:id])
    @gmname = @gm.gm_name
    @sourceid = @gm.source_id
    @keyword = @gm.keyword
    @filters = @gm.filters
    @foldername = ""
    @folderid = @gm.folderid
    @fph = @gm.folderid
    if @gm.state == 1 then
      @state = true
    else
      @state = false
    end
    @fph.split(',').each do |g|
      @foldername = @foldername + Folder.find(g).name + ","
    end
    @foldername = @foldername.chop
  end
  
  def create
    Gleanerman.create({
      :gm_name => params[:gmname],
      :source_id => params[:slsource],
      :keyword => params[:keyword],
      :filters => params[:filters],
      :state => params[:state]
    })
    redirect_to :action=>'index'
  end
  
  def update
    Gleanerman.update(params[:id],{
      :gm_name => params[:gmname],
      :source_id => params[:slsource],
      :keyword => params[:keyword],
      :filters => params[:filters],
      :folderid => params[:folder_path_h],
      :state => params[:state]
    })
    redirect_to :action=>'index'
  end
  
  def delete
    @gm = Gleanerman.find(params[:id])
    @gm.destroy
    redirect_to :action=>'index'
  end
  
  def getdata
    gm = Gleanerman.find(params[:id])
    if gm.source_id == 3 then
      @url = gm.keyword.to_s
    else
      @txtkeyword = gm.keyword.to_s
      @url = gm.gleanerman.url.to_s % @txtkeyword
    end
    
    #@abc = @url
    @items = readrss(@url)
  end
  
  def folders
    @folders = Folder.find(:all,:conditions=>" parent_id is null ")
  end
  
  def readrss(strfeed)
    content = ""         
    open(URI.escape(strfeed)) do |s|       
      content = s.read
    end
    rss = RSS::Parser.parse(content, false) # false表示不验证feed的合法性  
    return rss.channel.items # rss.channel.items亦可 
  end
  
end
