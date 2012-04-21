class FoldersController < EntitiesController
  def index
    @folderid = params[:id]
    @userid = @current_user.id
    if @folderid == nil || @folderid == "" then
      @folders = Folder.find(:all, :conditions => "parent_id is null " )
      @foldersun = Folder.find(:all, :conditions => "parent_id = #{@folders[0].id} " )
      @folderpath = flist(@folders[0].id, "")
      @folderid = @folders[0].id
    else
      @folders = Folder.find(:all, :conditions => "parent_id is null " )
      @foldersun = Folder.find(:all, :conditions => "parent_id = #{@folderid} " )
      @folderpath = flist(params[:id], "")
    end

  end
  
  def createfolder
    @folder = Folder.create({
                :displayname => params[:dn], 
                :name => params[:dn], 
                :user_id => @current_user, 
                :parent_id => params[:id],
                :is_single_document_class => 1,
                :document_class_id => 1,
                :allow_categorize => 1,
                :allow_discussing => 1,
                :auto_categorize => 1,
                :auto_keywords => 1,
                :auto_description => 1,
                :sort_order => 1,
                :folder_state => 1
              })
    FldPrivilege.create({
      :resource_id => @folder.id,
      :data => "admin|#{@current_user}|15"
    })
    DefaultDocPrivilege.create({
      :resource_id => @folder.id,
      :data => "admin|#{@current_user}|31"
    })
    redirect_to :action=>"index/#{params[:id]}"
  end
  
  def flist(id, str)
 
    fid = Folder.find(id)
 
    str = "<a href='/folders/index?id=#{fid.id}'>" + fid.name.to_s + "</a>"
    if fid.parent_id != nil then
      str = "<a href='/folders/index?id=#{fid.id}'>" + flist(fid.parent_id,str) + "</a>" + "\\" + str
    end
    return str
  end
  
  def updatefolder
    @did = params[:doc_id]
    @dcid = params[:drpdcid]
    @isdc_type = params[:isdc_type] 
    @chkeas_type = params[:chkeas_type]
    @chkeke_type = params[:chkeke_type]
    @chkac_type = params[:chkac_type]
    @chkeac_type = params[:chkeac_type]
    @fpdata = params[:fpdata]
    @dpdata = params[:dpdata]
    Folder.update(@did,{
      :is_single_document_class => @isdc_type,
      :document_class_id => @dcid,
      :allow_categorize => @chkac_type,
      :allow_discussing => @chkeac_type,
      :auto_keywords => @chkeke_type,
      :auto_description => @chkeas_type,
    })
    FldPrivilege.update(@did,{
      :data => @fpdata
    })
    DefaultDocPrivilege.update(@did,{
      :data => @dpdata
    })
  end
  
  def editfolder
    @lstas = ""
    @fp = ""
    @dp = ""
    @folderid = params[:id]
    @userid = @current_user.id
    #@docclass = DocumentClass.find(:all, :conditions => "user_id = '#{@userid}'")
    @folder = Folder.find(@folderid)
    fpv = FldPrivilege.find_by_resource_id(@folderid);
    #@abc = fpv
    ddp = DefaultDocPrivilege.find_by_resource_id(@folderid)
    fpv.data.split("^").each do |f|
      @lstas = @lstas + "<option value='#{f.split("|")[1]}'>#{f.split("|")[0]}</option>"
      @fp = @fp + foption(f.split("|")[2],f.split("|")[1])
    end
    
    ddp.data.split("^").each do |f|
      @dp = @dp + doption(f.split("|")[2],f.split("|")[1])
    end
    
    respond_to do |format|
      format.html{ render :layout => true }
    end
    
  end
  
  def userfolder
    @users = User.all
  end
  
  def foption(num,pid)
    fop = ""
    case num.to_i
    when 1
      fop = "<option value='1' parent_id='#{pid}'>1</option>"
    when 2
      fop = "<option value='2' parent_id='#{pid}'>2</option>"
    when 3
      fop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option>"
    when 4
      fop = "<option value='4' parent_id='#{pid}'>4</option>"
    when 5
      fop = "<option value='1' parent_id='#{pid}'>1</option><option value='4' parent_id='#{pid}'>4</option>"
    when 6
      fop = "<option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option>"
    when 7
      fop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option>"
    when 8
      fop = "<option value='8' parent_id='#{pid}'>8</option>"
    when 9
      fop = "<option value='1' parent_id='#{pid}'>1</option><option value='8' parent_id='#{pid}'>8</option>"
    when 10
      fop = "<option value='2' parent_id='#{pid}'>2</option><option value='8' parent_id='#{pid}'>8</option>"
    when 11
      fop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='8' parent_id='#{pid}'>8</option>"
    when 12
      fop = "<option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"
    when 13
      fop = "<option value='1' parent_id='#{pid}'>1</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"
    when 14
      fop = "<option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"      
    when 15
      fop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"
    end
    return fop
  end
  
  def doption(num,pid)
    dop = ""
    case num.to_i
    when 1
      dop = "<option value='1' parent_id='#{pid}'>1</option>"
    when 2
      dop = "<option value='2' parent_id='#{pid}'>2</option>"
    when 3
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option>"
    when 4
      dop = "<option value='4' parent_id='#{pid}'>4</option>"
    when 5
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='4' parent_id='#{pid}'>4</option>"
    when 6
      dop = "<option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option>"
    when 7
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option>"
    when 8
      dop = "<option value='8' parent_id='#{pid}'>8</option>"
    when 9
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='8' parent_id='#{pid}'>8</option>"
    when 10
      dop = "<option value='2' parent_id='#{pid}'>2</option><option value='8' parent_id='#{pid}'>8</option>"
    when 11
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='8' parent_id='#{pid}'>8</option>"
    when 12
      dop = "<option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"
    when 13
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"
    when 14
      dop = "<option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"      
    when 15
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option>"
    when 16
      dop = "<option value='16' parent_id='#{pid}'>16</option>"
    when 17
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='16' parent_id='#{pid}'>16</option>"
    when 18
      dop = "<option value='2' parent_id='#{pid}'>2</option><option value='16' parent_id='#{pid}'>16</option>"
    when 19
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='16' parent_id='#{pid}'>16</option>"
    when 20
      dop = "<option value='4' parent_id='#{pid}'>4</option><option value='16' parent_id='#{pid}'>16</option>"
    when 21
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='4' parent_id='#{pid}'>4</option><option value='16' parent_id='#{pid}'>16</option>"
    when 22
      dop = "<option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='16' parent_id='#{pid}'>16</option>"
    when 23
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='16' parent_id='#{pid}'>16</option>"
    when 24
      dop = "<option value='8' parent_id='#{pid}'>8</option><option value='2' parent_id='#{pid}'>2</option><option value='16' parent_id='#{pid}'>16</option>"
    when 25
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='8' parent_id='#{pid}'>8</option><option value='2' parent_id='#{pid}'>2</option><option value='16' parent_id='#{pid}'>16</option>"
    when 26
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='8' parent_id='#{pid}'>8</option>"
    when 27
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='8' parent_id='#{pid}'>8</option><option value='16' parent_id='#{pid}'>16</option>"
    when 28
      dop = "<option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option><option value='16' parent_id='#{pid}'>16</option>"
    when 29
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option><option value='16' parent_id='#{pid}'>16</option>"      
    when 30
      dop = "<option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option><option value='16' parent_id='#{pid}'>16</option>"
    when 31
      dop = "<option value='1' parent_id='#{pid}'>1</option><option value='2' parent_id='#{pid}'>2</option><option value='4' parent_id='#{pid}'>4</option><option value='8' parent_id='#{pid}'>8</option><option value='16' parent_id='#{pid}'>16</option>"
    end
      
    return dop
  end
end
